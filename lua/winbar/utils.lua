local M = {}
local vim = vim

local last_diagnostics_result = {}

local mt = {
	__index = function(_, _)
		return { count = 0, level = nil }
	end,
}

local severity_name = vim.tbl_add_reverse_lookup({
	[1] = "error",
	[2] = "warning",
	[3] = "info",
	[4] = "hint",
	[5] = "other",
})

setmetatable(severity_name, {
	__index = function()
		return "other"
	end,
})

local function is_insert() -- insert or replace
	local mode = vim.api.nvim_get_mode().mode
	return mode == "i" or mode == "ic" or mode == "ix" or mode == "R" or mode == "Rc" or mode == "Rx"
end

local function get_err_dict(errs)
	local ds = {}
	local max = #severity_name
	for _, err in ipairs(errs) do
		if err then
			-- calculate max severity
			local sev_num = err.severity
			local sev_level = severity_name[sev_num]
			if sev_num < max then
				max = sev_num
			end
			-- increment diagnostics dict
			if ds[sev_level] then
				ds[sev_level] = ds[sev_level] + 1
			else
				ds[sev_level] = 1
			end
		end
	end
	local max_severity = severity_name[max]
	return { level = max_severity, errors = ds }
end

function M.get_diagnostics()
	-- if is_disabled(opts.diagnostics) then return setmetatable({}, mt) end
	if is_insert() then
		return setmetatable(last_diagnostics_result, mt)
	end

	local diagnostics = vim.diagnostic.get(0)
	local result = {}
	local d = get_err_dict(diagnostics)

	result = {
		count = #diagnostics,
		level = d.level,
		errors = d.errors,
	}

	last_diagnostics_result = result
	return setmetatable(result, mt)
end

function M.get_icon()
	local path = vim.fn.bufname()
	local filetype = vim.bo.filetype
	local extension = vim.fn.fnamemodify(path, ":e")

	if filetype == "" then
		return "", "Default"
	end

	local loaded, webdev_icons = pcall(require, "nvim-web-devicons")
	if vim.fn.isdirectory(path) > 0 then
		local hl = loaded and "DevIconDefault" or nil
		return "", hl
	end

	if not loaded then
		if vim.fn.exists("*WebDevIconsGetFileTypeSymbol") > 0 then
			return vim.fn.WebDevIconsGetFileTypeSymbol(path), ""
		end
		return "", ""
	end

	if type == "terminal" then
		return webdev_icons.get_icon(type)
	end

	local icon, hl
	if filetype then
		-- Don't use a default here so that we fall through to the next case if no icon is found
		icon, hl = webdev_icons.get_icon_by_filetype(filetype, { default = false })
	end
	if not icon then
		icon, hl = webdev_icons.get_icon(vim.fn.fnamemodify(path, ":t"), extension, {
			true,
		})
	end

	if not icon then
		return "", ""
	end
	return icon, hl
end

function M.close_all_but_current()
	local current = vim.fn.bufnr("%")
	local buffers = vim.fn.getbufinfo({ buflisted = 1 })
	for _, buffer in ipairs(buffers) do
		if buffer.bufnr ~= current then
			vim.api.nvim_buf_delete(buffer.bufnr, { force = true })
		end
	end
end

return M
