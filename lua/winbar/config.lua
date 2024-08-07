local M = {}
local defaults = {
  icons = true,
  diagnostics = true,
  buf_modified = true,
  buf_modified_symbol = "M",
  dir_levels = 0,
  dim_inactive = {
    enabled = false,
    highlight = "WinbarNC",
    icons = true,
    name = true,
  },
  filetype_exclude = {
    "help",
    "startify",
    "dashboard",
    "packer",
    "neo-tree",
    "NeogitStatus",
    "NvimTree",
    "Trouble",
    "alpha",
    "lir",
    "Outline",
    "spectre_panel",
    "toggleterm",
    "TelescopePrompt",
    "prompt",
    "dap-repl",
    "aerial",
    "trouble",
  },
}

M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()
return M
