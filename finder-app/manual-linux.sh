#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}	

cd "$OUTDIR"

if [ ! -d "${OUTDIR}/linux-stable" ]; then #Esto funciona solo con el directorio temporal, para el actual tendre que utilizar una ruta absoluta
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
   cd linux-stable
   echo "Checking out version ${KERNEL_VERSION}"
   git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    echo "Ejecutar mrproper"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper #deep clean. Remove .config file with any existing configuration
    echo "mrproper done"
    echo "Ejecutar defconfig"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig #Configure the build for our virtual device for QEMU with a defined .config
    echo "defconfig done"
    echo "Ejecutar Build kernel"
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all #Build a kernel image for booting with QEMU
    echo "Build kernel done"
    echo "Build kernel modules"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules #Build any kernel modules
    echo "Build kernel modules done"
    echo "Build the device tree"
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs #Build the devicetree
    echo "Build device tree done"
    
fi

echo "Adding the Image in ${OUTDIR}"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p rootfs
cd rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install


cd ..
cd rootfs
echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
cp /home/oscar/Documentos/github/LinuxSP/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib

cp /home/oscar/Documentos/github/LinuxSP/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64

cp /home/oscar/Documentos/github/LinuxSP/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64

cp /home/oscar/Documentos/github/LinuxSP/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu/libc/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64

# TODO: Make device nodes
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE


# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp writer ${OUTDIR}/rootfs/home
cp finder.sh ${OUTDIR}/rootfs/home
mkdir ${OUTDIR}/rootfs/home/conf
cp conf/username.txt ${OUTDIR}/rootfs/home/conf
cp conf/assignment.txt ${OUTDIR}/rootfs/home/conf
cp finder-test.sh ${OUTDIR}/rootfs/home
cp autorun-qemu.sh ${OUTDIR}/rootfs/home

# TODO: Chown the root directory
cd ${OUTDIR}/rootfs/
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
cd "$OUTDIR/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f ../initramfs.cpio

