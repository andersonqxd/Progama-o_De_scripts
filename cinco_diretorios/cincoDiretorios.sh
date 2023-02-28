#!/bin/bash


mkdir cincos
cd cincos

#criando subdiretorios
for i in $(seq 1 5)
do
        mkdir pasta$i
        cd pasta$i

        #criando arquivos
        for i in $(seq 1 4)
        do
                touch arq$i.txt

                for j in $(seq 1 $i)
                do
                        if [[ $(wc -l arq$i.txt | cut -f1 -d" ") -le  $j ]]; then
                                echo $i >> arq$i.txt
                        else
                                exit
                        fi
                done
        done

        cd ..
done

