#!/bin/bash
#
## Simple IPTables Firewall with Whitelist & Blacklist
#
## List Locations
#

WHITELIST=/usr/local/etc/whitelist.txt
BLACKLIST=/usr/local/etc/blacklist.txt

#
## Specify ports you wish to use.
## For port listing reference see http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
#

ALLOWED="22 25 53 80 443 465 587 993"

#
## Specify where IP Tables is located
#

IPTABLES=/sbin/iptables
IPTABLES_SAVE=/sbin/iptables-save

#
## Save current iptables running configuration in case we want to revert back
## To restore using our example we would run "/sbin/iptables-restore < /usr/src/iptables.last"
#

$IPTABLES_SAVE > /usr/local/etc/iptables.last

#
## Clear current rules
#
## If current INPUT policy is set to DROP we will be locked out once we flush the rules
## so we must first ensure it is set to ACCEPT.
#
$IPTABLES -P INPUT ACCEPT
echo 'Setting default INPUT policy to ACCEPT'

$IPTABLES -F
echo 'Clearing Tables F'
$IPTABLES -X
echo 'Clearing Tables X'
$IPTABLES -Z
echo 'Clearing Tables Z'

#Always allow localhost.
echo 'Allowing Localhost'
$IPTABLES -A INPUT -s 127.0.0.1 -j ACCEPT

#
## Whitelist
#

for x in `grep -v ^# $WHITELIST | awk '{print $1}'`; do
echo "Permitting $x..."
$IPTABLES -A INPUT -s $x -j ACCEPT
done

#
## Blacklist
#

for x in `grep -v ^# $BLACKLIST | awk '{print $1}'`; do
echo "Denying $x..."
$IPTABLES -A INPUT -s $x -j DROP
done

#
## Permitted Ports
#

for port in $ALLOWED; do
echo "Accepting port TCP $port..."
$IPTABLES -A INPUT -p tcp --dport $port -j ACCEPT
done

for port in $ALLOWED; do
echo "Accepting port UDP $port..."
$IPTABLES -A INPUT -p udp --dport $port -j ACCEPT
done

#
##The following rule ensures that replies are not blocked.
##It also allows for things that may be related but not part of those connections such as ICMP.
#

$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

#
## NOTE: Test this script first to make sure it works as expected.
## Run "iptables -v -n -L" to ensure the rules are as expected and that your SSH port is correct.
##
## When you are sure this script works properly uncomment the following 2 lines to enforce the rules.
#

# $IPTABLES -A INPUT -p udp -j DROP
# $IPTABLES -A INPUT -p tcp --syn -j DROP

#
## Save the rules so they are persistent on reboot.
#
$TPTABLES_SAVE > /etc/iptables/rules.v4
