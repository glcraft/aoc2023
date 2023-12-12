#!/usr/bin/env nu
let file = (open day8_input.txt | lines)

let dirs = ($file
    | first
    | split chars
    | each {|i| if $i == "L" {0} else {1} }
)
let dirs_len = ($dirs | length)
let maps = $file 
    | skip 2 
    | parse "{location} = ({left}, {right})"
    | reduce -f {} {|it acc| $acc | merge {$it.location: [$it.left $it.right]} }

mut current_node = "AAA"
mut steps = 0

while $current_node != "ZZZ" {
    $current_node = ($maps | get $current_node | get ($dirs | get ($steps mod $dirs_len)))
    $steps += 1
}
$steps