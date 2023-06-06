#!/bin/bash
# Criado por Daniel Domingues
# https://github.com/lohcus

# Função para exibir uma linha divisória
funcao_linha() {
    largura_tela=$(tput cols)
    for i in $(seq 0 1 $((largura_tela - 1))); do
        echo -ne "${negrito}=${normal}"
    done
}

# Função para centralizar o texto na tela
funcao_centraliza() {
    coluna=$(( (largura_tela - ${#1}) / 2 ))
    tput cup "$2" $coluna
}

# Função para testar se o domínio existe
funcao_testa_dominio() {
    dominios=""
    # Obtém os domínios a partir do URL usando wget, grep, sed, awk, sort e uniq
    dominios=$(wget -qO- "$url" | grep -ioE 'href="([^"#]+)"' | grep -iE 'http://|https://' | sed 's/href="https\{0,1\}:\/\///' | awk -F '[/?&]' '{print $1}' | tr -d '"' | sed 's/www\.//g' | sort | uniq)

    if [ -z "$dominios" ]; then
        texto="[!] ERRO! ESTE DOMÍNIO NÃO ESTÁ RESPONDENDO [!]"
        funcao_centraliza "$texto" 5
        echo -e "${vermelho}$texto${normal}"
    else
        largura_campo=$(( (largura_tela - 2) / 2 ))

        # Exibe o cabeçalho com as colunas IP e URL
        texto="IP"
        tput cup 5 $(( (largura_campo - ${#texto}) / 2 ))
        echo -e "${ciano}$texto${normal}"

        tput cup 5 $(( largura_campo - 1 ))
        echo -e "${ciano}||${normal}"

        texto="URL"
        tput cup 5 $(( largura_campo + (( (largura_campo -${#texto}) / 2 )) ))
        echo -e "${ciano}$texto${normal}"

        funcao_linha
    fi
}

# Função para perguntar ao usuário se deseja realizar uma nova pesquisa
funcao_pergunta() {
    while true; do
        opcao="Y"
        echo -ne "${amarelo}Deseja realizar uma nova pesquisa? (Y/n): ${normal}"; 
        read -r opcao

        case ${opcao^^} in
            "N")
                exit 0
                ;;
            "Y")
                funcao_linha
                echo -ne "${amarelo}Digite um novo domínio: ${normal}"
                read -r url
                break
                ;;
            *)
                texto="[!] DIGITE Y PARA CONTINUAR OU N PARA SAIR [!]"
                for (( i=1; i<=$(( (largura_tela - ${#texto}) / 2 )); i++ )); do echo -n " "; done
                echo -e "${vermelho}[!] DIGITE ${verde}Y${vermelho} PARA CONTINUAR OU ${verde}N${vermelho} PARA SAIR [!]${normal}"
                ;;
        esac
    done
}

# Função principal do script
funcao_main() {
    clear
    funcao_linha

    texto=" SCRIPT PARSING "
    funcao_centraliza "$texto" 0
    echo -e "${ciano}$texto${normal}"

    texto="[+] Resolvendo URLs em: $url"
    funcao_centraliza "$texto" 2
    echo -e "${ciano}${texto::24}${vermelho}$url\n${normal}"

    funcao_linha

    # Testa se o domínio existe
    if funcao_testa_dominio; then
        linha=7
        cor="${negrito}"

        # Lê cada linha da variável "dominios"
        for dominio in $dominios; do
            # Verifica o IP do domínio e atribui à variável "ips"
            ips=$(host "$dominio" | grep "has address" | cut -d " " -f 4)

            # Condicional para alternar as cores dos resultados
            if [ "$cor" == "${negrito}" ]; then
                cor="${verde}"
            else
                cor="${negrito}"
            fi

            # Imprime os IPs e domínios na tela
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

    funcao_linha
}

# INICIO DO SCRIPT

# Definição das cores para formatação do texto
vermelho="\033[31;1m"
verde="\033[32;1m"
amarelo="\033[33;1m"
ciano="\033[36;1m"
normal="\033[m"
negrito="\033[1m"

# Verifica se foi passado um parâmetro válido (arquivo ou domínio)
if [ -z "$1" ]; then
    echo -e "${vermelho}[!] ERRO! Utilize a sintaxe: $0 <domínio>${normal}"; exit 1
elif [ -a "$1" ]; then
    # Lê cada linha do arquivo e chama a função funcao_main para cada domínio
    for url in $(cat "$1"); do
        funcao_main
        texto="[+] PRESSIONE ENTER PARA PESQUISAR O PRÓXIMO DOMÍNIO DA LISTA [+]"
        for (( i=1; i<=$(( (largura_tela - ${#texto}) / 2 )); i++ )); do echo -n " "; done
        echo -ne "${amarelo}$texto${normal}"; read -r
    done
else
    # Se foi passado apenas um domínio, chama a função funcao_main para ele
    url="$1"
    while true; do
        funcao_main
        funcao_pergunta
    done
fi