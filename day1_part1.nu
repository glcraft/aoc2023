open "day1_input.txt" 
    | lines
    | par-each {|line|
        $line 
            | split chars
            | where {|i| $in =~ \d}
    }
    | each {|input| $"($input|first)($input|last)" | into int}
    | math sum