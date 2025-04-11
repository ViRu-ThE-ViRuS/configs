return {
  "folke/flash.nvim",
  event = "BufReadPre",
  opts = { modes = { search = { enabled = false } } },
  init = function()
    local utils = require("utils")
    utils.map({"n", "x", "o"}, "sf", function() require('flash').jump() end)
    utils.map({"n", "x", "o"}, "sF", function() require('flash').treesitter_search() end)
    utils.map({"x", "o"}, "r", function() require('flash').remote() end)
    utils.add_command("[MISC] Toggle Flash Search", function() require("flash").toggle() end, { add_custom = true })
  end
}
