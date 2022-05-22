#!/bin/bash
# This script is meant for use with auto patching the PKGBUILD of linux-zen to add a KVM patch, and disable building kernel docs

curl -o kvm.patch "https://raw.githubusercontent.com/46620/patches/master/kvm.patch"
gpg --keyserver hkps://keys.openpgp.org --recv-key 3B94A80E50A477C7 # key fails normally, this is needed only for first run, but won't break the script if ran multiple times.
sed -i 's@pkgname=("$pkgbase" "$pkgbase-headers" "$pkgbase-docs")@pkgname=("$pkgbase" "$pkgbase-headers")@g' PKGBUILD
sed -i 's@make htmldocs@@g' PKGBUILD

ed PKGBUILD <<EOF
21i
  kvm.patch
.
w
q
EOF

updpkgsums

