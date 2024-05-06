local M = {}
local defaults = {
	icons = true,
	diagnostics = true,
	buf_modified = true,
}

M.options = {}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()
return M
