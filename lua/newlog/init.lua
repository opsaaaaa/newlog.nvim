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

local file_flags = {
    "--config-file",
    "--increment-file",
}

local function newlog_complete(arg_lead, cmd_line, _)
    local args_part = cmd_line:match("^:Newlog%s+(.*)$") or ""

    local words = vim.split(args_part, "%s+", {trimempty = true})

    if arg_lead ~= "" then
        table.insert(words, arg_lead)
    end

    if #words >= 2 and vim.tbl_contains(file_flags, words[#words - 1]) then
        return vim.fn.getcompletion(arg_lead, 'file')

    elseif arg_lead:match("^%-") then
        local suggestions = {}
        for _, flag in ipairs(flags) do
            if flag:find("^" .. arg_lead) then
                table.insert(suggestions, flag)
            end
        end
        return suggestions
    else
        return vim.fn.getcompletion(arg_lead, 'dir')
    end
end

local function newlog_cmd(cmd_info)
    local args = cmd_info.fargs or {}
    local is_info_flag = false

    for _, arg in ipairs(args) do
        if arg == "--editor" or arg == "-E" then
            vim.api.nvim_err_writeln(
                "Error: The --editor or -E flag cannot be used in :Newlog. " ..
                "The plugin automatically opens the file in Neovim and overrides the editor setting."
            )
            return
        elseif arg == "--help" or arg == "-h" or arg == "--version" or arg == "-v" then
            is_info_flag = true
        end
    end

    local flat_args = {}
    for _, arg in ipairs(args) do
        table.insert(flat_args, tostring(arg))
    end

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

    if is_info_flag then
        vim.api.nvim_echo({{output, "Normal"}}, true, {})
    else
        local file_path = output:gsub("%s+$", "")
        vim.cmd('e ' .. vim.fn.fnameescape(file_path))
    end
end

vim.api.nvim_create_user_command('Newlog', newlog_cmd, {nargs = '*', complete = newlog_complete})

