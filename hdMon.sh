#!/bin/bash

#### Criado por Diego Narducci Arioza
#### Versao 2.0 beta
#### Next Version -> Otimização do codigo, automatizaçao do script para rodar como daemon, verificar temperatura

#### O script apos executado, executa alguns testes no hd usando "smartctl", aguarda 3 minutos, e gera um log em "~/log-hd.log"
#### Se houver algum erro o usuario sera informado na tela pelo "zenity" 

#### Modos de execucao -> sem parametro -> testa os atributos smart dos hds e testes simples
#		       -> "full"-> executa o selftest short em todos os hds, aguarda 180 segundos e verifica as saidas
#exemplo 1: "monHD.sh"
#exemplo 2: "monHD.sh full"
#
# requerimento: zenity 
# requerimento: executar como root

# testado no ubuntu 16.04

particoes="sda sdb" # coloque os dispositivos separados por espaço.
logfile="$HOME/log-hd.log" # arquivo de log
modo="simples"

iniciar() {

for i in $particoes
do	
	check1=$(smartctl -H /dev/$i | grep "result" | sed 's/.*lt: //g') # verifica saida do cmd "smartctl -H" e retorna msg se encontrar erro.
		if [[ $check1 == "PASSED" ]]; then
		nada=""
	else
		msg1erro="O teste \"smartctl -H /dev/$i\" retornou erro na data \"$hora\""
		zenity --info --text="$msg1erro" --display=:0.0; echo "$msg1erro" >> $logfile;
		echo "$msg1erro1" >> $logfile	
	fi

	check2=$(smartctl -l selftest /dev/$i | sed 's/\#//g ; s/^ //g ; s/^[0-9]//g ; s/^[0-9]//g' | tr -s " " | cut -d " " -f 9) # verifica saida do teste "short" e retorna msg se encontrar erro.
	for j in $check2
	do
		if [ $j == "-" ];
		then
			nada=""	
		else
			msg2erro1="O teste \"smartctl -t short /dev/$i\" retornou erro na data \"$hora\""
			zenity --info --text="$msg2erro" --display=:0.0; echo "$msg2erro" >> $logfile;
		fi
	done

	check3=$(smartctl -A /dev/$i | grep "-" | sed 's/^ //g; s/^ //g' | tr -s " " | cut -d " " -f 9) #verifica saida do cmd "smartctl -A" e retorna msg se encontrar erro.
	for i in $check3sda
	do
		if [ $check3 == "-" ];
		then
			nada=""
		else
			msg3erro1="O teste \"smartctl -A /dev/$i\" retornou erro na data \"$hora\""
			zenity --info --text="$msg2erro" --display=:0.0; echo "$msg2erro" >> $logfile;
		fi
	done
done
}

###### INICIO DO PROGRAMA ########

if [[ "$*" == "full" ]] ; then
	for i in $particoes; do
		smartctl -s on /dev/$i
		smartctl -S on /dev/$i
		smartctl -o on /dev/$i
		smartctl -t short /dev/$i
	
		echo "modo full"
		modo="full"
	done
	sleep 180
fi

chmod 666 $logfile
hora=$(date)
echo -e " Log $hora - Teste $modo \n" >> $logfile

if [ $(id -u) -eq 0 ];
then
	q=$(which zenity)
	if [ -e "$q" ]; then
		nada=""
	else
		echo "o zenity nao esta instalado, o programa nao informara na tela caso encontre algum erro" >> $logfile
	fi
	iniciar
else
	zenity --info --text="O programa \"monHD\" deve ser executado pelo root" --display=:0.0
	echo " O programa \"monHD\" deve ser executado pelo root" >> $logfile
fi

echo -e "======================================================================================" >> $logfile
echo "Programa executado com sucesso, verifique o log: \"$logfile\" para mais informações."
echo "O programa só reportará no log se houver erros encontrados..."
