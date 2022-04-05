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
echo -n -e "\e[1;33mFolder name                   :  -- \e[0m ";   read DIR_NAME
echo ""

composer config -g http-basic.repo.magento.com $MAGENTO_PUBLIC_KEY $MAGENTO_PRIVATE_KEY
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition=$MA_EDI $DIR_NAME

chmod -R 777 /var/
chown -R www-data:www-data /var/www/html/
chmod -R 777 /var/

a2ensite 000-default.conf
a2enmod rewrite
systemctl stop apache2.service
systemctl start apache2.service
systemctl enable apache2.service

chmod 777 -R /var/
cd /var/www/html/$DIR_NAME/

echo "***************************************************************************************************"
echo ""
echo -n -e "\e[1;32mAfter complete the installation, \e[1;33mPlease press Enter \e[0m"
echo ""
echo "***************************************************************************************************"
echo ""
read Enter

cd /var/www/html/$DIR_NAME/
php bin/magento indexer:reindex
php bin/magento cron:install

chmod -R 777 /var/
clear
