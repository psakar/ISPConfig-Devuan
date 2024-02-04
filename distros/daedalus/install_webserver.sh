#---------------------------------------------------------------------
# Function: InstallWebServer Debian 9
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {
  
  if [ "$CFG_WEBSERVER" == "apache" ]; then
  CFG_NGINX=n
  CFG_APACHE=y
  echo -n "Installing Web server (Apache) and modules... "
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
	echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	apt_install apache2 apache2-doc apache2-utils libapache2-mod-php libapache2-mod-fcgid apache2-suexec-pristine libruby libapache2-mod-python php-memcache php-imagick php-php-gettext libapache2-mod-passenger
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and modules... "
	# Need to check if soemthing is asked before suppress messages
	# apt_install php8.3 php8.3-common php8.3-gd php8.3-mysql php8.3-imap php8.3-cli php8.3-cgi php-pear  php8.3-curl php8.3-intl php8.3-pspell php8.3-sqlite3 php8.3-tidy php8.3-xmlrpc php8.3-zip php8.3-mbstring php8.3-imap mcrypt php8.3-snmp php8.3-xmlrpc php8.3-xsl
	apt_install php8.3 php8.3-common php8.3-gd php8.3-mysql php8.3-imap php8.3-cli php8.3-cgi php-pear  php8.3-curl php8.3-intl php8.3-pspell php8.3-sqlite3 php8.3-tidy php8.3-xmlrpc php8.3-xsl php8.3-zip php8.3-mbstring php8.3-soap
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP-FPM... "
	#Need to check if soemthing is asked before suppress messages
	apt_install php8.3-fpm
	#Need to check if soemthing is asked before suppress messages
	a2enmod actions > /dev/null 2>&1 
	a2enmod proxy_fcgi > /dev/null 2>&1 
	a2enmod alias > /dev/null 2>&1 
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing needed programs for PHP and Apache (mcrypt, etc.)... "
	apt_install mcrypt imagemagick memcached curl tidy snmp
	echo -e "[${green}DONE${NC}]\n"
	
  if [ "$CFG_PHPMYADMIN" == "yes" ]; then
	source $APWD/distros/beowulf/install_phpmyadmin.sh
	echo -n "Installing phpMyAdmin... "
	InstallphpMyAdmin
	echo -e "[${green}DONE${NC}]\n"
  fi
	
	echo -n "Activating Apache modules... "
	a2enmod suexec > /dev/null 2>&1
	a2enmod rewrite > /dev/null 2>&1
	a2enmod ssl > /dev/null 2>&1
	a2enmod actions > /dev/null 2>&1
	a2enmod include > /dev/null 2>&1
	a2enmod dav_fs > /dev/null 2>&1
	a2enmod dav > /dev/null 2>&1
	a2enmod auth_digest > /dev/null 2>&1
	# a2enmod fastcgi > /dev/null 2>&1
	# a2enmod alias > /dev/null 2>&1
	# a2enmod fcgid > /dev/null 2>&1
	a2enmod cgi > /dev/null 2>&1
	a2enmod headers > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	
	echo -n "Disabling HTTP_PROXY... "
	echo "<IfModule mod_headers.c>" >> /etc/apache2/conf-available/httpoxy.conf
	echo "     RequestHeader unset Proxy early" >> /etc/apache2/conf-available/httpoxy.conf
	echo "</IfModule>" >> /etc/apache2/conf-available/httpoxy.conf
	a2enconf httpoxy > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Restarting Apache... "
	service apache2 restart
	echo -e "[${green}DONE${NC}]\n"
	
	echo -n "Installing Let's Encrypt (Certbot)... "
	apt_install certbot
	echo -e "[${green}DONE${NC}]\n"
  
    echo -n "Installing PHP Opcode Cache... "	
    apt_install php8.3-opcache php-apcu
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Restarting Apache... "
	service apache2 restart
	echo -e "[${green}DONE${NC}]\n"
  elif [ "$CFG_WEBSERVER" == "nginx" ]; then	
  CFG_NGINX=y
  CFG_APACHE=n
	echo -n "Installing Web server (nginx) and modules... "
	apt_install nginx
	service nginx start
	# apt_install php8.3 php8.3-common php-bcmath php8.3-gd php8.3-mysql php8.3-imap php8.3-cli php8.3-cgi php-pear mcrypt php8.3-curl php8.3-intl php8.3-pspell php8.3-sqlite3 php8.3-tidy php8.3-xmlrpc php8.3-xsl php8.3-zip php8.3-mbstring php8.3-imap mcrypt php8.3-snmp php8.3-xmlrpc php8.3-xsl
	apt_install php8.3 php8.3-common php-bcmath php8.3-gd php8.3-mysql php8.3-imap php8.3-cli php8.3-cgi php-pear mcrypt libruby php8.3-curl php8.3-intl php8.3-pspell php8.3-sqlite3 php8.3-tidy php8.3-xmlrpc php8.3-xsl php-memcache php-imagick php-php-gettext php8.3-zip php8.3-mbstring php8.3-soap php8.3-opcache
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP-FPM... "
	#Need to check if soemthing is asked before suppress messages
	apt_install php8.3-fpm
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.3/fpm/php.ini
	TIME_ZONE=$(echo "$TIME_ZONE" | sed -n 's/ (.*)$//p')
	sed -i "s/;date.timezone =/date.timezone=\"${TIME_ZONE//\//\\/}\"/" /etc/php/8.3/fpm/php.ini
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing needed programs for PHP and nginx (mcrypt, etc.)... "
	apt_install mcrypt imagemagick memcached curl tidy snmp
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Reloading PHP-FPM... "
	service php8.3-fpm restart
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing fcgiwrap... "
	apt_install fcgiwrap
	echo -e "[${green}DONE${NC}]\n"
  
  if [ "$CFG_PHPMYADMIN" == "yes" ]; then
	source $APWD/distros/debian10/install_phpmyadmin.sh
	echo -n "Installing phpMyAdmin... "
	InstallphpMyAdmin
	echo -e "[${green}DONE${NC}]\n"
  fi

   
	echo -n "Installing Let's Encrypt (Certbot)... "
	apt_install certbot
	echo -e "[${green}DONE${NC}]\n"
	
	# echo -n "Installing PHP Opcode Cache... "	
    # apt_install php8.3-opcache php-apcu
	# echo -e "[${green}DONE${NC}]\n"
  
  fi
  if [ "$CFG_PHP56" == "yes" ]; then
	echo -e "${red}Attention!!! You had installed php7 and php 5.6, to make php 5.6 work you had to configure the following in ISPConfig ${NC}"
	echo -e "${red}Path for PHP FastCGI binary: /usr/bin/php-cgi5.6 ${NC}"
	echo -e "${red}Path for php.ini directory: /etc/php/5.6/cgi ${NC}"
	echo -e "${red}Path for PHP-FPM init script: /etc/init.d/php5.6-fpm ${NC}"
	echo -e "${red}Path for php.ini directory: /etc/php/5.6/fpm ${NC}"
	echo -e "${red}Path for PHP-FPM pool directory: /etc/php/5.6/fpm/pool.d ${NC}"
  fi
}
