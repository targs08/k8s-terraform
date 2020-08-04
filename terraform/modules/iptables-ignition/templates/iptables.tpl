# sample configuration for iptables service

*filter
:INPUT ACCEPT [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
:RESTRICT-INPUT - [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j RESTRICT-INPUT

%{ for item in rules ~}
-A RESTRICT-INPUT -p ${item.proto} --dport ${item.port} -s ${item.cidr} -j ACCEPT %{if can(item.description) }-m comment --comment "${item.description}"%{ endif }
%{ endfor ~}
%{ for item in whitelist ~}
-A RESTRICT-INPUT -s ${item} -j ACCEPT
%{ endfor ~}
-A RESTRICT-INPUT -j REJECT --reject-with icmp-host-prohibited

COMMIT
