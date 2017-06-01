#!/usr/bin/perl
# 
# ETL para archivo de Cinemometros provisto por el Servicio Nacional de Metrología (SNM) de Peru.
# https://servicios.inacal.gob.pe
#
# En Peru, el Servicio Nacional de Metrología (SNM) fue creado el 6 de Enero de 1983 mediante la Ley N° 23560 
# y ha sido encomendado al INDECOPI - mediante el Decreto Supremo DS-024-93 ITINCI
# Convierte el archivo provisto por el INTI en formato PDF y convertido a texto
# en un archivos separado por comas.
#
# v1.0 - 01-Junio-2017 - Walter M. Lamagna - Extraccion y transformacion preliminar
#

if (($#ARGV + 1) < 1) {
	print "normalize_p.pl <archivo cinemometros_p.txt>\n";
	exit;
}

my $file = @ARGV[0];

open A, "$file" or die ("no pude abrir $file");
print "solicitante_Nombre,tipoMedidor_Marca,tipoMedidor_Modelo,desde,hasta\n";

while (<A> ) {
	chomp;
	$line = $_;
	$line =~ s/^\s*//g;
	next if ($line =~ /^mensaje/);

	$line =~ s#\.##g;
	$line =~ s/\s{2,33}/ /g;
	my ($solicitante_Nombre) = $line =~ m/.*solicitante_Nombre":"(.*?)",.*/g;
	next if ($solicitante_Nombre eq "");
	my ($tipoMedidor_Marca) = $line =~ m/.*tipoMedidor_Marca":"(.*?)",.*/g;
	my ($tipoMedidor_Modelo) = $line =~ m/.*tipoMedidor_Modelo":"(.*?)",.*/g;
	my ($resultado_Fecha_Emision) = $line =~ m/.*resultado_Fecha_Emision":"(.*?)",.*/g;
	my ($anio, $mes, $dia) = $resultado_Fecha_Emision =~ m/([0-9]{4})-([0-9]{2})-([0-9]{2})/g;
	my $resultado_Fecha_Emision_new = "$dia/$mes/$anio";
	my $anio_next = ($anio+1);
	my $resultado_Fecha_Emision_next = "$dia/$mes/$anio_next";

	$solicitante_Nombre =~ s/,/ /g;
	$tipoMedidor_Marca =~ s/,/ /g;
	$tipoMedidor_Modelo =~ s/,/ /g;

	$solicitante_Nombre =~ s/\s{2,33}/ /g;
	$tipoMedidor_Marca =~ s/\s{2,33}/ /g;
	$tipoMedidor_Modelo =~ s/\s{2,33}/ /g;

	print "$solicitante_Nombre,$tipoMedidor_Marca,$tipoMedidor_Modelo,$resultado_Fecha_Emision_new,$resultado_Fecha_Emision_next\n";
}
close A;

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
