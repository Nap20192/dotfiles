# Урок 5 — Remote, GitHub, PR (rhubarb + octo)

## Push / pull

```vim
:Git push                   " как в терминале, вывод в сплите
:Git push -u origin HEAD    " первая отправка ветки
:Git pull --rebase
:Git fetch
```

Статус ahead/behind виден в окне `Space gg` (заголовок) и в lualine.

## Ссылки на GitHub (rhubarb)

| Клавиши | Действие |
|---|---|
| `Space gy` | скопировать ссылку на текущую строку на GitHub |
| `Space gy` (visual) | ссылку на выделенные строки |
| `Space gY` | ссылку на весь файл |
| `:GBrowse` | открыть файл/объект в браузере |

Кидать коллеге ссылку на конкретную строку — `Space gy`, ссылка уже в
клипборде.

## Создать PR

```vim
:Git push -u origin HEAD
:!gh pr create --fill
```

## Ревью PR (octo)

| Команда | Действие |
|---|---|
| `:Octo pr list` | список PR (fzf-lua пикер) |
| `:Octo pr edit 42` | открыть PR: описание, треды, статусы |
| `:Octo review start` | начать ревью — дифф по файлам |
| `<leader>ca` | комментарий к строке (или к выделению) |
| `<leader>sa` | suggestion (предложить правку) |
| `]t` / `[t` | следующий/предыдущий тред |
| `:Octo review submit` | approve / request changes / comment |

Комментарии уходят в GitHub как обычное ревью. Чужой PR удобно тянуть в
worktree: `wt switch pr:123` — код живой, с LSP, а комментарии — через octo.

Ответить в треде: курсор на тред → `:Octo comment add`. Резолв —
`:Octo thread resolve`.

**Практика:** на любом своём PR: `:Octo pr list` → Enter → `:Octo review
start` → оставь комментарий `<leader>ca` → `:Octo review submit` → comment.
