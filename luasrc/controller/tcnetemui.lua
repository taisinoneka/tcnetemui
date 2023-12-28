-- /usr/lib/lua/luci/controller/example.lua
module("luci.controller.tcnetemui", package.seeall)

function index()
    entry({"admin", "tcnetemui"}, cbi("tcnetemui"), "tc-netem-ui").index = true
end