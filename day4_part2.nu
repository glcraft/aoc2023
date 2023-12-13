let cards = (open day4_input.txt
    | lines
    | parse -r 'Card\s+(?<id>\d+):\s*(?<win>[\d ]+)\s+\|\s+(?<have>[\d ]+)\s*$'
    | each {|card|
        let win = ($card.win | split row -r \s+ | into int)
        let have = ($card.have | split row -r \s+ | into int)
        ($have | where $it in $win | length) 
    }
)
mut total = 0
mut counter = []

for pts in $cards {
    let nbcards = 1 + (($counter | get coef) ++ [0] | math sum)
    if $pts > 0 {
        let win = $pts * $nbcards
        $total += $win
        $counter ++= [{count: ($pts + 1) coef: $nbcards}]
    }
    $counter = ($counter | each {|it| {count: ($it.count - 1) coef: $it.coef}} | where count > 0)
}
$total + ($cards | length)