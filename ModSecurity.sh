#!/bin/bash

#get package manager

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)

if [[ ! -z $YUM_CMD ]]; then
	sudo yum update -y
	yum install -y mod_security git

elif [[ ! -z $APT_GET_CMD ]]; then
	sudo apt-get update -y
	sudo apt-get install -y libapache2-mod-security2 git

else
	echo "error can't install package. exiting..."
exit 1;
fi

#ModSecurity Setup
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

#change from Detection to block
sed -i 's/# SecRuleEngine = DetectionOnly/SecRuleEngine = on/' /etc/modsecurity/modsecurity.conf

#Get ModSecurity Rules from OWASP

git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
cd owasp-modsecurity-crs
sudo mv crs-setup.conf.example /etc/modsecurity/crs-setup.conf
sudo mv rules/ /etc/modsecurity

grep -qxF 'IncludeOptional /etc/modsecurity/*.conf' /etc/apache2/mods-enabled/security2.conf || sed -i '/</IfModule>/i\IncludeOptional /etc/modsecurity/*.conf"' /etc/apache2/mods-enabled/security2.conf

grep -qxF 'Include /etc/modsecurity/rules/*.conf' /etc/apache2/mods-enabled/security2.conf || sed -i '/</IfModule>/i\Include /etc/modsecurity/rules/*.conf"' /etc/apache2/mods-enabled/security2.conf

#restart apache
/etc/init.d/apache2 restart

