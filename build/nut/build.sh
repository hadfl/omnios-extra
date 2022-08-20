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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=nut
VER=2.8.0
PKG=ooce/system/nut
SUMMARY="Network UPS Tools"
DESC="Network UPS Tools is a collection of programs which provide a common "
DESC+="interface for monitoring and administering UPS, PDU and SCD hardware."

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

SKIP_RTIME_CHECK=1

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --without-doc
    --disable-static
    --with-usb
    --with-snmp
    LT_SYS_LIBRARY_PATH=$OPREFIX/lib/$ISAPART64
"
LDFLAGS64+=" -R$OPREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
#install_smf ooce system-smartd.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
