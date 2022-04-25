#!/bin/bash

#Author: n4t5u
#email: hello@nasru.me

printf '\nWelcome to Linux-to-AD\n'
printf 'Choose your Distro
1. Debian
2. RPM\n
Enter Number: \n'
read number

case $number in
#for debian based distros
1) 
read -p 'Enter your domain Name: ' domainName
read -p 'Enter your Hostname Name: ' hostName
read -p 'Enter Domain Admin User: ' domainAdmin

echo 'You will be prompted to enter domain admin password in a bit....'

#change hostname to user preference
hostnamectl set-hostname $hostName.$domainName

#updates and upgrades all files before installation
apt update && apt upgrade -y

#install the initial required tools
apt install -y realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit zsh

cat <<EOF >> /usr/share/pam-configs/mkhomedir 
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session: required   
pam_mkhomedir.so umask=0022 skel=/etc/skel
EOF

pam-auth-update

echo 'You will be prompted to enter domain admin password in a bit....'

#join the doiman
realm join -v -U $domanAdmin $domainName

systemctl restart sssd

read -p "Enter New Username: " newUser
read -s -p "Enter Password: " newPassword

#checks if the username already exists
egrep "^$newUser" /etc/passwd >/dev/null

#adds new user if the username doesnot exist the in passwd file
if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
else
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $newPassword)
    useradd -m -p "$pass" "$username"
    [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
fi

#Install OhmyZSH
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#Enable UFW and add rules
ufw enable
ufw allow ssh
ufw allow 22

echo 'All operations completed successfully!'

;;

#for RPM based distros
2)
read 'Enter your domain Name: ' domainName
read 'Enter your Hostname Name: ' hostName
read 'Enter Domain Admin User: ' domainAdmin

echo 'You will be prompted to enter domain admin password in a bit....'

#change hostname to user preference
hostnamectl set-hostname $hostName.$domainName

#install the initial required tools
yum install -y realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

#join the doiman
realm join -v -U $domanAdmin $domainName

systemctl restart sssd
;;

*)
echo 'Stick to the specified numbers....'
;;
esac


