# newlog.nvim

A Neovim plugin that integrates the [newlog](https://github.com/opsaaaaa/newlog) command-line tool, providing a `:Newlog` command to create timestamped markdown files for logging or note-taking directly within Neovim. The plugin wraps the `newlog` tool, passes arguments and flags, and opens the resulting file in a new buffer.

`:Newlog [path/to/folder] [title]` to create timestamped markdown files (e.g., `25061000.md`).

## Prerequisites
- Install the `newlog` command-line tool and ensure its accessible in your `PATH`.

## Installation

### lazy.nvim
Add the following to your `lazy.nvim` configuration:

```lua
{
    "opsaaaaa/newlog.nvim",
    config = function()
        require("newlog")
    end,
}
```

## Usage

`:Newlog` Creates ./25061000.md in the current directory and opens it.

`:Newlog log/` Creates log/25061001.md and opens it.

`:Newlog log/ "My Title"` Creates log/25061002-my-title.md

`:Newlog --help` for more info.

