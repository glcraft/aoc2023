use std

const DIRS = [N E S W]

let lines = (open day10_input.txt | lines)
let map = ($lines | split chars)
let origin = ($lines 
    | enumerate 
    | each {|it|
        let res = ($it.item | str index-of S)
        if $res >= 0 {
            {x:$res y:$it.index}
        } else {
            null
        }
    }
    | where $it != null
    | get 0
)

def get-pipe []: record<x:int y:int> -> string {
    let cursor = $in
    $map | get $cursor.y | get $cursor.x
}

def turn-cw [dir:int]: int -> int {
    let pos = $in
    mut dir = $pos + $dir
    while $dir < 0 {
        $dir += 4
    }
    $dir mod 4
}

def next-direction [pipe:string]: int -> int {
    let dir = $in
    match [$pipe $dir] {
        ['|' $d] | ['-' $d] => $d
        ['L' 2] | ['F' 3] | ['7' 0] | ['J' 1] => ($dir | turn-cw -1)
        ['L' 3] | ['F' 0] | ['7' 1] | ['J' 2] => ($dir | turn-cw 1)
        _ => ""
    }
}
def move-cursor [dir:int]: record<x:int y:int> -> record<x:int y:int> {
    # N E S W
    # 0 1 2 3
    mut cursor = $in
    match $dir {
        0 => { $cursor.y -= 1 }
        2 => { $cursor.y += 1 }
        3 => { $cursor.x -= 1 }
        1 => { $cursor.x += 1 }
    }
    $cursor
}

def find-first-direction []: record<x:int y:int> -> int {
    let cursor = $in
    for dir in [0 1 2 3] {
        if not ($dir | next-direction ($cursor | move-cursor $dir | get-pipe) | is-empty) {
            return $dir
        }
    }
    error make {msg: unreachable}
    1
}

mut direction = ($origin | find-first-direction)
mut cursor = ($origin | move-cursor $direction)
mut steps = 1

while $cursor != $origin {
    let pipe = ($cursor | get-pipe)
    $direction = ($direction | next-direction $pipe)
    $cursor = ($cursor | move-cursor $direction)
    $steps += 1
}
$steps / 2