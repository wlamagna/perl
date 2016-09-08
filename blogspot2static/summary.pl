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

my $diretory_with_blog = $ARGV[1];

my %post_epoch_date = ();
my %post_epoch_title = ();
my %post_epoch_post = ();
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
			my $monthname, $daynum, $yearnum, $def_date_month;
			if ($fecha_post =~ /.*[0-9] de .*/) {  # It is probably spanish date with format "jueves, 3 de noviembre de 2011"
			  ($daynum,$monthname, $yearnum) = $fecha_post =~ m/.*, ([0-9]*) de (.*) de ([0-9]*)/g;
			  if ($date_set == 0) {
				setear_datos_fecha("es"); 
				$date_set = 1;
			  }
			} else { # I assume it is an english date, but there will be cases where it gives error with users feedback
			  # i cover those cases.
			  ($monthname, $daynum, $yearnum) = $fecha_post =~ m/.*, (.*) ([0-9]*), ([0-9]*)/g;
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
			$post_epoch_time = $time;
		}
		if ($line =~ /^template-title: /) {
			($post_title) = $line =~ m/template-title:  (.*)/g;
			#$post_title =~ s/\.//g;
			$post_title =~ s/\///g;
			$post_title =~ s/,//g;
			$post_title =~ s/://g;
			$post_title =~ s/#//g;
			$post_title =~ s/\?//g;
			$post_title =~ s/\s$//g;
		}
		if (($line =~ /^End Article ===/) && ($flag_post_article)) {
			my $post_article = "$tmpline_article";
			$tmpline_article = "";
			my $article_digest = md5_base64($post_article);
			$post_epoch_date{$post_epoch_time}{$article_digest} = $post_date;
			#$post_epoch_post{$post_epoch_time}{$article_digest} = $line;
			$post_epoch_post{$post_epoch_time}{$article_digest} = $post_article;
			$post_epoch_title{$post_epoch_time}{$article_digest} = $post_title;
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
}

# Create the container html with the frames
create_container_page("$diretory_with_blog/index.html", "$blog_title");

# Go through all the articles, look at the date, convert the epoch to year/month and
# build the archive index.
open A, ">$diretory_with_blog/menu.html" or die("Could not open menu.html\n");
close A;

# Create the header page
open A, ">$diretory_with_blog/top.html" or die("Could not open top.html\n");
print A "<center><a href=\"http:\/\/blog.wallves.com\" target=\"_top\">";
print A "<div style=\"font-weight: bold; font-size: 1.5em; color: #3182bd; font-family: cursive;\">";
print A "Server Linux Devops Blog : Sysadmin+Security</div></a></center>";
print A "<center>";
print A "<a href=\"http:\/\/www.wallves.com\" target=\"_top\">";
print A "<div style=\"font-size:0.8em;\">Author: Walter Lamagna</div></a></center>";
close A;

# Get a few stats about the total articles per year and per month to
# make a nicer index;
my %articles_per_year_month = ();
my %articles_per_year = ();
foreach my $epoch_article (reverse sort keys %post_epoch_date) {
	my ($sec, $min, $hour, $day,$month,$year) = (localtime($epoch_article))[0,1,2,3,4,5];
	$year += 1900;
	$month += 1;
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

#create_index_with_dates("$diretory_with_blog/index.html", \%post_epoch_date, \%articles_per_year_month, \%post_epoch_title, \%articles_per_year);
create_index_with_dates("$diretory_with_blog/menu.html", \%post_epoch_date, \%articles_per_year_month, \%post_epoch_title, \%articles_per_year);

file_start("$diretory_with_blog/central.html", "Server Linux Devops Blog from Walter Lamagna");
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
		put_content("$diretory_with_blog/central.html", \%post_epoch_title, \%post_epoch_post, \%post_epoch_date, "$epoch_article", "$md5", $put_ad);
		if ($contador_total_articulos == $page_length) {
			last INDEXER;
		}
	}
}
file_end("$diretory_with_blog/central.html");

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
		#create_page_header("$diretory_with_blog/$file_name.html", "$blog_title");
		#create_index_with_dates("$diretory_with_blog/$file_name.html", \%post_epoch_date, \%articles_per_year_month, \%post_epoch_title, \%articles_per_year);
		file_start("$diretory_with_blog/$file_name.html", "$title");
		put_content("$diretory_with_blog/$file_name.html", \%post_epoch_title, \%post_epoch_post, \%post_epoch_date, "$epoch_article", "$md5", 0);
		file_end("$diretory_with_blog/$file_name.html");
	}
}

print A "</table><div id=\"footer\">
Copyright under the MIT License (c) 2016 Walter Marcelo Lamagna
</div>";

print A "</body></html>";
close A;

