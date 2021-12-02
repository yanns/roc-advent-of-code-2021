app "cli-tutorial"
    packages { pf: "../../roc/examples/cli/platform" }
    imports [ pf.Stdout, pf.Task.{ await }, pf.File ]
    provides [ main ] to pf

# The CLI platform was modified to support File (https://gist.github.com/shrik450/dea48e77ccacc3f6da6bf9538cd61bde)

#measurements = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263 ]

increases = \measurements ->
    finalState = List.walk measurements { counts: 0, previousElement: None } \state, elem ->
        when state.previousElement is
            Some previousElement if previousElement < elem -> { counts: state.counts + 1, previousElement: Some elem }
            _ -> { state & previousElement: Some elem }
    finalState.counts


# The path is relative to where we run the code ;(
inputPath = "../adventofcode/day1/input.txt"

# TODO: use Str.toNum when available
strToNum: Str -> Result (Num *) [ NotANumber ]*
strToNum = \_string -> Ok 0

listStrToNum = \list ->
    List.walk list [] \state, elem ->
        when elem is
            Ok a -> List.append state a
            _ -> state

showIncreases = \input ->
    lines = Str.split input "\n"
    length = List.len lines |> Num.toStr
    first =
        lines
            |> List.get 1
            |> Result.withDefault ""
    increasesStr =
        lines
            |> List.map strToNum
            |> listStrToNum
            |> increases
            |> Num.toStr
    _ <- await (Stdout.line "Read \(length) elements. First one: \(first)")
    Stdout.line "There are \(increasesStr) increases"

main =
    _ <- await (Stdout.line "Trying to read file...")
    task = File.readUtf8 inputPath
    Task.attempt task \result ->
      when result is
          Ok input -> showIncreases input
          Err _ -> Stdout.line "Failed to read input."