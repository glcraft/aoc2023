let lines = open "day3_input.txt" | lines

def look_around [
    pos: record<x: int y:int>
] {

}

def get_gears [] {
    $lines
        | enumerate
        | each {|line|
            mut offset = 0
            mut result = []
            loop {
                $offset = ($line.item | str index-of -r $offset.. "*")
                if $offset == -1 {
                    return $result
                }
                $result ++= [{x:$offset y:$line.index}]
                $offset += 1
            }
        }
        | flatten
}

def get_numbers [] {
    $lines
        | enumerate
        | each {|line|
            let numbers = ($line.item | parse -r '(\d+)' | get capture0)
            mut offset = 0
            mut result = []
            for number in $numbers {
                $offset = ($line.item | str index-of -r $offset.. $number)
                if $offset == -1 {
                    make error make {msg: "should not happen" }
                }
                $result ++= [{number: $number x:$offset y:$line.index}]
                $offset += 1
            }
            $result
        }
}

def quadtree [] {

}

get_numbers | flatten | length