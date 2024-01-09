-- /usr/lib/lua/luci/controller/example.lua
module("luci.controller.tcnetemui", package.seeall)
local uci = require("luci.model.uci").cursor()

function index()
    entry({"admin", "tcnetemui"}, cbi("tcnetemui",{hidesavebtn=true, hideresetbtn=true, hideapplybtn=true}), "tc-netem-ui").index = true
end

function reset()
    luci.http.write("<p>ALL LIMITATIONS REMOVED</p>")
    luci.sys.exec(string.format("tc qdisc del dev %s root", uci:get("network", "lan", "device")))
    luci.sys.exec(string.format("tc qdisc del dev %s root", uci:get("network", "wan", "device")))
    luci.sys.exec("tc qdisc")
    local log = luci.sys.exec("tc qdisc show")
    luci.http.write(log)
end