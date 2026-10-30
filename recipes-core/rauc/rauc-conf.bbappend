FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
	file://system.conf \
	file://ca.cert.pem \
	file://st-rauc-fwu.sh \
"

RAUC_KEY_FILE = "${COREBASE}/meta-st/meta-st-ota/recipes-core/bundles/files/development-1.key.pem"
RAUC_CERT_FILE = "${COREBASE}/meta-st/meta-st-ota/recipes-core/bundles/files/development-1.cert.pem"

do_install:append () {
    install -Dm 0755 ${UNPACKDIR}/st-rauc-fwu.sh ${D}${nonarch_libdir}/rauc/st-rauc-fwu.sh
}

FILES:${PN} += "${nonarch_libdir}/rauc"

RDEPENDS:${PN} += "u-boot-tools-stm32mp-fwumdata"
