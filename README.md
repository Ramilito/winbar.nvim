# winbar.nvim
Sets a winbar at the top for each file

<img width="865" alt="image" src="https://github.com/Ramilito/winbar.nvim/assets/8473233/8cd807ea-86ee-48d9-96c2-fb725c522ef0">

## ✨ Features
- Shows if a file is modified and not saved
- Colored icons
- Integrates with diagnostics to highlight errors, warn, info, hints
- Can opt-out of icons and/or diagnostics
- Very fast!

## ⚡️ Dependencies
- [devicons](https://github.com/nvim-tree/nvim-web-devicons) (icons) -- If ```config.icons = true```

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  {
    "ramilito/winbar.nvim",
    event = "VimEnter", -- Alternatively, BufReadPre if we don't care about the empty file when starting with 'nvim'
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("winbar").setup({
        -- your configuration comes here, for example:
        icons = true,
        diagnostics = true,
        buf_modified = true,
        buf_modified_symbol = "M",
        -- or use an icon
        -- buf_modified_symbol = "●"
        background_color = "WinBarNC"
        -- or use a hex code:
		-- background_color = "#141415",
        -- or a different highlight:
        -- background_color = "Statusline"
        dim_inactive = {
            enabled = false,
            highlight = "WinBarNC",
            icons = true, -- whether to dim the icons
            name = true, -- whether to dim the name
        }
        exclude_if = nil
        -- define a function that returns a boolean to exclude winbar in specific circumstances.
        -- the function should return true when you want to exclude the winbar, false otherwise.
        -- for example:
		-- exclude_if = function()
		--   return vim.w.magenta == true
        -- end
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
  dir_levels = 0,
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

## Performance

### Startup

No startup impact since we use VimEnter to register the plugin.

### UI
On an M2 Mac running nvim ./file

<img width="356" alt="image" src="https://github.com/Ramilito/winbar.nvim/assets/8473233/f48e8f0c-2073-4cda-b222-93ed16bdfdc6">

On an M2 Mac running nvim

<img width="356" alt="image" src="https://github.com/Ramilito/winbar.nvim/assets/8473233/2c9ab552-ee7e-478a-b54a-15b2337797f3">


## Motivation
This plugin aims to help people move away from the tabline way of working but still need to orient them selves when working with multiple files by giving context.
The features are inspired by VSCode behaviour, some code is borrowed from bufferline, thanks for that 🙏.
