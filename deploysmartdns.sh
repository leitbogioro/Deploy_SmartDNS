#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cert_file="index"

sort="?C=M;O=D"
libssl_url="http://security-cdn.debian.org/debian-security/pool/updates/main/o/openssl/"
libssl1_0_0_deb="libssl1.0.0.deb"

smartdns_url="https://github.com/pymumu/smartdns/releases"
github="https://github.com/"
smartdns_file="smartdns"

start_smartdns="/etc/init.d/smartdns start"
stop_smartdns="/etc/init.d/smartdns stop"


[ $(id -u) != "0" ] && { echo "You must execute me as a root user!"; exit 1; }

if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi

if [ -f /etc/redhat-release ] && [ `cat /etc/redhat-release > /dev/null 2>&1 | grep -i 'centos'` ]; then
    OS='CentOS'
    elif [ ! -z "`cat /etc/issue | grep bian`" ]; then
        OS='Debian'
	cd /root
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ]; then
        OS='Ubuntu'
	cd /root
    else
        echo "Your OS is not supported, please install it on Ubuntu/Debian/CentOS"
        exit 1
fi

if [[ ${OS} == 'Debian' ]] || [[ ${OS} == 'Ubuntu' ]]; then
    apt-get update
    apt-get install wget cron -y
fi

get_latest_libssl1_0_0_ver(){
    wget -O ${cert_file} ${libssl_url}${sort}   
    get_libssl_ver=`awk '{print $6}' ${cert_file} | grep 'amd64' | grep 'libssl1.0.0' | sed -n '1p' | sed -r 's/.*href=\"(.*)\">libssl.*/\1/'`
    rm -rf ${cert_file}
}

get_latest_smartdns(){
    wget -O ${cert_file} ${smartdns_url}
    get_smartdns_ver=`awk '$2 ~ /x86_64.tar.gz/ {print $2}' index | sed -n '1p' | sed -r 's/.*href=\"(.*)\".*/\1/'`
    rm -rf ${cert_file}
}

inst_deb_Libssl_1_0_0(){
    if [[ -f "`dpkg -l | grep 'libssl1.0.0'`" ]]; then
        echo "You had installed libssl1.0.0!"
    else
        get_latest_libssl1_0_0_ver
	wget -O ${libssl1_0_0_deb} ${libssl_url}${get_libssl_ver}
	dpkg --install ${libssl1_0_0_deb}
    fi
}

download_smartdns(){
    get_latest_smartdns
    wget --no-check-certificate -O ${smartdns_file}.tar.gz ${github}${get_smartdns_ver}
    tar zxf ${smartdns_file}.tar.gz
}

apply_smartdns_service(){
    /lib/systemd/systemd-sysv-install enable smartdns
    ${start_smartdns}
}

replace_config_file(){
    if [[ -f /etc/smartdns/smartdns.conf ]]; then
	mv /etc/smartdns/smartdns.conf /etc/smartdns/smartdns.conf.bak
	wget --no-check-certificate https://raw.githubusercontent.com/leitbogioro/Deploy_SmartDNS/master/smartdns.conf
	mv smartdns.conf /etc/smartdns/smartdns.conf
	${start_smartdns}
    fi
}

inst_smartdns(){
    inst_deb_Libssl_1_0_0
    if [[ -f /usr/sbin/smartdns ]]; then
	echo "You had installed SmartDNS, upgrading..."
	${stop_smartdns}
	rm -rf /usr/sbin/smartdns
        download_smartdns
	cd ${smartdns_file}/src
	mv smartdns /usr/sbin/smartdns
	cd /root
	replace_config_file
	${start_smartdns}
	echo "Upgrade finished!"
    else
	download_smartdns
        cd ${smartdns_file}
	chmod +x ./install
        ./install -i		
	apply_smartdns_service
	${stop_smartdns}
	replace_config_file
	echo "SmartDNS has been installed!"
	cd /root
    fi
}

execute_smartdns_work() {
    if ! grep '/etc/smartdns/debian_smartdns.sh' /etc/crontab; then
        wget --no-check-certificate https://raw.githubusercontent.com/leitbogioro/Deploy_SmartDNS/master/debian_smartdns.sh
	mv debian_smartdns.sh /etc/smartdns/debian_smartdns.sh
        /lib/systemd/systemd-sysv-install enable cron
        systemctl start cron.service
        echo "1  */3    * * *   root    bash /etc/smartdns/debian_smartdns.sh" >> /etc/crontab
        /etc/init.d/cron restart
    fi
}

clean_smartdns_file(){
    echo "Cleaning redundant files..."
    rm -rf ${libssl1_0_0_deb}
    rm -rf ${smartdns_file}.tar.gz
    rm -rf ${smartdns_file}
}

set_local_dns(){
    rm -rf /etc/resolv.conf
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
    echo "nameserver 9.9.9.9" > /etc/resolv.conf
}

inst_smartdns
execute_smartdns_work
clean_smartdns_file
set_local_dns

rm -- "$0"
