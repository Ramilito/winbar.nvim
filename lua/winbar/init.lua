local utils = require("winbar.utils")
local config = require("winbar.config")
local M = {}

local function augroup(name)
	return vim.api.nvim_create_augroup("winbar_" .. name, { clear = true })
end

---@return string
function M.get_winbar()
	local diagnostics = {}
	local icon, hl = "", ""

	if config.options.diagnostics then
		diagnostics = utils.get_diagnostics()
	end

	if config.options.icons then
		icon, hl = utils.get_icon(M.icons_by_filename, M.icons_by_extension)
	end

	local sectionA = "  %#" .. hl .. "#" .. icon
	local sectionBhl = "Normal"
	local sectionC = ""

	if vim.api.nvim_get_option_value("mod", {}) and config.options.buf_modified then
		if diagnostics.level == "other" then
			sectionBhl = "BufferCurrentMod"
			sectionC = "%#" .. sectionBhl .. "#" .. " M"
		else
			sectionC = " M"
		end
	end

	if diagnostics.level == "error" then
		sectionBhl = "DiagnosticError"
	elseif diagnostics.level == "warning" then
		sectionBhl = "DiagnosticWarn"
	elseif diagnostics.level == "info" then
		sectionBhl = "DiagnosticInfo"
	elseif diagnostics.level == "hint" then
		sectionBhl = "DiagnosticHint"
	end

	local sectionB = "  " .. "%#" .. sectionBhl .. "#" .. "%t" .. sectionC
	return sectionA .. sectionB .. "%*"
end

function M.register()
	local events = { "VimEnter", "BufEnter", "BufModifiedSet" }
	if config.options.diagnostics then
		table.insert(events, "DiagnosticChanged")
	end

	vim.api.nvim_create_autocmd(events, {
		group = augroup("winbar"),
		callback = function()
			if vim.tbl_contains(config.options.filetype_exclude, vim.bo.filetype) then
				vim.opt_local.winbar = nil
				return
			end

			local win_number = vim.api.nvim_get_current_win()
			local win_config = vim.api.nvim_win_get_config(win_number)

			if win_config.relative == "" then
				vim.opt_local.winbar = " " .. "%*" .. M.get_winbar() .. "%*"
			else
				vim.opt_local.winbar = nil
			end
		end,
	})
end

function M.setup(options)
	config.setup(options)

	if options.icons then
		local has_devicons, devicons = pcall(require, "nvim-web-devicons")
		if has_devicons and devicons then
			M.icons_by_filename = devicons.get_icons_by_filename()
			M.icons_by_extension = devicons.get_icons_by_extension()
		else
			error("Icons is set to true but dependency nvim-web-devicons is missing")
		end
	end

	M.register()
end

return M
