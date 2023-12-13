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

def turn-cw [dir:int]: string -> string {
    let input = $in
    mut dir = $dir
    while $dir < 0 {
        $dir += 4
    }
    let pos = ($DIRS | std iter find-index {|it| $it == $input})
    $DIRS | get (($pos + $dir) mod 4)
}

def next-direction [pipe:string]: string -> string {
    let dir = $in
    match [$pipe $dir] {
        ['|' $d] | ['-' $d] => $d
        ['L' 'S'] | ['F' 'W'] | ['7' 'N'] | ['J' 'E'] => ($dir | turn-cw -1)
        ['L' 'W'] | ['F' 'N'] | ['7' 'E'] | ['J' 'S'] => ($dir | turn-cw 1)
        _ => ""
    }
}
def move-cursor [dir:string]: record<x:int y:int> -> record<x:int y:int> {
    mut cursor = $in
    match $dir {
        'N' => { $cursor.y -= 1 }
        'S' => { $cursor.y += 1 }
        'W' => { $cursor.x -= 1 }
        'E' => { $cursor.x += 1 }
    }
    $cursor
}

def find-first-direction []: record<x:int y:int> -> string {
    let cursor = $in
    for dir in $DIRS {
        if not ($dir | next-direction ($cursor | move-cursor $dir | get-pipe) | is-empty) {
            return $dir
        }
    }
    error make {msg: unreachable}
    ""
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