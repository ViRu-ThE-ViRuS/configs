local utils = require('utils')
local GetLSPIcon = require('lsp-setup/utils').GetLSPIcon

vim.g.vista_icon_indent = {"╰─▸ ", "├─▸ "}
vim.g.vista_fold_toggle_icons = {">", "$"}
vim.g.vista_fzf_preview = {'right:50%'}
vim.g.vista_disable_statusline = true

vim.cmd('let g:vista#renderer#icons = ' ..
        '{ "file": "' .. GetLSPIcon('File') ..
        '", "module": "' ..  GetLSPIcon('Module') ..
        '", "namespace": "' ..  GetLSPIcon('Namespace') ..
        '", "package": "' ..  GetLSPIcon('Package') ..
        '", "class": "' ..  GetLSPIcon('Class') ..
        '", "method": "' ..  GetLSPIcon('Method') ..
        '", "property": "' ..  GetLSPIcon('Property') ..
        '", "field": "' ..  GetLSPIcon('Field') ..
        '", "constructor": "' ..  GetLSPIcon('Constructor') ..
        '", "enum": "' ..  GetLSPIcon('Enum') ..
        '", "interface": "' ..  GetLSPIcon('Interface') ..
        '", "function": "' ..  GetLSPIcon('Function') ..
        '", "variable": "' ..  GetLSPIcon('Variable') ..
        '", "constant": "' ..  GetLSPIcon('Constant') ..
        '", "string": "' ..  GetLSPIcon('String') ..
        '", "number": "' ..  GetLSPIcon('Number') ..
        '", "boolean": "' ..  GetLSPIcon('Boolean') ..
        '", "array": "' ..  GetLSPIcon('Array') ..
        '", "object": "' ..  GetLSPIcon('Object') ..
        '", "key": "' ..  GetLSPIcon('Key') ..
        '", "null": "' ..  GetLSPIcon('Null') ..
        '", "enumMember": "' ..  GetLSPIcon('EnumMember') ..
        '", "struct": "' ..  GetLSPIcon('Struct') ..
        '", "event": "' ..  GetLSPIcon('Event') ..
        '", "operator": "' ..  GetLSPIcon('Operator') ..
        '", "member": "' ..  GetLSPIcon('Method') ..
        '", "typeParameter": "' ..  GetLSPIcon('TypeParameter') .. '" }')

vim.cmd [[
    augroup VistaCtags
        autocmd! BufEnter *
    augroup end
]]

utils.map('n', '<leader>k', '<cmd>Vista!!<cr>')
