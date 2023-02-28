O objetivo é criar um script que faça uma instalação do WordPress com o banco de dados e o servidor web executando em instâncias diferentes.
Como na atividade anterior, você deve começar criando um grupo de segurança com as seguintes características:
Aceitar conexões SSH (22/tcp) apenas a partir do IP visível da máquina que está executando o script.
Aceitar conexões HTTP (80/tcp) a partir da Internet.
Aceitar conexões MySQL (3306/tcp) a partir de outras máquinas no mesmo grupo de segurança.
A primeira parte é idêntica, o script deve criar uma primeira máquina virtual e realizar as seguintes ações:
Instalar o servidor MySQL.
Habilitar o acesso por todas as interfaces de rede da máquina.
Criar um banco de dados chamado scripts, usando usuário e senha para acesso remoto.
Em seguida, informar na tela o IP Privado. Essa informação também é usada na próxima etapa.
O script deve partir então para criar uma segunda instância. Agora há uma diferença. As seguintes ações devem ser realizadas na criação desse novo servidor:
Os pacotes cliente do MySQL deve ser instalados.
Uma pilha LAMP (Linux Apache MySQL PHP) deve ser configurada.
O código do WordPress deve ser baixado e descompactado. Um arquivo de configuração com as informações do banco da primeira instância deve ser criado.
O WordPress deve ser instalado no Apache.
