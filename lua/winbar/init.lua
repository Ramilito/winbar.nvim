local utils = require("winbar.utils")
local config = require("winbar.config")
local M = {}

local function augroup(name)
	return vim.api.nvim_create_augroup("winbar_" .. name, { clear = true })
end

local function get_file()
	local diagnostics = utils.get_diagnostics()
	local icon, hl = utils.get_icon()
	local sectionA = "  %#" .. hl .. "#" .. icon
	local sectionBhl = "Normal"
	local sectionC = ""

	if vim.api.nvim_get_option_value("mod", {}) then
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

function M.get_winbar()
	return "%*" .. get_file() .. "%*"
end

function M.setup(options)
	config.setup(options)
	vim.api.nvim_create_autocmd({ "BufEnter", "DiagnosticChanged", "BufModifiedSet" }, {
		group = augroup("winbar"),
		callback = function()
			local winbar_filetype_exclude = {
				"help",
				"startify",
				"dashboard",
				"packer",
				"neo-tree",
				"neogitstatus",
				"NvimTree",
				"Trouble",
				"alpha",
				"lir",
				"Outline",
				"spectre_panel",
				"toggleterm",
				"TelescopePrompt",
				"prompt",
			}

			if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
				vim.opt_local.winbar = nil
				return
			end

			local win_number = vim.api.nvim_get_current_win()
			local win_config = vim.api.nvim_win_get_config(win_number)

			if win_config.relative == "" then
				vim.opt_local.winbar = " " .. M.get_winbar()
			else
				vim.opt_local.winbar = nil
			end
		end,
	})
end

return M
