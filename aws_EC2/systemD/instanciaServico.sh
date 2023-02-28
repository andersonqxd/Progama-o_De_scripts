#!/bin/bash

chave=$1
ImageId=ami-08d4ac5b634553e16

#PEGANDO AS INFORMAÇÕES DE SUBREDE E GRUPO DE SEGURANÇA
SUBREDE=$(aws ec2 describe-instances --query "Reservations[0].Instances[0].SubnetId" --output text)
GRUPO=$(aws ec2 create-security-group --group-name "servico" --description "monitoramento servico" --output text)

#PASSANDO AS INFORMÇÕES SOBRE AS PORTAS PARA O GRUPO DE SEGURANÇA
PORT22=$(aws ec2 authorize-security-group-ingress --group-id $GRUPO --protocol tcp --port 22 --cidr 0.0.0.0/0)
PORT80=$(aws ec2 authorize-security-group-ingress --group-id $GRUPO --protocol tcp --port 80 --cidr 0.0.0.0/0)

#CRIANDO A INSTANCIA
INSTANCIA=$(aws ec2 run-instances --image-id $ImageId --instance-type t2.micro --key-name "$chave" --region us-east-1 --security-group-ids $GRUPO --subnet-id $SUBREDE --user-data file://execServico.sh --query "Instances[0].InstanceId" --output text)

echo "Criando servidor de Monitoramento..."

# ESPERAR FICAR RUUNNING PARA CONCLUIR O SCRIPT 
while [[ $STATUS != "running" ]]; do
	sleep 2
	STATUS=$(aws ec2 describe-instances --instance-id $INSTANCIA --query "Reservations[0].Instances[0].State.Name" --output text)
done

#PEGADO O IP DA INSTANCIA CRIADA
IPADD=$(aws ec2 describe-instances --instance-id $INSTANCIA --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo "Acesse: http://"$IPADD"/"
