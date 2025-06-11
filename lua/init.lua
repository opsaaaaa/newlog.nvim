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

-- local function newlog_cmd(...)
--     local args = {...}
--     print("Received args:", vim.inspect(args))
--     local flat_args = {}
--     for _, arg in ipairs(args) do
--         if type(arg) == "table" then
--             for _, sub_arg in ipairs(arg) do
--                 table.insert(flat_args, tostring(sub_arg))
--             end
--         else
--             table.insert(flat_args, tostring(arg))
--         end
--     end
--     print("Flat args:", vim.inspect(flat_args))
--     local escaped_args = {}
--     for _, arg in ipairs(flat_args) do
--         table.insert(escaped_args, vim.fn.shellescape(arg))
--     end
--     local cmd = "newlog " .. table.concat(escaped_args, " ") .. " -E '' 2>&1"
--     print("Constructed command:", cmd)
--     local output = vim.fn.system(cmd)
--     if vim.v.shell_error ~= 0 then
--         print("Error running newlog: " .. output)
--         return
--     end
--     local file_path = output:gsub("%s+$", "")
--     vim.cmd('e ' .. file_path)
-- end
--
local function newlog_cmd(cmd_info)
    -- Extract the arguments from cmd_info.fargs, default to empty table if nil
    local args = cmd_info.fargs or {}
    print("Received args:", vim.inspect(args))

    -- Flatten the arguments (in case of nested tables, though not expected here)
    local flat_args = {}
    for _, arg in ipairs(args) do
        table.insert(flat_args, tostring(arg))
    end
    print("Flat args:", vim.inspect(flat_args))

    -- Escape the arguments for shell safety
    local escaped_args = {}
    for _, arg in ipairs(flat_args) do
        table.insert(escaped_args, vim.fn.shellescape(arg))
    end

    -- Construct the command
    local cmd = "newlog " .. table.concat(escaped_args, " ") .. " -E '' 2>&1"
    print("Constructed command:", cmd)

    -- Execute the command
    local output = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        print("Error running newlog: " .. output)
        return
    end

    -- Open the created file
    local file_path = output:gsub("%s+$", "")
    vim.cmd('e ' .. file_path)
end

-- Function to handle the :Newlog command
-- local function newlog_cmd(...)
--     -- Collect all arguments passed to :Newlog
--     local args = {...}
--     -- Flatten arguments in case they are passed as a table
--     local flat_args = {}
--     for _, arg in ipairs(args) do
--         if type(arg) == "table" then
--             -- If arg is a table, extract its elements
--             for _, sub_arg in ipairs(arg) do
--                 table.insert(flat_args, tostring(sub_arg))
--             end
--         else
--             table.insert(flat_args, tostring(arg))
--         end
--     end

--     -- Escape each argument to handle spaces and special characters
--     local escaped_args = {}
--     for _, arg in ipairs(flat_args) do
--         table.insert(escaped_args, vim.fn.shellescape(arg))
--     end

--     -- Construct the shell command, forcing -E "" and redirecting stderr to stdout
--     local cmd = "newlog " .. table.concat(escaped_args, " ") .. " -E '' 2>&1"

--     -- Execute the command and capture output
--     local output = vim.fn.system(cmd)

--     -- Check for errors
--     if vim.v.shell_error ~= 0 then
--         print("Error running newlog: " .. output)
--         return
--     end

--     -- Trim whitespace from the file path and open it
--     local file_path = output:gsub("%s+$", "")
--     vim.cmd('e ' .. file_path)
-- end

-- Register the :Newlog command with custom completion
vim.api.nvim_create_user_command('Newlog', newlog_cmd, {nargs = '*', complete = newlog_complete})

