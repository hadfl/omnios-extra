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

PROG=dnsmasq
VER=2.90
PKG=ooce/network/dnsmasq
SUMMARY="Lightweight, easy to configure DNS forwarder"
DESC="dnsmasq is a lightweight, easy to configure DNS forwarder, designed to "
DESC+="provide DNS (and optionally DHCP and TFTP) services to a small-scale "
DESC+="network."

set_arch 64
set_clangver

export PATH=$GNUBIN:$PATH

BASEDIR=$PREFIX/$PROG
CONFFILE=/etc$BASEDIR/$PROG.conf
EXECFILE=$PREFIX/sbin/dnsmasq

copy_sample_config() {
    local relative_conffile=${CONFFILE#/}
    local dest_confdir=$DESTDIR/${relative_conffile%/*}

    logmsg "-- copying sample config"
    logcmd $MKDIR -p "$dest_confdir" || logerr "mkdir failed"
    logcmd $CP $TMPDIR/$BUILDDIR/$PROG.conf.example \
        $DESTDIR/$relative_conffile || logerr "copying configs failed"
}

# something in the build framework is complaining about not finding the nettle headers
# however, the compiler is happy to build stuff
EXPECTED_BUILD_ERRS=2

pre_configure() {
    typeset arch=$1

    MAKE_ARGS_WS="
        CC=$CC
        CFLAGS=\"$CFLAGS ${CFLAGS[$arch]}\"
        LDFLAGS=\"$LDFLAGS ${LDFLAGS[$arch]}\"
        PREFIX=$PREFIX
        MANDIR=$PREFIX/share/man
        COPTS=\"-DNO_IPSET -DHAVE_DNSSEC\"
        sunos_libs=\"-lnsl -lsocket\"
        nettle_cflags=\"-I/usr/include/gmp -I$PREFIX/include\"
        nettle_libs=\"-L$PREFIX/${LIBDIRS[$arch]} -Wl,-R$PREFIX/${LIBDIRS[$arch]} -lnettle -lhogweed\"
    "

    MAKE_INSTALL_ARGS_WS="
        PREFIX=$PREFIX
        MANDIR=$PREFIX/share/man
        COPTS=\"-DNO_IPSET -DHAVE_DNSSEC\"
    "

    # no configure
    false
}

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DBASEDIR=${BASEDIR#/}
    -DEXECFILE=$EXECFILE
    -DCONFFILE=$CONFFILE
    -DUSER=$PROG
    -DGROUP=$PROG
    -DPROG=$PROG
"

init
download_source "$PROG" "$PROG" "$VER"
patch_source
prep_build
build
copy_sample_config
xform files/$PROG.xml > $TMPDIR/$PROG.xml
install_smf ooce $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
