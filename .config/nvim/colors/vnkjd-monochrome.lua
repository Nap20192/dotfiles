local function normalize_style(opts)
    local style = opts.style or opts.gui
    if type(style) == "string" and style ~= "NONE" then
        for item in string.gmatch(style, "[^,]+") do
            opts[item] = true
        end
    elseif type(style) == "table" then
        for _, item in ipairs(style) do
            opts[item] = true
        end
    end

    opts.style = nil
    opts.gui = nil
    return opts
end

local function apply(groups)
    for group, opts in pairs(groups) do
        if opts.link then
            vim.api.nvim_set_hl(0, group, { link = opts.link })
        else
            vim.api.nvim_set_hl(0, group, normalize_style(opts))
        end
    end
end

local palettes = {
    dark = {
        bg = "#000000",
        fg = "#dadada",
        elevated = "#1c1c1c",
        subtle = "#303030",
        muted = "#707070",
        comment = "#9a9a9a",
        noise = "#191919",
        search = "#00afff",
        visual = "#ffaf00",
        syntax_yellow = "#ffaf00",
        cursorline = "#2a1f00",
        add = "#416241",
        add_text = "#93ad6d",
        remove = "#722529",
        remove_text = "#d77a61",
        change = "#2a2a2a",
        change_text = "#5f7a4f",
        error = "#ff005f",
        cursor = "#ffaf00",
        cursor_text = "#000000",
        selection_fg = "#000000",
        lsp_hint = "#78bdb7",
        syntax_blue = "#6c8db5",
        syntax_blue_bright = "#8eabd1",
        syntax_cyan = "#5d9690",
        syntax_magenta = "#9a7bb8",
    },
    light = {
        bg = "#fff7df",
        fg = "#000000",
        elevated = "#f3eadb",
        subtle = "#e4d9c0",
        muted = "#626262",
        comment = "#3f3f3f",
        noise = "#9b907f",
        search = "#00afff",
        visual = "#ffaf00",
        syntax_yellow = "#000000",
        cursorline = "#ffe8a3",
        add = "#8dda9e",
        add_text = "#5f7a4f",
        remove = "#da8d8d",
        remove_text = "#cf745d",
        change = "#e4d9c0",
        change_text = "#5f7a4f",
        error = "#ff005f",
        cursor = "#ffaf00",
        cursor_text = "#000000",
        selection_fg = "#000000",
        lsp_hint = "#2d716c",
        syntax_blue = "#5e7fa8",
        syntax_blue_bright = "#7d98bd",
        syntax_cyan = "#4f8b85",
        syntax_magenta = "#866ea8",
    },
}

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

local palette = assert(palettes[mode], "unknown nvim theme mode: " .. tostring(mode))
local transparent_terminal = vim.env.KITTY_WINDOW_ID ~= nil
    or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
    or vim.env.TERM == "xterm-kitty"
    or vim.env.TERM == "xterm-ghostty"
local transparent = vim.g.vnkjd_transparent_background ~= false
    and transparent_terminal

local C = {
    none = "NONE",
    pink = palette.syntax_magenta,
    mauve = palette.syntax_magenta,
    red = palette.error,
    peach = palette.syntax_yellow,
    yellow = palette.syntax_yellow,
    green = palette.add_text,
    teal = palette.syntax_cyan,
    sky = palette.search,
    blue = palette.syntax_blue,
    lavender = palette.syntax_blue_bright,
    text = palette.fg,
    overlay2 = palette.muted,
    overlay1 = palette.muted,
    overlay0 = palette.noise,
    surface2 = palette.noise,
    surface1 = palette.subtle,
    surface0 = palette.elevated,
    base = palette.bg,
    mantle = palette.elevated,
}

local base_bg = transparent and C.none or C.base
local mantle_bg = transparent and C.none or C.mantle
local surface_bg = transparent and C.none or C.surface0
local cursorline_bg = palette.cursorline
local select_fg = palette.selection_fg

vim.o.termguicolors = true
vim.g.colors_name = "vnkjd-monochrome"
vim.o.background = mode

-- Structure follows catppuccin/nvim group organization, with this repo's colors.
-- Upstream reference: https://github.com/catppuccin/nvim

apply({
    -- Editor
    Normal = { fg = C.text, bg = base_bg },
    NormalNC = { fg = C.text, bg = base_bg },
    NormalFloat = { fg = C.text, bg = mantle_bg },
    FloatBorder = { fg = C.overlay2, bg = mantle_bg },
    FloatTitle = { fg = C.text, bg = surface_bg, bold = true },
    ColorColumn = { bg = C.surface0 },
    Conceal = { fg = C.overlay1 },
    Cursor = { fg = palette.cursor_text, bg = palette.cursor },
    lCursor = { fg = palette.cursor_text, bg = palette.cursor },
    CursorIM = { fg = palette.cursor_text, bg = palette.cursor },
    CursorLine = { bg = cursorline_bg },
    CursorColumn = { bg = C.surface0 },
    CursorLineNr = { fg = C.text, bg = cursorline_bg, bold = true },
    Directory = { fg = C.blue, bold = true },
    EndOfBuffer = { fg = C.surface2 },
    Folded = { fg = C.overlay1, bg = base_bg },
    FoldColumn = { fg = C.overlay1, bg = base_bg },
    SignColumn = { fg = C.overlay1, bg = base_bg },
    LineNr = { fg = C.overlay1 },
    MatchParen = { fg = C.peach, bold = true, underline = true },
    ModeMsg = { fg = C.text, bold = true },
    MoreMsg = { fg = C.blue },
    NonText = { fg = C.surface2 },
    Question = { fg = C.blue },
    QuickFixLine = { fg = C.peach, reverse = true },
    Search = { fg = select_fg, bg = palette.search, bold = true },
    IncSearch = { fg = select_fg, bg = palette.visual, bold = true },
    CurSearch = { fg = select_fg, bg = palette.visual, bold = true },
    SpecialKey = { fg = C.surface2, bold = true },
    SpellBad = { sp = C.red, undercurl = true },
    SpellCap = { sp = C.yellow, undercurl = true },
    SpellLocal = { sp = C.blue, undercurl = true },
    SpellRare = { sp = C.green, undercurl = true },
    StatusLine = { fg = C.text, bg = base_bg, bold = true },
    StatusLineNC = { fg = C.overlay1, bg = base_bg },
    TabLine = { fg = C.overlay1, bg = base_bg },
    TabLineFill = { fg = C.overlay1, bg = base_bg },
    TabLineSel = { bg = surface_bg, bold = true, reverse = true },
    TermCursor = { fg = palette.cursor_text, bg = palette.cursor },
    TermCursorNC = { fg = C.base, bg = C.overlay2 },
    Title = { fg = C.blue, bold = true },
    Visual = { fg = select_fg, bg = palette.visual },
    VisualNOS = { fg = select_fg, bg = palette.visual },
    WarningMsg = { fg = C.yellow },
    Whitespace = { fg = C.surface2 },
    WildMenu = { fg = select_fg, bg = palette.search, bold = true },
    WinSeparator = { fg = C.overlay1, bg = base_bg },

    -- Popup menu
    Pmenu = { fg = C.text, bg = mantle_bg },
    PmenuSel = { fg = select_fg, bg = C.text, bold = true },
    PmenuMatch = { fg = C.text, bold = true },
    PmenuMatchSel = { fg = select_fg, bg = C.text, bold = true },
    PmenuExtra = { fg = C.overlay1, bg = mantle_bg },
    PmenuExtraSel = { fg = select_fg, bg = C.text, bold = true },
    PmenuKind = { fg = C.text, bg = mantle_bg, bold = true },
    PmenuKindSel = { fg = select_fg, bg = C.text, bold = true },
    PmenuSbar = { bg = C.surface0 },
    PmenuThumb = { bg = C.surface2 },
})

apply({
    -- Syntax
    Comment = { fg = palette.comment },
    SpecialComment = { link = "Special" },
    Constant = { fg = C.yellow, italic = true },
    String = { fg = C.green, italic = true },
    Character = { fg = C.teal, italic = true },
    Number = { fg = C.peach, italic = true },
    Float = { link = "Number" },
    Boolean = { fg = C.peach, italic = true },
    Identifier = { fg = C.text },
    Function = { fg = C.blue, bold = true },
    FunctionDeclaration = { link = "Function" },
    BuiltinFunction = { link = "Function" },
    Statement = { fg = C.mauve, bold = true },
    Conditional = { link = "Statement" },
    Repeat = { link = "Statement" },
    Label = { link = "Statement" },
    Operator = { link = "Statement" },
    Keyword = { fg = C.mauve, bold = true },
    Exception = { link = "Statement" },
    PreProc = { fg = C.pink, bold = true },
    Include = { link = "PreProc" },
    Define = { link = "PreProc" },
    Macro = { link = "PreProc" },
    PreCondit = { link = "PreProc" },
    Type = { fg = C.yellow, underline = true },
    BuiltinType = { link = "Type" },
    StorageClass = { link = "Type" },
    Structure = { link = "Type" },
    Typedef = { link = "Type" },
    Special = { fg = C.pink },
    SpecialChar = { link = "Special" },
    Tag = { fg = C.lavender, bold = true },
    Delimiter = { fg = C.overlay2 },
    Debug = { link = "Special" },
    Underlined = { fg = C.blue, underline = true },
    Ignore = { fg = C.overlay0 },
    Error = { fg = C.red, bold = true },
    ErrorMsg = { fg = C.red, bold = true },
    Todo = { fg = select_fg, bg = C.peach, bold = true },
    Added = { fg = C.green },
    Changed = { fg = C.blue },
    Removed = { fg = C.red },
    diffAdded = { link = "Added" },
    diffRemoved = { link = "Removed" },
    diffChanged = { link = "Changed" },
    DiffAdd = { bg = palette.add },
    DiffDelete = { bg = palette.remove },
    DiffChange = { bg = palette.change },
    DiffText = { bg = palette.change_text },
})

apply({
    -- Treesitter
    ["@comment"] = { link = "Comment" },
    ["@comment.documentation"] = { link = "Comment" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { link = "Constant" },
    ["@constant.macro"] = { link = "Constant" },
    ["@string"] = { link = "String" },
    ["@string.documentation"] = { link = "Comment" },
    ["@string.regexp"] = { link = "Special" },
    ["@string.escape"] = { link = "SpecialChar" },
    ["@string.special"] = { link = "String" },
    ["@string.special.symbol"] = { link = "String" },
    ["@string.special.url"] = { link = "Underlined" },
    ["@string.special.path"] = { link = "String" },
    ["@character"] = { link = "Character" },
    ["@character.special"] = { link = "SpecialChar" },
    ["@number"] = { link = "Number" },
    ["@number.float"] = { link = "Float" },
    ["@boolean"] = { link = "Boolean" },
    ["@function"] = { link = "Function" },
    ["@function.call"] = { link = "Function" },
    ["@function.builtin"] = { link = "BuiltinFunction" },
    ["@function.method"] = { link = "Function" },
    ["@function.method.call"] = { link = "Function" },
    ["@function.definition"] = { link = "FunctionDeclaration" },
    ["@function.method.definition"] = { link = "FunctionDeclaration" },
    ["@method"] = { link = "Function" },
    ["@method.call"] = { link = "Function" },
    ["@constructor"] = { link = "BuiltinFunction" },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.return"] = { link = "Keyword" },
    ["@keyword.function"] = { link = "Keyword" },
    ["@keyword.operator"] = { link = "Keyword" },
    ["@keyword.import"] = { link = "Include" },
    ["@keyword.type"] = { link = "Keyword" },
    ["@keyword.modifier"] = { link = "Keyword" },
    ["@keyword.repeat"] = { link = "Repeat" },
    ["@keyword.conditional"] = { link = "Conditional" },
    ["@keyword.conditional.ternary"] = { link = "Conditional" },
    ["@keyword.exception"] = { link = "Exception" },
    ["@keyword.coroutine"] = { link = "Keyword" },
    ["@keyword.debug"] = { link = "Debug" },
    ["@keyword.directive"] = { link = "PreProc" },
    ["@keyword.directive.define"] = { link = "Define" },
    ["@variable"] = { link = "Identifier" },
    ["@variable.builtin"] = { link = "BuiltinFunction" },
    ["@variable.parameter"] = { fg = C.text },
    ["@variable.member"] = { fg = C.text },
    ["@parameter"] = { fg = C.text },
    ["@field"] = { fg = C.text },
    ["@property"] = { fg = C.text },
    ["@module"] = { link = "Identifier" },
    ["@module.builtin"] = { link = "BuiltinFunction" },
    ["@namespace"] = { link = "Identifier" },
    ["@label"] = { link = "Label" },
    ["@attribute"] = { link = "PreProc" },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { link = "BuiltinType" },
    ["@type.definition"] = { link = "Type" },
    ["@type.qualifier"] = { link = "Keyword" },
    ["@operator"] = { link = "Operator" },
    ["@punctuation.delimiter"] = { link = "Delimiter" },
    ["@punctuation.bracket"] = { link = "Delimiter" },
    ["@punctuation.special"] = { link = "Special" },
    ["@tag"] = { link = "Tag" },
    ["@tag.attribute"] = { link = "Type" },
    ["@diff.plus"] = { link = "DiffAdd" },
    ["@diff.minus"] = { link = "DiffDelete" },
    ["@diff.delta"] = { link = "DiffChange" },
})

apply({
    -- LSP semantic tokens and diagnostics
    ["@lsp.type.function"] = { link = "Function" },
    ["@lsp.type.method"] = { link = "Function" },
    ["@lsp.type.function.go"] = { link = "Function" },
    ["@lsp.type.method.go"] = { link = "Function" },
    ["@lsp.type.function.defaultLibrary"] = { link = "BuiltinFunction" },
    ["@lsp.type.method.defaultLibrary"] = { link = "BuiltinFunction" },
    ["@lsp.typemod.function.defaultLibrary"] = { link = "BuiltinFunction" },
    ["@lsp.typemod.method.defaultLibrary"] = { link = "BuiltinFunction" },
    ["@lsp.typemod.function.defaultLibrary.go"] = { link = "BuiltinFunction" },
    ["@lsp.typemod.method.defaultLibrary.go"] = { link = "BuiltinFunction" },
    ["@lsp.typemod.function.declaration.go"] = { link = "FunctionDeclaration" },
    ["@lsp.typemod.method.declaration.go"] = { link = "FunctionDeclaration" },
    ["@lsp.typemod.function.definition.go"] = { link = "FunctionDeclaration" },
    ["@lsp.typemod.method.definition.go"] = { link = "FunctionDeclaration" },
    ["@lsp.type.macro"] = { link = "BuiltinFunction" },
    ["@lsp.type.decorator"] = { link = "BuiltinFunction" },
    ["@lsp.type.type"] = { link = "Type" },
    ["@lsp.type.class"] = { link = "Type" },
    ["@lsp.type.interface"] = { link = "Type" },
    ["@lsp.type.struct"] = { link = "Type" },
    ["@lsp.type.enum"] = { link = "Type" },
    ["@lsp.type.typeParameter"] = { link = "BuiltinType" },
    ["@lsp.type.parameter"] = { link = "@variable.parameter" },
    ["@lsp.type.variable"] = { link = "Identifier" },
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.member"] = { link = "@variable.member" },
    ["@lsp.type.enumMember"] = { link = "Constant" },
    ["@lsp.type.namespace"] = { link = "Identifier" },
    ["@lsp.type.keyword"] = { link = "Keyword" },
    ["@lsp.type.operator"] = { link = "Operator" },

    DiagnosticError = { fg = C.red, bold = true },
    DiagnosticWarn = { fg = C.yellow },
    DiagnosticInfo = { fg = C.blue },
    DiagnosticHint = { fg = palette.lsp_hint },
    DiagnosticOk = { fg = C.green },
    DiagnosticVirtualTextError = { fg = C.red },
    DiagnosticVirtualTextWarn = { fg = C.yellow },
    DiagnosticVirtualTextInfo = { fg = C.blue },
    DiagnosticVirtualTextHint = { fg = palette.lsp_hint },
    DiagnosticVirtualTextOk = { fg = C.green },
    DiagnosticUnderlineError = { sp = C.red, undercurl = true },
    DiagnosticUnderlineWarn = { sp = C.yellow, undercurl = true },
    DiagnosticUnderlineInfo = { sp = C.blue, undercurl = true },
    DiagnosticUnderlineHint = { sp = palette.lsp_hint, undercurl = true },
    DiagnosticUnderlineOk = { sp = C.green, undercurl = true },
    DiagnosticFloatingError = { link = "DiagnosticError" },
    DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
    DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
    DiagnosticFloatingHint = { link = "DiagnosticHint" },
    DiagnosticFloatingOk = { link = "DiagnosticOk" },
    DiagnosticSignError = { link = "DiagnosticError" },
    DiagnosticSignWarn = { link = "DiagnosticWarn" },
    DiagnosticSignInfo = { link = "DiagnosticInfo" },
    DiagnosticSignHint = { link = "DiagnosticHint" },
    DiagnosticSignOk = { link = "DiagnosticOk" },
    LspInlayHint = { fg = palette.lsp_hint, italic = true },
})

apply({
    -- Plugin integrations
    OilDir = { fg = C.blue, bold = true },

    fugitiveStagedHeading = { link = "Include" },
    fugitiveUnstagedHeading = { link = "Macro" },
    fugitiveUntrackedHeading = { link = "PreCondit" },
    fugitiveStagedModifier = { link = "Typedef" },
    fugitiveUnstagedModifier = { link = "Structure" },
    fugitiveUntrackedModifier = { link = "StorageClass" },
    fugitiveHeader = { link = "Label" },
    fugitiveHelpHeader = { link = "fugitiveHeader" },
    fugitiveHelpTag = { link = "Tag" },
    fugitiveHash = { link = "Identifier" },
    fugitiveSymbolicRef = { link = "Function" },
    fugitiveCount = { link = "Number" },
    fugitiveInstruction = { link = "Type" },
    fugitiveStop = { link = "Function" },

    FzfLuaNormal = { fg = C.text, bg = mantle_bg },
    FzfLuaBorder = { fg = C.overlay2, bg = mantle_bg },
    FzfLuaTitle = { fg = C.text, bg = surface_bg, bold = true },
    FzfLuaTitleFlags = { fg = C.text, bg = C.surface1 },
    FzfLuaBackdrop = { fg = C.overlay1, bg = base_bg },
    FzfLuaPreviewNormal = { fg = C.text, bg = surface_bg },
    FzfLuaPreviewBorder = { fg = C.overlay2, bg = surface_bg },
    FzfLuaPreviewTitle = { fg = C.text, bg = surface_bg, bold = true },
    FzfLuaCursor = { fg = palette.cursor_text, bg = palette.cursor },
    FzfLuaCursorLine = { bg = C.surface0 },
    FzfLuaCursorLineNr = { fg = C.text, bg = C.surface0 },
    FzfLuaSearch = { fg = select_fg, bg = palette.visual, bold = true },
    FzfLuaScrollBorderEmpty = { fg = C.overlay1, bg = base_bg },
    FzfLuaScrollBorderFull = { fg = C.overlay1, bg = base_bg },
    FzfLuaScrollFloatEmpty = { bg = C.surface0 },
    FzfLuaScrollFloatFull = { bg = C.surface2 },
    FzfLuaHelpNormal = { fg = C.text, bg = base_bg },
    FzfLuaHelpBorder = { fg = C.overlay1, bg = base_bg },
    FzfLuaHeaderBind = { fg = C.text },
    FzfLuaHeaderText = { fg = C.text },
    FzfLuaPathColNr = { fg = C.sky },
    FzfLuaPathLineNr = { fg = C.green },
    FzfLuaBufName = { fg = C.text },
    FzfLuaBufId = { fg = C.overlay1 },
    FzfLuaBufNr = { fg = C.text },
    FzfLuaBufLineNr = { fg = C.overlay1 },
    FzfLuaBufFlagCur = { fg = C.text },
    FzfLuaBufFlagAlt = { fg = C.sky },
    FzfLuaTabTitle = { fg = C.sky },
    FzfLuaTabMarker = { fg = C.text },
    FzfLuaDirIcon = { fg = C.blue },
    FzfLuaDirPart = { fg = C.overlay1 },
    FzfLuaFilePart = { fg = C.text },
    FzfLuaLivePrompt = { fg = C.text },
    FzfLuaLiveSym = { fg = C.sky },
    FzfLuaCmdEx = { fg = C.text },
    FzfLuaCmdBuf = { fg = C.green },
    FzfLuaCmdGlobal = { fg = C.text },
    FzfLuaFzfNormal = { fg = C.text, bg = mantle_bg },
    FzfLuaFzfCursorLine = { fg = C.text, bg = C.surface0 },
    FzfLuaFzfMatch = { fg = C.sky, bold = true },
    FzfLuaFzfBorder = { fg = C.overlay1, bg = base_bg },
    FzfLuaFzfScrollbar = { fg = C.overlay1, bg = base_bg },

    BlinkCmpMenu = { fg = C.text, bg = mantle_bg },
    BlinkCmpMenuBorder = { fg = C.overlay2, bg = base_bg },
    BlinkCmpMenuSelection = { fg = select_fg, bg = palette.visual, bold = true },
    BlinkCmpDoc = { fg = C.text, bg = mantle_bg },
    BlinkCmpDocBorder = { fg = C.overlay2, bg = base_bg },
    BlinkCmpDocSeparator = { fg = C.overlay2, bg = base_bg },
    BlinkCmpDocCursorLine = { bg = surface_bg },
    BlinkCmpSignatureHelp = { fg = C.text, bg = mantle_bg },
    BlinkCmpSignatureHelpBorder = { fg = C.overlay2, bg = base_bg },
    BlinkCmpSignatureHelpActiveParameter = { link = "Visual" },
    BlinkCmpLabel = { fg = C.text },
    BlinkCmpLabelMatch = { fg = C.text, bold = true },
    BlinkCmpLabelDeprecated = { fg = C.overlay1, strikethrough = true },
    BlinkCmpLabelDescription = { fg = C.overlay1 },
    BlinkCmpLabelDetail = { fg = C.overlay1 },
    BlinkCmpKind = { fg = C.overlay1 },
    BlinkCmpSource = { fg = C.overlay1 },
    BlinkCmpScrollBarThumb = { bg = C.surface2 },
    BlinkCmpScrollBarGutter = { bg = surface_bg },

    BlinkPairsOrange = { fg = C.peach, bold = true, nocombine = true },
    BlinkPairsPurple = { fg = C.mauve, bold = true, nocombine = true },
    BlinkPairsBlue = { fg = C.blue, bold = true, nocombine = true },
    BlinkPairsUnmatched = { fg = C.red, bold = true, underline = true, nocombine = true },
    BlinkPairsMatchParen = { link = "MatchParen" },

    BlinkIndent = { fg = C.surface1 },
    BlinkIndentOrange = { fg = C.peach },
    BlinkIndentViolet = { fg = C.mauve },
    BlinkIndentBlue = { fg = C.blue },
})

for _, kind in ipairs({
    "Text", "Method", "Function", "Constructor", "Field", "Variable",
    "Class", "Interface", "Module", "Property", "Unit", "Value", "Enum",
    "Keyword", "Snippet", "Color", "File", "Reference", "Folder",
    "EnumMember", "Constant", "Struct", "Event", "Operator", "TypeParameter",
}) do
    vim.api.nvim_set_hl(0, "BlinkCmpKind" .. kind, { link = "BlinkCmpKind" })
end
