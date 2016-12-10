#!/bin/bash

comando=$1;
list_file=$2;

if [[ "$list_file" == "" ]]; then
	echo -n "Use: gpgprotege.pl [-d|-c] [lista de archivo a cifrar]";
        echo "-d: descifra los archivos";
        echo "-c: cifra los archivos";
        echo "<lista de archivos> un archivo por linea para cifrar o descifrar";
	exit;
fi;

stty -echo
echo -ne "Ingrese la clave: "
read c1
echo -ne "\nIngrese la clave nuevamente: ";
read c2
if [[ "$c1" -ne "$c2" ]]; then
	echo -e "\nNo coinciden!\n\n";
	stty echo
	exit;
fi;
stty echo

echo;
TMP_IFS=$IFS;
IFS=$'\n';
for cifrar_este in `cat $list_file`; do
	if [[ "$comando" == "-c" ]]; then
		echo "Cifrando $cifrar_este\n";
		gpg --passphrase "${c1}" -c $cifrar_este;
		echo "Puede eliminar el original: $cifrar_este";
	fi;

        if [[ "$comando" == "-d" ]]; then
                # Si el archivo a descifrar termina con gpg, al descifrado
                # sacarle esa extension
                archivo_descifrado=$cifrar_este;
		if [[ $archivo_descifrado == *.gpg ]]; then
                	archivo_descifrado=`echo $cifrar_este | sed 's/\.gpg//g'`;
		fi;
		archivo_descifrado=${archivo_descifrado}.ori;
		echo "$archivo_descifrado";
                if [[ -e "$archivo_descifrado" ]]; then
			echo "Este archivo ya existe, no puedo sobreescribir $archivo_descifrado";
                else
			echo "Des-Cifrando $cifrar_este";
			gpg --passphrase "$c1" -o "$archivo_descifrado" -d "$cifrar_este";
                fi;
        fi;
done;
IFS=$TMP_IFS;
