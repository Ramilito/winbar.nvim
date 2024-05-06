# winbar.nvim
Sets a winbar at the top for each file

<img width="865" alt="image" src="https://github.com/Ramilito/winbar.nvim/assets/8473233/8cd807ea-86ee-48d9-96c2-fb725c522ef0">

## ✨ Features
- Shows if a file is modified and not saved
- Colored icons
- Integrates with diagnostics to highlight errors, warn, info, hints
- Can opt-out of icons and/or diagnostics
- Very fast!

## ⚡️ Requirements
- Technically none, although we use nvim-web-devicons icons, for perfomance reasons we have copied them into the plugin.

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  {
    "ramilito/winbar.nvim",
    event = "VimEnter", -- Alternatively BufReadPre if we don't care about the empty file when starting with 'nvim'
    config = function()
      require("winbar").setup({
        -- your configuration comes here, for example:
        icons = true,
        diagnostics = false,
        buf_modified = true
      })
    end
  },
}
```

## ⚙️ Configuration

### Setup
```lua
{
  icons = true,
  diagnostics = true,
  buf_modified = true,
  filetype_exclude = {
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
    "prompt"
  },
}
```
