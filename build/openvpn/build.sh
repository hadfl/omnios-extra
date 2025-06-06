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
#
# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=openvpn
VER=2.6.14
PKG=ooce/network/openvpn
LZOVER=2.10
SUMMARY="OpenVPN"
DESC="Flexible VPN solutions to secure your data communications, whether it's "
DESC+="for Internet privacy, remote access for employees, securing IoT, "
DESC+="or for networking Cloud data centers"

# PLUGIN VERSIONS
# source from https://github.com/skvadrik/re2c (required to build auth-ldap)
RE2CVER=3.1
AUTHLDAPVER=2.0.4

SKIP_LICENCES=Various

OPREFIX=$PREFIX
PREFIX+="/$PROG"

BUILD_DEPENDS_IPS="driver/tuntap compress/lz4"
RUN_DEPENDS_IPS="driver/tuntap"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG -DVER=$VER
    -DPKGROOT=$PROG
"

set_arch 64

init
prep_build

#########################################################################

save_buildenv

# Download and build a static version of liblzo
CONFIGURE_OPTS="--disable-shared"

build_dependency lzo lzo-$LZOVER lzo lzo $LZOVER
export LZO_CFLAGS="-I$DEPROOT/$PREFIX/include"
export LZO_LIBS="-L$DEPROOT/$PREFIX/lib/amd64 -llzo2"

restore_buildenv

#########################################################################

CPPFLAGS+=" -DOOCEVER=$RELVER"

CONFIGURE_OPTS[amd64]+="
    --includedir=$OPREFIX/include
    --libdir=$OPREFIX/lib/amd64
"

download_source $PROG $PROG $VER
patch_source
run_autoreconf -fi
build
install_smf ooce network-openvpn.xml
make_package $PROG.mog

#########################################################################

# Download and build auth-ldap plugin

#########################################################################

PROG=auth-ldap
VER=$AUTHLDAPVER
PKG=ooce/network/openvpn-auth-ldap
SUMMARY="OpenVPN Auth-LDAP Plugin"
DESC="username/password authentication via LDAP for OpenVPN 2.x."

OVPNDIR=$DESTDIR$OPREFIX/include
PLUGINDIR=$OPREFIX/lib/amd64/openvpn/plugins

set_patchdir patches-$PROG
RUN_DEPENDS_IPS="ooce/network/openvpn"

set_builddir openvpn-$PROG-$PROG-$VER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG -DVER=$VER
"

export MAKE

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

init
prep_build

#########################################################################

# Download and build re2c which is required to build auth-ldap
build_dependency -noctf re2c re2c-$RE2CVER openvpn/re2c re2c $RE2CVER # C++
export PATH+=":$DEPROOT/$PREFIX/bin"

#########################################################################

pre_install() {
    # the install target does not create the directory
    logcmd mkdir -p $DESTDIR$PLUGINDIR || logerr "mkdir failed"
}

CONFIGURE_OPTS[amd64]="
    --libdir=$PLUGINDIR
    --with-openldap=$OPREFIX
    --with-openvpn=$OVPNDIR
    OBJC=$CC
    OBJCFLAGS=-std=gnu11
"
CFLAGS+=" -fPIC"

download_source openvpn/$PROG $PROG $VER
patch_source
run_inbuild "./regen.sh"
build
make_package $PROG.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
