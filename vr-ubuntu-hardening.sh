#!/bin/bash
# Danonek2k18
# Simple iptables and kernel optimization script

clearScreen() {
	clear
	echo -e "\033[33m"
    echo "       ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄                                    "
	echo "      ▐██████████▀▀█████████████▀█▀▐████████████████████████████▄▄▄▄▄▄▄▄▄  ▐█████▌ "
	echo "     ▌ ██  ███▀    ▐█████████▌ ▌ █▄▐▀▀▀█  ▀▌▀▀▌▀▀▀▀▐▀▀███████████████████████████▌ "
	echo "    ▌   ▌    █▄     ██████████ | █ ▐ ▐─█ ▐█ ▐ ▌ ██   ▐███████████████████████████ "
	echo "     ▌  ▄   ████▌   ▐█████████▄▄▄█▄▐▄▄▄█▄▄▄▄▄▄▌▄███  ████████████████████████████  "
	echo "    ▌   ▀    ▐███    █████████████████████████▌  ▀▀████████████▌ ████▌ ██████████  "
	echo "     ▐   ▌  ▐████    █████████████████████████▌ ▀ ▐ ▄ ▐▄ ▌▄▌▄-▐▌ ▌ ▄ ▌▄██████████  "
	echo "       ▐██████████   ▐████████████████████████▌ ╔ ▀ ▀ ▐█  ▌ ▀  ▌ ▌ ──▌ █████████▌  "
	echo "        ████████████████████████████████████████████████ ▐██████████████████████▌  "
	echo "        ▐████████████████████████████▀▀▀▀▀▀▀▀▀▀▀▀▀▀█████████▀███████████████████  "
	echo ""
	echo -e "\033[0m"
}

menu() {
	while :
	do
		clearScreen
		echo -e "\033[33mTHE VICTORY ROYALE UBUNTU HARDENING SCRIPT\033[0m"
		echo ""
		echo "What do you want to do?"
		echo ""
		echo "   1) IPTABLES"
		echo "   2) KERNEL OPTIMISATION"
		echo "   3) EXIT"
		echo ""
		read -p "Choose [1-3]: " option
		case $option in
			1) iptablesSet ;;
			2) kernelSet ;;
			3)
			clearScreen
			exit
			;;
		esac
	done
}

iptablesSet() {
	iptables -F
	iptables -A INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset;
	iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT;
	iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP;
	iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT;
	iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP;
	iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set ;
	iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP;
	iptables -N port-scanning;
	iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN;
	iptables -A port-scanning -j DROP;
	iptables -A INPUT -m state --state INVALID -j DROP;
	iptables -A OUTPUT -m state --state INVALID -j DROP;
	iptables -A FORWARD -m state --state INVALID -j DROP;
	iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT; #HTTP
	iptables -A INPUT -p tcp --dport 22 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT; #SSH
	iptables -A INPUT -p tcp --dport 21 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT; #FTP
	iptables -A INPUT -p tcp --dport 443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT; #HTTPS
	iptables -A INPUT -p tcp --dport 3306 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT; #SQL
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP;
	iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP;
	iptables -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP;
	iptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP;
	iptables -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP;
	iptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP;
	iptables -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP;
	iptables -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP;
	iptables -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP;
	iptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP;
	iptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP;
	iptables -t mangle -A PREROUTING -p icmp -j DROP;
}

kernelSet() {
	echo "
	######################################## DANONEK TING
	# IP Spoofing protection
	net.ipv4.conf.all.rp_filter = 1
	net.ipv4.conf.default.rp_filter = 1

	# Ignore ICMP broadcast requests
	net.ipv4.icmp_echo_ignore_broadcasts = 1

	# Disable source packet routing
	net.ipv4.conf.all.accept_source_route = 0
	net.ipv6.conf.all.accept_source_route = 0 
	net.ipv4.conf.default.accept_source_route = 0
	net.ipv6.conf.default.accept_source_route = 0

	# Ignore send redirects
	net.ipv4.conf.all.send_redirects = 0
	net.ipv4.conf.default.send_redirects = 0

	# Block SYN attacks
	net.ipv4.tcp_syncookies = 1

	# Log Martians
	net.ipv4.conf.all.log_martians = 1
	net.ipv4.icmp_ignore_bogus_error_responses = 1

	# Ignore ICMP redirects
	net.ipv4.conf.all.accept_redirects = 0
	net.ipv6.conf.all.accept_redirects = 0
	net.ipv4.conf.default.accept_redirects = 0 
	net.ipv6.conf.default.accept_redirects = 0

	# Ignore Directed pings
	net.ipv4.icmp_echo_ignore_all = 1
	
	" >> /etc/sysctl.conf
}

dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`

if [ "$dist" == "Ubuntu" ]; then
  clearScreen
  menu
else
  echo "This script is meant for ubuntu!"
fi