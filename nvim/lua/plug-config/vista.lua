local lsp_icons = require('lsp-setup/lsp_utils').lsp_icons

local table = {
    file          = lsp_icons['File'].icon,
    module        = lsp_icons['Module'].icon,
    namespace     = lsp_icons['Namespace'].icon,
    package       = lsp_icons['Package'].icon,
    class         = lsp_icons['Class'].icon,
    method        = lsp_icons['Method'].icon,
    property      = lsp_icons['Property'].icon,
    field         = lsp_icons['Field'].icon,
    constructor   = lsp_icons['Constructor'].icon,
    enum          = lsp_icons['Enum'].icon,
    interface     = lsp_icons['Interface'].icon,
    ['function']  = lsp_icons['Function'].icon,
    variable      = lsp_icons['Variable'].icon,
    constant      = lsp_icons['Constant'].icon,
    string        = lsp_icons['String'].icon,
    number        = lsp_icons['Number'].icon,
    boolean       = lsp_icons['Boolean'].icon,
    array         = lsp_icons['Array'].icon,
    object        = lsp_icons['Object'].icon,
    key           = lsp_icons['Key'].icon,
    null          = lsp_icons['Null'].icon,
    enumMember    = lsp_icons['EnumMember'].icon,
    struct        = lsp_icons['Struct'].icon,
    event         = lsp_icons['Event'].icon,
    operator      = lsp_icons['Operator'].icon,
    member        = lsp_icons['Method'].icon,
    typeParameter = lsp_icons['TypeParameter'].icon,
}

vim.g['vista#renderer#icons '] = table
vim.g.vista_icon_indent = { "-> ", "-> " }
vim.g.vista_fold_toggle_icons = { ">", "$" }
vim.g.vista_fzf_preview = { 'right:50%' }
vim.g.vista_disable_statusline = true
-- vim.g.vista_default_executive = 'nvim_lsp'

return {
    'liuchengxu/vista.vim',
    cmd = 'Vista',
    init = function()
        require('utils').map('n', '<leader>k', function()
            vim.cmd.Vista({ bang = true, args = { '!' } })
        end)
    end
}
