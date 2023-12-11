export def main [
    ...fns:closure
] {
    let result = ($fns 
        | enumerate
        | each {|fn|
            mut result = ""
            let time = timeit { $result = (do $fn.item) }
            { 
                Part: ($fn.index + 1)
                Result: $result
                Time: $time
            }
        })
    $result ++ [{ 
        Part: "All"
        Time: ($result | get Time | math sum)
    }]
}