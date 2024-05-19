# Building OnePlus9Pro LineageOS kernel from source

## Preparation

There is a `Dockerfile` under the `build` directory in this repo that will set
up the build environment for you. You can use it to build the kernel.

For example,

```sh
cd build
docker build . -f Dockerfile -t android_kernel_builder
```

## Building kernel

### Getting source

```sh
# oneplus_sm8350
git clone --depth=1 https://github.com/LineageOS/android_kernel_oneplus_sm8350.git
```

### Finding the default config

To find the default config, you can check the `BoardConfigCommon.mk` file in the
<https://github.com/LineageOS/android_device_oneplus_sm8350-common>
(`oneplus_sm8350`) repo.

For example,

```
...
TARGET_KERNEL_CONFIG := vendor/lahaina-qgki_defconfig
...
```

The default config is `vendor/lahaina-qgki_defconfig`. All the configs are under
the `arch/arm64/configs` directory in the kernel source tree.

### Building

Start the container:

```sh
cd android_kernel_oneplus_sm8350

# Also, you may want to use `-m` to set the memory limit for the container
docker run -it --rm -u $(id -u):$(id -g) \
    -v $(pwd):/srv -w /srv android_kernel_builder bash
```

Inside the container:

```sh
export KERNEL_CMDLINE="ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 O=out"
# with default config we found above
make $KERNEL_CMDLINE "vendor/lahaina-qgki_defconfig"
make $KERNEL_CMDLINE -j$(nproc)
```

### Packing with AnyKernel3

First, create your own `anykernel.sh` file. You can use the `build/anykernel.sh`
in this repo as an example.

Fetch the `AnyKernel3` repo:

```sh
# Tested with commit 458caeda335554c58930bf6dbfa23e829911e338(Nov 6, 2023)
git clone --depth=1 https://github.com/osm0sis/AnyKernel3.git out/AnyKernel3
```

Packing:

```sh
# Inside the container
cp out/arch/arm64/boot/Image out/AnyKernel3/Image
cat out/arch/arm64/boot/dts/vendor/oplus/lemonadev/*.dtb > out/AnyKernel3/dtb
/usr/local/bin/mkdtboimg.py create out/AnyKernel3/dtbo.img out/arch/arm64/boot/dts/vendor/oplus/lemonadev/*.dtbo

# You can use your own `anykernel.sh` file
cp build/anykernel.sh out/AnyKernel3/anykernel.sh

cd out/AnyKernel3 && zip -r9 lemonadep-$(/bin/date -u '+%Y%m%d-%H%M').zip * -x .git README.md *placeholder
```

## Building kernel with KernelSu

The step is similar to the above. You only need to do is to integrate the
`KernelSu`. (This repo is already done this, and you can use it directly if you
want.)

### How to integrate the KernelSu?

Also see: <https://kernelsu.org/guide/how-to-integrate-for-non-gki.html>

Add KernelSU to the kernel source tree:

```sh
# I personally do NOT recommend you use the following one line command:
#
# $ curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
#
# Instead, you should download the script and check it before you run it.

# Under the kernel source directory
curl -LSs -o /tmp/setup_ksu.sh "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh"
# check it... and run
bash /tmp/setup_ksu.sh
```

Then check the follow config is enabled in your config(e.g.
`arch/arm64/configs/vendor/lahaina-qgki_defconfig`)

```
CONFIG_KPROBES=y
CONFIG_HAVE_KPROBES=y
CONFIG_KPROBE_EVENTS=y
```

## Acknowledgments

- [LineageOS](https://github.com/LineageOS/android_kernel_oneplus_sm8350)
- [KernelSu](https://github.com/tiann/KernelSU)
- [AnyKernel3](https://github.com/osm0sis/AnyKernel3)
- <https://github.com/awakened1712/android_kernel_oneplus_sm8350>
- <https://github.com/lateautumn233/android_kernel_oneplus_sm8250>
- <https://github.com/Kernel-SU/AnyKernel3>
