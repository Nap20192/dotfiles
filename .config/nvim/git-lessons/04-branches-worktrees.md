# Урок 4 — Ветки, merge, конфликты, worktree

## Ветки

```vim
:Git switch -c fix/thing    " создать и перейти
:Git switch main            " перейти
:Git branch                 " список в сплите
```

Быстрее — в lazygit (`Space gG`, урок 6): там ветки на `b`, checkout
по Enter.

## Merge и review перед ним

Ревью ветки перед мержем (из main):

```vim
:DiffviewOpen main...fix/thing   " что принесёт ветка
:Git log main..fix/thing         " её коммиты
:Git merge fix/thing
```

## Конфликты

При конфликте fugitive даёт трёхпанельный режим:

```vim
:Gvdiffsplit!    " на конфликтном файле: слева ours, справа theirs, центр — результат
```

В центральной панели:
- `d2o` — взять кусок из левой (ours / target)
- `d3o` — взять кусок из правой (theirs / merge)
- `]c` / `[c` — ходить по конфликтам
- поправил всё → `:Gwrite` — файл застейджен как resolved

Альтернатива: `:DiffviewOpen` во время merge показывает конфликтные файлы
отдельной секцией, Enter открывает тот же 3-way.

Закончить: `:Git commit` (merge commit) или `:Git merge --abort` — отмена.

## Worktree

Nvim сам worktree не создаёт — это делаешь снаружи и открываешь nvim внутри:

```bash
wt switch -c fix/thing     # worktrunk: создать + перейти
# или в herdr: Ctrl+Space w — worktree + workspace + claude
```

Внутри worktree nvim работает как обычно — fugitive/diffview видят ту же
базу git. Ревью из основного checkout: `:DiffviewOpen main...fix/thing` —
ветка worktree видна и без его открытия.

Влил — снаружи: `wt merge main` (squash+rebase+merge+cleanup) или
`git worktree remove`.

**Практика:** создай ветку, сделай конфликт (поменяй одну строку в двух
ветках), `:Git merge` → `:Gvdiffsplit!` → разреши через `d2o`/`d3o` →
`:Gwrite` → `:Git commit`.
