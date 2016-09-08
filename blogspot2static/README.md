```
BLOGNAME="serverlinux.blogspot.com.ar";
DIRSALIDA="output";
TMPFILE="pre";

# Este comando puede tardar de acuerdo a cuanto contenido haya
wget -kr http://${BLOGNAME}/;

#wget -kr http://serverlinux.blogspot.com
# Setear los años para los cuales hemos escrito.
M=`seq 2005 1 2016`;

# Crear este directorio para almacenar la fotos del blog que seran bajadas
# con el siguiente script:
#rm -rf externos
#mkdir externos
# Este comando obtiene los HTML del blog obtenido de Blogspot y 
# genera un formato intermedio que puede ser editado:
for i in $M; do find ${BLOGNAME}/$i -type f -exec ./produce.pl {} ${TMPFILE} \; done

mkdir ${DIRSALIDA};
# summary.pl <nombre del html utilizado en el paso anterior> <directorio de salida>
./summary.pl ${TMPFILE} ${DIRSALIDA};

mv externos ${DIRSALIDA};

cp -r js ${DIRSALIDA};
cp -r css ${DIRSALIDA};

# Ahora a testear!
cd output
python ../httpserver.py
```
