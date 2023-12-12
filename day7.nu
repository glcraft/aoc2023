use std

const cards_order = ["23456789TJQKA" "J23456789TQKA"]
const total_cards = ($cards_order.0 | str length)

def note-cards [
    --part(-p):int 
]: record<cards:string bid:string> -> any {
    let input = $in
    let cards = ($input 
        | get cards 
        | split chars
        | each {|c| {card:$c pos: ($cards_order | get ($part - 1) | str index-of $c)} }
    )
    ($cards | reduce -f 0 {|it acc| $acc * $total_cards + $it.pos})
}

def card-to-data [
    --part(-p):int 
]: record<cards:string bid:string> -> any {
    let input = $in
    
    mut count = ($input 
        | get cards 
        | split chars 
        | reduce --fold {} {|it acc| 
            $acc | merge {$it: (($acc | get -i $it | default 0) + 1)} 
        }
        | sort -v -r
    )
    if $part == 2 and "J" in ($count | columns) and $count.J != 5 {
        let nbJ = $count.J
        let win = ($count | columns | std iter find {|i| $i != "J"})
        $count = ($count 
            | reject J 
            | merge {$win: (($count | get $win) + $nbJ)} 
            | sort -v -r
        ) 
    }
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
    let per_card_score = ($input | note-cards -p $part)
    {
        bid: ($input.bid | into int)
        set_score: $set_score
        per_card_score: $per_card_score
    }
}

let data = (open day7_input.txt 
    | lines 
    | parse "{cards} {bid}"
)

use ./bench.nu *

bench {
    let data = ($data | par-each { $in | card-to-data -p 1})
    (1..7) 
        | each {|i|
            $data
                | where set_score == $i
                | sort-by per_card_score
                | get bid
                | into int
        }
        | flatten
        | enumerate
        | each {|i| ($i.index + 1) * $i.item }
        | math sum
} {
    let data = ($data | par-each { $in | card-to-data -p 2})
    (1..7) 
        | each {|i|
            $data
                | where set_score == $i
                | sort-by per_card_score
                | get bid
                | into int
        }
        | flatten
        | enumerate
        | each {|i| ($i.index + 1) * $i.item }
        | math sum
}