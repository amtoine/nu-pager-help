# nu-pager-help

A replacement for the builtin help command of Nushell, with paging for large help pages.

## What it does

`nu-pager-help` is a Nushell package that ships a single module: [`nu-pager-help`](nu-pager-help/mod.nu).

This module then exports one alias and one command
- `core help`: an alias to the builtin `help` command, so that you never loose it forever :wink:
- `help`: a thin wrapper around the builtin `help` command which
  - adds completion for the command name
  - uses a pager if the help page is too large for the current terminal height
