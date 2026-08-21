# Neovim config — архитектура

Справочник по устройству конфига: что откуда грузится, где что настроено, как добавлять новое.
Клавиши — в [HINTS.md](./HINTS.md).

---

## Содержание

1. [Требования](#требования)
2. [Расположение и stow](#расположение-и-stow)
3. [Порядок загрузки](#порядок-загрузки)
4. [Менеджер плагинов](#менеджер-плагинов)
5. [Инвентарь плагинов](#инвентарь-плагинов)
6. [LSP](#lsp)
7. [Форматирование](#форматирование)
8. [Автодополнение и сниппеты](#автодополнение-и-сниппеты)
9. [Treesitter](#treesitter)
10. [Тема и статусбар](#тема-и-статусбар)
11. [Отладка (DAP)](#отладка-dap)
12. [Файловые менеджеры](#файловые-менеджеры)
13. [Claude Code](#claude-code)
14. [Утилитные модули](#утилитные-модули)
15. [Что приходит из ~/.vimrc](#что-приходит-из-vimrc)
16. [Рецепты](#рецепты)
17. [Health](#health)
18. [Известные расхождения и мёртвый код](#известные-расхождения-и-мёртвый-код)

---

## Требования

| Что | Зачем |
|---|---|
| **Neovim 0.13.0-dev** | конфиг построен на `vim.pack` — встроенном менеджере плагинов, его нет в 0.11/0.12 |
| `git` | `vim.pack` клонирует плагины |
| `tree-sitter` CLI | **обязателен**: без него парсеры не собираются и подсветка молча падает на regex-движок. Ставится через Mason (`tree-sitter-cli` в `ensure_installed`) или `npm i -g tree-sitter-cli` / `pacman -S tree-sitter-cli` |
| `claude` | Claude Code CLI для claudecode.nvim |
| `tmux` или `kitty` | внешний терминал для Claude Code |
| `glow` | `:RenderMarkdown` |
| `pass` | `lua/vnkjd/functions/pass.lua` |
| `wl-copy` / `xclip` / `xsel` / `pbcopy` | системный буфер; без них — OSC52 |
| `rustc` + `cargo` | blink.pairs и blink.cmp собирают нативные биндинги |

Остальной инструментарий (LSP-серверы, форматтеры, линтеры, дебагеры) ставит Mason —
см. [LSP](#lsp).

---

## Расположение и stow

```
~/dotfiles/.config/nvim/   →   ~/.config/nvim/
```

Репозиторий использует **плоский layout**: `~/dotfiles` — это единственный stow-пакет,
`stow .` из корня раскладывает `.config/`, `.zshrc`, `.tmux.conf` и прочее в `~`.

> Это расходится с `~/CLAUDE.md`, который описывает схему «пакет на инструмент»
> (`dotfiles/nvim/.config/nvim/`). Фактическая структура — плоская.

Плагины ставятся вне репозитория: `~/.local/share/nvim/site/pack/core/opt/`.

---

## Порядок загрузки

```
init.lua
├── require "vnkjd"          → lua/vnkjd/init.lua
│   ├── vim.g.mapleader = " ", maplocalleader = ","      ← до плагинов, иначе бинды поедут
│   ├── require "vnkjd.pack" → lua/vnkjd/pack.lua        ← vim.pack.add по всем группам
│   ├── packadd nvim.difftool, packadd nvim.undotree     ← встроенные пакеты Neovim 0.13
│   ├── source ~/.vimrc                                  ← общий слой vim/nvim
│   ├── глобальные опции: completeopt, spelllang, winborder, diagnostic
│   └── глобальные бинды: <leader>d, <leader>cp/cP, <leader>?, gx, <C-S-w>, :RenderMarkdown
└── require "vnkjd.hidden"   → lua/vnkjd/hidden.lua
    └── машинно-зависимое: clipboard/OSC52, wrap+breakindent, netrw, jk, ;

затем автоматически:
ftdetect/filetype.vim        ← Go-шные filetype (tmpl, gomod, gosum, gowork, asm)
after/plugin/*.lua           ← в алфавитном порядке, по файлу на плагин
```

**Порядок в `after/plugin/` — алфавитный, и он решает конфликты биндов.**
Например `fzf.lua` вешает `<A-h>/<A-l>` на переключение вкладок, а `mini-tabline.lua`
грузится позже и перебивает те же клавиши (`<M-h>` и `<A-h>` — это один и тот же ключ)
на переключение буферов. Побеждает mini-tabline.

`lua/vnkjd/hidden.lua` задуман как машинно-локальный файл вне VCS, но сейчас закоммичен.

---

## Менеджер плагинов

`lua/vnkjd/pack.lua`. Никакого lazy.nvim — только встроенный `vim.pack`.

```lua
local gh = function(x) return "https://github.com/" .. x end
```

Плюс хелпер для своих плагинов:

```lua
local function vnkjd(name)   -- ~/Projects/vnkjd/<name> если есть локально, иначе GitHub
```

Спеки разложены по группам в таблице `M.specs` (`core`, `dap`, `git_tools`,
`claudecode`, …), в конце файла цикл идёт по списку имён групп и вызывает
`vim.pack.add(specs)`. Цикл защищён `if specs then` — поэтому список групп и
`M.specs` могут расходиться без поломки загрузки.

Пиннинг версий — через поле `version`:

```lua
{ src = gh("ThePrimeagen/harpoon"), version = "harpoon2" },
{ src = gh("nvim-neo-tree/neo-tree.nvim"), version = vim.version.range("3") },
```

`nvim-pack-lock.json` — лок-файл, `vim.pack` обновляет его сам при установке/апдейте.
Коммитить вместе с изменениями `pack.lua`.

Полезные команды: `:h vim.pack`, обновление — `vim.pack.update()`.

---

## Инвентарь плагинов

| Группа | Плагины | Где настроено |
|---|---|---|
| `core` — цвета | deepwhite.nvim, koda.nvim, nvim-colorizer.lua, auto-dark-mode.nvim | `after/plugin/theme.lua` |
| `core` — навигация | vim-tmux-navigator, harpoon (v2), mini.files, neo-tree.nvim | `harpoon.lua`, `mini-files.lua`, `neo-tree.lua` |
| `core` — UI | nvim-web-devicons, lualine.nvim, mini.tabline, which-key.nvim, fff.nvim | `lualine.lua`, `mini-tabline.lua`, `fff.lua` |
| `core` — сниппеты | LuaSnip, friendly-snippets | `completions.lua` |
| `core` — completion | blink.cmp, blink.lib, blink.pairs, blink.indent | `completions.lua`, `pairs.lua` |
| `core` — LSP | nvim-lspconfig, vim-go, conform.nvim, mason.nvim, mason-tool-installer, mason-lspconfig | `nvim-lspconfig.lua`, `mason.lua`, `conform.lua` |
| `core` — treesitter | nvim-treesitter, -textobjects (branch `main`), -context | `nvim-treesitter.lua` |
| `core` — утилиты | plenary.nvim, nui.nvim | — (зависимости) |
| `core` — текст | vim-abolish | — (дефолты) |
| `fzf_lua` | fzf-lua | `fzf.lua` |
| `dap` | nvim-dap, -virtual-text, -ui, nvim-nio | `nvim-dap.lua` — **lazy**, `load = false`, packadd on first debug keymap |
| `dap_go` / `dap_python` | nvim-dap-go, nvim-dap-python | `nvim-dap.lua` — **lazy**, see above |
| `jdtls` | nvim-jdtls | — (только учитывается в lualine) |
| `dadbod` | vim-dadbod, -completion, -ui | `vim-dadbod.lua` |
| `git_tools` | vim-fugitive, vim-rhubarb, fugitive-gitlab, vim-fubitive, vim-dispatch, diffview.nvim | `vim-fugitive.lua`, `diffview.lua`, `lazygit.lua`, Go tests/lint dispatch through `after/ftplugin/go.lua` |
| `claudecode` | claudecode.nvim | `claudecode.lua` |
| `leetcode` | leetcode.nvim | `leetcode.lua` — **lazy**, `load = false`, packadd on `<leader>lc` |
| `themery` | themery.nvim | `themery.lua` |
| `alabaster` | alabaster.nvim | — (тема для themery) |

Встроенные пакеты Neovim, включённые через `packadd`: `nvim.difftool` (`:DiffTool`),
`nvim.undotree` (`:Undotree`).

---

## LSP

Три слоя:

1. **`after/plugin/mason.lua`** — `mason.nvim` (`PATH = "append"`) плюс
   `mason-tool-installer` в `vim.defer_fn`, чтобы не тормозить старт. Список
   `ensure_installed` — 30 инструментов: LSP-серверы (`gopls`, `basedpyright`,
   `lua-language-server`, `rust-analyzer`, `typescript-language-server`,
   `bash-language-server`, `kotlin-lsp`, `tinymist`), форматтеры (`gofumpt`, `goimports`,
   `golines`, `stylua`, `prettier`, `isort`, `autopep8`, `ruff`, `mdsf`, `sqlfluff`, `buf`),
   линтеры (`golangci-lint`, `eslint_d`, `pylint`, `yamllint`, `jsonlint`, `markdownlint`,
   `protolint`, `stylelint`) и дебагеры (`delve`, `debugpy`, `gotestsum`).
   `luacheck` намеренно ставится мимо Mason — его LuaRocks-пакет не резолвится под Lua 5.5.
2. **`after/plugin/nvim-lspconfig.lua`** — `mason-lspconfig.setup()` плюс настройка
   серверов новым API `vim.lsp.config(name, opts)` + `vim.lsp.enable(name)`.
3. Дефолтные конфиги приезжают из `nvim-lspconfig`.

Настроены явно:

| Сервер | Особенности |
|---|---|
| `gopls` | `analyses.unusedparams`/`shadow`, полный набор inlay hints (включая `compositeLiteralFields`), `staticcheck = true`, `gofumpt = true` |
| `lua_ls` | runtime LuaJIT, глобалы `vim`/`require`, библиотека = весь runtimepath, телеметрия выключена |
| `rust_analyzer` | `check.command = "clippy"`, `cargo.allFeatures`, proc-макросы, inlay hints включаются в `on_attach` |
| `basedpyright` | `typeCheckingMode = "standard"`, `diagnosticMode = "openFilesOnly"`, inlay hints в `on_attach` |
| `ruff` | линт + формат; `hoverProvider` выключен в `on_attach`, чтобы hover остался за basedpyright |

Диагностика: `vim.diagnostic.config({ virtual_text = true })` в `lua/vnkjd/init.lua`.

---

## Форматирование

`after/plugin/conform.lua`:

- `format_after_save` — форматирование **асинхронное, после** записи файла.
  Раньше стоял `format_on_save`, который работает синхронно в `BufWritePre` и вешает
  редактор на всё время работы форматтера (замер: stylua 1.3 с на холодную, 190 мс
  на тёплую, prettier 190 мс). Сейчас блокирующая часть `:w` — около 12 мс;
- `lsp_format = "fallback"` — если для filetype форматтер не задан, работает LSP;
- таймаут 1 с;
- `vim.o.formatexpr` завёрнут на conform, поэтому `gq` тоже идёт через него;
- команда `:Format` и бинд `<leader>fo`.

| Filetype | Форматтеры |
|---|---|
| lua | stylua |
| go | goimports → gofumpt |
| python | isort → ruff_format |
| js/jsx/ts/tsx/json/jsonc/css/scss/html/yaml | prettier |
| markdown | mdsf |
| proto | buf |
| sql | sqlfluff |

---

## Автодополнение и сниппеты

`after/plugin/completions.lua` — **blink.cmp**, не nvim-cmp и не встроенный
`vim.lsp.completion`:

- keymap preset `default`, `<CR>` — accept с fallback;
- signature help включён;
- документация всплывает автоматически через 500 мс;
- fuzzy: `prefer_rust` с префилдом бинарников;
- меню рисуется в две колонки: `kind_icon + label + label_description`, затем `kind`.

Сниппеты: LuaSnip + friendly-snippets (`lazy_load()` из vscode-формата).
`lua/vnkjd/snippets.lua` даёт function-node'ы с датами (`current_date`, `yesterday_date`,
`tomorrow_date`) — заготовка под свои сниппеты.

`after/plugin/pairs.lua` — **blink.pairs**: автопары + радужная подсветка скобок и
подсветка парной скобки. При первом запуске, если нативная библиотека не собрана,
конфиг блокируется на `pairs.build():pwait(60000)` — то есть первый старт nvim может
подвиснуть до минуты, это нормально.

---

## Treesitter

`after/plugin/nvim-treesitter.lua` (рабочие — первые 46 строк, остальное закомментировано):

```lua
require("nvim-treesitter").setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
if vim.fn.executable("tree-sitter") == 1 then
    require("nvim-treesitter").install(treesitter_languages)
else
    -- громкое предупреждение вместо тихой деградации
end
```

> **Важно.** Ветка `main` у nvim-treesitter собирает парсеры через `tree-sitter` CLI.
> Если CLI нет — `install()` пропускается, парсеры не появляются, а `vim.treesitter.start`
> в autocmd падает внутри `pcall` **молча**, и буфер незаметно переезжает на regex-подсветку.
> Именно так конфиг и жил: `parsers installed: 0`, при этом Go-файлы подсвечивались
> старым движком плюс тяжёлыми regex-паттернами vim-go. Поэтому ветка `else` теперь
> кричит через `vim.notify`.

Языки: go, gomod, gosum, lua, make, markdown, proto, python, query, ruby, sql,
javascript, typescript, tsx, typst, vim, yaml.

Подсветка не включается глобально — есть autocmd на `FileType` для перечисленных языков,
который зовёт `vim.treesitter.start(buf)` и ставит
`indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"`.

`nvim-treesitter-textobjects` и `nvim-treesitter-context` установлены, но **не настроены** —
весь их setup закомментирован.

---

## Тема и статусбар

- `colors/vnkjd-monochrome.lua` — своя монохромная тема (494 строки), это дефолт.
- `after/plugin/theme.lua` — ставит colorscheme, поднимает `nvim-colorizer` в
  `vim.schedule`, настраивает `auto-dark-mode` (обе темы — `vnkjd-monochrome`, то есть
  переключение light/dark сейчас ничего не меняет). Там же шим `vim.tbl_flatten`,
  удалённой из API Neovim, — нужен старым плагинам.
- `after/plugin/themery.lua` — `<leader>th`, live preview включён. Список тем
  собирается из runtimepath (`colors/*.lua|vim`) **лениво, при первом открытии
  пикера**: на старте этот скан стоил 14 мс (70 тем × 2 `nvim_get_runtime_file`
  по 70 путям rtp).
- `after/plugin/lualine.lua` — тема статусбара собирается вручную из палитры
  light/dark. Режим берётся из `$XDG_CACHE_HOME/vnkjd/theme` (файл с одним словом
  `light`/`dark`), иначе из `vim.o.background`. Фон делается прозрачным, если терминал
  kitty/ghostty (по `$KITTY_WINDOW_ID`, `$GHOSTTY_RESOURCES_DIR`, `$TERM`); отключается
  через `vim.g.vnkjd_transparent_background = false`. Иконки выключены, разделителей нет.
  Секции: `lsp_status` | `branch` | путь к файлу | filetype | progress | location.
  Для jdtls-буферов путь показывается коротким — у них синтетические URI.

---

## Отладка (DAP)

`after/plugin/nvim-dap.lua`: nvim-dap + dap-ui + virtual text; `dap-go` для Go,
`dap-python` поверх `uv` с `test_runner = "pytest"`.

`dap.listeners` открывают UI на `attach`/`launch` и закрывают на `event_terminated`/
`event_exited`, так что руками дёргать интерфейс обычно не нужно.

---

## Файловые менеджеры

Их четыре, и активны не все:

| Менеджер | Статус | Вход |
|---|---|---|
| **neo-tree** | основной | `<C-b>`, `<leader>nt/nr/nb/ng` |
| **mini.files** | вспомогательный | `<leader>m`, `<leader>M` |
| **netrw** | остался из `hidden.lua` | `<leader>e` |

neo-tree: справа, ширина 34, `close_if_last_window`, git-статус и диагностика в дереве,
скрытые файлы видны, `follow_current_file`, файловый вотчер через libuv.

mini.files: превью включено, `use_as_default_explorer = false` (поэтому `-` и `<leader>e`
за ним не закреплены).

---

## Claude Code

`after/plugin/claudecode.lua` — мост между Neovim и Claude Code CLI
([coder/claudecode.nvim](https://github.com/coder/claudecode.nvim)).

Как это устроено: плагин поднимает локальный WebSocket-сервер (MCP), кладёт порт в
`CLAUDE_CODE_SSE_PORT` и запускает `claude` с `ENABLE_IDE_INTEGRATION=true`. Дальше
Claude видит открытый файл и выделение, а свои правки шлёт обратно как диффы, которые
открываются обычным `diffthis` в вертикальном сплите.

**Провайдер терминала — `external`**: Claude живёт не внутри Neovim, а рядом.

```lua
local function external_terminal_cmd(cmd_string, env_table)
    if vim.env.TMUX then  -- панель tmux справа на 40%
    else                  -- отдельное окно kitty
```

Ветка tmux прокидывает каждую переменную явным `-e KEY=VAL`, потому что новая панель
наследует окружение tmux-**сервера**, а не вызывающего процесса. Ветке kitty этого не
надо — там обычный дочерний процесс с env от `jobstart`.

Ограничение провайдера `external`: плагин не управляет фокусом чужого окна, поэтому
`:ClaudeCodeFocus` ведёт себя как `:ClaudeCode` (старт/стоп), а «показать окно» — no-op.

Бинды на префиксе `<leader>k*` — см. HINTS.md.
Проверка связи: `:ClaudeCodeStatus` в Neovim, `/ide` в Claude.

---

## Утилитные модули

`lua/vnkjd/functions/` — библиотека хелперов:

| Модуль | Что делает | Подключён? |
|---|---|---|
| `links.lua` | находит URL под курсором/в выделении, нормализует (обрезает пунктуацию, балансирует скобки, `www.` → `https://`) и открывает | **да** — `gx`, `:OpenLink` |
| `gotests.lua` | генерирует таблицу тестов через `gotests`, находит имя функции по AST, открывает тест-файл и прыгает на `// TODO` | частично — только `health()` |
| `treesitter.lua` | `find_enclosing_node`, `get_node_field_text` — подъём по AST от курсора | как зависимость `gotests` |
| `core.lua` | путь к dotfiles из `$VNKJD_DOTFILES_DIR`, `find_first_present_file`, строковые хелперы | нет |
| `test.lua` | запуск тестов через `:Dispatch` в quickfix + запоминание последней команды | нет |
| `lint.lua` | то же для линтеров, с выбором compiler | нет |
| `toggle_test.lua` | переключение исходник ↔ тест по правилам (`gsub` или своя функция) | нет |
| `pass.lua` | читает секрет через CLI `pass` | нет |

Модули без пометки «да» — библиотеки без точки вызова: их должен был подключать
`ftplugin/`, но **каталога `ftplugin/` в репозитории нет**. Код рабочий, просто
не подключён.

`lua/vnkjd/health.lua` — `:checkhealth vnkjd`, сейчас проверяет только gotests.

---

## Что приходит из ~/.vimrc

`lua/vnkjd/init.lua` делает `source ~/.vimrc` — это общий слой для vim и nvim. Оттуда:

- `set exrc` — проектные `.vimrc` подхватываются (следи, что клонируешь);
- undo: `undodir=~/.vim/undodir`, `undofile`, при этом `noswapfile`/`nobackup`;
- отступы: `tabstop=softtabstop=shiftwidth=4`, `expandtab`;
- вид: `nu` + `relativenumber`, `cursorline`, `colorcolumn=80`, `signcolumn=yes`,
  `foldcolumn=1`, `scrolloff=999` (курсор всегда по центру);
- производительность: `synmaxcol=128`, `syntax sync minlines=256`;
- русская раскладка через `langmap` — нормальный режим работает на кириллице;
- `augroup CreateMissingDirs` — создаёт недостающие каталоги при `:w`;
- `autocmd VimEnter * :clearjumps`;
- `BufWritePre *.go` с `:GoImports` — **только для чистого vim** (`if !has('nvim')`);
  в Neovim форматирование Go делает conform. Раньше guard'а не было, и синхронный
  `:GoImports` добавлял 297 мс к каждому сохранению Go-файла;
- бинды vim-go: `<leader>r` GoRun, `<leader>b` GoBuild, `<leader>t` GoTest,
  `<leader>f` GoFmt, `<leader>gd` GoDef, `<leader>i` GoImport;
- навигация по quickfix/loclist-стеку: `]<C-q>`/`[<C-q>`, `]<C-l>`/`[<C-l>`;
- `gV` — переспособ выделить последний вставленный текст.

---

## Рецепты

**Добавить плагин.** В `lua/vnkjd/pack.lua` — в существующую группу или новой группой
(тогда её имя надо дописать в цикл внизу файла). Конфиг — новым файлом
`after/plugin/<имя>.lua`. Запустить nvim: `vim.pack` доставит плагин и обновит
`nvim-pack-lock.json`.

**Добавить LSP-сервер.** Имя пакета — в `ensure_installed` в `after/plugin/mason.lua`,
затем в `after/plugin/nvim-lspconfig.lua`:

```lua
vim.lsp.config("имя", { settings = { ... } })
vim.lsp.enable("имя")
```

**Добавить форматтер.** Пакет — в `ensure_installed` (mason.lua), маппинг — в
`formatters_by_ft` (`after/plugin/conform.lua`). Формат по сохранению включится сам.

**Добавить язык treesitter.** Строку в `treesitter_languages` в
`after/plugin/nvim-treesitter.lua` — она же используется и для установки парсера,
и как паттерн autocmd, включающего подсветку.

**Обновить плагины.** `:lua vim.pack.update()`, затем закоммитить
`nvim-pack-lock.json`.

---

## Health

```vim
:checkhealth vnkjd        " свои проверки (сейчас — gotests)
:checkhealth claudecode   " WebSocket-сервер, наличие claude CLI
:checkhealth lsp
:Mason                    " статус инструментов
```

---

## Известные расхождения и мёртвый код

Чтобы не спотыкаться. Ничего из этого не сломано — просто не работает то, что выглядит
рабочим.

**Закомментированный код:**

- `after/plugin/nvim-treesitter.lua:47-369` — старый API: text objects, swap параметров,
  движение по функциям, context, фолдинг. Живого кода в файле — первые 46 строк.

**Мёртвые файлы:**

- `lua/plugins/dankcolors.lua` — спека в формате lazy.nvim (`return { { "RRethy/base16-nvim", … } }`)
  в каталоге `lua/plugins/`. `vim.pack` такой формат не читает и этот каталог не сканирует,
  так что файл не грузится никем. Внутри — интеграция с matugen и fs-watcher на живую
  перезагрузку темы.
- `nvim.log` — лог-файл закоммичен в репозиторий.

**Установлено, но не настроено:** `which-key.nvim`, `blink.indent`,
`nvim-treesitter-textobjects`, `nvim-treesitter-context`, `nvim-jdtls`, `alabaster.nvim`,
`deepwhite.nvim`, `koda.nvim` (последние три доступны через `:Themery`).

**Каталога `ftplugin/` нет** — поэтому пять модулей из `lua/vnkjd/functions/` никем
не вызываются, а привычных биндов вида `<localleader>t*` (тесты) и `<localleader>b*`
(бенчмарки/сборка) не существует.

**Не все языки покрыты treesitter.** В `treesitter_languages` нет `json`, `jsonc`,
`toml`, `bash`, `rust`, `css`, `html`, `dockerfile`, `diff`, `gitcommit` — эти filetype
подсвечиваются regex-движком. Список правится в `after/plugin/nvim-treesitter.lua`.

**Конфликты биндов:**

| Клавиша | Кто побеждает | Кого перебивает |
|---|---|---|
| `<M-h>` / `<M-l>` | `mini-tabline.lua` → буферы | `fzf.lua` → `<A-h>`/`<A-l>`, вкладки. Это те же клавиши; переключения вкладок сейчас нет |
| `<leader>fo` | `nvim-lspconfig.lua` → `:Format` | `conform.lua` → `conform.format` (эффект тот же) |
| `<leader>f`, `<leader>t`, `<leader>b`, `<leader>r`, `<leader>i` | vim-go из `~/.vimrc` | не перебивают, но заставляют nvim ждать `timeoutlen` на префиксах `<leader>f*`, `<leader>t*` |
