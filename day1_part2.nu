const table_convert = {
    zero: 0
    one: 1
    two: 2
    three: 3
    four: 4
    five: 5
    six: 6
    seven: 7
    eight: 8
    nine: 9
}
let digits_str = ($table_convert | columns | append ($table_convert | values | into string))
def str2int [] string->int {
    let input = $in
    try { return ($input | into int) } 
    $table_convert | get $input
}
open "day1_input.txt" 
    | lines
    | par-each {|line|
        $digits_str
            | each {|digit_str|
                {
                    index_begin: ($line | str index-of $digit_str) 
                    index_end: ($line | str index-of -e $digit_str) 
                    digit: ($digit_str | str2int)
                }
            }
            | where index_begin != -1
    }
    | par-each {|input| 
        let left = ($input | sort-by index_begin | first | get digit)
        let right = ($input | sort-by index_end | last | get digit)
        $"($left)($right)" | into int
    }
    | math sum