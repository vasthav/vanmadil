gateway script
Flush all the rules in filter and nat tables
iptables --flush
iptables --table nat --flush
# Delete all chains that are not in default filter and nat table
iptables --delete-chain
iptables --table nat --delete-chain

/sbin/ifconfig eth0 XXX.XXX.XXX.XXX netmask 255.255.255.0 broadcast XXX.XXX.XXX.255  # Internet
/sbin/ifconfig eth1 192.168.10.101 netmask 255.255.255.0 broadcast 192.168.10.255    # Private LAN

iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
iptables --append FORWARD --in-interface eth1 -j ACCEPT

# Set up IP FORWARDing and Masquerading
iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
# Assuming one NIC to local LAN
iptables --append FORWARD --in-interface eth0 -j ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward    # Enables packet forwarding by kernel
