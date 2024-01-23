module("luci.controller.tcnetemui", package.seeall)
local uci = require("luci.model.uci").cursor()

-- Sets entry point in LuCi portal
function index()
    entry({"admin", "tcnetemui"}, cbi("tcnetemui",{hidesavebtn=true, hideresetbtn=true, hideapplybtn=true}), "tc-netem-ui").index = true
end