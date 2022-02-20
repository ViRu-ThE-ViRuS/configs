local R = require('pears.rule')

require('pears').setup(function(conf)
    conf.pair("'", {
        close = "'",
        should_expand = R.not_(R.start_of_context "[a-zA-Z]")
    })
end)
