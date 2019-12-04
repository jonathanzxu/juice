#!/bin/bash
#LAST UPDATED 1/12/2019
#DO NOT USE, HAS BEEN DEPRECATED. REFER TO THEJUICE.PY INSTEAD
function contains () {
	local n=$#
	local value=${!n}
	for ((i=1;i < $#;i++)) {
			if [ "${!i}" == "${value}" ]; then
			echo "y"
			return 0
		fi
	}
	echo "n"
	return 1
	}
function main {
	RED="\033[0;31m"
	PURPLE="\033[0;35m"
	DEFAULT="\033[0m"
	echo -e "${PURPLE}PLEASE CREATE \'users.txt\' AND \'admins.txt\' IN NECROS FOLDER FIRST!!! ONE NAME PER LINE!! Remember: users means regular + admin!!! Don't forget your own account!"
	echo -e "${RED}WARNING: MAKE SURE ${PURPLE}FORENSICS QUESTIONS${RED} ARE COMPLETED AND POINTS AWARDED BEFORE CONTINUING. THIS SCRIPT WILL DELETE USERS AND USER DATA." 
	echo -e "${RED}type CONTINUE to continue. anything else will exit program.${DEFAULT}"
	read continue
	if [ $continue != "CONTINUE" ]; then
		exit
	fi
	echo -e "${DEFAULT}WELCOME TO NECROS SCRIPT. \nBase user password:"
	read passwd
	#echo "Thanks. Set other user passwords to:"
	#read upass
	#echo "How many authorized admins? Check README."
	#read admins
	#echo "How many authorized users? Check README."
	#read users
	#declare -a AUTHADMIN
	#declare -a AUTHUSER
	#counter=1
	#while [ $counter -le $admins ]
	#do
	#	echo "Next admin username:"
	#	read adminname
	#	AUTHADMIN+=('$adminname')
	#	AUTHUSER+=('$adminname')
	#	counter=$[$counter+1]
	#done
	#counter=1
	#while [ $counter -le $users ]
	#do
	#	echo "Next user username:"
	#	read username
	#	AUTHUSER+=('$username')
	#	counter=$[$counter+1]
	#done
	#adminin=$(getent group sudo | cut -d: -f4)
	#admin=$(echo $adminin | tr , '\\n')
	#echo $admin 
	#declare -a goodadmins
	#for i in "cat admins.txt"
	#do 
		#admin=$(sed s/$i/\\n/g <<< $admin)
	#done
	#for unadmin in "${admin[@]}"
	#do
	#	deluser $unadmin sudo
	#done
	#user=$(awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd)
	#for j in $(cat users.txt)
	#do
	#	user=$(sed s/$j/\\n/g <<< $user)
	#done
	#for delete in $user
	#do
	#	echo "deleting $delete ...."
	#	deluser "$delete"
	#done
	#uidzeroin=$(getent passwd 0 | cut -d: -f1)
	#uidzero=$(echo $uidzeroin | tr "\n")
	#for k in "$uidzero[@]"
	#do
	#	if [ k != "root" ]; then
	#		deluser $k
	#	fi
	#done
	
	#echo "Configure FTP? vsftpd[1] and pure-ftpd[2]. Input 0 for neither."
	#read ftp
	#echo "Configure samba? [Y/n]"
	#read samba
	#echo "Configure SSH? [Y/n]"
	#read ssh
	#echo "Delete all media files? [Y/n]"
	#read media
	echo "installing packages."
	apt-get install bum libpam-cracklib ufw gufw synaptic firefox hardinfo chkrootkit iptables portsentry lynis sysv-rc-conf nessus clamav unattended-upgrades fail2ban
	echo "packages installed."
	echo "blocking ports."
	iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP         #Block Telnet
   	iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
 	iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
 	iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP  #Block X-Windows
  	iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 7100 -j DROP       #Block X-Windows font server
  	iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
 	iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
 	iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
  	iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
  	iptables -A INPUT -p all -s localhost  -i eth0 -j DROP
	ufw deny 23
	ufw deny 2049
	ufw deny 515
	ufw deny 111
	ufw allow 22
	ufw allow 80
	ufw allow 443
	lsof -i -n -P
	netstat -tulpn
	echo "ports blocked."
	echo "deleting prohibited media."
	find / -name '*.mp3' -type f -delete
	find / -name '*.mov' -type f -delete
 	find / -name '*.mp4' -type f -delete
 	find / -name '*.avi' -type f -delete
  	find / -name '*.mpg' -type f -delete
  	find / -name '*.mpeg' -type f -delete
    	find / -name '*.flac' -type f -delete
   	find / -name '*.m4a' -type f -delete
    	find / -name '*.flv' -type f -delete
    	find / -name '*.ogg' -type f -delete
    	find /home -name '*.gif' -type f -delete
    	find /home -name '*.png' -type f -delete
    	find /home -name '*.jpg' -type f -delete
    	find /home -name '*.jpeg' -type f -delete
	echo "media deleted."
	echo "Setting password & lockout policy."
	sh -c "echo 'auth optional pam_tally.so deny=5 unlock_time=90 onerr=fail audit even_deny_root_account silent' >> /etc/pam.d/common-auth"
	sed -i '/PASS_MAX_DAYS/c\PASS_MAX_DAYS=15' /etc/login.defs
	sed -i '/PASS_MIN_DAYS/c\PASS_MIN_DAYS=8' /etc/login.defs
	sed -i '/PASS_WARN_AGE/c\PASS_WARN_AGE=7' /etc/login.defs
	sh -c "echo 'password requisite pam_cracklib.so retry=3 minlen=8 difok=3 local_users_only reject_username minclass=3 maxrepeat=2 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1' >> /etc/pam.d/common-password"
	sh -c "echo 'password required pam_pwhistory.so remember=400 use_authtok' >> /etc/pam.d/common-password"
	sh -c "echo 'password sufficient pam_unix.so nullok use_authtok sha512 shadow remember=7' >> /etc/pam.d/common-password"
	echo "Password & lockout policy set."
	
	echo "Is LAMPSTACK a thing in the README? [y/n]"
	read lampstack
	if [$lampstack == "y"]
	then
		echo "Enabling fail2ban"
		cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
		sh -c "echo 'enabled = true' >> /etc/fail2ban/jail.local"
		sh -c "echo 'port = ssh' >> /etc/fail2ban/jail.local"
		sh -c "echo 'filter = sshd' >> /etc/fail2ban/jail.local"
		sh -c "echo 'logpath = /var/log/auth.log' >> /etc/fail2ban/jail.local"
		sh -c "echo 'maxretry = 5' >> /etc/fail2ban/jail.local"
		sh -c "echo 'bantime = 600' >> /etc/fail2ban/jail.local"
		systemctl restart fail2ban.service
		systemctl enable fail2ban.service
		echo "Fail2ban enabled"	
	
		echo "Hiding sensitive APACHE information"
		sh -c "echo 'ServerTokens Prod' >> /etc/apache2/conf-available/custom.conf"
		sh -c "echo 'ServerSignature Off' >> /etc/apache2/conf-available/custom.conf"
		sh -c "echo 'TraceEnable Off' >> /etc/apache2/conf-available/custom.conf"
		sh -c "echo 'Options all -Indexes' >> /etc/apache2/conf-available/custom.conf"
		sh -c "echo 'Header unset ETag' >> /etc/apache2/conf-available/custom.conf"
		sh -c "echo 'Header always unset X-Powered-By' >> /etc/apache2/conf-available/custom.conf"
		sh -c "echo 'FileETag None' >> /etc/apache2/conf-available/custom.conf"
		sudo a2enmod headers
		sudo a2enconf custom.conf
		sudo systemctl restart apache2.service
		echo "Configured Apache"
	
	
	
		echo "Installing, enabling, and configuring mod_evasive"
		sudo apt-get install libapache2-mod-evasive
		sh -c "echo 'DOSPageCount 5' >> /etc/apache2/mods-enabled/evasive.conf"
		sh -c "echo 'DOSSiteCount 50' >> /etc/apache2/mods-enabled/evasive.conf"
		sh -c "echo 'DOSPageInterval 1' >> /etc/apache2/mods-enabled/evasive.conf"
		sh -c "echo 'DOSSiteInterval 1' >> /etc/apache2/mods-enabled/evasive.conf"
		sh -c "echo 'DOSBlockingPeriod 600' >> /etc/apache2/mods-enabled/evasive.conf"
		sh -c "echo 'DOSLogDir "var/log/mod_evasive"' >> /etc/apache2/mods-enabled/evasive.conf"
		sudo mkdir /var/log/mod_evasive
		sudo chown -R www-data: /var/log/mod_evasive
		sudo systemctl restart apache2.service
		echo "Installed, enabled, and configured mod_evasive"
	
		echo "Installing MySQL service"
		sudo mysql_secure_installation
	
		echo "Disabling remote MySQL access"
		sh -c "echo 'bind-address = 127.0.0.1' >> /etc/mysql/mysql.conf.d/mysqld.cnf"
		sudo systemctl restart mysql.service
		echo "Disabled remote MySQL access"
	
		#echo "Disabling LOCAL INFILE"
		#echo "If LOCAL INFILE is included in the README, DO NOT DELETE"
		#read -p "Are you sure? Type y or n" -n 1 -r
		#if [[ $y =~ ^[Yy]$ ]]
		#then
	

		echo "Securing PHP"
		php --ini | grep "Loaded Configuration File"
		echo "Type in the php.ini file name"
		read php.ini
		phpinifile = php.ini
		sh -c "echo 'expose_php = Off' >> $phpinifile"
		sh -c "echo 'display_errors = Off' >> $phpinifile"
		sh -c "echo 'mail.add_x_header = Off >> $phpinifile"
		sudo systemctl restart apache2.service
	
		echo "Disabling dangerous PHP functions"
		sh -c "echo 'disable_functions = show_source,system,shell_exec,passthru,exec,phpinfo,popen,proc_open,allow_url_fopen,curl_exec,curl_multi' >> $phpinifile"
		sh -c "echo 'allow_url_fopen=Off' >> $phpinifile"
		sh -c "echo 'allow_url_include=Off' >> $phpinifile"
		
		echo "Disabling file uploads. IS THIS SPECIFIED IN README?"
		read phpfileupld
		sh -c "echo 'file_uploads=Off' >> $phpinifile
		sh -c "echo 'upload_max_filesize=1M' >> $phpinifile
		sudo systemctl restart apache2.service
	fi
	echo "Turning firewall on."
	ufw enable
	echo "Firewall on. Check in gufw that incoming=deny outgoing=allow"
	echo "disabling guest account."
	sh -c "echo 'allow-guest=false' >> /etc/lightdm/lightdm.conf"
	echo "guest account disabled."
	echo "Deleting unauthorized users and affirming administrator roles."
	USERS="$(getent passwd | wc -l)"
	echo -e "Deleting harmful packages. ${RED}I AM NOT DELETING: SSH, APACHE2, NMAP, SAMBA, MYSQL or VSFTPD. You might need to use them.${DEFAULT}"
	apt-get purge medusa
	apt-get purge netcat-traditional
	apt-get purge squid
	apt-get purge john
	apt-get purge hydra
	apt-get purge nikto
	apt-get purge logkeys
	apt-get purge vncserver
	apt-get purge wireshark
	apt-get purge netcat
	apt-get purge ophcrack
	apt-get purge mariadb
	#apt-get purge mysql : might need to use this
	apt-get purge postfix
	apt-get purge telnet
	apt-get purge kismet
	apt-get purge doomsday
	echo "Harmful packages deleted."
	}
	
if [ "$(id -u)" != "0" ]; then
	echo "Yain't root!"
	echo "proper etiquette: sudo necros.sh"
	exit
else
	main
fi
