package :firewall_rules do
  description "close our ports for the outside world"

  EXPOSED_TCP_PORTS=config(:exposed_tcp_ports, default: "22,80").split(',')
  WHITELISTED_IPv4S=config(:whitelisted_ips, default: "83.117.149.26").split(',')

  firewall_rules = ERB.new( asset_path('firewall_rules.sh.erb') ).result

  target = "/root/firewall.sh"

  runner "rm -f #{target}"
  runner "touch #{target}"
  runner "chmod +x #{target}"
  push_text firewall_rules, target

  runner "/root/firewall.sh"

  # no verifyer here: We want to recompile and execute the
  # firewall on every reprovisioning

end
