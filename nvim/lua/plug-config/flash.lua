return {
  "folke/flash.nvim",
  event = "BufReadPre",
  opts = { modes = { search = { enabled = true } } },
  init = function()
    local utils = require("utils")
    utils.map("n", "sf", function() require('flash').jump() end, { desc = "Flash" })
    utils.map("n", "sF", function() require('flash').treesitter() end, { desc = "Flash" })
    utils.add_command("[MISC] Toggle Flash Search", function() require("flash").toggle() end, { add_custom = true })
  end
}
