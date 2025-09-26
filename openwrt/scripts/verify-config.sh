#!/bin/bash

# WarpNET Configuration Verification Script
# Checks that all required files are present and valid

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENWRT_DIR="${SCRIPT_DIR}/.."
FILES_DIR="${OPENWRT_DIR}/files"
CONFIG_DIR="${OPENWRT_DIR}/config"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
    else
        echo -e "${RED}✗${NC} $description (missing: $file)"
        ((ERRORS++))
    fi
}

check_executable() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            echo -e "${GREEN}✓${NC} $description"
        else
            echo -e "${YELLOW}⚠${NC} $description (not executable: $file)"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}✗${NC} $description (missing: $file)"
        ((ERRORS++))
    fi
}

check_syntax() {
    local file="$1"
    local description="$2"
    local interpreter="$3"
    
    if [ -f "$file" ]; then
        if $interpreter -n "$file" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $description syntax"
        else
            echo -e "${RED}✗${NC} $description syntax error"
            ((ERRORS++))
        fi
    fi
}

echo "WarpNET Configuration Verification"
echo "=================================="
echo ""

echo "Checking core configuration files..."
check_file "$CONFIG_DIR/diffconfig" "OpenWrt build configuration"
echo ""

echo "Checking system configuration files..."
check_file "$FILES_DIR/etc/banner" "SSH login banner"
check_file "$FILES_DIR/etc/config/network" "Network configuration"
check_file "$FILES_DIR/etc/config/wireless" "Wireless configuration"
check_file "$FILES_DIR/etc/config/firewall" "Firewall configuration"
check_file "$FILES_DIR/etc/config/dhcp" "DHCP configuration"
check_file "$FILES_DIR/etc/config/system" "System configuration"
check_file "$FILES_DIR/etc/config/https-dns-proxy" "DoH configuration"
check_file "$FILES_DIR/etc/stubby/stubby.yml" "DoT configuration"
echo ""

echo "Checking scripts and executables..."
check_executable "$FILES_DIR/etc/init.d/warpnet-setup" "First-boot setup script"
check_executable "$FILES_DIR/usr/bin/warpnet-dns" "DNS management tool"
check_executable "$SCRIPT_DIR/build.sh" "Build script"
check_executable "$SCRIPT_DIR/../../build-warpnet.sh" "Build helper script"
check_executable "$SCRIPT_DIR/download-logo.sh" "Logo download script"
echo ""

echo "Checking script syntax..."
check_syntax "$FILES_DIR/etc/init.d/warpnet-setup" "Init script" "sh"
check_syntax "$FILES_DIR/usr/bin/warpnet-dns" "DNS management script" "sh"
check_syntax "$SCRIPT_DIR/build.sh" "Build script" "bash"
check_syntax "$SCRIPT_DIR/../../build-warpnet.sh" "Build helper script" "bash"
echo ""

echo "Checking LuCI web interface files..."
check_file "$FILES_DIR/usr/lib/lua/luci/controller/warpnet.lua" "LuCI controller"
check_file "$FILES_DIR/usr/lib/lua/luci/model/cbi/warpnet/dns.lua" "DNS configuration page"
echo ""

echo "Checking documentation..."
check_file "$OPENWRT_DIR/../README.md" "Main README"
check_file "$OPENWRT_DIR/CUSTOMIZATION.md" "Customization guide"
echo ""

echo "Checking optional files..."
if [ -f "$FILES_DIR/www/luci-static/resources/icons/warpnet-logo.png" ]; then
    echo -e "${GREEN}✓${NC} WarpNET logo file"
else
    echo -e "${YELLOW}⚠${NC} WarpNET logo file (run scripts/download-logo.sh to download)"
    ((WARNINGS++))
fi
echo ""

echo "Verification Summary:"
echo "===================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All required files present${NC}"
else
    echo -e "${RED}✗ $ERRORS errors found${NC}"
fi

if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ No warnings${NC}"
else
    echo -e "${YELLOW}⚠ $WARNINGS warnings${NC}"
fi

echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}Configuration verification passed!${NC}"
    echo "You can now build the firmware with: ./build-warpnet.sh full"
    exit 0
else
    echo -e "${RED}Configuration verification failed!${NC}"
    echo "Please fix the errors above before building."
    exit 1
fi