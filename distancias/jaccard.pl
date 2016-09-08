#!/usr/bin/perl

# Obtain the jaccard similarity index from two strings
#
sub jaccard {
	my ($firststring, $secondstring) = @_;
	my @one = split(/ /, $firststring);
	my @two = split(/ /, $secondstring);
	my $cont_union = 0;
	my $cont_inter = 0;
	my @yavisto = ();
	# count the intersection and the union of the two strings.
	foreach my $o (@one) {
		next if ((grep { $_ eq "$o" } @yavisto));
		if ((grep { $_ eq "$o" } @two)) {
			$cont_inter++;
			push (@yavisto, "$o");
		}
		$cont_union++;
	}
	foreach my $o (@two) {
		next if ((grep { $_ eq "$o" } @yavisto));
		$cont_union++;
	}
	# Return the jaccard index
	return sprintf("%.3f", ($cont_inter/$cont_union));
}

# Returns the intersection of two similar strings
sub jcenter {
	my ($firststring, $secondstring) = @_;
	my @one = split(/ /, $firststring);
	my @two = split(/ /, $secondstring);
	# this array holds the words that conform the centre.
	my @yavisto = ();
	foreach my $o (@one) {
		next if ((grep { $_ eq "$o" } @yavisto));
		if ((grep { $_ eq "$o" } @two)) {
			push (@yavisto, "$o");
		}
	}
	return (\@yavisto);
}

# Clean the text entry.  Remove some symbols that i consider non significant 
# in this moment (year 2013), for this problem to resolve and in for this dataset.

sub clean_1 {
	my $o = $_[0];
        chomp $o;
        $o =~ s/\./ /g;
        $o =~ s/:/ /g;
        $o =~ s/_/ /g;
        $o =~ s/\;/ /g;
        $o =~ s/ - / /g;
        $o =~ s/>/ /g;
        $o =~ s/</ /g;
        $o =~ s/\(/ /g;
        $o =~ s/\t/ /g;
        $o =~ s/\|/ /g;
        $o =~ s/=/ /g;
        $o =~ s/ -/ /g;
        $o =~ s/- / /g;
        $o =~ s/#/ /g;
        $o =~ s/\*/ /g;
        $o =~ s/\)/ /g;
        $o =~ s/\// /g;
        $o =~ s/\s{2,30}/ /g;
	return ($o);
}
1;
