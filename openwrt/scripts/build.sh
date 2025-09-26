#!/bin/bash

# WarpNET OpenWrt Build Script for GL.iNet Flint 3 (GL-BE9300)

set -e

OPENWRT_VERSION="23.05.4"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/../build"
CONFIG_DIR="${SCRIPT_DIR}/../config"
FILES_DIR="${SCRIPT_DIR}/../files"

echo "=== WarpNET OpenWrt Build Script ==="
echo "Target: GL.iNet Flint 3 (GL-BE9300)"
echo "OpenWrt Version: ${OPENWRT_VERSION}"
echo ""

# Create build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Download OpenWrt if not exists
if [ ! -d "openwrt" ]; then
    echo "Downloading OpenWrt ${OPENWRT_VERSION}..."
    git clone https://git.openwrt.org/openwrt/openwrt.git
    cd openwrt
    git checkout "v${OPENWRT_VERSION}"
else
    echo "Using existing OpenWrt source..."
    cd openwrt
fi

# Update feeds
echo "Updating feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# Copy configuration
echo "Applying WarpNET configuration..."
cp "${CONFIG_DIR}/diffconfig" .config

# Copy custom files
echo "Copying custom files..."
rm -rf files
cp -r "${FILES_DIR}" files

# Make oldconfig to resolve dependencies
make oldconfig

echo ""
echo "=== Build Configuration Complete ==="
echo ""
echo "To build the firmware:"
echo "1. cd ${BUILD_DIR}/openwrt"
echo "2. make menuconfig  # (optional - review config)"
echo "3. make -j\$(nproc)  # build firmware"
echo ""
echo "The firmware will be in bin/targets/mediatek/filogic/"
echo ""
echo "Flash the *-sysupgrade.bin file to your GL.iNet Flint 3"