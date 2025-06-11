-- Define the list of all possible flags for the newlog command
local flags = {
    "--extension",
    "--date-format",
    "--filename-w-slug-format",
    "--filename-slugless-format",
    "--no-title",
    "--config-file",
    "--increment-file",
    "--help",
    "--version",
    "-e",
}

-- Define flags that expect file paths as their values
local file_flags = {
    "--config-file",
    "--increment-file",
}

-- Custom completion function for the :Newlog command
local function newlog_complete(arg_lead, cmd_line, cursor_pos)
    -- Extract everything after ":Newlog" from the command line
    local args_part = cmd_line:match("^:Newlog%s+(.*)$") or ""
    -- Split into individual words, trimming empty entries
    local words = vim.split(args_part, "%s+", {trimempty = true})
    -- If arg_lead is non-empty, it's the current word being typed
    if arg_lead ~= "" then
        table.insert(words, arg_lead)
    end

    -- If there's a previous word and it's a flag expecting a file, suggest files
    if #words >= 2 and vim.tbl_contains(file_flags, words[#words - 1]) then
        return vim.fn.getcompletion(arg_lead, 'file')
    -- If the current argument starts with '-', suggest matching flags
    elseif arg_lead:match("^%-") then
        local suggestions = {}
        for _, flag in ipairs(flags) do
            if flag:find("^" .. arg_lead) then
                table.insert(suggestions, flag)
            end
        end
        return suggestions
    -- Otherwise, suggest directories (for the folder path or other positional args)
    else
        return vim.fn.getcompletion(arg_lead, 'dir')
    end
end

local function newlog_cmd(cmd_info)
    local args = cmd_info.fargs or {}

    -- Check for --editor or -E flags
    for i, arg in ipairs(args) do
        if arg == "--editor" or arg == "-E" then
            vim.api.nvim_err_writeln(
                "Error: The --editor or -E flag cannot be used in :Newlog. " ..
                "The plugin automatically opens the file in Neovim and overrides the editor setting."
            )
            return
        end
        -- If --editor is followed by a value, skip that value to avoid processing it
        if arg == "--editor" and i < #args then
            table.remove(args, i + 1)
        end
    end

    -- Check for --help, -h, --version, -v flags
    local is_info_flag = false
    for _, arg in ipairs(args) do
        if arg == "--help" or arg == "-h" or arg == "--version" or arg == "-v" then
            is_info_flag = true
            break
        end
    end

    local flat_args = {}
    for _, arg in ipairs(args) do
        table.insert(flat_args, tostring(arg))
    end

    -- Escape the arguments for shell safety
    local escaped_args = {}
    for _, arg in ipairs(flat_args) do
        table.insert(escaped_args, vim.fn.shellescape(arg))
    end

    local cmd = "newlog " .. table.concat(escaped_args, " ") .. " -E '' 2>&1"

    local output = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_err_writeln("Error running newlog: " .. output)
        return
    end

    -- Handle output based on whether an info flag was used
    if is_info_flag then
        -- Print the output (help or version text) to the message area
        vim.api.nvim_echo({{output, "Normal"}}, true, {})
    else
        -- Open the created file in a new buffer
        local file_path = output:gsub("%s+$", "")
        vim.cmd('e ' .. vim.fn.fnameescape(file_path))
    end
end

-- Register the :Newlog command with custom completion
vim.api.nvim_create_user_command('Newlog', newlog_cmd, {nargs = '*', complete = newlog_complete})

