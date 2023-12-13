
def f [] {
    let input = $in
    let result = ($input
        | window 2
        | each {|l| $l.1 - $l.0}
    )
    if ($result | all {|i| $i == 0}) {
        {prev:($input | first) after:($input | last)}
    } else {
        let r = ($result | f)
        return {prev:(($input | first) - $r.prev) after:(($input | last) + $r.after)}
    }
}

let data = (open day9_input.txt | lines)

use bench.nu *

bench {
    let data = ($data
        | par-each {|line| 
            $line
                | split row -r \s+ 
                | into int
                | f
        }
    )
    [($data | get prev | math sum) ($data | get after | math sum)]
}

