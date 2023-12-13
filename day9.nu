
def f [] {
    let input = $in
    let result = ($input
        | window 2
        | each {|l| $l.1 - $l.0}
    )
    if ($result | all {|i| $i == 0}) {
        ($input | last)
    } else {
        let r = ($result | f)
        return (($input | last) + $r)
    }
}

open day9_input.txt
    | lines
    # | take 10
    | each {|line| 
        $line
            | split row -r \s+ 
            | into int
            | f
    }
    | math sum