require('neoscroll').setup({ })

local mappings = {}
mappings['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', '50'}}
mappings['<C-d>'] = {'scroll', {'vim.wo.scroll', 'true', '50'}}
mappings['<C-y>'] = {'scroll', {'-0.10', 'false', '50'}}
mappings['<C-e>'] = {'scroll', {'0.10', 'false', '50'}}
mappings['{'] = {'scroll', {'-0.10', 'true', '50', nil}}
mappings['}'] = {'scroll', {'0.10', 'true', '50', nil}}
mappings['zt'] = {'zt', {'50'}}
mappings['zz'] = {'zz', {'50'}}
mappings['zb'] = {'zb', {'50'}}

require('neoscroll.config').set_mappings(mappings)
