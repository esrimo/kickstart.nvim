-- Omarchy dynamic theme loader for Kickstart Neovim
local theme_file = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")
local specs = {}

if vim.fn.filereadable(theme_file) == 1 then
  local ok, raw_specs = pcall(dofile, theme_file)
  if ok and type(raw_specs) == "table" then
    local colorscheme_name = nil
    -- Step 1: Find the colorscheme name from the LazyVim spec or fallback to the colorscheme plugin name
    for _, spec in ipairs(raw_specs) do
      if spec[1] == "LazyVim/LazyVim" then
        if spec.opts and spec.opts.colorscheme then
          colorscheme_name = spec.opts.colorscheme
        end
      end
    end

    -- Step 2: Extract other plugin specs and configure them
    for _, spec in ipairs(raw_specs) do
      if spec[1] ~= "LazyVim/LazyVim" then
        local cloned_spec = vim.deepcopy(spec)
        -- Clear lazy = true so that the active theme plugin is always loaded immediately
        cloned_spec.lazy = false
        cloned_spec.priority = 1000

        -- Save any existing config function
        local orig_config = cloned_spec.config

        cloned_spec.config = function(plugin, opts)
          -- Run the original config function if it exists
          if type(orig_config) == "function" then
            pcall(orig_config, plugin, opts)
          elseif type(orig_config) == "string" then
            pcall(loadstring(orig_config))
          end

          -- If we have an explicit colorscheme name, apply it
          if colorscheme_name then
            pcall(vim.cmd.colorscheme, colorscheme_name)
          else
            -- Fallback: try setting colorscheme to the plugin's short name
            local name = cloned_spec.name or cloned_spec[1]:match("/([^/]+)$")
            if name then
              pcall(vim.cmd.colorscheme, name)
            end
          end
        end

        table.insert(specs, cloned_spec)
      end
    end
  end
end

-- If we didn't find any valid specs, fallback to tokyonight or habamax so Neovim doesn't break
if #specs == 0 then
  table.insert(specs, {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "tokyonight"
    end
  })
end

return specs
