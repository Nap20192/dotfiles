# Git в Neovim — серия уроков

Уроки под твой конфиг: fugitive, diffview, lazygit, octo. Кеймапы в тексте —
твои реальные (`<leader>` = пробел).

| # | Файл | Тема |
|---|------|------|
| 1 | `01-status-commit.md` | Статус, staging, коммиты (fugitive) |
| 2 | `02-diffs.md` | Диффы: diffview, сравнение ревизий |
| 3 | `03-history-blame.md` | История, blame, путешествия во времени |
| 4 | `04-branches-worktrees.md` | Ветки, merge, конфликты, worktree |
| 5 | `05-remote-github.md` | Push/pull, ссылки на GitHub, PR через octo |
| 6 | `06-lazygit.md` | Lazygit — когда быстрее в TUI |

## Как открыть урок в боковой панели

```vim
" открыть справа панелью шириной 80
:80vsplit .config/nvim/git-lessons/01-status-commit.md

" или командой-хелпером (см. ниже) — проще:
:GitLesson 1
```

Управление панелью:

| Команда / клавиши | Действие |
|---|---|
| `:GitLesson 2` | открыть урок 2 в правой панели (переиспользует окно) |
| `:GitLesson` | открыть этот индекс |
| `Ctrl+w q` или `:q` в панели | скрыть (закрыть) панель |
| `Ctrl+w h` / `Ctrl+w l` | прыгать между кодом и уроком (у тебя: `Ctrl+h/l`) |
| `Ctrl+w =` | выровнять ширину окон |
| `Ctrl+w >` / `Ctrl+w <` | шире / уже |
| `Ctrl+w o` | оставить только текущее окно |
| `zt` / `zz` | прокрутка: секцию к верху / к центру |

Читать удобно с `:set wrap linebreak` — `:GitLesson` включает это сам.
