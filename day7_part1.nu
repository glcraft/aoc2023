const cards_order = "23456789TJQKA"
const total_cards = ($cards_order | str length)

def note-cards []: record<cards:string bid:string> -> any {
    let input = $in
    let cards = ($input 
        | get cards 
        | split chars
        | each {|c| {card:$c pos: ($cards_order | str index-of $c)} }
    )
    ($cards | reduce -f 0 {|it acc| $acc * $total_cards + $it.pos})
}

def card-to-data []: record<cards:string bid:string> -> any {
    let input = $in
    
    let count = ($input 
        | get cards 
        | split chars 
        | reduce --fold {} {|it acc| 
            $acc | merge {$it: (($acc | get -i $it | default 0) + 1)} 
        }
        | sort -v -r
    )
    let set_score = (match ($count | values) {
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
        set_score: $set_score
        per_card_score: $per_card_score
    }
}

let data = (open day7_input.txt 
    | lines 
    | parse "{cards} {bid}"
    | par-each { $in | card-to-data }
)

let per_category = ((1..7) | each {|i|
    $data
        | where set_score == $i
        | sort-by per_card_score
        | get origin.bid
        | into int
})

$per_category
    | flatten
    | enumerate
    | each {|i| ($i.index + 1) * $i.item }
    | math sum