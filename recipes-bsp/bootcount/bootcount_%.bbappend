FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
	file://0001-bootcount-mark-rauc-slot-as-good.patch \
"

RDEPENDS:${PN}:append = " rauc"
