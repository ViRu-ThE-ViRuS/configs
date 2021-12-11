local utils = require('utils')
local get_lsp_icon = require('lsp-setup/utils').get_lsp_icon

vim.g.vista_icon_indent = {"╰─▸ ", "├─▸ "}
vim.g.vista_fold_toggle_icons = {">", "$"}
vim.g.vista_fzf_preview = {'right:50%'}
vim.g.vista_disable_statusline = true

vim.cmd('let g:vista#renderer#icons = ' ..
        '{ "file": "' .. get_lsp_icon('File') ..
        '", "module": "' ..  get_lsp_icon('Module') ..
        '", "namespace": "' ..  get_lsp_icon('Namespace') ..
        '", "package": "' ..  get_lsp_icon('Package') ..
        '", "class": "' ..  get_lsp_icon('Class') ..
        '", "method": "' ..  get_lsp_icon('Method') ..
        '", "property": "' ..  get_lsp_icon('Property') ..
        '", "field": "' ..  get_lsp_icon('Field') ..
        '", "constructor": "' ..  get_lsp_icon('Constructor') ..
        '", "enum": "' ..  get_lsp_icon('Enum') ..
        '", "interface": "' ..  get_lsp_icon('Interface') ..
        '", "function": "' ..  get_lsp_icon('Function') ..
        '", "variable": "' ..  get_lsp_icon('Variable') ..
        '", "constant": "' ..  get_lsp_icon('Constant') ..
        '", "string": "' ..  get_lsp_icon('String') ..
        '", "number": "' ..  get_lsp_icon('Number') ..
        '", "boolean": "' ..  get_lsp_icon('Boolean') ..
        '", "array": "' ..  get_lsp_icon('Array') ..
        '", "object": "' ..  get_lsp_icon('Object') ..
        '", "key": "' ..  get_lsp_icon('Key') ..
        '", "null": "' ..  get_lsp_icon('Null') ..
        '", "enumMember": "' ..  get_lsp_icon('EnumMember') ..
        '", "struct": "' ..  get_lsp_icon('Struct') ..
        '", "event": "' ..  get_lsp_icon('Event') ..
        '", "operator": "' ..  get_lsp_icon('Operator') ..
        '", "member": "' ..  get_lsp_icon('Method') ..
        '", "typeParameter": "' ..  get_lsp_icon('TypeParameter') .. '" }')

vim.cmd [[
    augroup VistaCtags
        autocmd! BufEnter *
        autocmd BufEnter,FileType vista syntax on
    augroup end
]]

utils.map('n', '<leader>k', '<cmd>Vista!!<cr>')
