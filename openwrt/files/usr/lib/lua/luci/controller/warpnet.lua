-- WarpNET DNS Configuration Controller
module("luci.controller.warpnet", package.seeall)

function index()
    entry({"admin", "warpnet"}, firstchild(), "WarpNET", 60).dependent = false
    entry({"admin", "warpnet", "dns"}, cbi("warpnet/dns"), "Secure DNS", 1)
end