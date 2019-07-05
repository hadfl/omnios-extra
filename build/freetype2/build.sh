#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=freetype
DOWNLOADDIR=freetype2
VER=2.10.1
PKG=ooce/library/freetype2
SUMMARY="A Free, High-Quality, and Portable Font Engine"
DESC="$SUMMARY"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
    --disable-static
    --enable-freetype-config
"

CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin/$ISAPART64
    --libdir=$OPREFIX/lib/$ISAPART64
"

init
download_source $DOWNLOADDIR $PROG $VER
patch_source
prep_build
build -ctf
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
