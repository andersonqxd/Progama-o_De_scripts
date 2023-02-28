#!/bin/bash

sudo su -

apt update
apt install -y apache2

apt-get update
apt install -y httpd
systemctl start httpd
systemctl enable httpd
touch /var/www/html/texto.html
chown ubuntu /var/www/html/texto.html

echo "[Unit]
Description=Atividade13
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=ubuntu
ExecStart=/home/ubuntu/monitoramento.sh
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/serviceScripts.service

echo "<html>
        <head>
        <title>Atividade 13</title>
                <style>
                        #i{
                                width: 25%;
                                height: 80%;
                                border: 3px solid #ccc;
                                border-radius: 25px;
                                margin-top: 5%;
                                margin-left: 36%;
                                background-color: blue;
                                padding-left: 40px;
                        }
                        body{
                                background-image: linear-gradient(to bottom, black, #CFFFE5, #C2E5D3);
                        }
                </style>
        </head>
        <body>
                <div>
                        <iframe src='texto.html' id='i'></iframe>
                </div>
        </body>
</html>" > /var/www/html/index.html
cat <<EOF > /home/ubuntu/monitoramento.sh
#!/bin/bash
while true;
do
        DATA=\$(date +%H:%M:%S-%D)
        TEMP=\$(uptime | sed 's/:[0-9][0-9] /\n/g;s/  /\n/g' | head -2 | tail -1)
        CMS=\$(uptime | sed 's/  /\n/g' | head -4 | tail -1)
        MEML=\$(free | head -2 | tail -1 | egrep -o '\w+' | head -4 | tail -1)
        MEMU=\$(free | head -2 | tail -1 | egrep -o '\w+' | head -3 | tail -1)
        BYT=\$(cat /proc/net/dev | tail -1 | egrep -o '\w+' | head -2 | tail -1)
        TRN=\$(cat /proc/net/dev | tail -1 | egrep -o '\w+' | head -10 | tail -1)
        echo -e '<h2>'\$DATA '<br>\n'\$TEMP '<br>\n'\$CMS '<br>\nMemoria livre: '\$MEML ', ocupada: '\$MEMU '<br>\nBytes recebidos: '\$BYT ', enviados: '\$TRN '<br>\n<hr width="50%" color="#ccc"></hr>\n' > /var/www/html/texto.html
sleep 5
done
EOF
sudo chmod +x /home/ubuntu/monitoramento.sh
sudo chmod +x /etc/systemd/system/serviceScripts.service
sudo systemctl start serviceScripts.service
sudo systemctl enable serviceScripts.service