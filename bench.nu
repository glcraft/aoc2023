
def multishot [
    nb:int
    fns:list<closure>
] {
    let result = ($fns 
        | enumerate
        | each {|fn|
            mut result = ""
            mut time_min = 1hr
            mut time_max = 0sec
            mut time_total = 0sec
            print $"Bench n°($fn.index + 1)..."
            for _ in 1..($nb) {
                let time = timeit { $result = (do $fn.item) }
                $time_min = ([$time_min $time] | math min )
                $time_max = ([$time_max $time] | math max )
                $time_total += $time
            }
            { 
                Part: ($fn.index + 1)
                Result: $result
                Time: {
                    Mean: ($time_total / $nb)
                    Min: $time_min
                    Max: $time_max
                    Total: $time_total
                }
            }
        })
    $result ++ [{ 
        Part: "All"
        Time: ($result | get Time.Total | math sum)
    }]
}

def one-shot [
    fns:list<closure>
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

export def main [
    --repeat:int = 1 # Number of time to repeat the bench
    ...fns:closure
] {
    if $repeat <= 0 {
        error make {msg: "number of repeat <= 0"}
    }
    if $repeat == 1 {
        one-shot $fns
    } else {
        multishot $repeat $fns
    }
}