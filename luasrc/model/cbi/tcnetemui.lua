local uci = require("luci.model.uci").cursor()
require "luci.util"
local m = Map("tcnetemui", translate("Traffic control network emulation Settings"))

local s = m:section(NamedSection, "settings", "tcnetemui")

local upload_limit_option = s:option(Value, "upload_limit", translate("Upload Limitation"),
translate("Set the upload limitation"))

s:option(Value, "upload_delay", translate("Upload delay"), translate("Set the Upload delay"))

s:option(Value, "upload_jitter", translate("Upload jitter"), translate("Set the Upload jitter"))

s:option(Value, "upload_packet_loss", translate("Upload Packet loss"), translate("Set the upload packet loss"))

s:option(Value, "download_limit", translate("Download Limitation"), translate("Set the download limitation"))

s:option(Value, "download_delay", translate("Download delay"), translate("Set the Download delay"))

s:option(Value, "download_jitter", translate("Download jitter"), translate("Set the Download jitter"))

s:option(Value, "download_packet_loss", translate("Download Packet loss"), translate("Set the download packet loss"))

local function get_device_for_interface(interface)
    return uci:get("network", interface, "device")
end

function m.on_after_commit(map)

    local lan_device = get_device_for_interface("lan")
    local wan_device = get_device_for_interface("wan")
    local saved_upload_limit = uci:get("tcnetemui", "settings", "upload_limit")
    local saved_download_limit = uci:get("tcnetemui", "settings", "download_limit")
    local saved_upload_packet_loss = uci:get("tcnetemui", "settings", "upload_packet_loss")
    local saved_download_packet_loss = uci:get("tcnetemui", "settings", "download_packet_loss")
    local saved_upload_delay = uci:get("tcnetemui", "settings", "upload_delay")
    local saved_download_delay = uci:get("tcnetemui", "settings", "download_delay")
    local saved_upload_jitter = uci:get("tcnetemui", "settings", "upload_jitter")
    local saved_download_jitter = uci:get("tcnetemui", "settings", "download_jitter")

    luci.sys.exec(string.format("tc qdisc del dev %s root",lan_device))
    luci.sys.exec(string.format("tc qdisc del dev %s root", wan_device))

    luci.sys.exec(string.format("tc qdisc add dev %s root netem rate %skbit delay %sms %sms loss %s",lan_device, saved_download_limit, saved_download_delay, saved_download_jitter, saved_download_packet_loss))
    luci.sys.exec(string.format("tc qdisc add dev %s root netem rate %skbit delay %sms %sms loss %s", wan_device, saved_upload_limit, saved_upload_delay, saved_upload_jitter, saved_upload_packet_loss))

    luci.sys.exec("tc qdisc")
end

return m