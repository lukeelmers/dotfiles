#!/bin/sh

# Local dev environment setup for OSX Yosemite (basically MAMP without MAMP)

# Inspired by:
# echo.co/blog/os-x-1010-yosemite-local-development-environment-apache-php-and-mysql-homebrew

# Description:
# This sets up Apache to run on boot on ports 8080 and 8443 with auto-VirtualHosts for directories in the ~/Sites folder and
# PHP-FPM via mod_fastcgi. The OSX firewall will forward all port 80 traffic to port 8080 and port 443 to port 8443, so
# we don't have specify the port number when visiting web pages in local web browsers or run Apache as root. MySQL is
# installed and set to run on boot as well. DNSMasq and some OSX configuration is used to direct any hostname ending in
# .dev to the local system to work in conjunction with Apache's auto-VirtualHosts.

# Use Homebrew services
brew tap homebrew/services

# Install MySQL
echo 'Installing MySQL'
brew install mysql

echo 'Configuring MySQL...'

# Copy the default my-default.cnf file to the MySQL Homebrew Cellar directory where it will be loaded on application start:
cp -v $(brew --prefix mysql)/support-files/my-default.cnf $(brew --prefix)/etc/my.cnf

# Configure MySQL to allow for the maximum packet size (local dev only).
# Also keep each InnoDB table in separate files to keep ibdataN-type file sizes low and make file-based backups easier to manage.
cat >> $(brew --prefix)/etc/my.cnf <<'EOF'

# Modifications for local dev environment
max_allowed_packet = 1073741824
innodb_file_per_table = 1
EOF

# Uncomment the sample option for innodb_buffer_pool_size to improve performance:
sed -i '' 's/^#[[:space:]]*\(innodb_buffer_pool_size\)/\1/' $(brew --prefix)/etc/my.cnf

# Use brew services to start MySQL:
echo 'Done. Restarting MySQL.'
brew services restart mysql

# Set password for MySQL root user:
echo ''
echo 'Setting password for MySQL root user...'
echo ''
$(brew --prefix mysql)/bin/mysql_secure_installation

# Stop built-in Apache:
echo 'Installing Apache...'
sudo launchctl unload /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null

# Install Apache 2.2 with the event MPM and set up PHP-FPM instead of mod_php, and Homebrew's OpenSSL library since it's more up-to-date than OSX
# But first tap homebrew/dupes, since homebrew-apache/httpd22 relies on homebrew-dupes/zlib:
brew tap homebrew/dupes
brew install homebrew/apache/httpd22 --with-homebrew-openssl --with-mpm-event

# In order to get Apache and PHP to communicate via PHP-FPM, we'll install the mod_fastcgi module:
brew install homebrew/apache/mod_fastcgi --with-homebrew-httpd22

# To prevent any potential problems with previous mod_fastcgi setups, remove all references to the mod_fastcgi module:
sed -i '' '/fastcgi_module/d' $(brew --prefix)/etc/apache2/2.2/httpd.conf

# Add the logic for Apache to send PHP to PHP-FPM with mod_fastcgi:
echo 'Configuring Apache...'
(export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; export MODFASTCGIPREFIX=$(brew --prefix mod_fastcgi) ; cat >> $(brew --prefix)/etc/apache2/2.2/httpd.conf <<EOF

# Modifications for local dev environment

# Send PHP extensions to mod_php
AddHandler php5-script .php
AddType text/html .php
DirectoryIndex index.php index.html

# Include our VirtualHosts
Include ${USERHOME}/Sites/httpd-vhosts.conf
EOF
)

# Create ~/Sites folder, as well as folders for logs and SSL files
echo 'Creating ~/Sites folder'
mkdir -pv ~/Sites/{logs,ssl}

# Populate the ~/Sites/httpd-vhosts.conf file:
echo 'Configuring vhosts...'
touch ~/Sites/httpd-vhosts.conf

(export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; cat > ~/Sites/httpd-vhosts.conf <<EOF
#
# Listening ports.
#
#Listen 8080  # defined in main httpd.conf
Listen 8443

#
# Use name-based virtual hosting.
#
NameVirtualHost *:8080
NameVirtualHost *:8443

#
# Set up permissions for VirtualHosts in ~/Sites
#
<Directory "${USERHOME}/Sites">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    <IfModule mod_authz_core.c>
        Require all granted
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Allow from all
    </IfModule>
</Directory>

# For http://localhost in the users Sites folder
<VirtualHost _default_:8080>
    ServerName localhost
    DocumentRoot "${USERHOME}/Sites"
</VirtualHost>
<VirtualHost _default_:8443>
    ServerName localhost
    Include "${USERHOME}/Sites/ssl/ssl-shared-cert.inc"
    DocumentRoot "${USERHOME}/Sites"
</VirtualHost>

#
# VirtualHosts
#

## Manual VirtualHost template for HTTP and HTTPS
#<VirtualHost *:8080>
#  ServerName project.dev
#  CustomLog "${USERHOME}/Sites/logs/project.dev-access.log" combined
#  ErrorLog "${USERHOME}/Sites/logs/project.dev-error.log"
#  DocumentRoot "${USERHOME}/Sites/project.dev"
#</VirtualHost>
#<VirtualHost *:8443>
#  ServerName project.dev
#  Include "${USERHOME}/Sites/ssl/ssl-shared-cert.inc"
#  CustomLog "${USERHOME}/Sites/logs/project.dev-access.log" combined
#  ErrorLog "${USERHOME}/Sites/logs/project.dev-error.log"
#  DocumentRoot "${USERHOME}/Sites/project.dev"
#</VirtualHost>

#
# Automatic VirtualHosts
#
# A directory at ${USERHOME}/Sites/webroot can be accessed at http://webroot.dev
# In Drupal, uncomment the line with: RewriteBase /
#

# This log format will display the per-virtual-host as the first field followed by a typical log line
LogFormat "%V %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combinedmassvhost

# Auto-VirtualHosts with .dev
<VirtualHost *:8080>
  ServerName dev
  ServerAlias *.dev

  CustomLog "${USERHOME}/Sites/logs/dev-access.log" combinedmassvhost
  ErrorLog "${USERHOME}/Sites/logs/dev-error.log"

  VirtualDocumentRoot ${USERHOME}/Sites/%-2+
</VirtualHost>
<VirtualHost *:8443>
  ServerName dev
  ServerAlias *.dev
  Include "${USERHOME}/Sites/ssl/ssl-shared-cert.inc"

  CustomLog "${USERHOME}/Sites/logs/dev-access.log" combinedmassvhost
  ErrorLog "${USERHOME}/Sites/logs/dev-error.log"

  VirtualDocumentRoot ${USERHOME}/Sites/%-2+
</VirtualHost>
EOF
)

# Create ~/Sites/ssl/ssl-shared-cert.inc and the SSL files it needs:
echo 'Setting up SSL...'
(export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; cat > ~/Sites/ssl/ssl-shared-cert.inc <<EOF
SSLEngine On
SSLProtocol all -SSLv2 -SSLv3
SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW
SSLCertificateFile "${USERHOME}/Sites/ssl/selfsigned.crt"
SSLCertificateKeyFile "${USERHOME}/Sites/ssl/private.key"
EOF
)

openssl req \
  -new \
  -newkey rsa:2048 \
  -days 3650 \
  -nodes \
  -x509 \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=$(whoami)/CN=*.dev" \
  -keyout ~/Sites/ssl/private.key \
  -out ~/Sites/ssl/selfsigned.crt

# Start Homebrew's Apache and set to start on login:
echo 'Done. Restarting Apache.'
brew services restart httpd22

# The following command will create the file /Library/LaunchDaemons/co.echo.httpdfwd.plist as root, and owned by root, since it needs elevated privileges:
# This will create a firewall rule to forward port 80 requests to 8080, and port 443 requests to 8443, so we don't have to manually specify a port in the URL

sudo bash -c 'export TAB=$'"'"'\t'"'"'
cat > /Library/LaunchDaemons/co.echo.httpdfwd.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
${TAB}<key>Label</key>
${TAB}<string>co.echo.httpdfwd</string>
${TAB}<key>ProgramArguments</key>
${TAB}<array>
${TAB}${TAB}<string>sh</string>
${TAB}${TAB}<string>-c</string>
${TAB}${TAB}<string>echo "rdr pass proto tcp from any to any port {80,8080} -> 127.0.0.1 port 8080" | pfctl -a "com.apple/260.HttpFwdFirewall" -Ef - &amp;&amp; echo "rdr pass proto tcp from any to any port {443,8443} -> 127.0.0.1 port 8443" | pfctl -a "com.apple/261.HttpFwdFirewall" -Ef - &amp;&amp; sysctl -w net.inet.ip.forwarding=1</string>
${TAB}</array>
${TAB}<key>RunAtLoad</key>
${TAB}<true/>
${TAB}<key>UserName</key>
${TAB}<string>root</string>
</dict>
</plist>
EOF'

# Load firewall rule manually now so we don't need to log out and back in:
sudo launchctl load -Fw /Library/LaunchDaemons/co.echo.httpdfwd.plist

# Install PHP (change number below to specify a particular version)
echo 'Installing PHP...'
brew install homebrew/php/php55 --homebrew-apxs --with-apache

# Set timezone (requires sudo), change a few PHP settings, and add error log
echo 'Configuring PHP...'
(export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; sed -i '-default' -e 's|^;\(date\.timezone[[:space:]]*=\).*|\1 \"'$(sudo systemsetup -gettimezone|awk -F"\: " '{print $2}')'\"|; s|^\(memory_limit[[:space:]]*=\).*|\1 512M|; s|^\(post_max_size[[:space:]]*=\).*|\1 200M|; s|^\(upload_max_filesize[[:space:]]*=\).*|\1 100M|; s|^\(default_socket_timeout[[:space:]]*=\).*|\1 600|; s|^\(max_execution_time[[:space:]]*=\).*|\1 300|; s|^\(max_input_time[[:space:]]*=\).*|\1 600|; $a\'$'\n''\'$'\n''; PHP Error log\'$'\n''error.log = '$USERHOME'/Sites/logs/php-error.log'$'\n' $(brew --prefix)/etc/php/5.5/php.ini)

# Fix a pear and pecl permissions problem (github.com/Homebrew/homebrew-php/issues/1039#issuecomment-41307694):
chmod -R ug+w $(brew --prefix php55)/lib/php

# Add optional opcache extension to speed up your PHP environment dramatically:
brew install php55-opcache

# Add optional mcrypt extension
brew install php55-mcrypt

# Bump up the opcache memory limit:
/usr/bin/sed -i '' "s|^\(\;\)\{0,1\}[[:space:]]*\(opcache\.enable[[:space:]]*=[[:space:]]*\)0|\21|; s|^;\(opcache\.memory_consumption[[:space:]]*=[[:space:]]*\)[0-9]*|\1256|;" $(brew --prefix)/etc/php/5.5/php.ini

# Start PHP-FPM:
echo 'Done. Restarting PHP.'
brew services restart php55
# To switch between PHP versions: brew services stop php55 && brew unlink php55 && brew link php54 && brew services start php54

# Use dnsmasq to make any DNS request ending in .dev reply with 127.0.0.1:
echo 'Installing dnsmasq...'
brew install dnsmasq
echo 'address=/.dev/127.0.0.1' > $(brew --prefix)/etc/dnsmasq.conf
echo 'listen-address=127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
echo 'port=35353' >> $(brew --prefix)/etc/dnsmasq.conf
echo 'Done. Restarting dnsmasq.'
brew services restart dnsmasq

# With DNSMasq running, configure OSX to use localhost for DNS queries ending in .dev:
echo 'Configuring localhost... (will require sudo)'
sudo mkdir -v /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dev'
sudo bash -c 'echo "port 35353" >> /etc/resolver/dev'

echo ''
echo 'Local dev environment set up successfully!'
echo 'To test, turn wifi off and on, then ping -c 3 fakedomainthatisntreal.dev (should return results from 127.0.0.1)'
echo ''
