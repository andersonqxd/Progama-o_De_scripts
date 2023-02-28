#!/bin/bash

user=$2
senha=$3
SUBREDE=$(aws ec2 describe-subnets --query 'Subnets[0].SubnetId' --output text)
GRUPO=$(aws ec2 create-security-group --group-name "progScripts10" --description "Grupo de Seguranca para Scripts" --output text)

# PEGANDO O IP PRIVADO
IPG=$(wget -qO- http://ipecho.net/plain)

port22=$(aws ec2 authorize-security-group-ingress --group-name "progScripts10" --protocol tcp --port 22 --cidr $IPG/32)
port80=$(aws ec2 authorize-security-group-ingress --group-name "progScripts10" --protocol tcp --port 80 --cidr 0.0.0.0/0)
port3306=$(aws ec2 authorize-security-group-ingress --group-name "progScripts10" --protocol tcp --port 3306 --source-group $GRUPO)

# CRIANDO O SCRIPT DO USER-DATA 
cat<<EOF > servidor.sh
#!/bin/bash
sudo su -

apt-get update
apt-get install mysql-server -y
systemctl start mysql.service
systemctl enable mysql

sleep 5

# ALTERANDO O IP (QUIS USAR DOIS COMANDO DIFERENTES POR FINALIDADE DE APRENDIZADO)
sed -i "32 s|mysqlx-bind-address	= 127.0.0.1|mysqlx-bind-address	= 0.0.0.0|g" /etc/mysql/mysql.conf.d/mysqld.cnf
cat /etc/mysql/mysql.conf.d/mysqld.cnf |grep "bind-address" | sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

# RESTARTANDO O SERVIÇO
systemctl restart mysql
systemctl enable mysql


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
echo "Criando servidor de Bando de Dados..."

# ESPERANDO FICAR EM RUNNING PARA MOSTRAR O IP PRIVADO
while [[ $STATUS != "running" ]]; do
        sleep 2
        STATUS=$(aws ec2 describe-instances --instance-id $INSTANCIA --query "Reservations[0].Instances[0].State.Name" --output text)
done

# PEGANDO O IP PRIVADO E MOSTRANDO NA TELA
IP1=$(aws ec2 describe-instances --instance-id $INSTANCIA --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
echo "IP Privado do Banco de Dados: "$IP1

#  CRIANDO SCRIPT PARA USER-DATA DA INSTANCIA CLIENTE
cat<<EOF >  cliente.sh
#!/bin/bash
sudo su -

apt-get update
apt-get install mysql-client -y
sleep 30

#  ADICIONANDO USUARIO E SENHA AO .my.cnf
echo -e "[client]\nuser="$user"\npassword="$senha > /root/.my.cnf
echo -e "[client]\nuser="$user"\npassword="$senha > /home/ubuntu/.my.cnf

# SCRIPT PARA CRIAR A TABELA PEGANDO USUARIO E O IP PRIVADO (OBS: NAO ESTA CRIANDO A TABELA SO MANUALMENTE)
echo -e "sudo mysql -u $user scripts -h $IP1 << EOF2 
USE scripts;
CREATE TABLE Teste(atividade INT);
exit
EOF2" > /home/ubuntu/scripts.sh
# rm /home/ubuntu/scripts.sh > /home/ubuntu/scripts.sh
chmod +x /home/ubuntu/scripts.sh
/home/ubuntu/./scripts.sh
EOF

#  SEGUNDA INSTANCIA (MYSQL CLIENTE)
INSTANCIA2=$(aws ec2 run-instances --image-id "ami-08d4ac5b634553e16" --instance-type t2.micro --key-name $1 --region us-east-1 --security-group-ids $GRUPO --subnet-id $SUBREDE --user-data file://cliente.sh --query "Instances[0].InstanceId" --output text)
echo "Criando servidor de Aplicação..."

while [[ $STATUS2 != "running" ]]; do
        sleep 2
        STATUS2=$(aws ec2 describe-instances --instance-id $INSTANCIA2 --query "Reservations[0].Instances[0].State.Name" --output text)
done

sleep 80
IP2=$(aws ec2 describe-instances --instance-id $INSTANCIA2 --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo "IP Público do Servidor de Aplicação: "$IP2
