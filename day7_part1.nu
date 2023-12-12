const cards_order = "23456789TJQKA"
const total_cards = ($cards_order | str length)

def note-cards []: record<cards:string bid:string> -> any {
    let input = $in
    let cards = ($input 
        | get cards 
        | split chars
        | each {|c| {card:$c pos: ($cards_order | str index-of $c)} }
        # | sort-by -r pos
    )
    {
        sorted: ($cards | get card | str join)
        score: ($cards | reduce -f 0 {|it acc| $acc * $total_cards + $it.pos})
    }
}

def card-to-data []: record<cards:string bid:string> -> any {
    let input = $in
    
    let count = ($input 
        | get cards 
        | split chars 
        | reduce --fold {} {|it acc| 
            $acc | merge {$it: (($acc | get -i $it | default 0) + 1)} 
        }
    )
    let count_order = ($count | values | sort -r)
    let set_score = (match $count_order {
        [5] => 7
        [4 ..] => 6
        [3 2] => 5
        [3 ..] => 4
        [2 2 ..] => 3
        [2 ..] => 2
        [1 ..] => 1
        $d => { error make {msg: $"unreachable \(data:($d)\)"} }
    })
    let per_card_score = ($input | note-cards)
    {
        origin: $input
        sorted: $per_card_score.sorted
        set_score: $set_score
        per_card_score: $per_card_score.score
    }
}

let data = (open day7_input.txt 
    | lines 
    # | take 50
    | parse "{cards} {bid}"
    | par-each { $in | card-to-data }
)

let per_category = ((7..1) | each {|i|
    $data
        | where set_score == $i
        | sort-by -r per_card_score
})

$per_category
    | flatten
    | reverse
    | enumerate
    | each {|i|
        let rank = ($i.index + 1)
        let bid = ($i.item.origin.bid | into int)
        $rank * $bid
        # {rank: ($i.index + 1) bid: ($i.item.origin.bid) input: $i.item.sorted}
    }
    | math sum