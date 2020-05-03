#!/bin/bash

cd /var/www/html/

echo "**********************************************************************************************"
echo ""
echo ""
echo "      Please give a me a folder name to download the Magento 2 CE in the root directory       "
echo ""
echo ""
echo "**********************************************************************************************"
read DIR_NAME

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition $DIR_NAME

chmod -R 777 /var/
chown -R www-data:www-data /var/www/html/
chmod -R 777 /var/

a2ensite 000-default.conf
a2enmod rewrite
systemctl stop apache2.service
systemctl start apache2.service
systemctl enable apache2.service

chmod 777 -R /var/
echo ""
echo ""
echo "**********************************************************************************************"
echo ""
echo ""
echo "      After complete the installation, please press Enter"
echo ""
echo ""
echo "**********************************************************************************************"
echo ""
echo ""
read Enter

cd /var/www/html/$DIR_NAME/
php bin/magento indexer:reindex
php bin/magento cron:install
composer update
php bin/magento setup:upgrade

chmod -R 777 /var/
