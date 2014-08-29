#!/bin/bash
# Prepare B3 image, switching off cache, and appending DTB; also
# builds the modules. Results go to deploy_root directory.
# Execute in top-level kernel directory.
# Copyright (c) 2014 sakaki <sakaki@deciban.com>
# License: GPL 3.0+
# NO WARRANTY
set -e
set -u
DR="deploy_root"
die() { cat <<< "$@" 1>&2; exit 1; }
if [ ! -d "${DR}" ]; then
    echo "Creating directory: ${DR}"
    mkdir "${DR}"
fi
echo "Cleaning prior ${DR}..."
if [ -d "${DR}/boot" ]; then
    rm -rf "${DR}/boot"
fi
if [ -d "${DR}/lib" ]; then
    rm -rf "${DR}/lib"
fi
if [ -s "${DR}.tar" ]; then
    rm -f "${DR}.tar"
fi

NUMTHREADS=$(( $(grep -E 'processor\s+:' /proc/cpuinfo | wc -l) + 1 ))
KNAME="$(basename "${PWD}")"
KNAME="${KNAME/linux-/Linux }"

echo "Compiling kernel (${KNAME})..."
make -j${NUMTHREADS} ARCH=arm CROSS_COMPILE=armv5tel-softfloat-linux-gnueabi- \
  zImage
echo "Compiling DTB..."
make ARCH=arm CROSS_COMPILE=armv5tel-softfloat-linux-gnueabi- kirkwood-b3.dtb
echo "Compiling modules..."
make -j${NUMTHREADS} ARCH=arm CROSS_COMPILE=armv5tel-softfloat-linux-gnueabi- \
  modules
echo "Installing modules to ${DR}..."
make ARCH=arm CROSS_COMPILE=armv5tel-softfloat-linux-gnueabi- \
  INSTALL_MOD_PATH="${DR}" modules_install
echo "Creating patched image for B3 (caches off, DTB appended)..."
pushd arch/arm/boot
# per Debian workaround #658904 (credit: Ian Campbell)
echo -n -e \\x11\\x3f\\x3f\\xee >  cache_head_patch
echo -n -e \\x01\\x35\\xc3\\xe3 >> cache_head_patch
echo -n -e \\x11\\x3f\\x2f\\xee >> cache_head_patch
echo -n -e \\x00\\x30\\xa0\\xe3 >> cache_head_patch
echo -n -e \\x17\\x3f\\x07\\xee >> cache_head_patch
cat cache_head_patch zImage dts/kirkwood-b3.dtb > zImage-dts-appended
rm cache_head_patch
mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 \
  -n "Gentoo ARM: ${KNAME}" -d zImage-dts-appended ../../../uImage
popd
echo "Final uImage has been created, copying to ${DR}..."
mkdir -p "${DR}/boot"
cp -v uImage "${DR}/boot/uImage"
cp -v System.map "${DR}/boot/System.map"
cp -v .config "${DR}/boot/config"
find "${DR}/lib/modules" -type l -name 'build' -delete
find "${DR}/lib/modules" -type l -name 'source' -delete
echo "Creating tarball..."
tar cf "${DR}.tar" "${DR}"
echo "Syncing filesystems, please wait..."
sync
echo "All done!"
