vim.g.db_ui_save_location = vim.fn.expand "~/.local/share/nvim/dadbod/"

vim.g.db_ui_table_helpers = {
    postgresql = {
        ["Table Size"] = [[
select
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name))),
    pg_total_relation_size(quote_ident(table_name))
from information_schema.tables
where table_schema = 'public'
    and table_name = '{table}';
]],
    },
}
