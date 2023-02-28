#!/bin/bash
user=$2
senha=$3

SUBREDE=$(aws ec2 describe-subnets --query 'Subnets[0].SubnetId' --output text)
GRUPO=$(aws ec2 create-security-group --group-name "ScriptsWordPress222" --description "Grupo de Seguranca para Scripts" --output text)
IPG=$(wget -qO- http://ipecho.net/plain)
PORT22=$(aws ec2 authorize-security-group-ingress --group-id $GRUPO --protocol tcp --port 22 --cidr $IPG/32)
PORT80=$(aws ec2 authorize-security-group-ingress --group-id $GRUPO --protocol tcp --port 80 --cidr 0.0.0.0/0)
PORT3306=$(aws ec2 authorize-security-group-ingress --group-id $GRUPO --protocol tcp --port 3306 --source-group $GRUPO)
# CRIANDO O SCRIPT DO USER-DATA 
cat<<EOF > servidor.sh
#!/bin/bash
sudo su -

apt-get update
apt-get install mysql-server -y
systemctl start mysql.service

sleep 5

# ALTERANDO O IP (QUIS USAR DOIS COMANDO DIFERENTES POR FINALIDADE DE APRENDIZADO)
sed -i "32 s|mysqlx-bind-address	= 127.0.0.1|mysqlx-bind-address	= 0.0.0.0|g" /etc/mysql/mysql.conf.d/mysqld.cnf
cat /etc/mysql/mysql.conf.d/mysqld.cnf |grep "bind-address" | sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf


# RESTARTANDO O SERVIÇO
systemctl restart mysql

# CONFIGURANDO O BANCO DE DADOS 
echo -e "sudo mysql<<EOF1
CREATE DATABASE scripts;
CREATE USER '$user'@'%' IDENTIFIED BY '$senha';
GRANT ALL PRIVILEGES ON scripts.* TO '$user'@'%';
USE scripts;
exit
EOF1
rm /home/ubuntu/scripts.sh" > /home/ubuntu/scripts.sh
chmod +x /home/ubuntu/scripts.sh
cd /home/ubuntu
./scripts.sh
EOF

# CRIAANDO A INSTANCIA
INSTANCIA=$(aws ec2 run-instances --image-id "ami-08d4ac5b634553e16" --instance-type t2.micro --key-name $1 --region us-east-1 --security-group-ids $GRUPO --subnet-id $SUBREDE --user-data file://servidor.sh --query "Instances[0].InstanceId" --output text)
echo "Criando servidor de Banco de Dados... Por favor, Aguarde."

while [[ $STATUS != "running" ]]; do
        sleep 2
        STATUS=$(aws ec2 describe-instances --instance-id $INSTANCIA --query "Reservations[0].Instances[0].State.Name" --output text)
done

IP1=$(aws ec2 describe-instances --instance-id $INSTANCIA --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
echo "IP Privado do Banco de Dados: "$IP1

# SEGUNDA INSTANCIA
cat<<EOF >  cliente.sh
#!/bin/bash
apt-get update
apt-get install -y mysql-client
apt-get install -y apache2 php-mysql php-curl libapache2-mod-php php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip

echo -e "[client]\nuser="$user"\npassword="$senha > /home/ubuntu/.my.cnf
cat<<EOF3 > /etc/apache2/sites-available/wordpress.conf
<Directory /var/www/html/wordpress/>
    AllowOverride All
</Directory>
EOF3
a2enmod rewrite
a2ensite wordpress



sudo touch wp-config.php

curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch wordpress/.htaccess
cp -a wordpress/. /var/www/html/wordpress
chown -R www-data:www-data /var/www/html/wordpress
find /var/www/html/wordpress/ -type d -exec chmod 750 {} \;
find /var/www/html/wordpress/ -type f -exec chmod 640 {} \;
systemctl restart apache2

echo -e " <?php\n
define( 'DB_NAME', 'scripts' );\n
define( 'DB_USER', '$user' );
define( 'DB_PASSWORD', '$senha' );
define( 'DB_HOST', '$IP1' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php'; " > /home/ubuntu/wp-config.php

sudo cp wp-config.php  /wordpress/
sudo cp -fr wp-config.php  /var/www/html/wordpress/

find /var/www/html/wordpress/ -type d -exec chmod 750 {} \;
find /var/www/html/wordpress/ -type f -exec chmod 640 {} \;
systemctl restart apache2
#service httpd restart
EOF

INSTANCIA2=$(aws ec2 run-instances --image-id "ami-08c40ec9ead489470" --instance-type t2.micro --key-name $1 --region us-east-1 --security-group-ids $GRUPO --subnet-id $SUBREDE --user-data file://cliente.sh --query "Instances[0].InstanceId" --output text)
echo "Criando servidor de Aplicação... Isso pode demorar então, por favor aguarde..."

while [[ $STATUS2 != "running" ]]; do
        sleep 2
        STATUS2=$(aws ec2 describe-instances --instance-id $INSTANCIA2 --query "Reservations[0].Instances[0].State.Name" --output text)
done

IP2=$(aws ec2 describe-instances --instance-id $INSTANCIA2 --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

while [[ $ON != "HTTP" ]]; do 
	sleep 2
	ON=$(curl -Is http://$IP2/wordpress/ | sed 's/\//\n/g' | head -1)
done

echo "IP Público do Servidor de Aplicação: "$IP2
echo -e "\nAcesse  http://"$IP2"/wordpress  para finalizar a configuração."
