module urange {
    export def transform [
        other: record<start:int end:int destination:int>
    ] record<start:int end:int> -> record<start:int end:int> {
        let input = $in
        let offset = ($other.destination - $other.start)
        {
            start: ($input.start + $offset)
            end: ($input.end + $offset)
        }
    }
    export def union [
        other: record<start:int end:int>
    ] record<start:int end:int> -> record<start:int end:int> {
        let input = $in
        let result = {
            start: ([$input.start $other.start] | math max)
            end: ([$input.end $other.end] | math min)
        }
        if ($result.start > $result.end) {
            error make {msg: "(intersect) bad range: start greater than end", result: $result}
        }
        $result
    }
    export def is-intersect [
        other: record<start:int end:int>
    ] record<start:int end:int> -> bool {
        let input = $in
        if ($input.start >= $input.end) or ($other.start >= $other.end) {
            error make {msg: "(is-intersect) bad range: start greater than end", input: $input, other: $other}
        }
        $input.start < $other.end and $input.end > $other.start
    }
    def make_result [inputs transformed] {
            {
                inputs: $inputs
                transformed: $transformed
            }
        }
    export def cut [
        other: record<start:int end:int destination:int>
    ] record<start:int end:int> -> list<record<start:int end:int>> {
        
        let input = $in
        
        match [($input.start < $other.start) ($input.end <= $other.start) ($input.start < $other.end) ($input.end <= $other.end) ] {
            [true false true true] => (make_result [{start: $input.start end: $other.start}] [({start: $other.start end: $input.end} | transform $other)])
            [false false true true] => (make_result [] [({start: $input.start end: $input.end} | transform $other)])
            [false false true false] => (make_result [{start: $other.end end: $input.end}] [({start: $input.start end: $other.end} | transform $other)])
            [true false true false] => (make_result [{start: $input.start end: $other.start} {start: $other.end end: $input.end}] [({start: $other.start end: $other.end} | transform $other)])
            [true true true true] | [false false false false] => (make_result [$input] [])
            _ => (error make {msg: "bad range: start greater than end", input: $input, other: $other })
        }
    }
}

use urange

def make-step [
    transformers: list<record<start:int end:int destination:int>>
] list<record<start:int end:int>> -> list<record<start:int end:int>> {
    mut inputs = $in
    mut output = []
    
    # $transformers
    #     | reduce -f {inputs: $input output: []} {|acc it|
    #         let res = ($it | urange cut $it)

    #     }

    for transformer in $transformers {
        if ($inputs | length) == 0 {
            break
        }
        
        let collides = ($inputs | where {$in | urange is-intersect $transformer})
        if ($collides | length) == 0 {
            continue
        }
        for input in $collides {
            let res = ($input | urange cut $transformer)
            $output ++= $res.transformed
            $inputs = ($inputs | where {not ($in | urange is-intersect $transformer)}) ++ $res.inputs
        }
        
    }
    $output ++ $inputs
}

def make-steps [
    maps: list
] record<start:int end:int> -> list<record<start:int end:int>> {
    let input = $in
    mut $result = [$input]
    # print "seed" $input
    mut from = "seed"
    loop {
        let step = ($maps | where from == $from | get -i 0)
        if $step == null {
            return $result
        }
        # print $"step ($step.from):($step.to)"
        $result = ($result | make-step $step.transformers)
        # print "$result" $result
        $from = $step.to
    }
}

def parse-file [] list<string> -> record {
    let lines = $in
    mut result = {
        maps: []
        seeds: []
    }
    mut current_map: any = null
    for line in $lines {
        if $line =~ "^seeds:" {
            $result.seeds = ($line
                | split row " "
                | skip 1
                | each { $in | into int }
            )
        } else if ($line =~ '^\w+-to-\w+') {
            if $current_map != null {
                $result.maps ++= [$current_map]
            }
            let captures = ($line | parse "{from}-to-{to} map:" | get 0)
            $current_map = {
                from: $captures.from
                to: $captures.to
                transformers: []
            }
        } else if ($line =~ '^\d+ \d+ \d+') { 
            let captures = ($line | parse -r '^(\d+) (\d+) (\d+)' | get 0)
            let start = ($captures.capture1 | into int)
            $current_map.transformers ++= [{
                destination: ($captures.capture0 | into int)
                start: $start
                end: (($captures.capture2 | into int) + $start)
            }]
        }
    }
    $result.maps ++= [$current_map]
    $result
}

# open "day5_input.txt" | lines | parse-file

let data = (open "day5_input.txt" | lines | parse-file)

let parts = [
    ($data.seeds | each {|seed| {start: $seed end: ($seed + 1)} })
    ($data.seeds | window 2 --stride 2 | each {|seed| {start: $seed.0 end: ($seed.1 + $seed.0)} })
]

let all_time = (timeit {
    $parts | enumerate | each {|part|
        mut result = 0
        let time = (timeit {
            $result = ($part.item | each {|seed_range| 
                $seed_range 
                    | make-steps $data.maps
                    | get start
                    | math min
                }
                | math min
            )
        })
        print $"Part ($part.index + 1): result: ($result), time: ($time)"
    }
})
print $"All parts: ($all_time)" 