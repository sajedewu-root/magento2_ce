#!/bin/bash

# Based on this script, we can install Elasticsearch in the system
# Here, we will install all the packages for Elasticsearch in the system.
# Install Elasticsearch in the linux (Ubuntu 20)

apt-get install openjdk-8-jdk -y

java -version

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.10.0-amd64.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.10.0-amd64.deb.sha512
shasum -a 512 -c elasticsearch-7.10.0-amd64.deb.sha512 
sudo dpkg -i elasticsearch-7.10.0-amd64.deb

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

sudo systemctl start elasticsearch

curl -X GET "localhost:9200/?pretty"

cd /etc/elasticsearch

sed -i 's,^# cluster.name:.*$,cluster.name: Magento Cluster,' elasticsearch.yml
sed -i 's,^# node.name:.*$,node.name: Magento Node,' elasticsearch.yml
sed -i 's,^# network.host:.*$,network.host: localhost,' elasticsearch.yml

sudo systemctl restart elasticsearch

curl -X GET "localhost:9200/?pretty"
