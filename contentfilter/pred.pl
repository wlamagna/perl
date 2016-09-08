#!/usr/bin/perl
# Author: Walter M. Lamagna
# Mail: wlamagna@gmail.com
# Date: 25/Nov/2012
#
# Nota: Predice cuanto le va a gustar una pelicula a un usuario
#

my $DEBUG=0;
my $usuario = $ARGV[0];
my $peli = $ARGV[1];

open F, "similes.txt" or die ($!);
print "Prediciendo para $usuario.\nSimilares a: $peli\n--------------------\n" if ($DEBUG);

my %productos_similares;
# Traigo los items similares al buscado
while(<F>) {
	chomp;
	my ($peliculas, $pred) = split(/\|/);
	my ($w, $p1, $p2) = split(/,/, $peliculas);
	next if ($pred < 0.96);
	if (("$p1" eq "$peli") | ("$p2" eq "$peli")) {
		print "[$pred] $peliculas\n"  if ($DEBUG);
		$productos_similares{"$peliculas"} = $pred;
	}
}
close F;

# Buscar , de los similares, los productos donde el usuaio
# dio una opinion
#
my %movies;
my @peliculas = ();
my @rating = ();
open F, "reco.txt" or die ($!);
while (<F>) {
	chomp;
	# Estan las peliculas
	if (/^\t/) {
		s/^\t//g;
		@peliculas = split(/\t/);
		next;
	}
	my ($nombre , @rating) = split(/\t/);
	next if ("$nombre" ne "$usuario");
	my $i = 0;
	foreach $p (@peliculas) {
		$movies{"$nombre"}{"$p"} = $rating[$i];
		$i++;
	}
}
close F;

print "El usuario puntuo estas peliculas:\n-------------------------------\n"  if ($DEBUG);

foreach $p (@peliculas) {
	next if ($movies{"$usuario"}{"$p"} == 0);
	print "$p\t" . $movies{"$usuario"}{"$p"} . "\n"  if ($DEBUG);
}

print "\nDe los similares, de estos dio opinion el usuario:\n---------------------------------------\n"  if ($DEBUG);
### Ahora, de los que el usuario dio opinion, y que son similares a los del producto
# que quiero predecir, hago la prediccion:
#
my $numerador = 0;
my $denominador = 0;
foreach $p (@peliculas) {
	next if ($movies{"$usuario"}{"$p"} == 0);
	foreach my $k (keys %productos_similares) {
		my ($w, $p1, $p2) = split(/,/, $k);
		if (("$p1" eq "$p") | ("$p2" eq "$p")) {
			print "$p:" . $movies{"$usuario"}{"$p"} . "," . $productos_similares{"$k"} . "\n"  if ($DEBUG);
			$numerador = $numerador + (($movies{"$usuario"}{"$p"}) * ($productos_similares{"$k"}));
			$denominador = $denominador + ($productos_similares{"$k"});
		}
	}
}
print "\n"  if ($DEBUG);
if (($numerador) & ($denominador)) {
	#print "$numerador\n";
	#print "$denominador\n";
	print ($numerador / $denominador);
} else {
	print "0";
}
print "\t$usuario\t$peli\n";

