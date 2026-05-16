local function hi(group, opts)
    opts = opts or {}
    local guifg = opts.guifg or "NONE"
    local guibg = opts.guibg or "NONE"
    local guisp = opts.guisp or "NONE"
    local gui = opts.gui or "NONE"
    local ctermfg = opts.ctermfg or "NONE"
    local ctermbg = opts.ctermbg or "NONE"
    local cterm = opts.cterm or "NONE"

    local cmd = string.format(
        "hi %s guifg=%s guibg=%s guisp=%s gui=%s ctermfg=%s ctermbg=%s cterm=%s",
        group,
        guifg,
        guibg,
        guisp,
        gui,
        ctermfg,
        ctermbg,
        cterm
    )
    vim.cmd(cmd)
end

local function link(from, to)
    vim.cmd(string.format("hi! link %s %s", from, to))
end

local theme_state = vim.fn.expand(
    (vim.env.XDG_CACHE_HOME or "~/.cache") .. "/vnkjd/theme"
)
local mode = vim.o.background
if vim.fn.filereadable(theme_state) == 1 then
    local state = vim.trim(vim.fn.readfile(theme_state, "", 1)[1] or "")
    if state == "light" or state == "dark" then
        mode = state
        vim.o.background = state
    end
end
local palette = require("vnkjd.theme").get(mode)
local transparent_terminal = vim.env.KITTY_WINDOW_ID ~= nil
    or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
    or vim.env.TERM == "xterm-kitty"
    or vim.env.TERM == "xterm-ghostty"

local transparent = vim.g.vnkjd_transparent_background ~= false
    and transparent_terminal
local base_bg = transparent and "NONE" or palette.bg
local popup_bg = transparent and "NONE" or palette.bg
local elevated_bg = transparent and "NONE" or palette.bg
local subtle_bg = transparent and "NONE" or palette.bg
local muted_bg = transparent and "NONE" or palette.bg
local select_fg = palette.selection_fg or "#000000"

-- Set up colorscheme
vim.cmd "set termguicolors"
vim.cmd 'let g:colors_name = "vnkjd-monochrome"'
vim.cmd("set background=" .. mode)

-- =============================================================================
-- BASE GROUPS
-- =============================================================================
hi("Normal", { guifg = palette.fg, guibg = base_bg })
hi("NormalNC", { guifg = palette.fg, guibg = base_bg })
hi("CursorLine", { guibg = elevated_bg })
hi("CursorLineNr", { guifg = palette.fg, guibg = elevated_bg, gui = "bold" })
hi("ColorColumn", { guibg = subtle_bg })
hi("LineNr", { guifg = palette.muted })
hi("FoldColumn", { guifg = palette.muted })
hi("Folded", { guifg = palette.muted, guibg = base_bg })
hi("EndOfBuffer", { guifg = palette.muted })
hi("Conceal", { guifg = palette.muted })
hi("NonText", { guifg = palette.noise })
hi("SpecialKey", { guifg = palette.noise, gui = "bold" })

-- =============================================================================
-- SYNTAX ELEMENTS
-- =============================================================================
hi("Comment", { guifg = palette.muted })
hi("Keyword", { guifg = palette.muted })
hi("Statement", { guifg = palette.fg })
hi("Function", { guifg = palette.fg, gui = "bold" })
hi("Identifier", { guifg = palette.fg })
hi("Type", { guifg = palette.fg, gui = "underline" })
hi("Typedef", { guifg = palette.fg, gui = "underline" })
hi("StorageClass", { guifg = palette.fg })
hi("Structure", { guifg = palette.fg })

hi("Constant", { guifg = palette.fg, gui = "italic" })
hi("String", { guifg = palette.fg, gui = "italic" })
hi("Number", { guifg = palette.fg, gui = "italic" })
hi("Boolean", { guifg = palette.fg, gui = "italic" })
hi("Float", { guifg = palette.fg, gui = "italic" })
hi("Character", { guifg = palette.fg, gui = "italic" })

hi("PreProc", { guifg = palette.fg })
hi("Include", { guifg = palette.fg })
hi("Define", { guifg = palette.fg })
hi("Macro", { guifg = palette.fg })
hi("PreCondit", { guifg = palette.fg })

hi("Special", { guifg = palette.fg })
hi("SpecialChar", { guifg = palette.fg })
hi("Tag", { guifg = palette.fg })
hi("Delimiter", { guifg = palette.fg })
hi("SpecialComment", { guifg = palette.fg })

hi("Underlined", { guifg = palette.fg, gui = "underline" })
hi("Ignore", { guifg = palette.fg })

-- =============================================================================
-- Oil
-- =============================================================================
hi("OilDir", { guifg = palette.fg, gui = "bold" })

-- =============================================================================
-- TREESITTER LINKS
-- =============================================================================
link("@function", "Function")
link("@function.call", "Function")
link("@function.builtin", "Function")
link("@function.method", "Function")
link("@function.method.call", "Function")

link("@type", "Type")
link("@type.builtin", "Type")
link("@type.definition", "Type")

link("@keyword", "Keyword")
link("@keyword.return", "Keyword")
link("@keyword.function", "Keyword")
link("@keyword.operator", "Keyword")
link("@keyword.import", "Keyword")
link("@keyword.type", "Keyword")
link("@keyword.modifier", "Keyword")
link("@keyword.repeat", "Keyword")
link("@keyword.conditional", "Keyword")
link("@keyword.exception", "Keyword")

link("@comment", "Comment")
link("@comment.documentation", "Comment")

link("@variable", "Identifier")
link("@variable.parameter", "Identifier")
link("@variable.member", "Identifier")
link("@constant", "Constant")
link("@constant.builtin", "Constant")
link("@string", "String")
link("@string.documentation", "String")
link("@string.regexp", "String")
link("@string.escape", "String")
link("@string.special", "String")
link("@string.special.symbol", "String")
link("@string.special.url", "String")
link("@string.special.path", "String")

link("@character", "Character")
link("@character.special", "Character")

link("@number", "Number")
link("@number.float", "Number")

link("@boolean", "Boolean")

link("@number", "Number")

link("@operator", "Operator")

link("@punctuation.delimiter", "Delimiter")
link("@punctuation.bracket", "Delimiter")

link("@tag", "Tag")
link("@tag.attribute", "Type")

-- =============================================================================
-- SEARCH AND VISUAL
-- =============================================================================
hi("Search", { guifg = select_fg, guibg = palette.search, gui = "bold" })
hi("IncSearch", { guifg = select_fg, guibg = palette.visual, gui = "bold" })
hi("CurSearch", { guifg = select_fg, guibg = palette.visual, gui = "bold" })
hi("Visual", { guifg = palette.fg, guibg = palette.visual })
hi("VisualNOS", { guibg = subtle_bg })

-- ================================visual=============================================
-- DIFF
-- ================================visual=============================================
hi("DiffAdd", { guibg = palette.add })
hi("DiffDelete", { guibg = palette.remove })
hi("DiffChange", { guibg = palette.change })
hi("DiffText", { guibg = palette.change_text })

link("@diff.plus", "DiffAdd")
link("@diff.minus", "DiffDelete")
link("@diff.delta", "DiffChange")

link("diffAdded", "DiffAdd")
link("diffRemoved", "DiffDelete")

-- =============================================================================
-- UI ELEMENTS
-- =============================================================================
hi("StatusLine", { guifg = palette.fg, guibg = base_bg, gui = "bold" })
hi("StatusLineNC", { guifg = palette.muted, guibg = base_bg })
hi("WinSeparator", { guifg = palette.muted, guibg = base_bg })
hi("TabLine", { guifg = palette.muted, guibg = base_bg })
hi("TabLineFill", { guifg = palette.muted, guibg = base_bg })
hi("TabLineSel", { guibg = elevated_bg, gui = "bold,reverse" })

hi("NormalFloat", { guifg = palette.fg, guibg = popup_bg })
hi("FloatBorder", { guifg = palette.muted, guibg = popup_bg })

hi("Pmenu", { guifg = palette.fg, guibg = popup_bg })
hi("PmenuSel", { guifg = select_fg, guibg = palette.fg })
hi("PmenuExtra", { guifg = palette.fg, guibg = popup_bg })
hi("PmenuExtraSel", { guifg = select_fg, guibg = palette.fg })
hi("PmenuKind", { guifg = palette.fg, guibg = popup_bg, gui = "bold" })
hi("PmenuKindSel", { guifg = select_fg, guibg = palette.fg, gui = "bold" })
hi("PmenuSbar", { guibg = subtle_bg })
hi("PmenuThumb", { guibg = muted_bg })

hi("WildMenu", { guifg = select_fg, guibg = palette.search, gui = "bold" })
hi("Directory", { guifg = palette.fg })
hi("Title", { guifg = palette.fg })
hi("Question", { guifg = palette.fg })
hi("MoreMsg", { guifg = palette.fg })
hi("ModeMsg", { guifg = palette.fg, gui = "bold" })

-- =============================================================================
-- MATCH AND SPELL
-- =============================================================================
hi("MatchParen", { guifg = palette.visual, gui = "bold,underline" })
hi("SpellBad", {
    guifg = palette.error,
    guisp = palette.error,
    gui = "undercurl",
})
hi("SpellCap", { guisp = palette.error, gui = "undercurl" })
hi("SpellLocal", { guisp = palette.error, gui = "undercurl" })
hi("SpellRare", { guisp = palette.error, gui = "undercurl" })

-- =============================================================================
-- ERROR AND TODO
-- =============================================================================
hi("Error", { guifg = palette.error, guibg = base_bg, gui = "bold,reverse" })
hi("ErrorMsg", { guibg = palette.error })
hi("WarningMsg", { guifg = palette.fg })
hi("Todo", { guifg = palette.search, gui = "bold,reverse" })

-- =============================================================================
-- DIAGNOSTICS
-- =============================================================================
hi("DiagnosticError", { guifg = palette.error, gui = "bold" })
hi("DiagnosticUnderlineError", { guisp = palette.error, gui = "undercurl" })
hi("DiagnosticVirtualTextError", { guifg = palette.error })
hi("DiagnosticFloatingError", { guifg = palette.error })
link("DiagnosticSignError", "DiagnosticError")

hi("DiagnosticWarn", { guisp = palette.noise })
hi("DiagnosticInfo", { guisp = palette.noise })
hi("DiagnosticHint", { guisp = palette.noise })
hi("DiagnosticOk", { guisp = palette.noise })

hi("DiagnosticVirtualTextWarn", { guisp = palette.noise })
hi("DiagnosticVirtualTextInfo", { guisp = palette.noise })
hi("DiagnosticVirtualTextHint", { guisp = palette.noise })
hi("DiagnosticVirtualTextOk", { guisp = palette.noise })

hi("DiagnosticUnderlineWarn", { guisp = palette.noise, gui = "undercurl" })
hi("DiagnosticUnderlineInfo", { guisp = palette.noise, gui = "undercurl" })
hi("DiagnosticUnderlineHint", { guisp = palette.noise, gui = "undercurl" })
hi("DiagnosticUnderlineOk", { guisp = palette.noise, gui = "undercurl" })

link("DiagnosticSignWarn", "DiagnosticWarn")
link("DiagnosticSignInfo", "DiagnosticInfo")
link("DiagnosticSignHint", "DiagnosticHint")
link("DiagnosticSignOk", "DiagnosticOk")

-- =============================================================================
-- CURSOR
-- =============================================================================
hi("Cursor", { guifg = palette.cursor_text, guibg = palette.cursor })

-- =============================================================================
-- SIGN COLUMN
-- =============================================================================
hi("SignColumn", { guifg = palette.fg })
hi("LineNr", { guifg = palette.muted })

-- =============================================================================
-- QUICKFIX
-- =============================================================================
hi("QuickFixLine", { guifg = palette.search, gui = "reverse" })
hi("qfFileName", { gui = "bold" })

-- =============================================================================
-- FUGITIVE
-- =============================================================================
link("fugitiveStagedHeading", "Include")
link("fugitiveUnstagedHeading", "Macro")
link("fugitiveUntrackedHeading", "PreCondit")
link("fugitiveStagedModifier", "Typedef")
link("fugitiveUnstagedModifier", "Structure")
link("fugitiveUntrackedModifier", "StorageClass")
link("fugitiveHeader", "Label")
link("fugitiveHelpHeader", "fugitiveHeader")
link("fugitiveHelpTag", "Tag")
link("fugitiveHash", "Identifier")
link("fugitiveSymbolicRef", "Function")
link("fugitiveCount", "Number")
link("fugitiveInstruction", "Type")
link("fugitiveStop", "Function")

-- =============================================================================
-- MISC LINKS
-- =============================================================================
link("Added", "Normal")
link("Changed", "Normal")
link("Removed", "Normal")
link("Boolean", "Constant")
link("Character", "Constant")
link("Float", "Constant")
link("Number", "Constant")
link("String", "Constant")
link("Conditional", "Statement")
link("Repeat", "Statement")
link("Label", "Statement")
link("Operator", "Statement")
link("Exception", "Statement")
link("Debug", "Special")
link("define", "PreProc")
link("include", "PreProc")

-- =============================================================================
-- FZF-LUA
-- =============================================================================
hi("FzfLuaNormal", { guifg = palette.fg, guibg = popup_bg })
hi("FzfLuaBorder", { guifg = palette.muted, guibg = popup_bg })
hi("FzfLuaTitle", { guifg = palette.fg, guibg = elevated_bg })
hi("FzfLuaTitleFlags", { guifg = palette.fg, guibg = subtle_bg })
hi("FzfLuaBackdrop", { guifg = palette.muted, guibg = base_bg })
hi("FzfLuaPreviewNormal", { guifg = palette.fg, guibg = elevated_bg })
hi("FzfLuaPreviewBorder", { guifg = palette.muted, guibg = elevated_bg })
hi("FzfLuaPreviewTitle", { guifg = palette.fg, guibg = elevated_bg })
hi("FzfLuaCursor", { guifg = palette.cursor_text, guibg = palette.cursor })
hi("FzfLuaCursorLine", { guibg = subtle_bg })
hi("FzfLuaCursorLineNr", { guifg = palette.fg, guibg = subtle_bg })
hi(
    "FzfLuaSearch",
    { guifg = select_fg, guibg = palette.visual, gui = "bold" }
)
hi("FzfLuaScrollBorderEmpty", { guifg = palette.muted, guibg = base_bg })
hi("FzfLuaScrollBorderFull", { guifg = palette.muted, guibg = base_bg })
hi("FzfLuaScrollFloatEmpty", { guibg = subtle_bg })
hi("FzfLuaScrollFloatFull", { guibg = muted_bg })
hi("FzfLuaHelpNormal", { guifg = palette.fg, guibg = base_bg })
hi("FzfLuaHelpBorder", { guifg = palette.muted, guibg = base_bg })
hi("FzfLuaHeaderBind", { guifg = palette.fg })
hi("FzfLuaHeaderText", { guifg = palette.fg })
hi("FzfLuaPathColNr", { guifg = palette.search })
hi("FzfLuaPathLineNr", { guifg = palette.add })
hi("FzfLuaBufName", { guifg = palette.fg })
hi("FzfLuaBufId", { guifg = palette.muted })
hi("FzfLuaBufNr", { guifg = palette.fg })
hi("FzfLuaBufLineNr", { guifg = palette.muted })
hi("FzfLuaBufFlagCur", { guifg = palette.fg })
hi("FzfLuaBufFlagAlt", { guifg = palette.search })
hi("FzfLuaTabTitle", { guifg = palette.search })
hi("FzfLuaTabMarker", { guifg = palette.fg })
hi("FzfLuaDirIcon", { guifg = palette.fg })
hi("FzfLuaDirPart", { guifg = palette.muted })
hi("FzfLuaFilePart", { guifg = palette.fg })
hi("FzfLuaLivePrompt", { guifg = palette.fg })
hi("FzfLuaLiveSym", { guifg = palette.search })
hi("FzfLuaCmdEx", { guifg = palette.fg })
hi("FzfLuaCmdBuf", { guifg = palette.add })
hi("FzfLuaCmdGlobal", { guifg = palette.fg })
hi("FzfLuaFzfNormal", { guifg = palette.fg, guibg = popup_bg })
hi("FzfLuaFzfCursorLine", { guifg = palette.fg, guibg = subtle_bg })
hi("FzfLuaFzfMatch", { guifg = palette.search, gui = "bold" })
hi("FzfLuaFzfBorder", { guifg = palette.muted, guibg = base_bg })
hi("FzfLuaFzfScrollbar", { guifg = palette.muted, guibg = base_bg })

-- =============================================================================
-- BLINK.CMP
-- =============================================================================
hi("BlinkCmpMenu", { guifg = palette.fg, guibg = popup_bg })
hi("BlinkCmpMenuBorder", { guifg = palette.muted, guibg = base_bg })
link("BlinkCmpMenuSelection", "PmenuSel")

hi("BlinkCmpDoc", { guifg = palette.fg, guibg = popup_bg })
hi("BlinkCmpDocBorder", { guifg = palette.muted, guibg = base_bg })
hi("BlinkCmpDocSeparator", { guifg = palette.muted, guibg = base_bg })
hi("BlinkCmpDocCursorLine", { guibg = elevated_bg })

hi("BlinkCmpSignatureHelp", { guifg = palette.fg, guibg = popup_bg })
hi("BlinkCmpSignatureHelpBorder", { guifg = palette.muted, guibg = base_bg })
link("BlinkCmpSignatureHelpActiveParameter", "Visual")

hi("BlinkCmpLabel", { guifg = palette.fg })
hi("BlinkCmpLabelMatch", { guifg = palette.fg, gui = "bold" })
hi("BlinkCmpLabelDeprecated", { guifg = palette.muted, gui = "strikethrough" })
hi("BlinkCmpLabelDescription", { guifg = palette.muted })
hi("BlinkCmpLabelDetail", { guifg = palette.muted })
hi("BlinkCmpKind", { guifg = palette.muted })
hi("BlinkCmpSource", { guifg = palette.muted })

hi("BlinkCmpScrollBarThumb", { guibg = muted_bg })
hi("BlinkCmpScrollBarGutter", { guibg = elevated_bg })

for _, kind in ipairs {
    "Text", "Method", "Function", "Constructor", "Field", "Variable",
    "Class", "Interface", "Module", "Property", "Unit", "Value", "Enum",
    "Keyword", "Snippet", "Color", "File", "Reference", "Folder",
    "EnumMember", "Constant", "Struct", "Event", "Operator", "TypeParameter",
} do
    link("BlinkCmpKind" .. kind, "BlinkCmpKind")
end
