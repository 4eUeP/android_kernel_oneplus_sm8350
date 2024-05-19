FROM debian:trixie

RUN apt-get update && apt-get install -y \
      bc binutils bison build-essential flex cpio make \
      gcc-aarch64-linux-gnu clang libclang-dev llvm-dev lld \
      python3 libssl-dev ca-certificates xz-utils git zip curl

# Or use the main branch:
# https://android.googlesource.com/platform/system/libufdt/+/refs/heads/main/utils/src/mkdtboimg.py
RUN curl -s https://android.googlesource.com/platform/system/libufdt/+/66e4db632d6018faf99acd108f61c2a4695421c7/utils/src/mkdtboimg.py?format=TEXT \
      | base64 -d > /usr/local/bin/mkdtboimg.py && \
    chmod +x /usr/local/bin/mkdtboimg.py

RUN echo "root:toor" | chpasswd && useradd -u 1000 -m builder
