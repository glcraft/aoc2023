def find-roots []: record<Time: int Distance: int> -> list<int> {
    let input = $in
    let delta = ($input.Time * $input.Time) - (4 * $input.Distance)
    if $delta > 0 {
        [
            ((0 - $input.Time - ($delta | math sqrt)) / (2 * -1))
            ((0 - $input.Time + ($delta | math sqrt)) / (2 * -1))
        ]
    } else if $delta == 0 {
        [((0 - $input.Time) / (2 * -1))]
    } else {
        []
    }
    
}

let file = (open day6_input.txt 
    | lines 
    | each { $in | split row -r '\s+'}
)
let races = ($file.0 
    | zip $file.1 
    | skip 1 
    | each {|inp| 
        {
            ($file.0.0 | parse "{name}:" | get 0.name): $inp.0
            ($file.1.0 | parse "{name}:" | get 0.name): $inp.1
        } 
    }
)

use ./bench.nu *

bench {
    $races 
        | par-each {|i| {Time: ($i.Time | into int) Distance: ($i.Distance | into int)} | find-roots | into int }
        | each {|race| $race.0 - $race.1 }
        | math product
} {
    let result = ({
        Time: ($races.Time | str join | into int)
        Distance: ($races.Distance | str join | into int)
    } | find-roots | into int)
    $result.0 - $result.1 
}