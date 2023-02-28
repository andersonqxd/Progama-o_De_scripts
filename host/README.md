Vamos criar um script chamado hosts.sh que nos ajude a relacionar nomes de máquinas à IPs.
O script deve guardar em um arquivo chamado hosts.db um par (nomedamaquina,IP) para cada entrada.
Você deve criar as seguintes funções para manipular o arquivo que são invocadas com os parâmetros indicados:
adicionar (parâmetros -a hostname -i IP)
remover (parâmetro -d hostname)
procurar (parâmetro hostname)
listar (parâmetro -l)
Você precisa obrigatoriamente utilizar o comando getopts para tratar os parâmetros de entrada. As funções vão ser simples mesmo, o objetivo é apenas praticar a sintaxe.
