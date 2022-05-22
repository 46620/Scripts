#!/bin/bash
# This script is meant for use with auto patching the PKGBUILD of linux-zen to add a KVM patch, and disable building kernel docs

sed -i 's@pkgbase=linux-lts@pkgbase=linux-lts-server@g' PKGBUILD
sed -i 's@pkgname=("$pkgbase" "$pkgbase-headers" "$pkgbase-docs")@pkgname=("$pkgbase" "$pkgbase-headers")@g' PKGBUILD
sed -i 's@make htmldocs@@g' PKGBUILD

ed PKGBUILD <<EOF
69i
  yes n | make LSMOD=/etc/modprobed.db localmodconfig
.
w
q
EOF

updpkgsums

