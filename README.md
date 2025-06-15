# newlog.nvim

A Neovim plugin for creating new files with date timestamps and incrementing
indices to ensure filenames are unique and chronologically sorted.

Primarily designed for taking daily notes.

## Installation

Using lazy.nvim:
```lua
  return {
    {
      'opsaaaaa/newlog.nvim',
      cmd = {"NLConfig", "NL", "NewLog"},
      config = function()
        require("newlog").setup({})
      end
    },
  }
```

## Usage

`:h newlog` for more info.

### Commands

`*:NewLog* [directory] [title] [extension]`
  Create and edit a new log file.
  Examples:
  - `:NewLog log/` > `log/YYMMDD00.md`
  - `:NewLog . notes about new log` > `./YYMMDD01-notes-about-new-log.md`
  - `:NewLog log/ .txt` > `log/YYMMDD00.txt`
  - `:NewLog` > `./YYMMDD00.md`
  - `:NewLog log/ some title .txt` > `log/YYMMDD00-some-title.txt`

`*:NL* [directory] [title] [extension]`
  Alias for :NewLog

`*:NLConfig* [option] [value]`
  Configure NewLog options at runtime.
  Examples:
  - `:NLConfig extension .txt` - Change default extension
  - `:NLConfig date_format %Y-%m-%d` - Change date format
  - `:NLConfig no_title true` - Set no_title option
  - `:NLConfig` (without arguments) - Display current configuration



### Configuration

Example configuration: 
```lua
  require("newlog").setup({
    extension = ".md",
    -- File extension for new logs.
    date_format = "%Y-%m-%d",
    -- Format for dates in filenames. Uses Lua's os.date() format.
    filename_template_no_slug = "log-{{ date }}-{{ index }}{{ extension }}",
    -- Template for filenames when no title is provided.
    filename_template_with_slug = "{{ date }}-{{ slug }}{{ extension }}",
    --Template for filenames when a title is provided. 
    content_template = "{{ title }}\n{{ underscores }}\n\n",
    -- Template for the initial content of the log file.
  })
```

### Templates

NewLog uses a simple template system with {{ variable }} placeholders.

Available template variables:

  • date: The formatted date according to date_format
  • index: Two-digit index number (00, 01, 02, etc.)
  • extension: File extension including the dot
  • title: The title provided as argument (empty if none)
  • slug: URL-friendly version of the title (empty if no title)
  • underscores: A line of dashes matching the title length (for Markdown)

Example template usage: 
```lua
  filename_template_with_slug = "{{ date }}_{{ index }}_{{ slug }}{{ extension }}"
  content_template = "# {{ title }}\n\nDate: {{ date }}\nFile: {{ slug }}\n\n"
```

