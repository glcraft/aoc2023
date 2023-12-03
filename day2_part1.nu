const MAX = {red: 12, green: 13, blue: 14}

open "day2_input.txt" 
    | lines
    | parse -r '^Game (?<id>\d+): (?<sets>.*)$'
    | each {|game|
        let wrong_game = ($game
            | get sets
            | split row '; '
            | each {|set|
                $set
                    | split row ', '
                    | parse -r '^(?<count>\d+) (?<color>red|green|blue)$'
                    | any {|balls| ($balls.count | into int) > ($MAX | get $balls.color) }
            }
            | any {|b| $b})
        $game | merge {wrong_game: ($wrong_game)}
    }
    | where wrong_game == false
    | get id
    | into int
    | math sum