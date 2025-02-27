local M = {}
local last_diagnostics_result = {}

local mt = {
  __index = function(_, _)
    return { count = 0, level = nil }
  end,
}

local severity_name = {
  [1] = "error",
  [2] = "warning",
  [3] = "info",
  [4] = "hint",
  [5] = "other",
}

for k, v in pairs(severity_name) do
  ---@diagnostic disable-next-line: assign-type-mismatch
  severity_name[v] = k
end

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
  for _, err in ipairs(errs["diagnostics"]) do
    if err then
      local sev_num = err.severity
      local sev_level = severity_name[sev_num]
      if sev_num then
        if sev_num < max then
          max = sev_num
        end
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

function M.get_diagnostics(diagnostics)
  if diagnostics == nil or diagnostics == {} then
    return {}
  end

  -- if is_disabled(opts.diagnostics) then return setmetatable({}, mt) end
  if is_insert() then
    return setmetatable(last_diagnostics_result, mt)
  end

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

local nvim_set_hl = vim.api.nvim_set_hl
function M.set_up_highlight(icon_data)
  local hl_group = M.get_highlight_name(icon_data)
  if hl_group and (icon_data.color or icon_data.cterm_color) then
    nvim_set_hl(0, M.get_highlight_name(icon_data), {
      fg = icon_data.color,
      ctermfg = tonumber(icon_data.cterm_color),
    })
  end
end

function M.get_highlight_name(data)
  return "DevIcon" .. data.name
end

---@return string, string
function M.get_icon(icons_by_filename, icons_by_extension)
  local path = vim.fn.bufname()
  local filetype = vim.fn.fnamemodify(path, ":t")
  local ext = vim.fn.fnamemodify(path, ":e")
  if vim.bo.filetype == "" then
    return "", "Default"
  end

  if vim.fn.isdirectory(path) > 0 then
    return "", "Default"
  end

  local icon = icons_by_filename[string.lower(filetype)] or icons_by_extension[ext]

  if not icon then
    return "", ""
  end

  M.set_up_highlight(icon)
  return icon.icon, M.get_highlight_name(icon)
end

return M
