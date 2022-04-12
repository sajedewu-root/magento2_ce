#!/bin/bash

# this script for 2.4.3

cd /var/www/html/

echo "***************************************************************************************************"
echo ""
echo -n -e "\e[1;32mMagento Info                  :  --\e[0m"
echo ""
echo "***************************************************************************************************"
echo ""
echo -n -e "\e[1;33mMagento2 Public Key           :  -- \e[0m ";  read MAGENTO_PUBLIC_KEY
echo -n -e "\e[1;33mMagento2 Private Key          :  -- \e[0m ";  read MAGENTO_PRIVATE_KEY
echo -n -e "\e[1;33mMagento2 Edition              :  -- \e[0m ";  read MA_EDI
echo ""
echo "***************************************************************************************************"
echo ""
echo -n -e "\e[1;32mPlease give a me a folder name to download the Magento 2 CE in the root directory  \e[0m"
echo ""
echo "***************************************************************************************************"
echo ""
echo -n -e "\e[1;33mFolder name                   :  -- \e[0m ";  read DIR_NAME
echo ""

sudo apt update -y
sudo apt upgrade -y

curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
composer


if [ -z "$MA_EDI" ];
  then 
    composer config -g http-basic.repo.magento.com $MAGENTO_PUBLIC_KEY $MAGENTO_PRIVATE_KEY
    composer create-project --repository=https://repo.magento.com/ magento/project-community-edition $DIR_NAME
  else
    composer config -g http-basic.repo.magento.com $MAGENTO_PUBLIC_KEY $MAGENTO_PRIVATE_KEY
    composer create-project --repository=https://repo.magento.com/ magento/project-community-edition=$MA_EDI $DIR_NAME
fi


cd /var/www/html/$DIR_NAME
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chown -R :www-data . 
chmod u+x bin/magento


# change the root directory info

sed -i "s+DocumentRoot /var/www/html/mg/+DocumentRoot /var/www/html/$DIR_NAME/+g" /etc/apache2/sites-available/000-default.conf


chmod -R 777 /var/
chown -R www-data:www-data /var/www/html/
chmod -R 777 /var/

systemctl stop apache2.service
systemctl start apache2.service
systemctl enable apache2.service
systemctl restart apache2.service		
a2ensite 000-default.conf
a2enmod rewrite
systemctl restart apache2.service

chmod 777 -R /var/
cd /var/www/html/$DIR_NAME/

echo "************************************************************************"
echo ""
echo -n -e "Magento 2 Command Line installation process   : -- \e[0m " 
echo ""
echo "************************************************************************"
echo ""
echo -n -e "\e[1;33mMagento URL                       :  -- \e[0m ";  read URL
echo -n -e "\e[1;33mDatabase Host Name Ex. Localhost  :  -- \e[0m ";  read DB_HOST_NAME
echo -n -e "\e[1;33mDatabase Name                     :  -- \e[0m ";  read DB_NAME 
echo -n -e "\e[1;33mDatabase User                     :  -- \e[0m ";  read DB_USER_ID
echo -n -e "\e[1;33mDatabse Passowrd                  :  -- \e[0m ";  read DB_PASSWORD
echo -n -e "\e[1;33mAdministrator First Name          :  -- \e[0m ";  read DB_ADMIN_FNAME
echo -n -e "\e[1;33mAdministrator Last Name           :  -- \e[0m ";  read DB_ADMIN_LNAME
echo -n -e "\e[1;33mAdministrator Emaill Address      :  -- \e[0m ";  read DB_ADMIN_EMAIL
echo -n -e "\e[1;33mAdministrator User Id             :  -- \e[0m ";  read DB_ADMIN_ID
echo -n -e "\e[1;33mAdministrator User Password       :  -- \e[0m ";  read DB_ADMIN_PASSWORD
echo -n -e "\e[1;33mLanguage                          :  -- \e[0m ";  read LANG
echo -n -e "\e[1;33mCurrency Ex. USD                  :  -- \e[0m ";  read CURR
echo -n -e "\e[1;33mTimezone Ex. America/Chicago      :  -- \e[0m ";  read TIME_ZONE
echo ""


php bin/magento setup:install \
--base-url="http://$URL/" \
--db-host="$DB_HOST_NAME" \
--db-name="$DB_NAME" \
--db-user="$DB_USER_ID" \
--db-password="$DB_PASSWORD" \
--admin-firstname="$DB_ADMIN_FNAME" \
--admin-lastname="$DB_ADMIN_LNAME" \
--admin-email="$DB_ADMIN_EMAIL" \
--admin-user="$DB_ADMIN_ID" \
--admin-password="$DB_ADMIN_PASSWORD" \
--language="$LANG" \
--currency="$CURR" \
--timezone="$TIME_ZONE" \
--use-rewrites=1 \
--search-engine=elasticsearch7 \
--elasticsearch-host=localhost:9200 \
--elasticsearch-port=9200 \
--backend-frontname="admin"


echo "***************************************************************************************************"
echo ""
echo -n -e "\e[1;32mAfter complete the installation, \e[1;33mPlease press Enter \e[0m"
echo ""
echo "***************************************************************************************************"
read Enter

cd /var/www/html/$DIR_NAME/
php bin/magento indexer:reindex
php bin/magento cron:install
php bin/magento module:disable Magento_TwoFactorAuth

chmod -R 777 /var/
clear
