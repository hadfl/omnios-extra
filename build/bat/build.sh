#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=bat
VER=0.24.0
PKG=ooce/util/bat
SUMMARY="A cat clone with wings"
DESC="A cat(1) clone with syntax highlighting and Git integration."

BUILD_DEPENDS_IPS="
    ooce/developer/rust
"

set_arch 64

# ansi_colours wants gnu-ar
export AR="$USRBIN/gar"

export RUSTFLAGS="-C link-arg=-R$PREFIX/lib/amd64"

init
download_source $PROG v$VER
patch_source
prep_build
PKG_CONFIG_PATH=${PKG_CONFIG_PATH[amd64]} RUSTONIG_SYSTEM_LIBONIG=1 build_rust
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
