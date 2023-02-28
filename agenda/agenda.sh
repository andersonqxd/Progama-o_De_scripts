#!/bin/bash


OPERATION=$1
NOME=$2
NOME2=$3
EMAIL=$4
ARQUIVO="agenda.db"

if [[ $OPERATION == "listar" ]]
then
        if [ -s $ARQUIVO ]
        then
                echo "$(cat $ARQUIVO \n)"
        else
                echo "arquivo vazio!!!"
        fi

elif [[ $OPERATION ==  "adicionar" ]]
then
        if [ -s != $ARQUIVO ]
        then
                echo "$NOME $NOME2:$EMAIL" >> $ARQUIVO
                echo "Usuario $NOME $NOME2 adicionado!"
        else
                echo "$NOME $NOME2:EMAIL" >> $ARQUIVO
                echo "Arquivo criado!!!"
                echo "Usuario $NOME $NOME2 adicionado!"
        fi

elif [[ $OPERATION == "remover" ]]
then
        if  sed -n "/$NOME/d" $ARQUIVO 
        then
                echo "Usuario $(grep $NOME $ARQUIVO | cut -f1 -d':') removido"
               
		 sed -i "/$NOME/d" $ARQUIVO 



        else
                echo "Usuario $NOME $NOME2 nao existe!"
        fi
fi


