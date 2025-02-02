# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

FIREFOX_PATCHSET="firefox-91esr-patches-06j.tar.xz"

LLVM_MAX_SLOT=13

PYTHON_COMPAT=( python3_{8..10} )
PYTHON_REQ_USE="ncurses,sqlite,ssl"

WANT_AUTOCONF="2.1"

# Convert the ebuild version to the upstream mozilla version, used by mozlinguas
MOZ_PV="${PV/_p*}esr"

# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/config?h=maint-11.0#n4
# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/config?h=maint-11.0#n11
# and https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-launcher/config?h=maint-11.0#n2
# and https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/https-everywhere/config?h=maint-11.0#n2
# and https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/config?h=maint-11.0#n81
TOR_PV="11.0.10"
TOR_TAG="11.0-1-build1"
TORLAUNCHER_VERSION="0.2.33"
HTTPSEVERYWHERE_VERSION="2021.7.13"
NOSCRIPT_VERSION="11.4.3"

inherit autotools check-reqs desktop flag-o-matic llvm \
	multiprocessing pax-utils python-any-r1 toolchain-funcs xdg

TOR_SRC_BASE_URI="https://dist.torproject.org/torbrowser/${TOR_PV}"
TOR_SRC_ARCHIVE_URI="https://archive.torproject.org/tor-package-archive/torbrowser/${TOR_PV}"

PATCH_URIS=(
	https://dev.gentoo.org/~{juippis,polynomial-c,whissi}/mozilla/patchsets/${FIREFOX_PATCHSET}
)

SRC_URI="
	${TOR_SRC_BASE_URI}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	${TOR_SRC_BASE_URI}/src-tor-launcher-${TORLAUNCHER_VERSION}.tar.xz
	${TOR_SRC_BASE_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
	${TOR_SRC_ARCHIVE_URI}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	${TOR_SRC_ARCHIVE_URI}/src-tor-launcher-${TORLAUNCHER_VERSION}.tar.xz
	${TOR_SRC_ARCHIVE_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
	https://addons.cdn.mozilla.net/user-media/addons/722/noscript_security_suite-${NOSCRIPT_VERSION}-an+fx.xpi
	https://www.eff.org/files/https-everywhere-${HTTPSEVERYWHERE_VERSION}-eff.xpi
	${PATCH_URIS[@]}"

DESCRIPTION="Private browsing without tracking, surveillance, or censorship"
HOMEPAGE="https://www.torproject.org/ https://gitweb.torproject.org/tor-browser.git"

KEYWORDS="~amd64 ~x86"

SLOT="0"
LICENSE="BSD CC-BY-3.0 MPL-2.0 GPL-2 LGPL-2.1"
IUSE="+clang dbus hardened"
IUSE+=" pulseaudio"
IUSE+=" +system-av1 +system-harfbuzz +system-icu +system-jpeg +system-libevent +system-libvpx system-png +system-webp"
IUSE+=" wayland"

BDEPEND="${PYTHON_DEPS}
	app-arch/unzip
	app-arch/zip
	>=dev-util/cbindgen-0.19.0
	>=net-libs/nodejs-10.23.1
	virtual/pkgconfig
	>=virtual/rust-1.51.0
	|| (
		(
			sys-devel/clang:13
			sys-devel/llvm:13
			clang? (
				=sys-devel/lld-13*
			)
		)
		(
			sys-devel/clang:12
			sys-devel/llvm:12
			clang? (
				=sys-devel/lld-12*
			)
		)
		(
			sys-devel/clang:11
			sys-devel/llvm:11
			clang? (
				=sys-devel/lld-11*
			)
		)
	)
	amd64? ( >=dev-lang/nasm-2.13 )
	x86? ( >=dev-lang/nasm-2.13 )"

COMMON_DEPEND="
	>=dev-libs/nss-3.68
	>=dev-libs/nspr-4.32
	dev-libs/atk
	dev-libs/expat
	>=x11-libs/cairo-1.10[X]
	>=x11-libs/gtk+-3.4.0:3[X]
	x11-libs/gdk-pixbuf
	>=x11-libs/pango-1.22.0
	>=media-libs/mesa-10.2:*
	media-libs/fontconfig
	>=media-libs/freetype-2.4.10
	kernel_linux? ( !pulseaudio? ( media-libs/alsa-lib ) )
	virtual/freedesktop-icon-theme
	>=x11-libs/pixman-0.19.2
	>=dev-libs/glib-2.26:2
	>=sys-libs/zlib-1.2.3
	>=dev-libs/libffi-3.0.10:=
	media-video/ffmpeg
	x11-libs/libX11
	x11-libs/libxcb:=
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXt
	dbus? (
		sys-apps/dbus
		dev-libs/dbus-glib
	)
	system-av1? (
		>=media-libs/dav1d-0.8.1:=
		>=media-libs/libaom-1.0.0:=
	)
	system-harfbuzz? (
		>=media-libs/harfbuzz-2.8.1:0=
		>=media-gfx/graphite2-1.3.13
	)
	system-icu? ( >=dev-libs/icu-69.1:= )
	system-jpeg? ( >=media-libs/libjpeg-turbo-1.2.1 )
	system-libevent? ( >=dev-libs/libevent-2.0:0=[threads] )
	system-libvpx? ( >=media-libs/libvpx-1.8.2:0=[postproc] )
	system-png? ( >=media-libs/libpng-1.6.35:0=[apng] )
	system-webp? ( >=media-libs/libwebp-1.1.0:0= )"

RDEPEND="${COMMON_DEPEND}
	pulseaudio? (
		|| (
			media-sound/pulseaudio
			>=media-sound/apulse-0.1.12-r4
		)
	)
	!www-client/torbrowser-launcher"

DEPEND="${COMMON_DEPEND}
	x11-libs/libICE
	x11-libs/libSM
	pulseaudio? (
		|| (
			media-sound/pulseaudio
			>=media-sound/apulse-0.1.12-r4[sdk]
		)
	)
	wayland? ( >=x11-libs/gtk+-3.11:3[wayland] )
	virtual/opengl"

S="${WORKDIR}/firefox-tor-browser-${MOZ_PV}-${TOR_TAG}"

llvm_check_deps() {
	if ! has_version -b "sys-devel/clang:${LLVM_SLOT}" ; then
		einfo "sys-devel/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if use clang ; then
		if ! has_version -b "=sys-devel/lld-${LLVM_SLOT}*" ; then
			einfo "=sys-devel/lld-${LLVM_SLOT}* is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi
	fi

	einfo "Using LLVM slot ${LLVM_SLOT} to build" >&2
}

moz_clear_vendor_checksums() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -ne 1 ]] ; then
		die "${FUNCNAME} requires exact one argument"
	fi

	einfo "Clearing cargo checksums for ${1} ..."

	sed -i \
		-e 's/\("files":{\)[^}]*/\1/' \
		"${S}"/third_party/rust/${1}/.cargo-checksum.json \
		|| die
}

moz_install_xpi() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local DESTDIR=${1}
	shift

	insinto "${DESTDIR}"

	local emid xpi_file xpi_tmp_dir
	for xpi_file in "${@}" ; do
		emid=
		xpi_tmp_dir=$(mktemp -d --tmpdir="${T}")

		# Unpack XPI
		unzip -qq "${xpi_file}" -d "${xpi_tmp_dir}" || die

		# Determine extension ID
		if [[ -f "${xpi_tmp_dir}/install.rdf" ]] ; then
			emid=$(sed -n -e '/install-manifest/,$ { /em:id/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }' "${xpi_tmp_dir}/install.rdf")
			[[ -z "${emid}" ]] && die "failed to determine extension id from install.rdf"
		elif [[ -f "${xpi_tmp_dir}/manifest.json" ]] ; then
			emid=$(sed -n -e 's/.*"id": "\([^"]*\)".*/\1/p' "${xpi_tmp_dir}/manifest.json")
			[[ -z "${emid}" ]] && die "failed to determine extension id from manifest.json"
		else
			die "failed to determine extension id"
		fi

		einfo "Installing ${emid}.xpi into ${ED}${DESTDIR} ..."
		newins "${xpi_file}" "${emid}.xpi"
	done
}

mozconfig_add_options_ac() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in ${@} ; do
		echo "ac_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_add_options_mk() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in ${@} ; do
		echo "mk_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_use_enable() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_enable "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}

mozconfig_use_with() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_with "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}

pkg_pretend() {
	# Ensure we have enough disk space to compile
	CHECKREQS_DISK_BUILD="6400M"

	check-reqs_pkg_pretend
}

pkg_setup() {
	# Ensure we have enough disk space to compile
	CHECKREQS_DISK_BUILD="6400M"

	check-reqs_pkg_setup

	llvm_pkg_setup

	python-any-r1_pkg_setup

	# These should *always* be cleaned up anyway
	unset \
		DBUS_SESSION_BUS_ADDRESS \
		DISPLAY \
		ORBIT_SOCKETDIR \
		SESSION_MANAGER \
		XAUTHORITY \
		XDG_CACHE_HOME \
		XDG_SESSION_COOKIE

	# Build system is using /proc/self/oom_score_adj, bug #604394
	addpredict /proc/self/oom_score_adj

	if ! mountpoint -q /dev/shm ; then
		# If /dev/shm is not available, configure is known to fail with
		# a traceback report referencing /usr/lib/pythonN.N/multiprocessing/synchronize.py
		ewarn "/dev/shm is not mounted -- expect build failures!"
	fi

	# Ensure we use C locale when building, bug #746215
	export LC_ALL=C
}

src_unpack() {
	for a in ${A} ; do
		case "${a}" in
			"src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz")
				unpack "${a}"
				;;

			"src-tor-launcher-${TORLAUNCHER_VERSION}.tar.xz")
				local destdir="${S}"/browser/extensions/tor-launcher
				echo ">>> Unpacking ${a} to ${destdir}"
				mkdir "${destdir}" || die
				tar -C "${destdir}" -x -o --strip-components 1 \
					-f "${DISTDIR}/${a}" || die
				;;

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-11.0#n75
			"https-everywhere-${HTTPSEVERYWHERE_VERSION}-eff.xpi")
				local destdir="${WORKDIR}"/https-everywhere/chrome/torbutton/content/extensions/https-everywhere/
				echo ">>> Unpacking ${a} to ${destdir}"
				mkdir -p "${destdir}" || die
				unzip -qo "${DISTDIR}/${a}" -d "${destdir}" || die
				;;

			"noscript_security_suite-${NOSCRIPT_VERSION}-an+fx.xpi")
				local destdir="${WORKDIR}"
				echo ">>> Copying ${a} to ${destdir}"
				cp "${DISTDIR}/${a}" "${destdir}" || die
				;;

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-11.0#n35
			"tor-browser-linux64-${TOR_PV}_en-US.tar.xz")
				local destdir="${WORKDIR}"/profile
				echo ">>> Unpacking ${a} to ${destdir}"
				mkdir "${destdir}" || die
				tar -C "${destdir}" -x -o --strip-components 1 \
					-f "${DISTDIR}/${a}" \
					tor-browser_en-US/Browser/TorBrowser/Docs \
					tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default || die
				;;

			*)
				unpack "${a}"
				;;
		esac
	done
}

src_prepare() {
	if use system-av1 && has_version "<media-libs/dav1d-1.0.0"; then
		rm -v "${WORKDIR}"/firefox-patches/0033-bgo-835788-dav1d-1.0.0-support.patch || die
		elog "<media-libs/dav1d-1.0.0 detected, removing 1.0.0 compat patch."
	elif ! use system-av1; then
		rm -v "${WORKDIR}"/firefox-patches/0033-bgo-835788-dav1d-1.0.0-support.patch || die
		elog "-system-av1 USE flag detected, removing 1.0.0 compat patch."
	fi

	eapply "${WORKDIR}/firefox-patches"

	# Revert "Change the default Firefox profile directory to be TBB-relative"
	eapply "${FILESDIR}"/${PN}-91.3.0-Do_not_store_data_in_the_app_bundle.patch
	eapply "${FILESDIR}"/${PN}-91.3.0-Change_the_default_Firefox_profile_directory.patch

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

	# Make cargo respect MAKEOPTS
	export CARGO_BUILD_JOBS="$(makeopts_jobs)"

	# Make LTO respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/build/moz.configure/lto-pgo.configure \
		|| die "sed failed to set num_cores"

	# Make ICU respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/intl/icu_sources_data.py \
		|| die "sed failed to set num_cores"

	# sed-in toolchain prefix
	sed -i \
		-e "s/objdump/${CHOST}-objdump/" \
		"${S}"/python/mozbuild/mozbuild/configure/check_debug_ranges.py \
		|| die "sed failed to set toolchain prefix"

	sed -i \
		-e 's/ccache_stats = None/return None/' \
		"${S}"/python/mozbuild/mozbuild/controller/building.py \
		|| die "sed failed to disable ccache stats call"

	einfo "Removing pre-built binaries ..."
	find "${S}"/third_party -type f \( -name '*.so' -o -name '*.o' \) -print -delete || die

	# Clearing checksums where we have applied patches
	moz_clear_vendor_checksums target-lexicon-0.9.0

	# Create build dir
	BUILD_DIR="${WORKDIR}/${PN}_build"
	mkdir -p "${BUILD_DIR}" || die

	xdg_src_prepare
}

src_configure() {
	# Show flags set at the beginning
	einfo "Current BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Current CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Current CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Current LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Current RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"

	local have_switched_compiler=
	if use clang && ! tc-is-clang ; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."
		have_switched_compiler=yes
		AR=llvm-ar
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
		NM=llvm-nm
		RANLIB=llvm-ranlib
	elif ! use clang && ! tc-is-gcc ; then
		# Force gcc
		have_switched_compiler=yes
		einfo "Enforcing the use of gcc due to USE=-clang ..."
		AR=gcc-ar
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		NM=gcc-nm
		RANLIB=gcc-ranlib
	fi

	if [[ -n "${have_switched_compiler}" ]] ; then
		# Because we switched active compiler we have to ensure
		# that no unsupported flags are set
		strip-unsupported-flags
	fi

	# Ensure we use correct toolchain
	export HOST_CC="$(tc-getBUILD_CC)"
	export HOST_CXX="$(tc-getBUILD_CXX)"
	tc-export CC CXX LD AR NM OBJDUMP RANLIB PKG_CONFIG

	# Pass the correct toolchain paths through cbindgen
	if tc-is-cross-compiler ; then
		export BINDGEN_CFLAGS="${SYSROOT:+--sysroot=${ESYSROOT}} --target=${CHOST} ${BINDGEN_CFLAGS-}"
	fi

	# Set MOZILLA_FIVE_HOME
	export MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# python/mach/mach/mixin/process.py fails to detect SHELL
	export SHELL="${EPREFIX}/bin/bash"

	# Set state path
	export MOZBUILD_STATE_PATH="${BUILD_DIR}"

	# Set MOZCONFIG
	export MOZCONFIG="${S}/.mozconfig"

	# Initialize MOZCONFIG
	mozconfig_add_options_ac '' --enable-application=browser

	# Set Gentoo defaults
	export MOZILLA_OFFICIAL=1

	mozconfig_add_options_ac 'Gentoo default' \
		--allow-addon-sideload \
		--disable-cargo-incremental \
		--disable-crashreporter \
		--disable-install-strip \
		--disable-strip \
		--disable-updater \
		--enable-official-branding \
		--enable-release \
		--enable-system-ffi \
		--enable-system-pixman \
		--host="${CBUILD:-${CHOST}}" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--prefix="${EPREFIX}/usr" \
		--target="${CHOST}" \
		--without-ccache \
		--with-intl-api \
		--with-libclang-path="$(llvm-config --libdir)" \
		--with-system-nspr \
		--with-system-nss \
		--with-system-zlib \
		--with-toolchain-prefix="${CHOST}-" \
		--with-unsigned-addon-scopes=app,system \
		--x-includes="${SYSROOT}${EPREFIX}/usr/include" \
		--x-libraries="${SYSROOT}${EPREFIX}/usr/$(get_libdir)"

	if ! use x86 ; then
		mozconfig_add_options_ac '' --enable-rust-simd
	fi

	mozconfig_use_with system-av1
	mozconfig_use_with system-harfbuzz
	mozconfig_use_with system-harfbuzz system-graphite2
	mozconfig_use_with system-icu
	mozconfig_use_with system-jpeg
	mozconfig_use_with system-libevent system-libevent "${SYSROOT}${EPREFIX}/usr"
	mozconfig_use_with system-libvpx
	mozconfig_use_with system-png
	mozconfig_use_with system-webp

	mozconfig_use_enable dbus

	mozconfig_add_options_ac '' --disable-eme

	mozconfig_add_options_ac '' --disable-geckodriver

	if use hardened ; then
		mozconfig_add_options_ac "+hardened" --enable-hardening
		append-ldflags "-Wl,-z,relro -Wl,-z,now"
	fi

	mozconfig_add_options_ac '' --disable-jack

	mozconfig_use_enable pulseaudio
	# force the deprecated alsa sound code if pulseaudio is disabled
	if use kernel_linux && ! use pulseaudio ; then
		mozconfig_add_options_ac '-pulseaudio' --enable-alsa
	fi

	mozconfig_add_options_ac '' --disable-sndio

	mozconfig_add_options_ac '' --disable-necko-wifi

	if use wayland ; then
		mozconfig_add_options_ac '+wayland' --enable-default-toolkit=cairo-gtk3-wayland
	else
		mozconfig_add_options_ac '' --enable-default-toolkit=cairo-gtk3
	fi
	# Rename the binary and set the profile location
	mozconfig_add_options_ac 'torbrowser' --with-app-name=torbrowser
	mozconfig_add_options_ac 'torbrowser' --with-app-basename=torbrowser

	# see https://gitweb.torproject.org/tor-browser.git/tree/old-configure.in?h=tor-browser-91.3.0esr-11.0-1#n1885
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/mozconfig-linux-x86_64?h=maint-11.0
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/build?h=maint-11.0#n114
	mozconfig_add_options_mk 'torbrowser' "MOZ_APP_DISPLAYNAME=\"Tor Browser\""
	mozconfig_add_options_ac 'torbrowser' \
		--enable-optimize \
		--enable-official-branding \
		--enable-default-toolkit=cairo-gtk3 \
		--disable-strip \
		--disable-install-strip \
		--disable-tests \
		--disable-debug \
		--disable-crashreporter \
		--disable-webrtc \
		--disable-parental-controls \
		--disable-eme \
		--enable-proxy-bypass-protection \
		MOZ_TELEMETRY_REPORTING= \
		--with-tor-browser-version=${TOR_PV}  \
		--enable-update-channel=release \
		--enable-bundled-fonts \
		--with-branding=browser/branding/official \
		--disable-tor-browser-update \
		--enable-tor-launcher

	# Avoid auto-magic on linker
	if use clang ; then
		# This is upstream's default
		mozconfig_add_options_ac "forcing ld=lld due to USE=clang" --enable-linker=lld
	else
		mozconfig_add_options_ac "linker is set to bfd" --enable-linker=bfd
	fi

	# LTO flag was handled via configure
	filter-flags '-flto*'

	if is-flag '-g*' ; then
		if use clang ; then
			mozconfig_add_options_ac 'from CFLAGS' --enable-debug-symbols=$(get-flag '-g*')
		else
			mozconfig_add_options_ac 'from CFLAGS' --enable-debug-symbols
		fi
	else
		mozconfig_add_options_ac 'Gentoo default' --disable-debug-symbols
	fi

	if is-flag '-O0' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O0
	elif is-flag '-O4' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O4
	elif is-flag '-O3' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O3
	elif is-flag '-O1' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O1
	elif is-flag '-Os' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-Os
	else
		mozconfig_add_options_ac "Gentoo default" --enable-optimize=-O2
	fi

	# Debug flag was handled via configure
	filter-flags '-g*'

	# Optimization flag was handled via configure
	filter-flags '-O*'

	if use clang ; then
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1482204
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1483822
		# toolkit/moz.configure Elfhack section: target.cpu in ('arm', 'x86', 'x86_64')
		local disable_elf_hack=
		if use amd64 ; then
			disable_elf_hack=yes
		elif use x86 ; then
			disable_elf_hack=yes
		elif use arm ; then
			disable_elf_hack=yes
		fi

		if [[ -n ${disable_elf_hack} ]] ; then
			mozconfig_add_options_ac 'elf-hack is broken when using Clang' --disable-elf-hack
		fi
	elif tc-is-gcc ; then
		if ver_test $(gcc-fullversion) -ge 10 ; then
			einfo "Forcing -fno-tree-loop-vectorize to workaround GCC bug, see bug 758446 ..."
			append-cxxflags -fno-tree-loop-vectorize
		fi
	fi

	if ! use elibc_glibc ; then
		mozconfig_add_options_ac '!elibc_glibc' --disable-jemalloc
	fi

	# Allow elfhack to work in combination with unstripped binaries
	# when they would normally be larger than 2GiB.
	append-ldflags "-Wl,--compress-debug-sections=zlib"

	# Make revdep-rebuild.sh happy; Also required for musl
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}",--enable-new-dtags

	# Pass $MAKEOPTS to build system
	export MOZ_MAKE_FLAGS="${MAKEOPTS}"

	# Use system's Python environment
	export MACH_USE_SYSTEM_PYTHON=1
	export PIP_NO_CACHE_DIR=off

	# Disable notification when build system has finished
	export MOZ_NOSPAM=1

	# Portage sets XARGS environment variable to "xargs -r" by default which
	# breaks build system's check_prog() function which doesn't support arguments
	mozconfig_add_options_ac 'Gentoo default' "XARGS=${EPREFIX}/usr/bin/xargs"

	# Set build dir
	mozconfig_add_options_mk 'Gentoo default' "MOZ_OBJDIR=${BUILD_DIR}"

	# Show flags we will use
	einfo "Build BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Build CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Build CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Build LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Build RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"

	# Handle EXTRA_CONF and show summary
	local ac opt hash reason

	# Apply EXTRA_ECONF entries to $MOZCONFIG
	if [[ -n ${EXTRA_ECONF} ]] ; then
		IFS=\! read -a ac <<<${EXTRA_ECONF// --/\!}
		for opt in "${ac[@]}"; do
			mozconfig_add_options_ac "EXTRA_ECONF" --${opt#--}
		done
	fi

	echo
	echo "=========================================================="
	echo "Building ${PF} with the following configuration"
	grep ^ac_add_options "${MOZCONFIG}" | while read ac opt hash reason; do
		[[ -z ${hash} || ${hash} == \# ]] \
			|| die "error reading mozconfig: ${ac} ${opt} ${hash} ${reason}"
		printf "    %-30s  %s\n" "${opt}" "${reason:-mozilla.org default}"
	done
	echo "=========================================================="
	echo

	./mach configure || die
}

src_compile() {
	local -x GDK_BACKEND=x11

	./mach build --verbose || die
}

src_install() {
	# Default bookmarks
	local PROFILE_DIR="${WORKDIR}/profile/Browser/TorBrowser/Data/Browser/profile.default"
	cat "${PROFILE_DIR}"/bookmarks.html > \
		"${WORKDIR}"/torbrowser_build/dist/bin/browser/chrome/en-US/locale/browser/bookmarks.html || die

	# xpcshell is getting called during install
	pax-mark m \
		"${BUILD_DIR}"/dist/bin/xpcshell \
		"${BUILD_DIR}"/dist/bin/torbrowser \
		"${BUILD_DIR}"/dist/bin/plugin-container

	DESTDIR="${D}" ./mach install || die

	# Upstream cannot ship symlink but we can (bmo#658850)
	rm "${ED}${MOZILLA_FIVE_HOME}/${PN}-bin" || die
	dosym ${PN} ${MOZILLA_FIVE_HOME}/${PN}-bin

	# Don't install llvm-symbolizer from sys-devel/llvm package
	if [[ -f "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" ]] ; then
		rm -v "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" || die
	fi

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-11.0#n48
	insinto ${MOZILLA_FIVE_HOME}/browser/extensions
	newins "${WORKDIR}"/noscript_security_suite-${NOSCRIPT_VERSION}-an+fx.xpi {73a6fe31-595d-460b-a920-fcc0f8843232}.xpi

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-11.0#n75
	pushd "${WORKDIR}"/https-everywhere || die
		find chrome/ | zip -q -X -@ "${ED}${MOZILLA_FIVE_HOME}/omni.ja"
	popd || die

	local PREFS_DIR="${MOZILLA_FIVE_HOME}/browser/defaults/preferences"
	insinto "${PREFS_DIR}"

	# see: https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-11.0#n132
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build#n174
	newins - 000-tor-browser.js <<-EOF
		pref("extensions.torlauncher.prompt_for_locale", "false");
		pref("intl.locale.requested", "en-US");
	EOF

	# Set dictionary path to use system hunspell
	newins - gentoo-prefs.js <<-EOF
		pref("spellchecker.dictionary_path", "${EPREFIX}/usr/share/myspell");
	EOF

	local GENTOO_PREFS="${ED}${PREFS_DIR}/gentoo-prefs.js"

	# Force the graphite pref if USE=system-harfbuzz is enabled, since the pref cannot disable it
	if use system-harfbuzz ; then
		cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set gfx.font_rendering.graphite.enabled pref"
		sticky_pref("gfx.font_rendering.graphite.enabled", true);
		EOF
	fi

	# Install icons
	local icon_srcdir="${S}/browser/branding/official"

	local icon size
	for icon in "${icon_srcdir}"/default*.png ; do
		size=${icon%.png}
		size=${size##*/default}

		if [[ ${size} -eq 48 ]] ; then
			newicon "${icon}" ${PN}.png
		fi

		newicon -s ${size} "${icon}" ${PN}.png
	done

	# Install menus
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/RelativeLink/start-tor-browser.desktop
	domenu "${FILESDIR}"/torbrowser.desktop

	# Install wrapper
	# see: https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/RelativeLink/start-tor-browser
	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/lib/anon-ws-disable-stacked-tor/torbrowser.sh
	rm "${ED}"/usr/bin/torbrowser || die # symlink to /usr/lib64/torbrowser/torbrowser

	newbin - torbrowser <<-EOF
		#!/bin/sh

		unset SESSION_MANAGER
		export GSETTINGS_BACKEND=memory

		export TOR_HIDE_UPDATE_CHECK_UI=1
		export TOR_NO_DISPLAY_NETWORK_SETTINGS=1
		export TOR_SKIP_CONTROLPORTTEST=1
		export TOR_SKIP_LAUNCH=1
		export TOR_USE_LEGACY_LAUNCHER=1

		if @DEFAULT_WAYLAND@ && [[ -z \${MOZ_DISABLE_WAYLAND} ]]; then
			if [[ -n "\${WAYLAND_DISPLAY}" ]]; then
				export MOZ_ENABLE_WAYLAND=1
			fi
		fi

		exec /usr/$(get_libdir)/torbrowser/torbrowser --class "Tor Browser" "\${@}"
	EOF

	# Update wrapper
	local use_wayland="false"
	if use wayland ; then
		use_wayland="true"
	fi
	sed -i -e "s:@DEFAULT_WAYLAND@:${use_wayland}:" "${ED}/usr/bin/${PN}" || die

	# torbrowser and torbrowser-bin are identical
	rm "${ED}"${MOZILLA_FIVE_HOME}/torbrowser-bin || die
	dosym torbrowser ${MOZILLA_FIVE_HOME}/torbrowser-bin

	# see: https://trac.torproject.org/projects/tor/ticket/11751#comment:2
	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/lib/anon-ws-disable-stacked-tor/torbrowser.sh
	dodoc "${FILESDIR}/99torbrowser.example"
	dodoc "${FILESDIR}/torrc.example"

	dodoc "${WORKDIR}/profile/Browser/TorBrowser/Docs/ChangeLog.txt"
}

pkg_preinst() {
	xdg_pkg_preinst

	# If the apulse libs are available in MOZILLA_FIVE_HOME then apulse
	# does not need to be forced into the LD_LIBRARY_PATH
	if use pulseaudio && has_version ">=media-sound/apulse-0.1.12-r4" ; then
		einfo "APULSE found; Generating library symlinks for sound support ..."
		local lib
		pushd "${ED}${MOZILLA_FIVE_HOME}" &>/dev/null || die
		for lib in ../apulse/libpulse{.so{,.0},-simple.so{,.0}} ; do
			# A quickpkg rolled by hand will grab symlinks as part of the package,
			# so we need to avoid creating them if they already exist.
			if [[ ! -L ${lib##*/} ]] ; then
				ln -s "${lib}" ${lib##*/} || die
			fi
		done
		popd &>/dev/null || die
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	if use pulseaudio && has_version ">=media-sound/apulse-0.1.12-r4" ; then
		elog "Apulse was detected at merge time on this system and so it will always be"
		elog "used for sound.  If you wish to use pulseaudio instead please unmerge"
		elog "media-sound/apulse."
		elog
	fi

	if [[ -z "${REPLACING_VERSIONS}" ]] ; then
		ewarn "This patched firefox build is _NOT_ recommended by Tor upstream but uses"
		ewarn "the exact same sources. Use this only if you know what you are doing!"
		elog "Torbrowser uses port 9150 to connect to Tor. You can change the port"
		elog "in /etc/env.d/99torbrowser to match your setup."
		elog "An example file is available at /usr/share/doc/${P}/99torbrowser.example.bz2"
		elog ""
		elog "To get the advanced functionality (network information,"
		elog "new identity), Torbrowser needs to access a control port."
		elog "Set the Variables in /etc/env.d/99torbrowser accordingly."
	fi
}
