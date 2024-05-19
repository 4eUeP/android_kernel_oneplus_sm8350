#!/bin/bash
#
# Inside the container, e.g. android_kernel_builder
set -e

clean() {
    rm -rf ./out
}

build() {
    export KERNEL_CMDLINE="ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 O=out"
    make $KERNEL_CMDLINE "vendor/lahaina-qgki_defconfig"
    make $KERNEL_CMDLINE -j$(nproc)
}

packing() {
    cp -r AnyKernel3 out/AnyKernel3

    cp out/arch/arm64/boot/Image out/AnyKernel3/Image
    cat out/arch/arm64/boot/dts/vendor/oplus/lemonadev/*.dtb > out/AnyKernel3/dtb
    /usr/local/bin/mkdtboimg.py create out/AnyKernel3/dtbo.img out/arch/arm64/boot/dts/vendor/oplus/lemonadev/*.dtbo
    cp build/anykernel.sh out/AnyKernel3/anykernel.sh
    cd out/AnyKernel3 && zip -r9 lemonadep-$(/bin/date -u '+%Y%m%d-%H%M').zip * -x .git README.md *placeholder
}

clean
build
packing
