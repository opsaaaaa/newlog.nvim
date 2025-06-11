In the following code I want to you re-implement the code golang code from this cli called newlog into this lua plugin. I've decided it'd be better to implement it directly  instead of wrapping the command with the lua plugin. 



To simplify things for vim I'm thinking a few changes ought to be made as well.

Instead of storing the config in a toml file allow the user to do the same configuration with lazy.nvim's config options. 

Just ignore the --editor setting and the --config-file flag and the --increment-file flag as those aren't applicable in the context of a vim plugin

The interface should be something like this `:NewLog [path/to/folder] [title] [extension]` (with :NL as an alias).
Instead of having the title argument ambiguous being either the first or second argument just always interpret the first argument as the folder path and the second as the title. just give the user an error if the first argument isn't a valid folder path. and if a third argument is provide that should be used as the extension.

For vim, instead of using flags, I think we should allow the user to set those values with a command in vim. Similar to how :set works. I'm thinking a secondary command like :NLConfig for setting any of those config values.

The most basic usage would be calling `newlog` without any arguments or flags.
this would generate a empty markdown file in the current directory named with the date followed by a two digit index. `YYMMDD00.md` if its run a second time, then it ought to generate another empty file but increment the suffixed index by one `YYMMDD01.md`. The app ought to store the file current index and the last run date in a file. (please choose a standard location for this file based on nvim conventions for plugin data). If the file doesn't exist the folder and file should be initialized. The index is specific to the current day. so when creating this timestamp id the app should reference that file and compare the current date to the previously run date. if the date is the same it should increment the index stored in the file and set the last run date to the current day.

When the command is called with the folder path first argument it should create the new file inside the specificed directory.
It should check if the specified path is a file, and then return an error saying that the provided argument was a file and not a directory.
Similarly it should also provide an error to the user if the file doesn't exist.
`newlog path/to/folder` would create a file `path/to/folder/YYMMDD02.md`.

The second argument should be the files title. The title should be used in two places. a sluggified filename friendly version of the title should be used in the filename.
`newlog path/to/folder "title of new log file"` should create a file like `./path/to/folder/YYMMDD03-title-of-new-log-file.md`
When a title is provided it should also write a line to the file containing the title unaltered followed by another line of underscores matching the same character length of the title with an extra newline following that.
so the contents of `./path/to/folder/YYMMDD04-title-of-new-log-file.md` ought to look like this:
```
title of new log file
---------------------

```

The final argument should overwrite the default extension.
I'm also thinking the extension ought to include the `.` so i'd be `.md` instead of `md` to allow for extension strings like `.html.twig`

After the file is created vim should open it in a new buffer.

The configuration for the application should come from a table the use can provide in the lazy.nvim config option.
Please include the provided defaults in the code and merge the two tables ensuring that the user specified values take precedent over the default values.
Additionally the user should be able to change these value on the fly with :NLConfig

The following values the user should be able to configure.
date-format string                  it should accept a date format string in the lua way for handling date formatting.
filename-slugless-format string     Filename template without slug
filename-w-slug-format string       Filename template with slug
no-title                            Do not include title in file contents

Additionally a new feature I'd like to support is providing a folder path as part of the date format and name format.
so the user can have it create files with paths like `YYYY/MM/DD/00-filename.md`. date format something like `YYYY/MM/DD` and file name format something like `{{ date }}/{{ index }}-{{ slug }}{{ extension }}`.

for the filename templating choose a method and format typical for lua.


