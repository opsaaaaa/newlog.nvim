local M = {}

M.check = function()
    if vim.fn.executable('newlog') == 1 then
        vim.health.ok("newlog is installed and found in PATH")
    else
        vim.health.error("newlog is not installed or not found in PATH", 
            {"Ensure the newlog binary is installed and accessible in your PATH."})
    end
end

return M

