FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://rauc.config"
KERNEL_CONFIG_FRAGMENTS:append = " ${UNPACKDIR}/rauc.config"
