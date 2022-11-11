# This script was written running on Ubuntu server 20.04 running in a VM

#moodle, php, apache2 & mysql install
sudo apt update -y
sudo apt upgrade -y
git clone -b MOODLE_400_STABLE git://git.moodle.org/moodle.git
sudo apt-get -y install apache2
sudo apt -y install php
sudo apt install -y mysql-server
sudo cp moodle -R /var/www/html
sudo apt install -y php-iconv
sudo apt install -y php-mbstring
sudo apt install -y php-curl
sudo apt install -y php-tokenizer
sudo apt install -y php-xmlrpc
sudo apt install -y php-soap
sudo apt install -y php-ctype
sudo apt install -y php-zip
sudo apt install -y php-zlib
sudo apt install -y php-gd
sudo apt install -y php-mysqli
sudo apt install -y php-xml
sudo apt install -y php-intl
sudo chown www-data /var/www
#sudo chmod -R a+rwX /var/www
sudo chown -R root /var/www/html/moodle
sudo chmod -R 0755 /var/www/html/moodle
#sudo chmod -R a+rwX /var/www/html/moodle
sudo mkdir /var/www/moodledata # If your putting the moodledata folder on a different drive then please change command to the directory where that drive resides example, use this command to check if it is mounted: cat /proc/mounts | grep moodledata
sudo chmod 0777 /var/www/moodledata

#mysql commands
sed -i 's/;extension=mysqli/extension=mysqli/' /etc/php/7.4/apache2/php.ini
sed -i 's/;max_input_vars = 1000/max_input_vars = 5000/' /etc/php/7.4/apache2/php.ini
password=$(date | md5sum | grep -o '^\S\+')
ip4=$(/sbin/ip -o -4 addr list enp0s3 | awk '{print $4}' | cut -d/ -f1)
echo "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER moodleuser@localhost IDENTIFIED BY '"$password"';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO moodleuser@localhost;
FLUSH PRIVILEGES;" > scripts/moodle.sql
sudo mysql < scripts/moodle.sql
echo $password > mysqlpassword.txt
sudo service apache2 restart

echo "<?php" > /var/www/html/moodle/config.php
echo "unset(\$CFG);" >> /var/www/html/moodle/config.php
echo "global \$CFG;" >> /var/www/html/moodle/config.php
echo "\$CFG = new stdClass();" >> /var/www/html/moodle/config.php
echo "\$CFG->dbtype    = 'mysqli';" >> /var/www/html/moodle/config.php
echo "\$CFG->dblibrary = 'native';" >> /var/www/html/moodle/config.php
echo "\$CFG->dbhost    = 'localhost';" >> /var/www/html/moodle/config.php
echo "\$CFG->dbname    = 'moodle';" >> /var/www/html/moodle/config.php
echo "\$CFG->dbuser    = 'moodleuser';" >> /var/www/html/moodle/config.php
echo "\$CFG->dbpass    = '{DBPASSWORD}';" >> /var/www/html/moodle/config.php
echo "\$CFG->prefix    = 'mdl_';" >> /var/www/html/moodle/config.php
echo "\$CFG->dboptions = array (" >> /var/www/html/moodle/config.php
echo "  'dbpersist' => 0," >> /var/www/html/moodle/config.php
echo "  'dbport' => ''," >> /var/www/html/moodle/config.php
echo "  'dbsocket' => ''," >> /var/www/html/moodle/config.php
echo "  'dbcollation' => 'utf8mb4_unicode_ci'," >> /var/www/html/moodle/config.php
echo ");" >> /var/www/html/moodle/config.php
echo "\$CFG->wwwroot   = 'http://{IPV4}/moodle';" >> /var/www/html/moodle/config.php
echo "\$CFG->dataroot  = '/var/www/moodledata';" >> /var/www/html/moodle/config.php
echo "\$CFG->admin     = 'admin';" >> /var/www/html/moodle/config.php
echo "\$CFG->directorypermissions = 0777;" >> /var/www/html/moodle/config.php
echo "require_once(__DIR__ . '/lib/setup.php');" >> /var/www/html/moodle/config.php

sed -i -e "s/{DBPASSWORD}/$password/" /var/www/html/moodle/config.php
sed -i -e "s/{IPV4}/$ip4/" /var/www/html/moodle/config.php
sudo chmod 0644 /var/www/html/moodle/config.php

echo "Moodle install complete, please go to http://$ip4/moodle - please follow the Moodle install wizard"
echo "The MySQL database password is $password"
echo "To view it again a file called "mysqlpassword.txt" has been placed in your home folder"
echo "Run this command to view it - cat ~/mysqlpassword.txt"

# if you wish, you can enable HTTPS for your install but this will only work for installs that is meant to face the public internet and not running locally on a virtual machine
# You can use a service such as Let's encrypt, install instuctions for Ubuntu 20.04 are located here https://certbot.eff.org/instructions?ws=apache&os=ubuntufocal