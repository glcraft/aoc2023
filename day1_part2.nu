let digits_str = [one two three four five six seven eight nine "1" "2" "3" "4" "5" "6" "7" "8" "9"]

open "day1_input.txt" 
    | lines
    | par-each {|line|
        $digits_str
            | enumerate
            | each {|digit_str|
                match ($line | str index-of $digit_str.item) {
                    -1 => null
                    $index => ({
                        index_begin: $index
                        index_end: ($line | str index-of -e $digit_str.item) 
                        digit: ($digit_str.index mod 9 + 1)
                    })
                }
                
            }
            | where $in != null
    }
    | par-each {|input| 
        let left = ($input | sort-by index_begin | first | get digit)
        let right = ($input | sort-by index_end | last | get digit)
        $"($left)($right)" | into int
    }
    | math sum