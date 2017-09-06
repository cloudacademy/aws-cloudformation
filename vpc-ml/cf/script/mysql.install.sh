#!/bin/bash
exec > >(tee /var/log/userdata.log)
exec 2>&1
whoami
echo userdata deployment script 1.4
echo =======================================

# Download and Install the Latest Updates for the OS
apt-get update && apt-get upgrade -y

# Set the Server Timezone to CST
echo "America/New_York" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Enable Ubuntu Firewall and allow SSH & MySQL Ports
ufw enable
ufw allow 22
ufw allow 3306

# Install Java
apt-get -y install default-jre
java -version

apt-get -y install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list

# Install Logstash
apt-get -y update
apt-get -y install logstash

# Install essential packages
apt-get -y install htop

echo ==================================

export DEBIAN_FRONTEND=noninteractive

debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password'
debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password'

apt-get install --assume-yes mysql-server-5.7

# Update bind address to 0.0.0.0
sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
systemctl status mysql

mysql -uroot -ppassword -e "USE mysql; ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';"
mysql -uroot -ppassword -e "USE mysql; UPDATE user SET Host='%' WHERE User='root' AND Host='localhost'; DELETE FROM user WHERE Host != '%' AND User='root'; FLUSH PRIVILEGES;"

mysql -uroot -ppassword -e "create database testdb;"

mysql -uroot -ppassword -e "use testdb; create table testtable (PersonID int, LastName varchar(255), FirstName varchar(255), City varchar(255), Date datetime(6));"
mysql -uroot -ppassword -e "use testdb; describe testtable;"

echo ==================================

mkdir /etc/logstash/connectors
cd /etc/logstash/connectors/
curl -OL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.44.tar.gz
tar -zxvf mysql-connector-java-5.1.44.tar.gz
mv ./mysql-connector-java-5.1.44/mysql-connector-java-5.1.44-bin.jar .
cd /etc/logstash/conf.d

cat > logstash-elasticsearch.conf << "EOF"
input {
 jdbc {
    jdbc_driver_library => "/etc/logstash/connectors/mysql-connector-java-5.1.44-bin.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    jdbc_connection_string => "jdbc:mysql://localhost:3306/testdb"
    jdbc_user => "root"
    jdbc_password => "password"
    statement => "SELECT * FROM testtable"
    schedule => "* * * * *"
  }
}
output {
  elasticsearch {
	hosts => ["search-rds-logstash-test-gv6d4f64d227kgwjbrohgys43e.us-west-2.es.amazonaws.com:443"]
	ssl => "true"
	index => "fraud22"
  }
  stdout { codec => rubydebug }
}
EOF

systemctl restart logstash.service
systemctl status logstash.service

echo ==================================

echo FINSIHED!!