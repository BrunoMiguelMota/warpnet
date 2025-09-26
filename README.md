# WarpNET OpenWrt Firmware for GL.iNet Flint 3 (GL-BE9300)

A custom OpenWrt firmware configuration branded as **WarpNET** with enterprise-grade security features, secure DNS, and multi-WAN support.

## Features

### 🔒 Security
- **Secure DNS**: Pre-configured DNS-over-HTTPS (DoH) and DNS-over-TLS (DoT)
- **DNS Firewall**: Blocks all non-secure DNS traffic from LAN clients
- **Default Provider**: Quad9 secure DNS (9.9.9.9)
- **Custom DNS**: Support for custom secure DNS servers via web UI

### 🌐 Network Support
- **Multi-WAN**: DHCP, PPPoE, Static IP, USB tethering, Hotspot
- **Auto-configuration**: All WAN types supported and auto-configured
- **Load Balancing**: Support for multiple WAN connections

### 🎨 Branding
- **Custom Branding**: WarpNET logo and branding throughout
- **Custom Banner**: ASCII art banner on SSH login
- **Web Interface**: Branded LuCI web interface

### 🚀 Automation
- **Zero Configuration**: All features enabled and configured on first boot
- **No Manual Steps**: Flash and use immediately
- **English UI**: Default language set to English

## Quick Start

### Prerequisites
- Linux build environment (Ubuntu 20.04+ recommended)
- At least 20GB free disk space
- 8GB+ RAM recommended
- Git and build tools installed

### Build Instructions

1. **Clone this repository**:
   ```bash
   git clone https://github.com/BrunoMiguelMota/warpnet.git
   cd warpnet/openwrt
   ```

2. **Install build dependencies** (Ubuntu/Debian):
   ```bash
   sudo apt update
   sudo apt install build-essential ccache ecj fastjar file g++ gawk \
   gettext git java-propose-classpath libelf-dev libncurses5-dev \
   libncursesw5-dev libssl-dev python3 python3-dev python3-distutils \
   python3-setuptools rsync subversion swig time unzip wget xsltproc \
   zlib1g-dev
   ```

3. **Run the build script**:
   ```bash
   ./scripts/build.sh
   ```

4. **Build the firmware** (after script completes):
   ```bash
   cd build/openwrt
   make -j$(nproc)
   ```

### Manual Build (Alternative)

If you prefer to build manually or customize further:

1. **Download OpenWrt 23.05.4**:
   ```bash
   git clone https://git.openwrt.org/openwrt/openwrt.git
   cd openwrt
   git checkout v23.05.4
   ```

2. **Update feeds**:
   ```bash
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```

3. **Apply WarpNET configuration**:
   ```bash
   cp ../config/diffconfig .config
   make oldconfig
   ```

4. **Copy custom files**:
   ```bash
   cp -r ../files .
   ```

5. **Optional: Customize configuration**:
   ```bash
   make menuconfig
   ```

6. **Build**:
   ```bash
   make -j$(nproc)
   ```

## Flashing Instructions

### For GL.iNet Flint 3 (GL-BE9300)

1. **Locate the firmware**: After building, find the sysupgrade file:
   ```
   bin/targets/mediatek/filogic/openwrt-mediatek-filogic-glinet_gl-be9300-squashfs-sysupgrade.bin
   ```

2. **Flash via web interface**:
   - Connect to your GL.iNet router
   - Go to the admin panel (usually http://192.168.8.1)
   - Navigate to System → Firmware Upgrade
   - Upload the sysupgrade.bin file
   - Wait for the upgrade to complete

3. **Flash via SSH** (advanced users):
   ```bash
   scp openwrt-*-sysupgrade.bin root@192.168.8.1:/tmp/
   ssh root@192.168.8.1
   sysupgrade -v /tmp/openwrt-*-sysupgrade.bin
   ```

## Post-Flash Configuration

**No manual configuration needed!** WarpNET firmware is fully automated:

- ✅ Secure DNS (DoH/DoT) automatically enabled
- ✅ DNS firewall rules applied
- ✅ All WAN types pre-configured
- ✅ Web interface ready at http://192.168.1.1
- ✅ SSH access available (OpenWrt defaults)

### Default Settings

- **Router IP**: 192.168.1.1
- **WiFi**: OpenWrt defaults (configurable via web interface)
- **SSH**: root user (set password on first login)
- **DNS**: Quad9 secure DNS (9.9.9.9)
- **Firewall**: Secure DNS enforcement enabled

## Customization

### Changing DNS Provider

Via web interface:
1. Go to WarpNET → Secure DNS
2. Select your preferred provider or enter custom server
3. Choose DoH, DoT, or both protocols
4. Apply changes

### Adding WAN Connections

All WAN types are pre-configured but disabled:
1. Go to Network → Interfaces
2. Enable the desired WAN type (PPPoE, Static, USB, etc.)
3. Configure connection details
4. Save and apply

### Logo Replacement

Replace the placeholder logo with the actual WarpNET logo:
```bash
# Download the logo
wget https://warpnet.es/images/logowarpnet.png

# Convert to appropriate sizes and copy to firmware files
cp logowarpnet.png openwrt/files/www/luci-static/resources/icons/warpnet-logo.png
```

## File Structure

```
openwrt/
├── config/
│   └── diffconfig              # OpenWrt build configuration
├── files/                      # Custom firmware files
│   ├── etc/
│   │   ├── banner             # Custom SSH banner
│   │   ├── config/            # System configurations
│   │   ├── init.d/            # Init scripts
│   │   └── stubby/            # DNS-over-TLS config
│   ├── usr/lib/lua/luci/      # LuCI web interface
│   └── www/                   # Web assets
├── patches/                   # OpenWrt patches (if needed)
└── scripts/
    └── build.sh              # Build automation script
```

## Technical Details

### Target Device
- **Device**: GL.iNet Flint 3 (GL-BE9300)
- **Architecture**: MediaTek MT7981
- **Platform**: mediatek/filogic
- **Flash**: 128MB NAND
- **RAM**: 1GB DDR4

### Secure DNS Implementation
- **DoH**: https-dns-proxy on port 5053
- **DoT**: stubby on port 5054
- **Fallback**: Both services for redundancy
- **Enforcement**: Firewall blocks port 53 (traditional DNS)

### Network Features
- **Multi-WAN**: Automatic failover and load balancing
- **USB Tethering**: Support for mobile broadband
- **Hotspot**: Share internet via WiFi hotspot
- **IPv6**: Full dual-stack support

## Troubleshooting

### Build Issues
- Ensure all dependencies are installed
- Check available disk space (20GB+ required)
- Try building with fewer parallel jobs: `make -j1`

### DNS Issues
- Check secure DNS services: `/etc/init.d/https-dns-proxy status`
- Verify firewall rules: `iptables -L | grep 53`
- Test DNS resolution: `nslookup google.com 127.0.0.1`

### Network Issues
- Check interface status: `ip addr show`
- Verify WAN connection: `ping -c 3 8.8.8.8`
- Review network config: `cat /etc/config/network`

## Support

For issues and feature requests:
- **Website**: https://warpnet.es
- **Email**: info@warpnet.es
- **GitHub**: https://github.com/BrunoMiguelMota/warpnet

## License

This firmware configuration is provided as-is for the WarpNET project. OpenWrt components retain their original licenses.

---

**WarpNET** - Enterprise-grade security for your network infrastructure.