#!/usr/bin/perl

$num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "\nUse: sortbib.pl <filename in order of latex parts> <filename of possibly unsorted bibitems>\n";
    exit;
}

my $list_file =$ARGV[0];
my $bibitem_file = $ARGV[1];

open A, "$list_file" or die("Could not find $list_file");
my @archivos = <A>;
close A;

my %bibitems = ();
my $contador = 1;
foreach my $a (@archivos) {
	open B, "$a" or die ("No pude encontrar $a");
	while (<B>) {
		my $line = $_;
		(my @subitems) = $line =~ m/\\cite\{(.*?)\}/g;
		foreach my $s (@subitems) {
			if (!defined($bibitems{"$s"})) {
				$bibitems{"$s"} = $contador;
				$contador++;
			}
		}
		#print "\n" if ($#subitems >= 0);
	}
	close B;
}

my @keys = sort { $bibitems{$a} <=> $bibitems{$b} } keys %bibitems;

open C, "$bibitem_file" or die ("Could not find $bibitem_file");
my %bibitems_file_content = ();
while (<C>) {
	next if $_ !~ /^\\bibitem/;
	chomp;
	my $line = $_;
	my ($bibitem, $content) = $line =~ m/\\bibitem\{(.*?)\} (.*)/g;
	#print "$bibitem -- $content\n";
	$bibitems_file_content{"$bibitem"} = "$content";
	#my @subitems = $line =~ m/\\cite\{(.*?)\}/g;
	
}
close C;

foreach my $key ( @keys ) {
	if (!defined($bibitems_file_content{"$key"})) {
		print "$key -> not found!\n";
	} else {
		print "\\bibitem{$key} " . $bibitems_file_content{"$key"} . "\n";
	}
}





