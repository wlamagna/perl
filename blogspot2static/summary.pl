#!/usr/bin/perl
#
# The MIT License (MIT)
# 
# Copyright (c) 2016 Walter Marcelo Lamagna (wlamagna@gmail.com)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
use Time::Local;
use Digest::MD5 qw(md5_base64);
use URI::Escape;
use Getopt::Long;
use POSIX qw(strftime);

require "funcion.pl" or die ("funcion.pl not found");

# These would be passed as arguments in the future
my $page_length = 8;
my $calendar = "y";

my $num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "\nUsage: summary.pl <directory with html files created with produce.pl> <directory to ouput new blog>\n";
    print "\nexample: summary.pl predir output\n";
    exit;
}

my $dirname = $ARGV[0];
#open (A, $ARGV[0]) or die("file $ARGV[0] not found\n");

my $directory_with_blog = $ARGV[1];

my %post_epoch_date = ();
my %post_epoch_title = ();
my %post_epoch_post = ();
my %post_epoch_tag = ();	# post and their tags
my @possible_tags = ();		# list of all tags found
my @possible_years = ();	# list of all years found
my %articles_per_tag = ();	# Amount of articles per tag
my $post_epoch_time = "";
my $post_title = "";
my $post_date = "";
#~ my $flag_post_article = 0;
my $blog_title = "";
# To know if the date / language variables have been set
my $date_set = 0;
my $tmpline_article = "";

foreach my $fp (glob("$dirname/*.html")) {
	open (A, $fp) or die("file $ARGV[0] not found\n");
	print "File:$fp\n";
	my $flag_post_article = 0;
	while(<A>) {
		my $line = $_;
		if (($line =~ /^blog-title: /) && ($blog_title eq "")) {
			($blog_title) = $line =~ m/blog-title: (.*)/g;
		}
		if ($line =~ /^begin-template-date: /) {
			$post_title = "";
			$post_epoch_time = "";
			my ($fecha_post) = $line =~ m/begin-template-date: (.*)/g;
			$post_date = $fecha_post;
			#
			# It supports three format of dates for the post templates
			#
			# begin-template-date: Friday, September 25, 2009
			# begin-template-date: 27/10/2005
			#
			my $monthname, $daynum, $yearnum, $def_date_month;
			if ($fecha_post =~ /.*[0-9] de .*/) {  # It is probably spanish date with format "jueves, 3 de noviembre de 2011"
				($daynum,$monthname, $yearnum) = $fecha_post =~ m/.*, ([0-9]*) de (.*) de ([0-9]*)/g;
				if ($date_set == 0) {
					setear_datos_fecha("es");
					$date_set = 1;
				}
			} elsif ($fecha_post =~ /.*, .* [0-9]*, [0-9]*/) {
			  # I assume it is an english date, but there will be cases where it gives error with users feedback
			  # i cover those cases.
				($monthname, $daynum, $yearnum) = $fecha_post =~ m/.*, (.*) ([0-9]*), ([0-9]*)/g;
				if ($date_set == 0) {
					setear_datos_fecha("en");
					$date_set = 1;
				}
			} else {
				my $mnum;
				($daynum, $mnum, $yearnum) = $fecha_post =~ m#([0-9]*)/([0-9]*)/([0-9]*)#g;
				$monthname = $month_name_en[($mnum-1)];
				if ($date_set == 0) {
					setear_datos_fecha("en");
					$date_set = 1;
				}
			}
			$def_date_month = $month_name_lookup{$monthname};
			my $def_date_year = $yearnum;
			my $def_date_day = $daynum;
			my $def_date = "$def_date_day/$def_date_month/$def_date_year";
			my $time = timelocal(0,0,0,$def_date_day,$def_date_month,$def_date_year); 
			my $wday = strftime "%w", localtime($time);
			$dianombre = @days_en[$wday-1];
			#print "[$fecha_post] $dianombre $daynum ($wday) $monthname [$def_date] $yearnum\n";
			$post_date = "$dianombre, $monthname $daynum, $yearnum";
			$post_epoch_time = $time;
		}
		if ($line =~ /^template-title: /) {
			($post_title) = $line =~ m/template-title: (.*)/g;
			$post_title = trim($post_title);
			#$post_title =~ s/\.//g;
			$post_title =~ s/\///g;
			$post_title =~ s/,//g;
			$post_title =~ s/://g;
			$post_title =~ s/#//g;
			$post_title =~ s/\?//g;
			$post_title =~ s/\s$//g;
		}
		if ($line =~ /^tags: /) {
			($post_tags) = $line =~ m/tags: (.*)/g;
			$post_tags =~ s/ //g;
			my @p = split(",", $post_tags);
			foreach my $onep (@p) {
				if (defined($articles_per_tag{"$onep"})) {	
					$articles_per_tag{"$onep"}++;
				} else {
					$articles_per_tag{"$onep"} = 1;
				}
				if (!(grep { $onep eq $_ } @possible_tags )) {
					push(@possible_tags, $onep);
				}			
			}
		}
		if (($line =~ /^End Article ===/) && ($flag_post_article)) {
			my $post_article = "$tmpline_article";
			$tmpline_article = "";
			my $article_digest = md5_base64($post_article);
			$post_epoch_date{$post_epoch_time}{$article_digest} = $post_date;
			#$post_epoch_post{$post_epoch_time}{$article_digest} = $line;
			$post_epoch_post{$post_epoch_time}{$article_digest} = $post_article;
			$post_epoch_title{$post_epoch_time}{$article_digest} = $post_title;
			$post_epoch_tag{$post_epoch_time}{$article_digest} = $post_tags;
			$post_tags = "";
			$flag_post_article = 0;
		}
		if ($flag_post_article) {
			#$line =~ s/\n//g;
			$tmpline_article = "$tmpline_article$line";
		}
		if ($line =~ /^Begin Article ===/) {
			$post_article = "";
			$flag_post_article = 1;
		}
	}
	close A;
	#break;
}

# Create the container html with the frames
create_container_page("$directory_with_blog/index.html", "$blog_title");

# Create the header page
open A, ">$directory_with_blog/top.html" or die("Could not open top.html\n");
print A "<center><a href=\"http:\/\/blog.wallves.com\" target=\"_top\">\n";
print A "<div style=\"font-weight: bold; font-size: 1.5em; color: #ffb366; font-family: cursive;\">\n";
print A "Server Linux Devops Blog : Sysadmin+Security</div></a></center>\n";
print A "<center>
<a href=\"http:\/\/www.wallves.com\" target=\"_top\">
<div style=\"font-size:0.8em;\">Author: Walter Lamagna</div></a></center>
<style type=\"text/css\">
a:link {color: #ccffcc; text-decoration: none;}
a:active {color: #b3ffff; text-decoration: underline; }
a:visited {color: #b3ffff; text-decoration: underline; }
a:hover {color: #ff0000; text-decoration: none; }
</style>\n";

#
# Go through all the articles, look at the date, convert the epoch to year/month and
# build the archive index.
#
close A;

# Get a few stats about the total articles per year and per month to
# make a nicer index;
my %articles_per_year_month = ();
my %articles_per_year = ();
foreach my $epoch_article (reverse sort keys %post_epoch_date) {
	my ($sec, $min, $hour, $day,$month,$year) = (localtime($epoch_article))[0,1,2,3,4,5];
	$year += 1900;
	$month += 1;
	if (!( grep { $_ eq $year } @possible_years )) {
		push @possible_years, "$year";
	}			

	foreach my $md5 (keys %{$post_epoch_date{$epoch_article}}) {
		if (defined($articles_per_year_month{$year}{$month})) {
			$articles_per_year_month{$year}{$month}++;
		} else {
			$articles_per_year_month{$year}{$month} = 1;
		}
		if (!(defined($articles_per_year{$year}))) {
			$articles_per_year{$year} = 1;
		} else {
			$articles_per_year{$year}++;
		}
	}
}

# ---------------------------------------------------------------------------------------------
# Agrego a top.html los a#os y cantidad de articulos
# Agrego las categorias posibles (Tags)
#
# ---------------------------------------------------------------------------------------------
#create_index_with_dates("$directory_with_blog/index.html", \%post_epoch_date, \%articles_per_year_month, \%post_epoch_title, \%articles_per_year);
create_years_list("$directory_with_blog/top.html", \%articles_per_year);
create_tags_list("$directory_with_blog/top.html", \%articles_per_tag);


# ---------------------------------------------------------------------------------------------
# Aca creo el central.html con algunos articulos
# La cantidad de articulos esta determinada por la variable $page_length
#
# ---------------------------------------------------------------------------------------------
file_start("$directory_with_blog/central.html", "Server Linux Devops Blog from Walter Lamagna");
my $first_post = 1;
my $put_ad = 0;
my $articles_date = scalar(keys %post_epoch_date);
my $contador_total_articulos = 0;
INDEXER: foreach my $epoch_article (reverse sort keys %post_epoch_date) {
	my $counter = scalar(keys %{$post_epoch_date{$epoch_article}});
	$articles_date = $articles_date - 1;
	foreach my $md5 (keys %{$post_epoch_date{$epoch_article}}) {
		$counter = $counter - 1;
		$contador_total_articulos = $contador_total_articulos + 1;
		if ((($counter + $articles_date) == 0) || ($contador_total_articulos == $page_length)) {
			$put_ad = 1;
		}
		put_content("$directory_with_blog/central.html", \%post_epoch_title, 
		\%post_epoch_post, \%post_epoch_date, \%post_epoch_tag, "$epoch_article", "$md5", $put_ad);
		if ($contador_total_articulos == $page_length) {
			last INDEXER;
		}
	}
}
file_end("$directory_with_blog/central.html");

#
# Create a page for each post also
#
foreach my $epoch_article (reverse sort keys %post_epoch_date) {
	foreach my $md5 (keys %{$post_epoch_date{$epoch_article}}) {
		my $title = $post_epoch_title{$epoch_article}{$md5};
		#my $file_name = uri_escape($title);
		#$title =~ s/\.//g;
		$title =~ s/\///g;
		$title =~ s/,//g;
		$title =~ s/://g;
		$title =~ s/#//g;
		$title =~ s/\?//g;
		$title =~ s/\s$//g;
		my $file_name = $title;
		#create_page_header("$directory_with_blog/$file_name.html", "$blog_title");
		#create_index_with_dates("$directory_with_blog/$file_name.html", 
		#\%post_epoch_date, \%articles_per_year_month, \%post_epoch_title, \%articles_per_year);
		file_start("$directory_with_blog/$file_name.html", "$title");
		put_content("$directory_with_blog/$file_name.html", \%post_epoch_title, 
		\%post_epoch_post, \%post_epoch_date, \%post_epoch_tag, "$epoch_article", "$md5", 0);
		file_end("$directory_with_blog/$file_name.html");
	}
}

#
# Create one page for each year with the posts related to that year
#
foreach my $y (@possible_years) {
	print "Creando: $directory_with_blog/y$y.html\n";
	file_start("$directory_with_blog/y$y.html", "Year $y");
}
foreach my $epoch_article (reverse sort keys %post_epoch_date) {
	my ($sec, $min, $hour, $day,$month,$year) = (localtime($epoch_article))[0,1,2,3,4,5];
	$year += 1900;
	$month += 1;
	foreach my $md5 (keys %{$post_epoch_date{$epoch_article}}) {
		my $title = $post_epoch_title{$epoch_article}{$md5};
		#my $file_name = uri_escape($title);
		#$title =~ s/\.//g;
		$title =~ s/\///g;
		$title =~ s/,//g;
		$title =~ s/://g;
		$title =~ s/#//g;
		$title =~ s/\?//g;
		$title =~ s/\s$//g;
		my $file_name = $title;
		put_content("$directory_with_blog/y$year.html", \%post_epoch_title, 
		\%post_epoch_post, \%post_epoch_date, \%post_epoch_tag, "$epoch_article", "$md5", 0);
	}
}
foreach my $y (@possible_years) {
	file_end("$directory_with_blog/y$y.html");
}


#
# Create one page for each tag with the posts related to that tag
# 

foreach my $t (@possible_tags) {
	print "Creando: $directory_with_blog/tag_$t.html\n";
	file_start("$directory_with_blog/tag_$t.html", "Category $t");
}
foreach my $epoch_article (reverse sort keys %post_epoch_date) {
	my ($sec, $min, $hour, $day,$month,$year) = (localtime($epoch_article))[0,1,2,3,4,5];
	$year += 1900;
	$month += 1;
	foreach my $md5 (keys %{$post_epoch_date{$epoch_article}}) {
		my $title = $post_epoch_title{$epoch_article}{$md5};
		my $tag_list = $post_epoch_tag{$epoch_article}{$md5};
		#my $file_name = uri_escape($title);
		#$title =~ s/\.//g;
		$title =~ s/\///g;
		$title =~ s/,//g;
		$title =~ s/://g;
		$title =~ s/#//g;
		$title =~ s/\?//g;
		$title =~ s/\s$//g;
		my $file_name = $title;
		my @subtags = split(",", $tag_list);
		foreach my $st (@subtags) {
			put_content("$directory_with_blog/tag_$st.html", \%post_epoch_title, 
			\%post_epoch_post, \%post_epoch_date, \%post_epoch_tag, "$epoch_article", "$md5", 0);
		}
	}
}
foreach my $t (@possible_tags) {
	file_end("$directory_with_blog/tag_$t.html");
}


print A "</table><div id=\"footer\">
Copyright under the MIT License (c) 2016 Walter Marcelo Lamagna
</div>";

print A "</body></html>";
close A;

