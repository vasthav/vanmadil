#!/bin/sh
#
## Quick n Dirty Firewall
#
## List Locations
#

WHITELIST=/usr/local/etc/whitelist.txt
BLACKLIST=/usr/local/etc/blacklist.txt

#
## Specify ports you wish to use.
#

ALLOWED="22 25 53 80 443 465 587 993"

#
## Specify where IP Tables is located
#

IPTABLES=/sbin/iptables

#
## Clear current rules
#

$IPTABLES -F
echo 'Clearing Tables F'
$IPTABLES -X
echo 'Clearing Tables X'
$IPTABLES -Z
echo 'Clearing Tables Z'

echo 'Allowing Localhost'
#Allow localhost.
$IPTABLES -A INPUT -t filter -s 127.0.0.1 -j ACCEPT

#
## Whitelist
#

for x in `grep -v ^# $WHITELIST | awk '{print $1}'`; do
        echo "Permitting $x..."
        $IPTABLES -A INPUT -t filter -s $x -j ACCEPT
done

#
## Blacklist
#

for x in `grep -v ^# $BLACKLIST | awk '{print $1}'`; do
        echo "Denying $x..."
        $IPTABLES -A INPUT -t filter -s $x -j DROP
done

#
## Permitted Ports
#

for port in $ALLOWED; do
        echo "Accepting port TCP $port..."
        $IPTABLES -A INPUT -t filter -p tcp --dport $port -j ACCEPT
done

for port in $ALLOWED; do
        echo "Accepting port UDP $port..."
        $IPTABLES -A INPUT -t filter -p udp --dport $port -j ACCEPT
done


$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -p udp -j DROP
$IPTABLES -A INPUT -p tcp --syn -j DROP

iptables-save > /etc/iptables/rules.v4
