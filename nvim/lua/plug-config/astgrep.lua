-- ast-grep integration with fzf-lua
-- uses fzf_live to stream structural search results

-- map filetype to ast-grep language
local ft_to_lang = {
  typescript = 'typescript',
  typescriptreact = 'tsx',
  javascript = 'javascript',
  javascriptreact = 'jsx',
  python = 'python',
  rust = 'rust',
  go = 'go',
  c = 'c',
  cpp = 'cpp',
  java = 'java',
  kotlin = 'kotlin',
  lua = 'lua',
  ruby = 'ruby',
  swift = 'swift',
  css = 'css',
  html = 'html',
  json = 'json',
  yaml = 'yaml',
  toml = 'toml',
  bash = 'bash',
  sh = 'bash',
  zsh = 'bash',
}

-- ast-grep picker (all files)
local function ast_grep_picker()
  local fzf = require('fzf-lua')

  fzf.fzf_live(
    function(query)
      query = type(query) == 'table' and query[1] or query
      if not query or query == '' then return '' end
      return string.format("ast-grep run --pattern %s --heading never --color always 2>/dev/null",
        vim.fn.shellescape(query))
    end,
    {
      prompt = 'AstGrep> ',
      copen = 'horizontal copen',
      previewer = 'builtin',
      actions = {
        ['default'] = fzf.actions.file_edit_or_qf,
        ['ctrl-x'] = fzf.actions.file_split,
        ['ctrl-v'] = fzf.actions.file_vsplit,
        ['ctrl-t'] = fzf.actions.file_tabedit,
        ['ctrl-q'] = fzf.actions.file_sel_to_qf,
      },
    }
  )
end

-- ast-grep picker with language from current buffer
local function ast_grep_picker_ft()
  local fzf = require('fzf-lua')
  local ft = vim.bo.filetype
  local lang = ft_to_lang[ft]

  if not lang then
    vim.notify('ast-grep: no language mapping for filetype "' .. ft .. '"', vim.log.levels.WARN)
    -- fallback to generic picker
    return ast_grep_picker()
  end

  fzf.fzf_live(
    function(query)
      query = type(query) == 'table' and query[1] or query
      if not query or query == '' then return '' end
      return string.format("ast-grep run --pattern %s --lang %s --heading never --color always 2>/dev/null",
        vim.fn.shellescape(query), lang)
    end,
    {
      prompt = string.format('AstGrep [%s]> ', lang),
      copen = 'horizontal copen',
      previewer = 'builtin',
      actions = {
        ['default'] = fzf.actions.file_edit_or_qf,
        ['ctrl-x'] = fzf.actions.file_split,
        ['ctrl-v'] = fzf.actions.file_vsplit,
        ['ctrl-t'] = fzf.actions.file_tabedit,
        ['ctrl-q'] = fzf.actions.file_sel_to_qf,
      },
    }
  )
end

return {
  -- virtual plugin for ast-grep cli integration
  'ast-grep/ast-grep',
  virtual = true,
  lazy = true,
  init = function()
    local utils = require('utils')

    -- <c-p>sg: ast-grep all files
    utils.map("n", "<c-p>sg", function() ast_grep_picker() end)

    -- <c-p>sG: ast-grep with current buffer's language
    utils.map("n", "<c-p>sG", function() ast_grep_picker_ft() end)

    -- command interface
    utils.add_command('AstGrep', ast_grep_picker, {
      cmd_opts = { bang = false, nargs = 0, desc = 'AST-grep structural search' },
    })
    utils.add_command('[AST] Search', ast_grep_picker, { add_custom = true })

    utils.add_command('AstGrepFt', ast_grep_picker_ft, {
      cmd_opts = { bang = false, nargs = 0, desc = 'AST-grep search for current filetype' },
    })
    utils.add_command('[AST] Search (filetype)', ast_grep_picker_ft, { add_custom = true })
  end,
}
