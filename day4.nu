open day4_input.txt
    | lines
    | parse -r 'Card\s+(?<id>\d+):\s*(?<win>[\d ]+)\s+\|\s+(?<have>[\d ]+)\s*$'
    | each {|card|
        {
            id: $card.id
            win: ($card.win | split row -r \s+ | into int)
            have: ($card.have | split row -r \s+ | into int)
        }
    }
    | each {|card|
        match ($card.have | where {|numb| $numb in $card.win } | length) {
            0 => 0
            $d => (2 ** ($d - 1))
        }
    }
    | math sum