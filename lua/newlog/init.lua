local M = {}

-- Default configuration
M.defaults = {
  extension = ".md",
  date_format = "%y%m%d",
  filename_slugless_format = "{{ date }}{{ index }}{{ extension }}",
  filename_with_slug_format = "{{ date }}{{ index }}-{{ slug }}{{ extension }}",
  no_title = false,
}

-- Current configuration (will be initialized with defaults and user config)
M.config = {}

-- Get the data directory path according to Neovim conventions
function M.get_data_dir()
  local data_path = vim.fn.stdpath("data") .. "/newlog"
  if vim.fn.isdirectory(data_path) == 0 then
    vim.fn.mkdir(data_path, "p")
  end
  return data_path
end

-- Load or initialize the increment file
function M.load_increment()
  local increment_file = M.get_data_dir() .. "/increment.json"
  local increment = { date = "", next_index = 0 }

  if vim.fn.filereadable(increment_file) == 1 then
    local file = io.open(increment_file, "r")
    if file then
      local content = file:read("*all")
      file:close()
      local ok, data = pcall(vim.fn.json_decode, content)
      if ok then
        increment = data
      end
    end
  end

  return increment
end

-- Save the increment data
function M.save_increment(increment)
  local increment_file = M.get_data_dir() .. "/increment.json"
  local file = io.open(increment_file, "w")
  if file then
    file:write(vim.fn.json_encode(increment))
    file:close()
    return true
  end
  return false
end

-- Convert title to a filename-friendly slug
function M.slugify(title)
  local slug = title:lower()
  slug = slug:gsub("%s+", "-")      -- Replace spaces with hyphens
  slug = slug:gsub("[^%w%-]", "")   -- Remove non-alphanumeric characters except hyphens
  return slug
end

-- Render a template string with the provided data
function M.render_template(template, data)
  local result = template
  for key, value in pairs(data) do
    result = result:gsub("{{%s*" .. key .. "%s*}}", value)
  end
  return result
end

-- Create a new log file
function M.create_log(args)
  -- Process arguments
  local dir_path, title, extension

  -- First arg should be directory path if provided
  if args[1] then
    if vim.fn.isdirectory(args[1]) == 1 then
      dir_path = args[1]
    elseif vim.fn.filereadable(args[1]) == 1 then
      vim.api.nvim_err_writeln("Error: " .. args[1] .. " is a file, not a directory")
      return
    else
      vim.api.nvim_err_writeln("Error: Directory " .. args[1] .. " does not exist")
      return
    end
  else
    dir_path = "."  -- Default to current directory
  end

  -- Second arg is title if provided
  if args[2] then
    title = args[2]
  end

  -- Third arg is extension if provided
  if args[3] then
    extension = args[3]
    -- Add leading dot if not present
    if not extension:match("^%.") then
      extension = "." .. extension
    end
  else
    extension = M.config.extension
    -- Add leading dot if not present
    if not extension:match("^%.") then
      extension = "." .. extension
    end
  end

  -- Load increment file
  local increment = M.load_increment()

  -- Format current date
  local current_date = os.date(M.config.date_format)

  -- Determine index
  local index
  if current_date == increment.date then
    index = increment.next_index
    increment.next_index = increment.next_index + 1
  else
    increment.date = current_date
    index = 0
    increment.next_index = 1
  end

  -- Format index as two digits
  local index_str = string.format("%02d", index)

  -- Prepare template data
  local template_data = {
    date = current_date,
    index = index_str,
    extension = extension,
    slug = title and M.slugify(title) or "",
  }

  -- Generate filename using appropriate template
  local filename
  if title then
    filename = M.render_template(M.config.filename_with_slug_format, template_data)
  else
    filename = M.render_template(M.config.filename_slugless_format, template_data)
  end

  -- Ensure all directories in the path exist
  local full_path = dir_path .. "/" .. filename
  local dir_to_create = vim.fn.fnamemodify(full_path, ":h")
  if vim.fn.isdirectory(dir_to_create) == 0 then
    vim.fn.mkdir(dir_to_create, "p")
  end

  -- Create the file
  local file = io.open(full_path, "w")
  if not file then
    vim.api.nvim_err_writeln("Error: Could not create file " .. full_path)
    return
  end

  -- Write title and underscores if applicable
  if title and not M.config.no_title then
    local underscores = string.rep("-", #title)
    file:write(title .. "\n" .. underscores .. "\n\n")
  end

  file:close()

  -- Save updated increment
  M.save_increment(increment)

  -- Open the file in Neovim
  vim.cmd("edit " .. vim.fn.fnameescape(full_path))
end

-- Update configuration with :NLConfig command
function M.update_config(args)
  if #args == 0 then
    -- Display current config
    local config_str = "NewLog Configuration:\n"
    for key, value in pairs(M.config) do
      config_str = config_str .. "  " .. key .. " = " .. vim.inspect(value) .. "\n"
    end
    vim.api.nvim_echo({{config_str, "Normal"}}, true, {})
    return
  end

  if #args == 1 then
    vim.api.nvim_err_writeln("Error: Missing value for " .. args[1])
    return
  end

  local key = args[1]
  local value = args[2]

  if key == "date_format" then
    M.config.date_format = value
  elseif key == "filename_slugless_format" then
    M.config.filename_slugless_format = value
  elseif key == "filename_with_slug_format" then
    M.config.filename_with_slug_format = value
  elseif key == "extension" then
    -- Add leading dot if not present
    if not value:match("^%.") then
      value = "." .. value
    end
    M.config.extension = value
  elseif key == "no_title" then
    if value == "true" then
      M.config.no_title = true
    elseif value == "false" then
      M.config.no_title = false
    else
      vim.api.nvim_err_writeln("Error: no_title must be 'true' or 'false'")
      return
    end
  else
    vim.api.nvim_err_writeln("Error: Unknown configuration key: " .. key)
    return
  end

  vim.api.nvim_echo({{"Updated " .. key .. " = " .. vim.inspect(M.config[key]), "Normal"}}, true, {})
end

-- Directory completion for NewLog command
function M.complete_dirs(arg_lead, _, _)
  return vim.fn.getcompletion(arg_lead, 'dir')
end

-- Setup commands
function M.setup_commands()
  vim.api.nvim_create_user_command("NewLog", function(opts)
    M.create_log(opts.fargs)
  end, {
    nargs = "*",
    complete = M.complete_dirs,
    desc = "Create a new log file with timestamp"
  })

  vim.api.nvim_create_user_command("NL", function(opts)
    M.create_log(opts.fargs)
  end, {
    nargs = "*",
    complete = M.complete_dirs,
    desc = "Alias for NewLog"
  })

  vim.api.nvim_create_user_command("NLConfig", function(opts)
    M.update_config(opts.fargs)
  end, {
    nargs = "*",
    desc = "Update NewLog configuration"
  })
end

-- Setup function for the plugin
function M.setup(opts)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})

  -- Initialize commands
  M.setup_commands()
end

return M
