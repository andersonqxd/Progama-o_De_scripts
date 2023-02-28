#!/bin/bash

chave=$1
ImageId=ami-08d4ac5b634553e16

SubnetId=$(aws ec2 describe-instances --query "Reservations[0].Instances[0].SubnetId" --output text)

GroupId=$(aws ec2 create-security-group --group-name "server" --description "criando pagina instancia com pagina html" --output text)

aws ec2 authorize-security-group-ingress --group-id $GroupId --protocol tcp --port 22 --cidr 181.191.243.188/32
aws ec2 authorize-security-group-ingress --group-id $GroupId --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 run-instances --image-id $ImageId --instance-type t2.micro --key-name "$chave" --security-group-ids $GroupId --subnet-id $SubnetId --user-data file://executavel.sh > instancia.txt

InstanceId=$(cat instancia.txt | sed -n "/InstanceId/p" | cut -f4 -d'"')
rm -r instancia.txt

for ((i=0;;i++ )); do

        if [[ "$InstanceId" == "$(aws ec2 describe-instances --query "Reservations[$i].Instances[0].InstanceId" --output text)" ]]; then
                getInstanceIp=$(aws ec2 describe-instances --query "Reservations[$i].Instances[0].PublicIpAddress" --output text)
                break;
        fi
done

echo "Criando servidor..."
echo "Acesse: http://$getInstanceIp/"