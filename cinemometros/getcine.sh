# Este script obtiene la ultima version del archivo de 
# cinemometros homologados por el INTI Argentina
#
# v1.0 - 24/Mayo/2017 - Walter Lamagna
# v2.0 - 01/Jun/2017 - Walter Lamagna - Agrego la obtencion de los datos de Cinemometros de los hermanos Peruanos
#

# Obtiene cinemometros homologados en la Republica Argentina
wget http://www.inti.gob.ar/metrologia/metrologiaLegal/pdf/cinemometros.pdf -O cinemometros.`date +%s`.pdf
#
# Obtiene cinemometros homologados en la Republica del Peru
for a in `seq 0 1 9`; do
	wget --quiet --user-agent=Mozilla/5.0 --save-cookies cookies.txt \
--post-data "busqueda_Id=2&tipoMedidores_ID=4&resultadoMetrologia_Id=&tipoMedidor_Numero_Serie=$a&resultado_Documento_Codigo_Laboratorio=&resultado_Documento_Numero=&resultado_Documento_Anio=&resultado_Numero_Certificado=&" --no-check-certificate https://servicios.inacal.gob.pe/sccapi/api/resultado/rm/listado -O peru_cinemometros_${a}.txt;
done

cat peru_cinemometros_[0-9].txt | sed 's/{"/\n/g' | sort | uniq > tmp_peru.csv;
./normalize_p.pl tmp_peru.csv > data_peru.csv;
rm tmp_peru.csv peru_cinemometros_[0-9].txt;

#
# Argentina: Convierte el archivo PDF a TEXTO
#
ARCHIVOS="cinemometros.1116.pdf cinemometros.1216.pdf cinemometros.0217.pdf";
ARCHIVOS="$ARCHIVOS cinemometros.0317.pdf cinemometros.0417.pdf cinemometros.0517.pdf";
for a in $ARCHIVOS; do
pdftotext -fixed 3 -nopgbrk $a;
done;
cat cinemometros.*.txt > cinemometros.txt
echo "MARCA,MODELO,INDUSTRIA,NDESERIE,APROBACION,desde,hasta,TIPO" > data.csv;
./normalize.pl cinemometros.txt | sort | uniq >> data.csv

