# Урок 6 — Lazygit: когда быстрее в TUI

`Space gG` — lazygit во float-окне поверх nvim. Это не замена fugitive, а
ускоритель для операций, где TUI удобнее: интерактивный rebase, стэши,
черри-пики, разгребание веток.

Выход — `q` (возвращаешься ровно где был в nvim).

## Панели (цифры или стрелки)

| Панель | Что там |
|---|---|
| 1 Status | репо, remote |
| 2 Files | незакоммиченное; `space` — stage, `c` — commit, `d` — discard |
| 3 Branches | `space` — checkout, `n` — новая, `M` — merge в текущую, `r` — rebase |
| 4 Commits | история; тут главная сила ↓ |
| 5 Stash | `space` — apply, `g` — pop, `d` — drop |

## За что его держать

**Интерактивный rebase без боли** (панель Commits):
- `s` — squash в предыдущий
- `f` — fixup (squash без сообщения)
- `r` — reword сообщение
- `e` — edit (остановиться на коммите)
- `Ctrl+j` / `Ctrl+k` — двигать коммит вверх/вниз
- `d` — дропнуть коммит

Никакого `git rebase -i` с редактированием todo-файла — двигаешь коммиты
как строки в списке.

**Ещё быстрые вещи:**
- `Shift+A` в Files — amend в последний коммит
- `c` на коммите в Commits — checkout на него
- `Shift+C` на коммите — cherry-pick (copy) → `Shift+V` — paste в текущую ветку
- `Enter` на файле — stage по строкам (`space` на строке/куске)
- `z` — undo (reflog-based, спасает после неудачного rebase)

## Правило разделения труда

- посмотреть/застейджить/закоммитить — fugitive (`Space gg`, не выходя из кода)
- дифф/ревью/история — diffview (`Space gv`, `Space gh`)
- rebase/squash/stash/cherry-pick/жонглирование ветками — lazygit (`Space gG`)
- PR-комментарии — octo (урок 5)

**Практика:** наделай 3 мусорных коммита → `Space gG` → панель Commits →
squash двух через `s`, reword первого через `r` → `z` чтобы всё отменить.
