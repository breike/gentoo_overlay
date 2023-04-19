# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PLOCALES="ar_SA ay_WI be_BY be_BY@latin bg_BG cs_CZ de_CH de_DE el_GR eo_EO es_AR es_BO es_ES fa_IR fi_FI fr_FR hi_IN ie_001 it_IT ja_JP jb_JB ko_KR lt_LT mk_MK nl_NL pl_PL pt_BR qu_WI ru_RU sk_SK sq_AL sr_SR sv_SE tg_TJ tk_TM tr_TR uk_UA vi_VN zh_CN zh_TW"

inherit desktop git-r3 qmake-utils plocale

DESCRIPTION="Feature-rich dictionary lookup program"
HOMEPAGE="http://goldendict.org/"
EGIT_REPO_URI="https://github.com/xiaoyifang/${PN}.git"
EGIT_BRANCH="staged"
EGIT_SUBMODULES=()

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="debug ffmpeg zim"

RDEPEND="
	app-arch/bzip2
	>=app-text/hunspell-1.2:=
	dev-libs/eb
	dev-libs/lzo
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qthelp:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtsql:5
	dev-qt/qtsvg:5
	dev-qt/qtwebengine:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	dev-qt/qtxml:5
	media-libs/libvorbis
	media-libs/tiff:0
	sys-libs/zlib
	x11-libs/libX11
	x11-libs/libXtst
	ffmpeg? (
		media-libs/libao
		media-video/ffmpeg:0=
	)
	zim? (
		app-arch/lzma
		app-arch/zstd
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-qt/linguist-tools:5
	virtual/pkgconfig
"

src_prepare() {
	# disable git
	sed -i -e '/git describe/s/^/#/' goldendict.pro || die

	# fix installation path
	sed -i -e '/PREFIX = /s:/usr/local:/usr:' goldendict.pro || die

	# add trailing semicolon
	sed -i -e '/^Categories/s/$/;/' redist/org.goldendict.GoldenDict.desktop || die

	echo "QMAKE_CXXFLAGS_RELEASE = $CXXFLAGS" >> goldendict.pro
	echo "QMAKE_CFLAGS_RELEASE = $CFLAGS" >> goldendict.pro

	local loc_dir="${S}/locale"
	plocale_find_changes "${loc_dir}" "" ".ts"
	rm_loc() {
		rm -vf "locale/${1}.ts" || die
		sed -i "/${1}.ts/d" goldendict.pro || die
	}
	plocale_for_each_disabled_locale rm_loc

	default
}

src_configure() {
	local myconf=()

	if ! use ffmpeg ; then
		myconf+=( CONFIG+=no_ffmpeg_player )
	fi

	if use zim ; then
		myconf+=( CONFIG+=zim_support )
	fi

	myconf+=( CONFIG+=no_qtmultimedia_player )
	eqmake5 "${myconf[@]}" goldendict.pro
}

install_locale() {
	insinto /usr/share/apps/goldendict/locale
	doins "${S}"/.qm/${1}.qm
	eend $? || die "failed to install $1 locale"
}

src_install() {
	dobin goldendict
	domenu redist/org.goldendict.GoldenDict.desktop
	doicon redist/icons/goldendict.png

	insinto /usr/share/goldendict/help
	plocale_for_each_locale install_locale
}
