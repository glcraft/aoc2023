#!/usr/bin/env nu

# https://www.dcode.fr/pgcd
def pgcd [] {
    let input = $in
    mut A = ($input | math max)
    mut B = ($input | math min)
    mut R = ($A mod $B)
    while $R > 0 {
        $A = $B
        $B = $R
        $R = ($A mod $B)
    }
    return $B
}
# https://www.dcode.fr/ppcm
def ppcm [] {
    let input = $in
    match ($input | length) {
        1 => $input.0
        2 => ($input.0 * $input.1 / ($input | pgcd))
        $size => {
            let half = ($size // 2)
            [($input | take $half | ppcm) ($input | skip $half | ppcm)] | ppcm
        }
    }
}


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

use ./bench.nu *

let compute = {|current_nodes|
    $current_nodes
        | par-each {|node|
            mut current_node = $node
            mut steps = 0
            while $current_node !~ "Z$" {
                $current_node = ($maps | get $current_node | get ($dirs | get ($steps mod $dirs_len)))
                $steps += 1
            }
            $steps
        }
        | ppcm
}

bench {
    do $compute ["AAA"]
} {
    do $compute ($maps | columns | where {|i| $i =~ "A$"})
}