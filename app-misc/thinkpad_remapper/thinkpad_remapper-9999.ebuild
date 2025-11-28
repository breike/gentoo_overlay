# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..14} )

inherit git-r3

EGIT_REPO_URI="https://github.com/breike/${PN}.git"

DESCRIPTION="Custom remapping script."
HOMEPAGE="https://www.openstenoproject.org/plover/"

SLOT="0"
LICENSE="CC0-1.0"

IUSE=""

DEPEND="
	dev-python/evdev
"

src_install() {
	mkdir -p "${D}/usr/bin/"
	mkdir -p "${D}/etc/init.d/"
	cp "${S}/thinkpad_remapper.py" "${D}/usr/bin/"
	cp "${S}/thinkpad_remapper" "${D}/etc/init.d/thinkpad_remapper"
	chmod +x "${D}/init.d/thinkpad_remapper"
}
