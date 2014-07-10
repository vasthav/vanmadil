#!/bin/bash
# Modify script as per your setup
# Usage: Sample firewall script
# ---------------------------
_input=/usr/local/etc/blacklist.txt
_pub_if="eth0"
IPT=/sbin/iptables
 
# Die if file not found
[ ! -f "$_input" ] && { echo "$0: File $_input not found."; exit 1; }
 
# DROP and close everything
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP
 
# Unlimited lo access
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT
 
# Allow all outgoing connection but no incoming stuff by default
$IPT -A OUTPUT -o ${_pub_if} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -i ${_pub_if} -m state --state ESTABLISHED,RELATED -j ACCEPT
 
 
### Setup our black list ###
# Create a new chain 
$IPT -N droplist
 
# Filter out comments and blank lines
# store each ip or subnet in $ip
egrep -v "^#|^$" x | while IFS= read -r ip
do
        # Append everything to droplist
	$IPT -A droplist -i ${_pub_if} -s $ip -j LOG --log-prefix " Drop Bad IP List "
	$IPT -A droplist -i ${_pub_if} -s $ip -j DROP
done <"${_input}"
 
# Finally, insert or append our black list 
$IPT -I INPUT -j droplist
$IPT -I OUTPUT -j droplist
$IPT -I FORWARD -j droplist
 
 
# Okay add your rest of $IPT commands here 
# Example: open port 53
#$IPT -A INPUT -i ${_pub_if} -s 0/0 -d 1.2.3.4 -p udp --dport 53 -j ACCEPT
#$IPT -A INPUT -i ${_pub_if} -s 0/0 -d 1.2.3.4 -p tcp --dport 53 -j ACCEPT
 
# Open port 80
$IPT -A INPUT -i ${_pub_if} -p tcp --destination-port 80  -j ACCEPT
 
# Allow incoming ICMP ping pong stuff
# $IPT -A INPUT -i ${_pub_if} -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -m limit --limit 30/sec  -j ACCEPT
# $IPT -A INPUT -i ${_pub_if}  -p icmp -m icmp --icmp-type 3 -m limit --limit 30/sec -j ACCEPT
# $IPT -A INPUT -i ${_pub_if}  -p icmp -m icmp --icmp-type 5 -m limit --limit 30/sec -j ACCEPT
# $IPT -A INPUT -i ${_pub_if}  -p icmp -m icmp --icmp-type 11 -m limit --limit 30/sec -j ACCEPT
 
# drop and log everything else
$IPT -A INPUT -m limit --limit 5/m --limit-burst 7 -j LOG
$IPT -A INPUT -j DROP
iptables-save > /etc/iptables/rules.v4
