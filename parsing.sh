#!/bin/bash

#FUNCAO PARA IMPRIMIR AS DIVISORIAS
divisao () {
	#RECALCULA A LARGURA E ALTURA DA JANELA
	colunas=$(tput cols) #VERIFICA O TAMANHO DA JANELA PARA PODER DESENHAR O LAYOUT DO SCRIPT
	#LACO PARA PREENCHER UMA LINHA COM "="
	for i in $(seq 0 1 $(($colunas-1)))
	do
		printf "\033[35;1m=\033[m"
	done
	echo
}

main () {
	#ENTRA NUM LACO INFINITO (SAI QUANDO DIGITA "N" NA PERGUNTA FINAL)
	while true
	do
		rm index*.* &> /dev/null

		clear
		#CHAMA A FUNCAO PARA DESENHAR UMA DIVISORIA
		divisao
		echo

		centro_coluna=$(( $(( $(( $colunas-14))/2 )))) #CALCULO PARA CENTRALIZAR O TEXTO
		tput cup 0 $centro_coluna #POSICIONAR O CURSOR
		printf "\033[37;1mSCRIPT PARSING\n\033[m"

		centro_coluna=$(( $(( $(( $colunas-$(( 24+${#url}))))/2 )))) #CALCULO PARA CENTRALIZAR O TEXTO
		tput cup 2 $centro_coluna #POSICIONAR O CURSOR
		printf "\033[32;1m[+] Resolvendo URLs em: \033[36;1m$url\n\n\033[m"
		printf "[+] Resolvendo URLs em: $url\n\n" > $url.ip.txt

		divisao
		echo

		#TESTA SE O DOMINIO EXISTE
		if wget $url 2>/dev/null
		then
			centro_coluna=$(( $(( $(( $colunas-$(( 48+${#url}))))/2 )))) #CALCULO PARA CENTRALIZAR O TEXTO
			tput cup 5 $centro_coluna 2> /dev/null #POSICIONAR O CURSOR
			printf "\033[31;1m[+] Concluido! Salvando os resultados em \033[32;1m$url.ip.txt\n\033[m"
			divisao

			#SELECIONA UM DE CADA DOMINIO ENCONTRADO E SALVA NUM ARQUIVO
			#cat index.html | grep href | cut -d "/" -f 3 | cut -d "\"" -f 1 | grep "\." | cut -d ":" -f 1 | sort | uniq > dominios.txt
			cat index.html | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep :// | cut -d "/" -f 3 | cut -d ":" -f 1 | grep "\." | grep -v "%" | sort | uniq > dominios.txt
		else
			centro_coluna=$(( $(( $(( $colunas-31))/2 )))) #CALCULO PARA CENTRALIZAR O TEXTO
			tput cup 5 $centro_coluna #POSICIONAR O CURSOR
			printf "\033[31;1mEste site nao esta respondendo!\n\033[m"
		fi
		#TESTA SE O ARQUIVO dominio.txt EXISTE. SE EXISTE EH PQ FORAM ENCONTRADOS DOMINIOS NO SITE DIGITADO
		if [ -a dominios.txt ]
		then
			tabela=$(( $colunas/4 )) #DIVIDE O TAMANHO DA JANELA EM 4 PARA PODER DIVIDIR OS RESULTADOS EM colunas
			centro_coluna=$(( ($tabela-4+2)/2 )) #CALCULO PARA CENTRALIZAR O TEXTO DENTRO DAS colunas
			tput cup 7 $centro_coluna #POSICIONAR O CURSOR
			echo -n "Line"
			tput cup 7 $tabela  #POSICIONAR O CURSOR
			echo -n "||"
			centro_coluna=$(( $tabela + (($tabela-2+2)/2) )) #CALCULO PARA CENTRALIZAR O TEXTO DENTRO DAS colunas
			tput cup 7 $centro_coluna #POSICIONAR O CURSOR
			echo -n "IP"
			tput cup 7 $(( $tabela*2 )) #POSICIONAR O CURSOR
			echo -n "||"
			centro_coluna=$(( $tabela * 2 + (($tabela*2-7+2)/2) ))  #CALCULO PARA CENTRALIZAR O TEXTO DENTRO DAS colunas
			tput cup 7 $centro_coluna #POSICIONAR O CURSOR
			echo "ADDRESS"

			#CONTEUDO A SER SALVO NO ARQUIVO TXT
			echo "=============================================================================" >> $url.ip.txt
			echo "	Line			IP			ADDRESS" >> $url.ip.txt
			echo "=============================================================================" >> $url.ip.txt

			divisao

			line=1  #VARIAVEL DA POSICAO DA LINHA PARA CADA RESULTADO
			cor=38

			#LE O ARQUIVO COM OS DOMINIOS E PROCURA O IP DE CADA
			for dominio in $(cat dominios.txt)
			do
				#VERIFICA O IP DO DOMINIO E SALVA NUM ARQUIVO PARA POSTERIOR USO
				host $dominio | grep "has address" | cut -d " " -f 4 > ips.txt

				#cCONDICAO PARA COLORIR OS RESULTADOS
				if [ $cor -eq 38 ]
				then
					cor=32
				else
					cor=38
				fi

				#LE O ARQUIVO COM OS IPs E IMPRIME NA TELA
				for ip in $(cat ips.txt)
				do
					centro_coluna=$(( ($tabela-${#line}+2)/2 )) #CALCULO PARA CENTRALIZAR O TEXTO DENTRO DAS colunas
					tput cup $(($line+8)) $centro_coluna #POSICIONAR O CURSOR
					printf "\033[$cor;1m$line\033[m"
					tput cup  $(($line+8)) $tabela #POSICIONAR O CURSOR
					echo -n "||"
					centro_coluna=$(( $tabela + (($tabela-${#ip}+2)/2) )) #CALCULO PARA CENTRALIZAR O TEXTO DENTRO DAS colunas
					tput cup  $(($line+8)) $centro_coluna #POSICIONAR O CURSOR
					printf "\033[$cor;1m$ip\033[m"
					tput cup  $(($line+8)) $(( $tabela*2 )) #POSICIONAR O CURSOR
					echo -n "||"
					centro_coluna=$(( $tabela * 2 + (($tabela*2-${#dominio}+2)/2) )) #CALCULO PARA CENTRALIZAR O TEXTO DENTRO DAS colunas
					tput cup  $(($line+8)) $centro_coluna #POSICIONAR O CURSOR
					printf "\033[$cor;1m$dominio\n\033[m"

					echo "	$line		$ip			$dominio" >> $url.ip.txt #CONTEUDO A SER SALVO NO ARQUIVO TXT

					let line=$line+1 #INCREMENTA A VARIAVEL PARA PULAR LINHA
				done
			done
		fi
		divisao

		#CONDICIONAL PARA VERIFICAR SE VAI PARA O PROXIMO SITE DA LISTA OU PERGUNTA OUTRO DOMINIO
		if [[ $file -eq 1 ]]
		then
			printf "\033[32;1mPRESSIONE ENTER PARA PESQUISAR O PROXIMO DOMINIO DA LISTA\033[m"
			read
			break
		fi

		opcao="Y"
		#FICA NESSE LACO ATE QUE SEJA DIGITADO "y" ou "n"
		while true
		do
			printf "\033[32;1mNova pesquisa? (Y/n): \033[m"
			read opcao

			if [[ ${opcao^^} == "N" ]]
			then
				echo
				rm index*.* &> /dev/null
				rm dominios.txt &> /dev/null
				rm ips.txt &> /dev/null
				exit
		elif [[ ${opcao^^} == "Y" ]]
			then
				printf "\033[37;1mNova URL: \033[m"
				read url
				break
			fi
		done
	done
}

#==================================INICIO DO SCRIPT PRINCIPAL=====================================
rm *.ip.txt

#TESTA SE O PAR^AMETRO FOI UM ARQUIVO OU UM DOMINIO
if [ -a $1 ]
then
	for url in $(cat $1)
	do
		file=1
		main
	done
	echo
	rm index*.* &> /dev/null
	rm dominios.txt &> /dev/null
	rm ips.txt &> /dev/null
else
	file=0
	url=$1 #ATRIBUI O PARAMETRO A VARIAVEL $URL
	main
fi
