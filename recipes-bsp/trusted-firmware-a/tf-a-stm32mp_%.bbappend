FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append := " \
	file://0001-fwu-add-logs-for-demo-purpose.patch \
"
