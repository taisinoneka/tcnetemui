local uci = require("luci.model.uci").cursor()
require "luci.util"
local m = Map("tcnetemui", translate("Traffic control network emulation Settings"))

local s = m:section(NamedSection, "settings", "tcnetemui")

local upload_limit_option = s:option(Value, "upload_limit", translate("Upload Limitation"),
translate("Set the upload limitation"))

s:option(Value, "upload_delay", translate("Upload delay"), translate("Set the Upload delay"))

s:option(Value, "upload_jitter", translate("Upload jitter"), translate("Set the Upload jitter"))

s:option(Value, "download_limit", translate("Download Limitation"), translate("Set the download limitation"))

s:option(Value, "download_delay", translate("Download delay"), translate("Set the Download delay"))

s:option(Value, "download_jitter", translate("Download jitter"), translate("Set the Download jitter"))

s:option(Value, "packet_loss", translate("Packet loss"), translate("Set the network packet loss"))


function m.on_after_commit(map)
    local saved_upload_limit = uci:get("tcnetemui", "settings", "upload_limit")
    local saved_download_limit = uci:get("tcnetemui", "settings", "download_limit")
    local saved_packet_loss = uci:get("tcnetemui", "settings", "packet_loss")
    local saved_delay = uci:get("tcnetemui", "settings", "upload_delay")
    local saved_delay = uci:get("tcnetemui", "settings", "download_delay")
    local saved_jitter = uci:get("tcnetemui", "settings", "upload_jitter")
    local saved_jitter = uci:get("tcnetemui", "settings", "download_jitter")

    luci.sys.exec("tc qdisc del dev br-lan root")
    luci.sys.exec("tc qdisc del dev eth0.2 root")

    luci.sys.exec(string.format("tc qdisc add dev br-lan root netem rate %skbit delay %sms %sms loss %s", saved_download_limit, saved_delay, saved_jitter, saved_packet_loss))
    luci.sys.exec(string.format("tc qdisc add dev eth0.2 root netem rate %skbit delay %sms %sms", saved_upload_limit, saved_delay, saved_jitter))

    luci.sys.exec("tc qdisc")
end

return m