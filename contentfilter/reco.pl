#!/usr/bin/perl
# Author: Walter M. Lamagna
# Mail: wlamagna@gmail.com
# Date: 25/Nov/2012
#
# Nota: Calcula la similitud entre peliculas dados los votos de los usuarios.
#
%movies = ();

my @peliculas = ();

# Leo los datos de la matriz
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
	my $i = 0;
	foreach $p (@peliculas) {
		$movies{"$nombre"}{"$p"} = $rating[$i];
		$i++;
	}
}
close F;

# Imprimo los datos leidos
#foreach my $persona (keys %movies) {
#	foreach my $peli (keys %{$movies{"$persona"}}) {
#		print "$persona\t$peli: " . $movies{"$persona"}{"$peli"} . "\n";
#	}
#}
# Similitud entre productos: Similitud de los Vectores de los ratings de los dos
# productos.  los valores son aquellos ratings dados por los usuarios.
# Cuando un usuario no vota alguno de los productos, eso no va.
my @yavistos = ();
# comparo todos con todos
%vectores = ();
foreach my $p1 (@peliculas) {
	push(@yavistos, $p1);
	foreach my $p2 (@peliculas) {
		next if ( grep { $_ eq "$p2"} @yavistos);
		# busco los ratings de los usuarios que votaron ambos productos y 
		# armo dos vectores
		my $cuenta_pares = 0;
		foreach my $usuario (keys %movies) {
			next if (!($movies{"$usuario"}{"$p1"}) || !($movies{"$usuario"}{"$p2"}));
#			print "$usuario\t$p1\t$p2\t" . $movies{"$usuario"}{"$p1"} . "\t" . $movies{"$usuario"}{"$p2"} . "\n";
			$cuenta_pares++;
			if (defined($vectores{"$p1-$p2"})) {
				$vectores{"$p1-$p2"} = $vectores{"$p1-$p2"} . $movies{"$usuario"}{"$p1"} . "," . $movies{"$usuario"}{"$p2"} . "|";
			} else {
				$vectores{"$p1-$p2"} = $movies{"$usuario"}{"$p1"} . "," . $movies{"$usuario"}{"$p2"} . "|";
			}
		}
		if ($cuenta_pares > 5) {
			print "$cuenta_pares,$p1,$p2|";
#			print $vectores{"$p1-$p2"};
			if (defined($vectores{"$p1-$p2"})) {
				print calcular_coseno($vectores{"$p1-$p2"});
			} else {
				print "0";
			}
			print "\n";
		}
	}
}

exit;
foreach my $p1 (keys %movies) {
	push(@yavistos, $p1);
	foreach my $p2 (keys %movies) {
		next if ( grep { $_ eq "$p2"} @yavistos);
		print "$p1\t$p2\n";
	}
}


sub calcular_coseno () {
	my $vectores = @_[0];
	my (@valores) = split(/\|/,$vectores);
	my $suma_mult = 0;
	my $primer_modulo = 0;
	my $segundo_modulo = 0;
	foreach my $v (@valores) {
		my ($v1, $v2) = split(/,/, $v);
		$suma_mult = $suma_mult + ($v1*$v2);
		$primer_modulo = ($primer_modulo + ($v1**2));
		$segundo_modulo = ($segundo_modulo + ($v2**2));
	}
	#print ">>> $primer_modulo\n";
	$primer_modulo = sqrt($primer_modulo);
	$segundo_modulo = sqrt($segundo_modulo);
	#print "--> $suma_mult $primer_modulo $segundo_modulo\n";
	return($suma_mult/($primer_modulo*$segundo_modulo));
}

