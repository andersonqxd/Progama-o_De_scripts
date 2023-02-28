#!/bin/bash

arquivo="$1" 
while read  linha; do
        avg=$(ping -c 1  $linha |grep  "rtt" | cut -d " " -f4 | cut -d "/" -f2)
        if [[ $(ping -c 1  $linha |grep  "rtt")  ]]
        then
              	echo "$linha $avg ms" >> media.txt 
        else
                echo "ping fail"
        fi

done<$arquivo
sort  media.txt
rm media.txt
