#!/usr/bin/perl
# Author: Walter Lamagna (wlamagna@gmail.com)
# Year: 2012
#
# Levenstein distance in perl
# I found part of this in Wikipedia, but it has some errors. Use at your own risk.
#
my $first = @ARGV[0];
my $second = @ARGV[1];

print levenstein($first, $second) . "\n";

sub levenstein {
	my $word1 = shift;
	my $word2 = shift;
	return 0 if $word1 eq $word2;
	my @d;

	my $len1 = length $word1;
	my $len2 = length $word2;

#	print "[$len1] $word1\n";
#	print "[$len2] $word2\n";
	$d[0][0] = 0;
	for (1 .. $len1) {
		$d[$_][0] = $_;
		#print "$_ , $len1 , " . substr($word1,$_) . "|" . substr($word2,$_) . "\n";
		#print ">$_\n" if $_!=$len1 && substr($word1,$_) eq substr($word2,$_);
#		return $_-1 if $_!=$len1 && substr($word1,$_) eq substr($word2,$_);
	}
	for (1.. $len2) {
		$d[0][$_] = $_;
		#print "$_ , $len2 , " . substr($word1,$_) . "|" . substr($word2,$_) . "\n";
		#print ">$_\n" if $_!=$len1 && substr($word1,$_) eq substr($word2,$_);
#		return $_-1 if $_!=$len2 && substr($word1,$_) eq substr($word2,$_);
	}
	for my $i (1 .. $len1) {
		my $w1 = substr($word1,$i-1,1);
#		print "$w1:";
		for (1 .. $len2) {
#			print "[$_] $d[$i-1][$_],$d[$i][$_-1],$d[$i-1][$_-1] ->";
			$d[$i][$_] = _min($d[$i-1][$_]+1, $d[$i][$_-1]+1, $d[$i-1][$_-1]+($w1 eq substr($word2,$_-1,1) ? 0 : 1));
#			print "$d[$i][$_]\n";
		}
	}
	return $d[$len1][$len2];
}

sub _min {
	return $_[0] < $_[1]
	? $_[0] < $_[2] ? $_[0] : $_[2]
	: $_[1] < $_[2] ? $_[1] : $_[2];
}
