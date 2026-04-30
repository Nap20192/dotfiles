-- Here I load files with custom settings for machine.
-- This lua file is hidden from VCS, so I can do tricky stuff there.
pcall(require, "vnkjd.hidden")

require "vnkjd"
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
  group = grp,
  callback = function()
    local win_h = vim.api.nvim_win_get_height(0)
    local off = math.min(vim.o.scrolloff, math.floor(win_h / 2))
    local dist = vim.fn.line "$" - vim.fn.line "."
    local rem = vim.fn.line "w$" - vim.fn.line "w0" + 1
    if dist < off and win_h - rem + dist < off then
      local view = vim.fn.winsaveview()
      view.topline = view.topline + off - (win_h - rem + dist)
      vim.fn.winrestview(view)
    end
  end,
})
