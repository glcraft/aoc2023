const MAX = {red: 12 green: 13 blue: 14}
const MIN = {red: 0 green: 0 blue: 0}

open "day2_input.txt" 
    | lines
    | parse -r '^Game (?<id>\d+): (?<sets>.*)$'
    | each {|game|
        $game
            | get sets
            | split row '; '
            | each {|set|
                $set
                    | split row ', '
                    | parse -r '^(?<count>\d+) (?<color>red|green|blue)$'
                    | reduce --fold $MIN {|it, acc| $acc | merge { $it.color: ($it.count | into int) } }
            }
            | reduce --fold $MIN {|it, acc| [$acc $it] | math max }
    }
    | each {|game| $game.red * $game.green * $game.blue}
    | math sum