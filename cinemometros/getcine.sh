# Este script obtiene la ultima version del archivo de 
# cinemometros homologados por el INTI Argentina
#
# v1.0 - 24/Mayo/2017 - Walter Lamagna
#
wget http://www.inti.gob.ar/metrologia/metrologiaLegal/pdf/cinemometros.pdf -O cinemometros.`date +%s`.pdf


#
# Convierte el archivo PDF a TEXTO
#

ARCHIVOS="cinemometros.1116.pdf cinemometros.1216.pdf cinemometros.0217.pdf";
ARCHIVOS="$ARCHIVOS cinemometros.0317.pdf cinemometros.0417.pdf cinemometros.0517.pdf";

for a in $ARCHIVOS; do
	pdftotext -fixed 3 -nopgbrk $a;
done;

cat cinemometros.*.txt > cinemometros.txt

echo "MARCA,MODELO,INDUSTRIA,NDESERIE,APROBACION,desde,hasta,TIPO" > data.csv;
./normalize.pl cinemometros.txt | sort | uniq >> data.csv

