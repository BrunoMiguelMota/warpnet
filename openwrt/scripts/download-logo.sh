#!/bin/bash

# WarpNET Logo Download Script
# Downloads and optimizes the WarpNET logo for firmware use

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="${SCRIPT_DIR}/../files"
LOGO_URL="https://warpnet.es/images/logowarpnet.png"
LOGO_DIR="${FILES_DIR}/www/luci-static/resources/icons"

echo "WarpNET Logo Download Script"
echo "==========================="

# Create logo directory if it doesn't exist
mkdir -p "${LOGO_DIR}"

# Download the logo
echo "Downloading WarpNET logo..."
if command -v wget >/dev/null 2>&1; then
    wget -O "${LOGO_DIR}/warpnet-logo.png" "${LOGO_URL}"
elif command -v curl >/dev/null 2>&1; then
    curl -o "${LOGO_DIR}/warpnet-logo.png" "${LOGO_URL}"
else
    echo "Error: Neither wget nor curl found. Please install one of them."
    echo "Manual download: ${LOGO_URL}"
    exit 1
fi

# Check if download was successful
if [ -f "${LOGO_DIR}/warpnet-logo.png" ]; then
    echo "Logo downloaded successfully!"
    
    # Try to optimize with ImageMagick if available
    if command -v convert >/dev/null 2>&1; then
        echo "Optimizing logo sizes..."
        cd "${LOGO_DIR}"
        
        # Create different sizes
        convert warpnet-logo.png -resize 64x64 warpnet-logo-64.png
        convert warpnet-logo.png -resize 128x128 warpnet-logo-128.png
        convert warpnet-logo.png -resize 256x256 warpnet-logo-256.png
        
        # Optimize PNG
        if command -v optipng >/dev/null 2>&1; then
            optipng -o7 *.png
        fi
        
        echo "Logo optimization complete!"
    else
        echo "ImageMagick not found. Logo downloaded but not optimized."
        echo "Install ImageMagick with: sudo apt install imagemagick"
    fi
    
    echo "Logo files:"
    ls -la "${LOGO_DIR}"/warpnet-logo*.png
else
    echo "Error: Logo download failed."
    echo "Please download manually from: ${LOGO_URL}"
    echo "Save to: ${LOGO_DIR}/warpnet-logo.png"
    exit 1
fi

echo ""
echo "Logo download complete! You can now build the firmware."