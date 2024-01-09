local uci = require("luci.model.uci").cursor()
require "luci.util"
local m = Map("tcnetemui", translate("Traffic Control Network Emulation"))
m.footer = [[test]]
local css = [[<style></style>
<script type="text/javascript">//<![CDATA[
console.log("test");
function resetUploadLimit() {
    var uploadLimitField = document.getElementById('widget\.cbid\.tcnetemui\.settings\.upload_limit');
        if (uploadLimitField) {
            uploadLimitField.value = '0';
        }
    var uploadDelayField = document.getElementById('widget\.cbid\.tcnetemui\.settings\.upload_delay')
        if (uploadDelayField) {
            uploadDelayField.value = '0';
        }
    var uploadJitterField = document.getElementById('widget\.cbid\.tcnetemui\.settings\.upload_jitter')
        if (uploadJitterField) {
            uploadJitterField.value = '0';
        }
    var uploadPacketLossField = document.getElementById('widget\.cbid\.tcnetemui\.settings\.upload_packet_loss')
        if (uploadPacketLossField) {
            uploadPacketLossField.value = '0';
        }
    var downloadLimitField = document.getElementById('widget\.cbid\.tcnetemui\.settings\.download_limit');
        if (downloadLimitField) {
            downloadLimitField.value = '0';
        }
    var downloadDelayField = document.getElementById('widget\.cbid\.tcnetemui\.settings\.download_delay')
        if (downloadDelayField) {
            downloadDelayField.value = '0';
        }
    var downloadJitterField = document.getElementById('widget\.cbid\.tcnetemui\.settings\.download_jitter')
        if (downloadJitterField) {
            downloadJitterField.value = '0';
        }
    var downloadPacketLossField = document.getElementById('widget\.cbid\.tcnetemui\.settings\.download_packet_loss')
        if (downloadPacketLossField) {
            downloadPacketLossField.value = '0';
        }
}
window.addEventListener('DOMContentLoaded', (event) => {
    var button = document.getElementById("cbid\.tcnetemui\.settings\.remove_all");
    if (button) {
        button.addEventListener("click", function(event) {
            resetUploadLimit();
        });
    }
})</script>]]
luci.http.write(css)
local s = m:section(NamedSection, "settings", "tcnetemui", "Settings", "Emulate network properties to simulate real-world network impairments")

local upload_limit_option = s:option(Value, "upload_limit", translate("Upload rate limit"),
translate("Accepts value in kbps. e.g. '10000' for 10mbps"))
    upload_limit_option.datatype = "uinteger"
    upload_limit_option.default = "0"

local download_limit_option = s:option(Value, "download_limit", translate("Download rate limit"), translate("Accepts value in kbps. e.g. '10000' for 10mbps"))
    download_limit_option.datatype = "uinteger"
    download_limit_option.default = "0"

local additional_settings = s:option(Flag, "additional_settings", translate("Additional settings"))

local upload_delay_option = s:option(Value, "upload_delay", translate("Upload delay"), translate("Accepts value in ms. e.g. '100' for 100ms"))
    upload_delay_option.datatype = "uinteger"
    upload_delay_option.default = "0"
    upload_delay_option:depends("additional_settings", "1")

local upload_jitter_option = s:option(Value, "upload_jitter", translate("Upload jitter"), translate("Accepts value in ms. e.g. '100' for 100ms"))
    upload_jitter_option.datatype = "uinteger"
    upload_jitter_option.default = "0"
    upload_jitter_option:depends("additional_settings", "1")

local upload_packet_loss_option = s:option(Value, "upload_packet_loss", translate("Upload Packet loss"), translate("Accepts value as percentage. e.g. '10' for 10%"))
    upload_packet_loss_option.datatype = "range(0,100)"
    upload_packet_loss_option.default = "0"
    upload_packet_loss_option:depends("additional_settings", "1")

local download_delay_option = s:option(Value, "download_delay", translate("Download delay"), translate("Accepts value in ms. e.g. '100' for 100ms"))
    download_delay_option.datatype = "uinteger"
    download_delay_option.default = "0"
    download_delay_option:depends("additional_settings", "1")

local download_jitter_option = s:option(Value, "download_jitter", translate("Download jitter"), translate("Accepts value in ms. e.g. '100' for 100ms"))
    download_jitter_option.datatype = "uinteger"
    download_jitter_option.default = "0"
    download_jitter_option:depends("additional_settings", "1")

local download_packet_loss_option = s:option(Value, "download_packet_loss", translate("Download Packet loss"), translate("Accepts value as percentage. e.g. '10' for 10%"))
    download_packet_loss_option.datatype = "range(0,100)"
    download_packet_loss_option.default = "0"
    download_packet_loss_option:depends("additional_settings", "1")

local set_button = s:option(Button, "set", " ")
    set_button.inputtitle = translate("Set limitations")
    set_button.inputstyle = "Save"

local remove_all_button = s:option(Button, "remove_all", " ")
    remove_all_button.inputstyle = "Reset"
    remove_all_button.inputtitle = translate("Remove all limitations")
    remove_all_button.id = "removeAllButton"

local function get_device_for_interface(interface)
    return uci:get("network", interface, "device")
end

function remove_all_button.write(self, s)
    local lan_device = get_device_for_interface("lan")
    local wan_device = get_device_for_interface("wan")
    luci.sys.exec(string.format("tc qdisc del dev %s root",lan_device))
    luci.sys.exec(string.format("tc qdisc del dev %s root", wan_device))
    luci.sys.exec("tc qdisc")
    uci:save("tcnetemui")
    uci:commit("tcnetemui")
end

--function m.on_after_commit(map)
function set_button.write(self, m)

    local lan_device = get_device_for_interface("lan")
    local wan_device = get_device_for_interface("wan")
    local saved_upload_limit = uci:get("tcnetemui", "settings", "upload_limit")
    if saved_upload_limit == nil then
        saved_upload_limit = "0"
    end
    local saved_download_limit = uci:get("tcnetemui", "settings", "download_limit")
    local saved_upload_packet_loss = uci:get("tcnetemui", "settings", "upload_packet_loss")
    local saved_download_packet_loss = uci:get("tcnetemui", "settings", "download_packet_loss")
    local saved_upload_delay = uci:get("tcnetemui", "settings", "upload_delay")
    local saved_download_delay = uci:get("tcnetemui", "settings", "download_delay")
    local saved_upload_jitter = uci:get("tcnetemui", "settings", "upload_jitter")
    local saved_download_jitter = uci:get("tcnetemui", "settings", "download_jitter")
    local saved_additional_settings = uci:get("tcnetemui", "settings", "additional_settings")

    if saved_download_limit == nil then
        saved_download_limit = "0"
    end
    if saved_upload_packet_loss == nil then
        saved_upload_packet_loss = "0"
    end
    if saved_download_packet_loss == nil then
        saved_download_packet_loss = "0"
    end
    if saved_upload_delay == nil then
        saved_upload_delay = "0"
    end
    if saved_download_delay == nil then
        saved_download_delay = "0"
    end
    if saved_upload_jitter == nil then
        saved_upload_jitter = "0"
    end
    if saved_download_jitter == nil then
        saved_download_jitter = "0"
    end

    if tonumber(saved_upload_jitter) > 0 and tonumber(saved_upload_delay) == 0 then
        saved_upload_delay = "1"
    end

    if tonumber(saved_download_jitter) > 0 and tonumber(saved_download_delay) == 0 then
        saved_download_delay = "1"
    end

    luci.sys.exec(string.format("tc qdisc del dev %s root",lan_device))
    luci.sys.exec(string.format("tc qdisc del dev %s root", wan_device))

    if(saved_additional_settings == '1') then
        luci.sys.exec(string.format("tc qdisc add dev %s root netem rate %skbit delay %sms %sms loss %s",lan_device, saved_download_limit, saved_download_delay, saved_download_jitter, saved_download_packet_loss))
        luci.sys.exec(string.format("tc qdisc add dev %s root netem rate %skbit delay %sms %sms loss %s", wan_device, saved_upload_limit, saved_upload_delay, saved_upload_jitter, saved_upload_packet_loss))
    else
        luci.sys.exec(string.format("tc qdisc add dev %s root netem rate %skbit",lan_device, saved_download_limit))
        luci.sys.exec(string.format("tc qdisc add dev %s root netem rate %skbit", wan_device, saved_upload_limit))
    end

    luci.sys.exec("tc qdisc")
    uci:save("tcnetemui")
    uci:commit("tcnetemui")
end
return m