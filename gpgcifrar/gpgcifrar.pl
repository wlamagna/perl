#!/usr/bin/perl
#
#

$num_args = $#ARGV + 1;
if ($num_args != 2) {
	print "\nUse: gpgprotege.pl [-d|-c] [lista de archivo a cifrar]\n";
	print "-d: descifra los archivos\n";
	print "-c: cifra los archivos\n";
	print "<lista de archivos> un archivo por linea para cifrar o descifrar\n";
	exit;
}

my $comando =$ARGV[0];
my $list_file =$ARGV[1];

# Que no se vea cuando uno escribe la clave
system ( "stty -echo");
print "Ingrese la clave: ";
chomp ($c1 = <STDIN>);
if ("$comando" eq "-c") {
	print "\nIngrese la clave nuevamente: ";
	chomp ($c2 = <STDIN>);
	system ( "stty echo");
	if ("$c2" ne "$c1") {
		print "\nNo coinciden!\n";
		exit;
	}
}
system ( "stty echo") if ("$comando" eq "-d");
print "\n";
open A, "$list_file" or die ("No pude encontrar $list_file");
while (<A>) {
	chomp;
	my $cifrar_este = $_;
	if ("$comando" eq "-c") {
		print "Cifrando $cifrar_este\n";
		system ( "gpg --passphrase $c1 -c $cifrar_este" );
		print "Puede eliminar el original: $cifrar_este\n";
		#unlink "$cifrar_este";
	}
	if ("$comando" eq "-d") {
		# Si el archivo a descifrar termina con gpg, al descifrado
		# sacarle esa extension
		my $archivo_descifrado = $cifrar_este;
		$archivo_descifrado =~ s/\.gpg//g if ("$cifrar_este" =~ /\.gpg/);
		$archivo_descifrado = "$archivo_descifrado.ori" if ("$cifrar_este" !~ /\.gpg/);
		if (-e "$archivo_descifrado") {
			print "Este archivo ya existe, no puedo sobreescribir $archivo_descifrado\n";
		} else {
			print "Des-Cifrando $cifrar_este\n";
			system ( "gpg --passphrase $c1 -o $archivo_descifrado -d $cifrar_este" );
		}
	}
}
close A;
