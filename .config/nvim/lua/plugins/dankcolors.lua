return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({

				base00 = '#0f1417',
				base01 = '#181c1f',
				base02 = '#1c2023',
				base03 = '#92999d',
				base0B = '#fff672',
				base04 = '#222425',
				base05 = '#c1c5c7',
				base06 = '#c1c5c7',
				base07 = '#c1c5c7',
				base08 = '#c04163',
				base09 = '#c04163',
				base0A = '#20779f',
				base0C = '#6898ac',
				base0D = '#20779f',
				base0E = '#afd9eb',
				base0F = '#afd9eb',
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
