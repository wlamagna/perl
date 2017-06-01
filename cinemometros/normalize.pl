#!/usr/bin/perl
# 
# ETL para archivo de Cinemometros provisto por el INTI (Instituto Nacional Tecnologia Industrial) http://www.inti.gob.ar/
#
# Convierte el archivo provisto por el INTI en formato PDF y convertido a texto
# en un archivos separado por comas.
#
#
# v1.0 - 24-Mayo-2017 - Walter M. Lamagna - Extraccion y transformacion preliminar
# v2.0 - 29-Mayo-2017 - Walter M. Lamagna - Un parche para radar "TraffiPatro", solucion para Tipos de Portatil sin registro grafico
#

if (($#ARGV + 1) < 1) {
	print "normalize.pl <archivo cinemometros.txt>\n";
	exit;
}

my $file = @ARGV[0];

open A, "$file" or die ("no pude abrir $file");

my %radares = ();

my $tmp_MODELO = "";
my $tmp_INDUSTRIA = "";
my $tmp_NDESERIE = "";
my $tmp_TIPO = "";

while (<A> ) {
	chomp;
	$line = $_;
	$line =~ s/^\s*//g;
	next if ($line =~ /^MARCA/);
	next if ($line =~ /^CODIGO/);
	next if ($line =~ /^estados unidos/);
	if ($line =~ /^PORTATIL sin reg./) {
		$tmp_TIPO = "$line";
		next;
	}
	# Un casos especiales, pendiente arreglar:
	next if ($line =~ /^Laser Atlanta\/Jet Software SpeedLaser\/Imágenes/ );
	next if ($line =~ /^Stalker Lidar\/Detectra Lidar/);
	next if ($line =~ /^PARVUS M9/);
	$line =~ s/Á/A/g;
	$line =~ s#DNCI\s{2,30}N..#>DNCI Nr#g;
	$line =~ s#DNCI\sNr\s{2,30}([0-9])#DNCI Nr \1#g;
	$line =~ s#\s{3,30}al\s{3,30}# al #g;
	$line =~ s/\s{2,33}/\t/g;
	my ($MARCA,$MODELO,$INDUSTRIA,$NDESERIE,$APROBACION,$Vigentedesde,$TIPO) = split (/\t/, $line);
	$TIPO="$tmp_TIPO $TIPO";
	$tmp_TIPO="";
	$Vigentedesde =~ s# al #,#g;
	$Vigentedesde =~ s#//#/#g;
	$Vigentedesde =~ s# ##g;
	# Esa mania de no ponerle el 20 adelante a los años
	$Vigentedesde =~ s#([0-9]{2}),#20\1,#g;
	$Vigentedesde =~ s#([0-9]{2})$#20\1#g;
	next if ($MARCA eq "");
	if ($INDUSTRIA eq "/ argentina") { $INDUSTRIA = "argentina"; }
	if ($INDUSTRIA eq "argentina /") { $INDUSTRIA = "argentina"; }
	if ($INDUSTRIA eq "Argentina /") { $INDUSTRIA = "argentina"; }
	if ($INDUSTRIA eq "EE UU") { $INDUSTRIA = "estados unidos"; }
	$TIPO =~ s/PORTATIL sin reg. gráfico/PORTATIL/g;
	$TIPO = trim($TIPO);
	print "$MARCA,$MODELO,$INDUSTRIA,$NDESERIE,$APROBACION,$Vigentedesde,$TIPO\n";
}
close A;

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
