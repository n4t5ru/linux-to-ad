#!/bin/bash

#Author: n4t5u
#email: hello@nasru.me

echo 'Welcome to Linux-to-AD'
echo 'Choose your Distro
        1. Debian
        2. RPM
        3. Arch'


read number

case $number in
    #for debian based distros
    1) 
        echo 'Enter your domain Name:'
        read domainName
        echo 'Enter your Hostname Name:'
        read hostName
        echo 'Enter Domain Admin User'
        read domainAdmin

        pamConfig="<< EOF 
                Name: activate mkhomedir
                Default: yes
                Priority: 900
                Session-Type: Additional
                Session:
                        required        pam_mkhomedir.so umask=0022 skel=/etc/skel
                EOF"

        echo 'You will be prompted to enter domain admin password in a bit....'

        #change hostname to user preference
        hostnamectl set-hostname $hostName.$domainName

        #install the initial required tools
        apt install -y realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

        #join the doiman
        realm join -v -U $domanAdmin $domainName

        cat > /usr/share/pam-configs/mkhomedir $pamConfig

        pam-auth-update

        systemctl restart sssd
    ;;

    #for RPM based distros
    2)
        echo 'Enter your domain Name:'
        read domainName
        echo 'Enter your Hostname Name:'
        read hostName
        echo 'Enter Domain Admin User'
        read domainAdmin

        echo 'You will be prompted to enter domain admin password in a bit....'

        #change hostname to user preference
        hostnamectl set-hostname $hostName.$domainName

        #install the initial required tools
        yum install -y realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

        #join the doiman
        realm join -v -U $domanAdmin $domainName

        systemctl restart sssd
    ;;

    3)
        echo 'Why do you wanna join a domain with Arch....'
    ;;

    *)
        echo 'Stick to the numbers....'
    ;;
esac


