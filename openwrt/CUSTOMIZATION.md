# WarpNET Firmware Customization Guide

This guide explains how to customize the WarpNET firmware for your specific needs.

## Logo Replacement

### Step 1: Download the WarpNET Logo
```bash
# Download the official logo
wget https://warpnet.es/images/logowarpnet.png -O warpnet-logo.png

# Or use curl if wget is not available
curl -o warpnet-logo.png https://warpnet.es/images/logowarpnet.png
```

### Step 2: Optimize the Logo
```bash
# Install ImageMagick for image processing
sudo apt install imagemagick

# Create different sizes for various uses
convert warpnet-logo.png -resize 64x64 files/www/luci-static/resources/icons/warpnet-logo-64.png
convert warpnet-logo.png -resize 128x128 files/www/luci-static/resources/icons/warpnet-logo-128.png
convert warpnet-logo.png -resize 256x256 files/www/luci-static/resources/icons/warpnet-logo-256.png

# Replace the placeholder
cp warpnet-logo.png files/www/luci-static/resources/icons/warpnet-logo.png
```

## DNS Server Customization

### Adding Custom DNS Providers

Edit `files/usr/bin/warpnet-dns` to add new providers:

```bash
# Add this case to the set_provider function
"custom-provider")
    DOH_URL="https://your-dns-provider.com/dns-query"
    DOT_SERVERS="1.2.3.4 5.6.7.8"
    DOT_NAME="your-dns-provider.com"
    ;;
```

### Default DNS Server

To change the default DNS server, edit:
- DoH: `files/etc/config/https-dns-proxy`
- DoT: `files/etc/stubby/stubby.yml`

Example for Cloudflare:
```bash
# DoH Configuration
uci set https-dns-proxy.@https-dns-proxy[0].resolver_url='https://cloudflare-dns.com/dns-query'

# DoT Configuration (edit stubby.yml)
upstream_recursive_servers:
  - address_data: 1.1.1.1
    tls_auth_name: "cloudflare-dns.com"
  - address_data: 1.0.0.1
    tls_auth_name: "cloudflare-dns.com"
```

## Network Customization

### Default IP Address

Edit `files/etc/config/network`:
```bash
config interface 'lan'
    option ipaddr '192.168.10.1'  # Change from 192.168.1.1
    option netmask '255.255.255.0'
```

### WiFi Settings

Edit `files/etc/config/wireless`:
```bash
config wifi-iface 'default_radio0'
    option ssid 'YourCustomSSID'
    option key 'YourSecurePassword'
```

### Additional WAN Types

To add support for specific mobile carriers or VPN connections, modify `files/etc/config/network`.

## Branding Customization

### System Hostname
Edit `files/etc/config/system`:
```bash
config system
    option hostname 'YourBrand-Router'
```

### Login Banner
Edit `files/etc/banner` to customize the SSH login message.

### Web Interface Title
The version strings are set in `config/diffconfig`:
```bash
CONFIG_VERSION_DIST="YourBrand"
CONFIG_VERSION_NICK="YourBrand"
CONFIG_VERSION_MANUFACTURER="Your Company"
```

## Package Selection

### Adding Packages
Edit `config/diffconfig` to add more packages:
```bash
# VPN support
CONFIG_PACKAGE_openvpn-openssl=y
CONFIG_PACKAGE_luci-app-openvpn=y

# Network monitoring
CONFIG_PACKAGE_bandwidthd=y
CONFIG_PACKAGE_luci-app-statistics=y

# AdBlock
CONFIG_PACKAGE_adblock=y
CONFIG_PACKAGE_luci-app-adblock=y
```

### Removing Packages
To remove packages and save space:
```bash
# Disable IPv6 if not needed
# CONFIG_PACKAGE_ip6tables is not set
# CONFIG_PACKAGE_odhcp6c is not set
```

## Security Hardening

### Additional Firewall Rules
Edit `files/etc/config/firewall` to add custom rules:
```bash
# Block specific countries (requires geoip)
config rule
    option name 'Block-Country-XX'
    option src 'wan'
    option extra '-m geoip --src-cc XX'
    option target 'DROP'
```

### SSH Key Authentication
Add your SSH public key:
```bash
mkdir -p files/etc/dropbear
echo "ssh-rsa YOUR_PUBLIC_KEY_HERE" > files/etc/dropbear/authorized_keys
```

## Performance Tuning

### CPU Governor
For better performance on battery-powered setups:
```bash
# Add to first-boot script
echo 'performance' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

### Network Buffer Sizes
Add to `files/etc/sysctl.conf`:
```
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 12582912 16777216
net.ipv4.tcp_wmem = 4096 12582912 16777216
```

## Testing Your Customizations

### Local Testing
```bash
# Test configuration syntax
uci show -c config/

# Validate scripts
shellcheck files/usr/bin/warpnet-dns
shellcheck scripts/build.sh
```

### Build Testing
```bash
# Quick syntax check without full build
./scripts/build.sh
cd build/openwrt
make oldconfig
```

## Debugging

### Enable Debug Logging
Add to your configuration:
```bash
# In files/etc/config/system
config system
    option log_level '7'  # Debug level
```

### Network Debugging
```bash
# Add network diagnostic tools
CONFIG_PACKAGE_tcpdump=y
CONFIG_PACKAGE_netstat-nat=y
CONFIG_PACKAGE_ss=y
```

## Advanced Customizations

### Custom Init Scripts
Create additional scripts in `files/etc/init.d/` for custom services.

### Custom Web Pages
Add custom LuCI pages in `files/usr/lib/lua/luci/`.

### Package Feeds
To include packages from external feeds, edit the feeds configuration in the build script.

## Backup and Restore

### Configuration Backup
```bash
# Create a backup of your customizations
tar -czf warpnet-custom-$(date +%Y%m%d).tar.gz files/ config/
```

### Restore from Backup
```bash
# Restore customizations
tar -xzf warpnet-custom-YYYYMMDD.tar.gz
```

## Troubleshooting

### Build Failures
1. Check disk space (need 20GB+)
2. Verify all dependencies are installed
3. Clean build directory: `rm -rf build/`
4. Try single-threaded build: `make -j1 V=s`

### Runtime Issues
1. Check system logs: `logread`
2. Verify service status: `/etc/init.d/service-name status`
3. Test network connectivity: `ping 8.8.8.8`
4. Check DNS resolution: `nslookup google.com`

For more help, visit: https://warpnet.es