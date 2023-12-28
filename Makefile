include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI user interface for Traffic Control Network Emulation tool
LUCI_DEPENDS:=+tc-full +kmod-netem +bash +luci-base +lua +luci-compat
PKG_VERSION:=v1.1
include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature