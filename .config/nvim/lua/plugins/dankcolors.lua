return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({

				base00 = '#131315',
				base01 = '#2a2a2a',
				base02 = '#353535',
				base03 = '#a59999',
				base0B = '#ffe372',
				base04 = '#222223',
				base05 = '#bbbcbf',
				base06 = '#bbbcbf',
				base07 = '#bbbcbf',
				base08 = '#b26377',
				base09 = '#b26377',
				base0A = '#747a8c',
				base0C = '#42464e',
				base0D = '#747a8c',
				base0E = '#60636a',
				base0F = '#60636a',
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
