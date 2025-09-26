#!/bin/bash

# WarpNET Firmware Build Helper Script
# Simplified interface for building WarpNET firmware

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENWRT_DIR="${SCRIPT_DIR}/openwrt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${BLUE}"
    echo " __      __                 _   _ ______ _______ "
    echo " \\ \\    / /                | \\ | |  ____|__   __|"
    echo "  \\ \\  / /  ___  _ __  _ __ |  \\| | |__     | |   "
    echo "   \\ \\/ /  / _ \\| '_ \\| '_ \\| . \` |  __|    | |   "
    echo "    \\  /  | (_) | |_) | |_) | |\\  | |____   | |   "
    echo "     \\/    \\___/| .__/| .__/|_| \\_|______|  |_|   "
    echo "                | |   | |                         "
    echo "                |_|   |_|                         "
    echo ""
    echo " WarpNET Firmware Builder for GL.iNet Flint 3"
    echo -e "${NC}"
}

show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup     - Install build dependencies (Ubuntu/Debian)"
    echo "  prepare   - Download OpenWrt and prepare build environment"
    echo "  build     - Build the firmware"
    echo "  clean     - Clean build directory"
    echo "  full      - Do setup, prepare and build (complete process)"
    echo "  help      - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 full       # Complete build process"
    echo "  $0 build      # Just build (after prepare)"
    echo "  $0 clean      # Clean up build files"
    echo ""
}

install_dependencies() {
    echo -e "${YELLOW}Installing build dependencies...${NC}"
    
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y \
            build-essential ccache ecj fastjar file g++ gawk \
            gettext git java-propose-classpath libelf-dev libncurses5-dev \
            libncursesw5-dev libssl-dev python3 python3-dev python3-distutils \
            python3-setuptools rsync subversion swig time unzip wget xsltproc \
            zlib1g-dev
    elif command -v yum >/dev/null 2>&1; then
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y \
            gawk gettext git-core libncurses-devel openssl-devel \
            python3-devel rsync unzip wget which zlib-devel
    else
        echo -e "${RED}Error: Unsupported package manager. Please install dependencies manually.${NC}"
        echo "Required packages are listed in the README.md file."
        exit 1
    fi
    
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
}

prepare_build() {
    echo -e "${YELLOW}Preparing build environment...${NC}"
    
    cd "${SCRIPT_DIR}"
    
    # Run the OpenWrt build preparation script
    "${OPENWRT_DIR}/scripts/build.sh"
    
    echo -e "${GREEN}Build environment prepared!${NC}"
}

build_firmware() {
    echo -e "${YELLOW}Building WarpNET firmware...${NC}"
    
    BUILD_DIR="${OPENWRT_DIR}/build/openwrt"
    
    if [ ! -d "$BUILD_DIR" ]; then
        echo -e "${RED}Error: Build directory not found. Run 'prepare' first.${NC}"
        exit 1
    fi
    
    cd "$BUILD_DIR"
    
    # Get number of CPU cores for parallel build
    CORES=$(nproc)
    
    echo -e "${BLUE}Building with ${CORES} parallel jobs...${NC}"
    
    # Build the firmware
    make -j"${CORES}" || {
        echo -e "${RED}Build failed with parallel jobs. Trying single-threaded...${NC}"
        make -j1 V=s
    }
    
    echo -e "${GREEN}Build completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Firmware location:${NC}"
    find bin/targets/ -name "*sysupgrade.bin" -o -name "*factory.bin" | head -5
    echo ""
    echo -e "${YELLOW}Flash the sysupgrade.bin file to your GL.iNet Flint 3${NC}"
}

clean_build() {
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    
    BUILD_DIR="${OPENWRT_DIR}/build"
    
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
        echo -e "${GREEN}Build directory cleaned!${NC}"
    else
        echo -e "${BLUE}Build directory already clean.${NC}"
    fi
}

check_requirements() {
    echo -e "${BLUE}Checking system requirements...${NC}"
    
    # Check disk space (need at least 20GB)
    AVAILABLE_SPACE=$(df . | awk 'NR==2 {print $4}')
    REQUIRED_SPACE=$((20 * 1024 * 1024)) # 20GB in KB
    
    if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
        echo -e "${RED}Error: Insufficient disk space. Need at least 20GB free.${NC}"
        echo "Available: $(($AVAILABLE_SPACE / 1024 / 1024))GB"
        exit 1
    fi
    
    # Check memory (recommended 8GB)
    TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
    if [ "$TOTAL_MEM" -lt 6144 ]; then
        echo -e "${YELLOW}Warning: Less than 8GB RAM detected. Build might be slow.${NC}"
    fi
    
    echo -e "${GREEN}System requirements check passed.${NC}"
}

main() {
    print_banner
    
    case "${1:-help}" in
        "setup")
            install_dependencies
            ;;
        "prepare")
            check_requirements
            prepare_build
            ;;
        "build")
            check_requirements
            build_firmware
            ;;
        "clean")
            clean_build
            ;;
        "full")
            check_requirements
            install_dependencies
            prepare_build
            build_firmware
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

main "$@"