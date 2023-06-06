#!/bin/bash
# Criado por Daniel Domingues
# https://github.com/lohcus

# FUNÇÃO PARA IMPRIMIR AS DIVISÓRIAS
divisoria() {
    largura_tela=$(tput cols) # VERIFICA O TAMANHO DA JANELA
    for i in $(seq 0 1 $((largura_tela - 1))); do
        echo -ne "${negrito}=${normal}"
    done
}

centraliza_texto() {
	coluna=$(( (largura_tela - ${#1}) / 2 ))
    tput cup "$2" $coluna
}

testa_dominio() {
    dominios=""
    dominios=$(wget -qO- "$url" | grep -ioE 'href="([^"#]+)"' | grep -iE 'http://|https://' | sed 's/href="https\{0,1\}:\/\///' | awk -F '[/?&]' '{print $1}' | tr -d '"' | sed 's/www\.//g' | sort | uniq)

	if [ -z "$dominios" ]; then
        texto="[!] ERRO! ESTE DOMÍNIO NÃO ESTÁ RESPONDENDO OU NÃO FOI POSSÍVEL REALIZAR PARSING NESSA PÁGINA [!]"
		centraliza_texto "$texto" 5
		echo -e "${vermelho}$texto${normal}"
	else
		largura_campo=$(( (largura_tela - 2) / 2 ))

		texto="IP"
		tput cup 5 $(( (largura_campo - ${#texto}) / 2 ))
		echo -e "${ciano}$texto${normal}"

		tput cup 5 $(( largura_campo - 1 ))
		echo -e "${ciano}||${normal}"

		texto="URL"
		tput cup 5 $(( largura_campo + (( (largura_campo -${#texto}) / 2 )) ))
		echo -e "${ciano}$texto${normal}"

		divisoria
	fi
}

funcao_pergunta() {
	while true; do
	opcao="Y"
	echo -ne "${amarelo}Deseja realizar uma nova pesquisa? (Y/n): ${normal}"
	read -r opcao

	case ${opcao^^} in
		"N")
			exit 0
			;;
		"Y")
			divisoria
			echo -ne "${amarelo}Digite um novo domínio: ${normal}"
			read -r url
			break
			;;
		*)
            texto="[!] OPÇÃO INVÁLIDA. POR FAVOR, DIGITE Y PARA CONTINUAR OU N PARA SAIR [!]"
            for (( i=1; i<=$(( (largura_tela - ${#texto}) / 2 )); i++ )); do echo -n " "; done
			echo -e "${vermelho}[!] OPÇÃO INVÁLIDA. POR FAVOR, DIGITE ${verde}Y${vermelho} PARA CONTINUAR OU ${verde}N${vermelho} PARA SAIR [!]${normal}"
			;;
	esac
done
}


principal() {
    clear
    divisoria

    texto=" SCRIPT PARSING "
    centraliza_texto "$texto" 0
    echo -e "${ciano}$texto${normal}"

    texto="[+] Resolvendo URLs em: $url"
    centraliza_texto "$texto" 2
    echo -e "${ciano}${texto::24}${vermelho}$url\n${normal}"

    divisoria

    # Testa se o domínio existe
    if testa_dominio; then
    # Testa se a variável "dominios" não está vazia
        linha=7
        cor="${negrito}"

        # Lê cada linha da variável "dominios"
        for dominio in $dominios; do
            # Verifica o IP do domínio e atribui à variável "ips"
            ips=$(host "$dominio" | grep "has address" | cut -d " " -f 4)

            # CONDIÇÃO PARA COLORIR OS RESULTADOS
            if [ "$cor" == "${negrito}" ]; then
                cor="${verde}"
            else
                cor="${negrito}"
            fi

            # Lê a variável "dominios" e imprime cada um na tela
            for ip in $ips; do
                for (( i=1; i<=$(( (largura_campo - ${#ip}) / 2 )); i++ )); do echo -n " "; done
                echo -ne "${cor}$ip${normal}"
                
                for (( i=1; i<=$(( (largura_campo - ${#ip} - 1 ) / 2 )); i++ )); do echo -n " "; done
                echo -ne "${ciano}||${normal}"

                for (( i=1; i<=$(( (largura_campo - ${#dominio} - 1) / 2 )); i++ )); do echo -n " "; done
                echo -e "${cor}$dominio${normal}"

                ((linha++))
            done
        done
    fi

    divisoria

    # CONDICIONAL PARA VERIFICAR SE VAI PARA O PRÓXIMO SITE DA LISTA OU PERGUNTA OUTRO DOMÍNIO
    if [[ $file -eq 1 ]]; then
        texto="[+] PRESSIONE ENTER PARA PESQUISAR O PRÓXIMO DOMÍNIO DA LISTA [+]"
		for (( i=1; i<=$(( (largura_tela - ${#texto}) / 2 )); i++ )); do echo -n " "; done
		echo -ne "${amarelo}$texto${normal}"
        read -r
    fi
}

# ==================================INICIO DO SCRIPT PRINCIPAL=====================================
vermelho="\033[31;1m"
verde="\033[32;1m"
amarelo="\033[33;1m"
ciano="\033[36;1m"
normal="\033[m"
negrito="\033[1m"

# TESTA SE O PARÂMETRO FOI UM ARQUIVO OU UM DOMÍNIO
if [ -z "$1" ]; then
	echo -e "${vermelho}[!] ERRO! Utilize a sintaxe: $0 <domínio>${normal}"
	exit 1
elif [ -a "$1" ]; then
    for url in $(cat "$1"); do
        file=1
        principal
    done
    echo
else
    url="$1"
    while true; do
        file=0
        principal
        funcao_pergunta
    done
fi