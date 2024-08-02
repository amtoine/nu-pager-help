def complete-commands [context: string]: [ nothing -> list<string> ] {
    let words_already_there = $context | split words | skip 1
    let complete_words = $words_already_there
        | if $context ends-with ' ' { } else { drop 1 }
        | str join ' '

    scope commands
        | where $it.name starts-with $complete_words
        | get name
        | str replace --regex $'^($complete_words) ?' ''
        | filter { $in != '' }
}

# the builtin help command
export alias "core help" = help

# a replacement for help that will use a pager if the help page is too big
#
# see `core help` for the builtin `help` command
#
# # Examples
#
# ```nushell
# # get the help of `str screaming-snake-case` in Neovim
# help str screaming-snake-case --pager {
#     let help_file = mktemp -t help.XXXXXXX
#     $in | ansi strip | save --force $help_file
#     nvim $help_file
# }
# ```
export def help [
    ...cmd: string@complete-commands # the command that needs some help
    --pager: closure # the pager (defaults to less)
] {
    let h = if ($cmd | is-empty) {
        core help
    } else {
        let command = $cmd | str join ' '
        if $command not-in (help commands | get name) {
            error make {
                msg: $"(ansi red_bold)invalid_command(ansi reset)",
                label: {
                    text: "not found in scope"
                    span: (metadata $cmd).span,
                },
                help: ([
                    $"command (ansi cyan)($command)(ansi reset) was not found,"
                    $"please have a look at (ansi cyan)scope commands"
                    $"(ansi reset) for a complete list of commands available "
                    "in your current scope",
                ] | str join)
            }
        }

        $command | core help $in | str trim
    }

    if ($h | lines | length) < (term size).rows {
        print $h
    } else {
        let pager = $pager | default { less -r }
        $h | do $pager
    }
}
