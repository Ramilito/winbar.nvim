local utils = require("winbar.utils")
local vim = vim
local M = {}

local function augroup(name)
	return vim.api.nvim_create_augroup("winbar_" .. name, { clear = true })
end

local get_buf_option = function(opt)
	local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
	if not status_ok then
		return nil
	else
		return buf_option
	end
end

local function get_file()
	local diagnostics = utils.get_diagnostics()
	local icon, hl = utils.get_icon()
	local filename = "%#" .. hl .. "#" .. "   " .. " " .. "%t" .. "%*"
	if icon then
		filename = "%#" .. hl .. "#" .. icon .. " " .. "%t" .. "%*"
	end

	if diagnostics.level == "error" then
		return "%#WinError#" .. " " .. filename
	elseif diagnostics.level == "warning" then
		return "%#WinWarning#" .. " " .. filename
	elseif get_buf_option("mod") then
		return "%#WinWarning#" .. " " .. filename
	else
		return "  " .. filename
	end
end

function M.get_winbar()
	return "%*" .. get_file() .. "%*"
end

function M.setup()
  load = vim.schedule_wrap(M.get_winbar)
	vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
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
			local config = vim.api.nvim_win_get_config(win_number)

			if config.relative == "" then
				vim.opt_local.winbar = " " .. load()
				-- vim.opt_local.statuscolumn = require("user.statuscolumn")
			else
				vim.opt_local.winbar = nil
			end
			-- vim.wo.winhighlight = 'Normal:NvimSeparator'
		end,
	})
end

return M
