#!/bin/bash
# Correção: 1,0

adicionar() {
    printf "%-10s % s\n" $1 $2 >> host.db


}
remover() {
    sed -i "/$1/d" host.db >> host.db

}
procurar() {
    grep $1 host.db | cut -f1 -d" "
}
listar() {
    cat host.db

}
mostraIp() {
    sed -n "/$1/p" host.db | tr -s " " | cut -f2 -d" "
}

while getopts "a:d:lr:" OPTS;
do
    if [[ $OPTS == a && $3 == -i ]]
    then
        adicionar $2 $4
    elif [[ $OPTS == d ]]
    then
        remover $2
    elif [[ $OPTS == l ]]
    then 
        listar
    elif [[ $OPTS == r ]]
    then
        procurar $2
    fi

    exit
done
mostraIp $1

