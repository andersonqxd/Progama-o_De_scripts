#!/bin/bash

NUMERO1=$1
NUMERO2=$2
NUMERO3=$3


if [[ $NUMERO1 =~ ^[0-9]+$ ]] && [[ $NUMERO2 =~ ^[0-9]+$  ]] && [[ $NUMERO3 =~ ^[0-9]+$  ]]
then

        if [ $NUMERO1 -gt $NUMERO2 ]  && [ $NUMERO3 -lt $NUMERO1 ]
        then
                echo $NUMERO1

        elif [ $NUMERO2 -gt $NUMERO1 ] && [ $NUMERO3 -lt $NUMERO2 ]
        then
                echo $NUMERO2
        else
                echo $NUMERO3
        fi

 else
         if [[ $NUMERO1 =~ ^[a-z+]+$ ]]
         then
                 echo "opa!!! $NUMERO1 nao é um numero"

         elif [[ $NUMERO2 =~ ^[a-z]+$ ]]
         then
                 echo "opa!!! $NUMERO2 nao é um numero"

         else
                 echo "opa!!! $NUMERO3 nao é um numero"
         fi

fi

