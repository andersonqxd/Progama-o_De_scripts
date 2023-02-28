#!/bin/bash

#Entra no modo root
sudo su -

apt update
apt install -y apache2
 
echo “ Antonio Anderson de Franca 510229 ” > var/www/html/index.html