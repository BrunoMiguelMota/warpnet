-- WarpNET Secure DNS Configuration Interface
require("luci.sys")

m = Map("warpnet-dns", "WarpNET Secure DNS Configuration", 
    "Configure DNS-over-HTTPS (DoH) and DNS-over-TLS (DoT) settings. " ..
    "All insecure DNS traffic is blocked by the firewall.")

s = m:section(TypedSection, "dns-provider", "DNS Provider Selection")
s.anonymous = true
s.addremove = false

provider = s:option(ListValue, "provider", "DNS Provider")
provider:value("quad9", "Quad9 (Secure)")
provider:value("cloudflare", "Cloudflare")
provider:value("google", "Google")
provider:value("custom", "Custom Server")
provider.default = "quad9"

protocol = s:option(ListValue, "protocol", "Secure DNS Protocol")
protocol:value("doh", "DNS-over-HTTPS (DoH)")
protocol:value("dot", "DNS-over-TLS (DoT)")
protocol:value("both", "Both DoH and DoT")
protocol.default = "both"

custom_server = s:option(Value, "custom_server", "Custom DNS Server")
custom_server:depends("provider", "custom")
custom_server.placeholder = "https://dns.example.com/dns-query"

-- Status section
status = m:section(TypedSection, "status", "DNS Service Status")
status.template = "cbi/nullsection"

function status.cfgsections(self)
    return {"status"}
end

-- Apply button
function m.on_commit(self)
    luci.sys.call("/etc/init.d/warpnet-dns restart")
end

return m