local utils = require('utils')
local persistence = require('persistence')

persistence.setup()
utils.add_command('[MISC] Restore Session for CWD', persistence.load, nil, true)