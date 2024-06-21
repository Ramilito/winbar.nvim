local utils = require("winbar.utils")
local config = require("winbar.config")
local M = {}

local function augroup(name)
  return vim.api.nvim_create_augroup("winbar_" .. name, { clear = true })
end

local function get_filename()
  local path = vim.fn.expand("%:p:h")
  local parts = vim.split(path, "/")
  local levels = config.options.dir_levels
  local start = math.max(#parts - levels + 1, 1)
  local dir_levels = table.concat(vim.list_slice(parts, start, #parts), "/")
  return dir_levels
end

---@return string
function M.get_winbar(opts)
  local diagnostics = {}
  local icon, hl = "", ""
  local should_dim = not opts.active and config.options.dim_inactive.enabled

  if config.options.diagnostics then
    diagnostics = utils.get_diagnostics()
  end

  if config.options.icons then
    icon, hl = utils.get_icon(M.icons_by_filename, M.icons_by_extension)
  end

  -- don't highlight icon if the window is not active
  if should_dim and config.options.dim_inactive.icons then
    hl = config.options.dim_inactive.highlight
  end

  local sectionA = "  %#" .. hl .. "#" .. icon
  local sectionBhl = "Winbar"
  local sectionC = ""

  if vim.api.nvim_get_option_value("mod", {}) and config.options.buf_modified_symbol then
    if diagnostics.level == "other" then
      sectionBhl = "BufferCurrentMod"
      sectionC = "%#" .. sectionBhl .. "# " .. config.options.buf_modified_symbol
    else
      sectionC = " " .. config.options.buf_modified_symbol
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

  -- don't highlight name if the window is not active
  if should_dim and config.options.dim_inactive.name then
    sectionBhl = config.options.dim_inactive.highlight
  end

  local sectionB = "  " .. "%#" .. sectionBhl .. "#" .. get_filename() .. sectionC
  return sectionA .. sectionB .. "%*"
end

function M.register()
  local events = { "VimEnter", "BufEnter", "BufModifiedSet", "WinEnter", "WinLeave" }
  if config.options.diagnostics then
    table.insert(events, "DiagnosticChanged")
  end

  vim.api.nvim_create_autocmd(events, {
    group = augroup("winbar"),
    callback = function(args)
      if vim.tbl_contains(config.options.filetype_exclude, vim.bo.filetype) then
        vim.opt_local.winbar = nil
        return
      end

      local win_number = vim.api.nvim_get_current_win()
      local win_config = vim.api.nvim_win_get_config(win_number)

      if win_config.relative == "" then
        vim.opt_local.winbar = " " .. "%*" .. M.get_winbar({ active = args.event ~= "WinLeave" }) .. "%*"
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
