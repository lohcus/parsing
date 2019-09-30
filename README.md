Script para realizar parsing em páginas HTML. Aceita um único domínio como parâmetro ou um arquivo com uma lista de vários domínios.

Após cada uso, as pesquisas ficam salvas em arquivos de nomes <dominio>.ip.txt, que são apagados quando se executa o script novamente, para evitar poluição.
  
Caso deseje salvar esses arquivos, copie-os par aoutro diretório.  

Sintaxe de uso:

./parsing.sh <domínio>

./parsing.sh <arquivo_com_lista_dominios>



Exemplos:

./parsing.sh globo.com

./parsing.sh urls.txt
