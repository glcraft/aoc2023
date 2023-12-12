use std

const cards_order = ["23456789TJQKA" "J23456789TQKA"]
const total_cards = ($cards_order.0 | str length)
const total_score = ($total_cards ** 5)

def score-cards [
    --part(-p):int 
]: list<string> -> int {
    let input = $in
    let part = ($part - 1)
    ($input | reduce -f 0 {|c acc| $acc * $total_cards + ($cards_order | get $part | str index-of $c)})
}

def score-kind [
    --part(-p):int 
]: list<string> -> int {
    let input = $in
    
    mut count = ($input 
        | reduce --fold {} {|it acc| 
            $acc | merge {$it: (($acc | get -i $it | default 0) + 1)} 
        }
    )
    if $part == 2 {
        let nbJ = ($count | get -i J | default 0)
        if $nbJ in 1..4 {
            let win = ($count | sort -v -r | columns | where {$in != 'J'}  | first)
            $count = ($count 
                | reject J 
                | merge {$win: (($count | get $win) + $nbJ)} 
            ) 
        }
    }
    ($count | values | reduce -f 0 {|it acc| $acc + ($it ** 2) })
}

def card-to-data [
    --part(-p):int 
]: record<cards:string bid:string> -> any {
    let input = $in
    let input_cards = ($input
        | get cards 
        | split chars 
    )
    let set_score = ($input_cards | score-kind -p $part)
    let per_card_score = ($input_cards | score-cards -p $part)
    {
        bid: ($input.bid | into int)
        score : ($set_score * $total_score + $per_card_score)
    }
}

let data = (open day7_input.txt 
    | lines 
    | parse "{cards} {bid}"
)

use ./bench.nu *

let compute = {|p| $data 
    | par-each { $in | card-to-data -p $p }
    | sort-by score
    | enumerate
    | reduce -f 0 {|i acc| $acc + ($i.index + 1) * $i.item.bid }
}

bench --repeat 10 {
    do $compute 1
} {
    do $compute 2
}