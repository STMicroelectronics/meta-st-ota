FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append := " \
	file://0001-stm32mpu-update-env-to-support-boot-A-B.patch \
"
