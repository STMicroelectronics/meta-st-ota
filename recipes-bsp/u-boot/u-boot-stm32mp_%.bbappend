FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append := " \
	file://0001-autoboot-set-rauc_slot-to-be-used-in-kernel-cmdline.patch \
	file://0002-fwu-add-logs-for-demo-purpose.patch \
"
