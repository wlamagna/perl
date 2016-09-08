### Descripcion

Cifra y descifra

### Ejemplos de uso

Cifrando, en este ejemplo lee el contenido de
lista2.txt y los cifra.  Elimina el original tras
cifrarlo.

./gpgcifrar.pl -c lista2.txt

Descifra uno a uno los archivos cuyo nombre esta
en el archivo lista2.txt.  Si la extension del nombre
del archivo finaliza con .gpg, elimina la extension para
crear el archivo descifrado.   Si ya existe un archivo con
ese nombre, no hace nada.  Si el archivo no tiene extension
.gpg entonces le agrega al descifrado una exstencion ".ori"

./gpgcifrar.pl -d lista2.txt



