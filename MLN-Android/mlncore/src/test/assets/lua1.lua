pt = require('print_table').print_r
--pt(_G.package.preload)
Argo = require('Argo')

local t = {
    name = 'n1'
}

t = Argo.bind('userdata', t)

print(t.name)