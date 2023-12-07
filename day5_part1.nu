
def make-step [
    transformers: list<record<start:int end:int destination:int>>
] record<start:int end:int> -> list<record<start:int end:int>> {
    
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

open "day5_input.txt" | lines | parse-file