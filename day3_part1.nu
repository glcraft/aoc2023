let lines = open "day3_input.txt" | lines

def watch_symbol_range [
    line: string
    range: range
] {
    ($line | str substring $range) =~ '[^\d.]'
}
def watch_symbol_list [
    line: string
    range: list
] {
    for posx in $range {
        if $posx < 0 or $posx >= ($line | str length) {
            continue
        }
        let char = $line | split chars | get $posx
        if $char =~ '[^\d.]' {
            return true
        }
    }
    return false
}
def watch_symbol_x [
    line: string
    range: any
] {
    match ($range | describe) {
        "range" => (watch_symbol_range $line $range)
        "list<int>" => (watch_symbol_list $line $range)
        $desc => (error make {msg: $"invalid type of range: ($desc)"})
    }
}
def watch_symbol_xy [
    pos: record<x: int, y: int>
    length: int
] {
    for offset_y in [-1 1] {
        let posy = $pos.y + $offset_y
        if $posy < 0 or $posy >= ($lines|length) {
            continue
        }
        let line = $lines | get $posy
        if (watch_symbol_range $line ([($pos.x - 1) 0] | math max)..([($pos.x + $length + 1) ($line | str length)] | math min)) {
            return true
        }
    }
    watch_symbol_list ($lines | get $pos.y) [($pos.x - 1) ($pos.x + $length)]
}

def find_element [
    fn: closure
] any->any {
    let input = $in
    for item in $input {
        if (do $fn $item) {
            return $item
        }
    }
    null
}

def find_number [
    pos: record<x: int, y: int>
] {
    let line = $lines | get $pos.y
    let it = $line 
        | split chars
        | enumerate
        | skip $pos.x

    let begin = $it | find_element {|c| $c.item =~ \d }
    if $begin == null {
        return null
    }
    let end = $it 
        | skip ($begin.index - $pos.x) 
        | find_element {|c| $c.item =~ '[^\d]' }
        | default {index:($line | str length)}
        | get index
    {
        begin: $begin.index
        end: $end
    }
}

$lines 
    | enumerate
    | par-each {|line|
        mut offset = 0
        mut result = 0
        loop {
            let found = ($line.item | find_number {x:$offset y:$line.index})
            if $found == null {
                return $result
            }
            if (watch_symbol_xy {x:$found.begin y:$line.index} ($found.end - $found.begin)) {
                $result += ($line 
                    | get item 
                    | str substring $found.begin..($found.end)
                    | into int
                )
            }
            $offset = $found.end
        }
    }
    | math sum