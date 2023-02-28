Nesta questão, você deve começar criando um grupo de segurança com as seguintes características:
Aceitar conexões SSH (22/tcp) apenas a partir do IP visível da máquina que está executando o script.
Aceitar conexões HTTP (80/tcp) a partir da Internet.
Aceitar conexões MySQL (3306/tcp) a partir de outras máquinas no mesmo grupo de segurança.
Com o grupo de segurança criado, o script deve criar uma primeira máquina virtual e realizar as seguintes ações:
Instalar o servidor MySQL.
Habilitar o acesso por todas as interfaces de rede da máquina.
Criar um banco de dados chamado scripts, usando usuário e senha para acesso remoto.
Em seguida, informar na tela o IP Privado. Essa informação também é usada na próxima etapa.
O script deve partir então para criar uma segunda instância. As seguintes ações devem ser realizadas na criação desse novo servidor:
Os pacotes cliente do MySQL deve ser instalados.
Uma conexão deve ser feita no servidor da primeira máquina.
No banco scripts, criar uma tabela chamada Teste com apenas um campo chamado atividade do tipo inteiro.
A correção será feita pelo login do professor na segunda máquina, em seguida de conexão manual ao banco e verificação se a tabela foi de fato criada.
