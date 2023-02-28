#!/bin/bash 
#ENTRADA DOS PARAMETROS
TEMPO=$1
DIR=$2

#LAÇO PARA FICAR TESTANDO A CONDIÇÃO, ENQUANTO FOR VERDADEIRA 
while true
do
        QTD_INTENS_DIR=$(ls $DIR | wc -l) #NUMERO DE INTENS NO DIRETORIO

        ls ${DIR} > old_itens_dir.txt #ITENS DO DIRETORIO
        sleep $TEMPO #TEMPO PASSADO NO PARAMETRO
        QTD_INTENS_VER=$(ls $DIR | wc -l) #QUANTIDADE DE ITENS A SER VERIFICADO
 

        # CONDIÇÃO TESTA SE QTD_INTENS_DIR E MENOR QUE QTD_INTENS_VER
        if [ ${QTD_INTENS_DIR} -lt ${QTD_INTENS_VER} ]
        then
                ls ${DIR} > itens_dir_mod.txt #ADICIONA OS AQUIVOS DO DIRETORIO PARA UM ARQUIVO DE TEXTO SOBREESCREVENDO

                #USANDO O COMANDO diff PARA COMPARAR OS ARQUIVOS E ADICIONANDO A UMA VARIAVEL
                itens_dif=$(diff old_itens_dir.txt itens_dir_mod.txt | grep "> " | cut -f2 -d ">" )
                
                DATA=$(date +%d-%m-%Y) #VARIAVEL DATE RECEBE A DATA
                HORAS=$(date +%H:%M:%S) #VARIAVEL HORA RECEBE A HORA

                ##ESCREVENDO A SAIDA E MANDADO PARA O dirSensors.log
                echo "[${DATA} ${HORAS}] Alteração! ${QTD_INTENS_DIR} -> ${QTD_INTENS_VER}. Adicionados: ${itens_dif}." >> dirSensors.log
                #MOSTRANDO O DADOS ARMAZENADOS
                cat dirSensors.log
                
                #REMOVENDO OS ARQUIVOS QUE SO SERAM NECESARIO NO MOMENTO DO TESTE.
                rm old_itens_dir.txt 
                rm itens_dir_mod.txt


        #TESTANDO SE QTD_INTENS_DIR É MAIOR QUE QTD_INTENS_VER
        elif [ ${QTD_INTENS_DIR} -gt ${QTD_INTENS_VER} ]
        then
                ls ${DIR} > itens_dir_mod.txt

                itens_dif=$(diff old_itens_dir.txt itens_dir_mod.txt | grep "< " | cut -f2 -d "<")
                DATA=$(date +%d-%m-%Y)#VARIAVEL DATE RECEBE A DATA
                HORAS=$(date +%H:%M:%S)#VARIAVEL DATE RECEBE A HORA
                echo "[${DATA} ${HORAS}] Alteração! ${QTD_INTENS_DIR} -> ${QTD_INTENS_VER}. Removidos: ${itens_dif}." >> dirSensors.log
                cat dirSensors.log
                rm old_itens_dir.txt
                rm itens_dir_mod.txt
 fi
done
