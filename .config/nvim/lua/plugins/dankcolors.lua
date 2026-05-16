return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({

				base00 = '#000000',
				base01 = '#000000',
				base02 = '#000000',
				base03 = '#a5a299',
				base0B = '#ffe872',
				base04 = '#474644',
				base05 = '#fffdf9',
				base06 = '#fffdf9',
				base07 = '#fffdf9',
				base08 = '#ff8a7f',
				base09 = '#ff8a7f',
				base0A = '#fff6db',
				base0C = '#fffbef',
				base0D = '#fff6db',
				base0E = '#fffcf4',
				base0F = '#fffcf4',
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
