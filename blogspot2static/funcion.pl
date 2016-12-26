# Some useful variables
#
# How many posts in the main page, this can be customized
our $counter = 8;
# Month names, may be translated to other languages in the future
our @days_en = ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday");
our @days_es = ("Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado", "Domingo");
our @month_name_en = qw/ January February March April May June July August September October November December /;
our @month_name_es = qw/ enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre /;
our %month_num = ();
our %month_name_lookup = ();

sub setear_datos_fecha() {
  my $lang = $_[0];
  for (my $i=0; $i<13; $i++) {
    if ($lang eq "es") {
	$month_num{$i+1} = $month_name_es[$i];
	$month_name_lookup{"$month_name_es[$i]"} = $i;
    }
    if ("$lang" eq "en") {
	$month_num{$i+1} = $month_name_en[$i];
	$month_name_lookup{"$month_name_en[$i]"} = $i;
    }
  }
}


sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };


sub create_container_page() {
	my $file_name = $_[0];
	my $blog_title = $_[1];
	# Creating the web page
	open A, ">$file_name" or die("Could not create the index.html file!\n");

print A "<html>
<head>
<meta charset=\"UTF-8\" />
<title>$blog_title</title>
<link rel=\"shortcut icon\" href=\"/favicon.ico?v=6cd6089ee7f6\">
<link rel=\"stylesheet\" type=\"text/css\" href=\"css/blogstyle.css\">
<script type=\"text/javascript\" src=\"js/jquery-1.4.2.min.js\"></script>
<script type=\"text/javascript\" src=\"js/archive_anim.js\"></script>
</head>
<frameset rows=\"100,*\" border=\"0\">
  <frame name=\"alto\" src=\"top.html\" scrolling=\"no\">
  <frame name=\"central\" src=\"central.html\">
</frameset>
</html>\n";
	close A;
}




sub file_start() {
	my $file_name = $_[0];
	my $title = $_[1];
	open A, ">$file_name" or die("create_file(): Could not open $file_name for creation!\n");
	print A "<html>\n<head>
<title>$title</title>
<link rel=\"stylesheet\" type=\"text/css\" href=\"css/blogstyle.css\">
</head>
<body style=\"margin:20;padding:0;\">
<script language=\"javascript\">
window.parent.document.title = \"$title\";
</script>\n";
	close A;
}

sub file_end() {
	my $file_name = $_[0];
	open A, ">>$file_name" or die("create_file(): Could not open $file_name for creation!\n");
	print A "</body></html>";
	close A;
}

sub put_content() {
	my $file_name = $_[0];
	my %post_epoch_title = %{ $_[1] };
	my %post_epoch_post = %{ $_[2] };
	my %post_epoch_date = %{ $_[3] };
	my %post_epoch_tags = %{ $_[4] };
	my $epoch_article = $_[5];
	my $md5 = $_[6];
	my $put_ad = $_[7];
	open A, ">>$file_name" or die("put_content(): Could not open $file_name for addition!\n");
	my $title = $post_epoch_title{$epoch_article}{$md5};
	my $file_name = uri_escape($title);
	print A "<div id=\"section\">\n";
	if ($put_ad == 1) {
		print A "<script type=\"text/javascript\">
google_ad_client = \"ca-pub-1655368661140826\";
google_ad_slot = \"5799356291\";
google_ad_width = 728;
google_ad_height = 90;
</script><!-- blog_linux_1 -->";
		print A "<script type=\"text/javascript\" src=\"http://pagead2.googlesyndication.com/pagead/show_ads.js\">\n";
		print A "</script>";
	}
	print A "<p id=\"postTitle\"><a href=\"$file_name.html\" id=\"alink\">$title</a></p>\n";
	#print A $post_epoch_title{$epoch_article}{$md5};
	print A $post_epoch_post{$epoch_article}{$md5};
	print A "<b>Published: " . $post_epoch_date{$epoch_article}{$md5} . "</b>\n";
	#print A "</div><hr>\n";
	# print some status about the script execution, for debugging:
	#print "$epoch_article\t" . $post_epoch_date{$epoch_article}{$md5} . "\t$title [$counter]\n";
	my $tags = $post_epoch_tags{$epoch_article}{$md5};
	my @taglist = split(",", $tags);
	foreach my $t (@taglist) {
		print A "<a href=\"tag_$t\">$t</a>&nbsp;";
	}
	print A "\n</div>\n";
	print A "\n<hr>\n";
	close A;
}


# This function creates the menu.html file withe
# the years/month/articles
sub create_tags_list() {
	my $file_name = $_[0];
	my %articles_per_tag = %{ $_[1] };

	# And now, just create the date index with the articles
	open A, ">>$file_name" or die("create_tags_list(): Could not open $file_name for addition!\n");
	print A "<center>\n";
	foreach my $tag (sort keys %articles_per_tag) {
		print A "<a href=\"tag_$tag.html\" target=\"central\">$tag</a> (";
		print A $articles_per_tag{$tag};
		print A ")&nbsp\n";
	}
	print A "</center>\n";
	print A "</div>";
	close A;
}


# This function creates the menu.html file withe
# the years/month/articles
sub create_years_list() {
	my $file_name = $_[0];
	my %articles_per_year = %{ $_[1] };

	# And now, just create the date index with the articles
	my $previous_year = "";
	my $previous_month = "";
	open A, ">>$file_name" or die("create_index_with_dates(): Could not open $file_name for addition!\n");
	print A "<div style=\"font-family: Verdana; color: #b3ffff; font-size: 12px;\">\n";
	print A "\n<center>\n";
	foreach my $year (reverse sort keys %articles_per_year) {
		print A "<a href=\"y$year.html\" target=\"central\">$year</a> (";
		print A $articles_per_year{$year};
		print A ")&nbsp\n";
	}
	print A "</center>\n";
	close A;
}


# This function creates the menu.html file withe
# the years/month/articles
sub create_index_with_dates() {
	my $file_name = $_[0];
	my %post_epoch_date = %{ $_[1] };
	my %articles_per_year_month = %{ $_[2] };
	my %post_epoch_title = %{ $_[3] };
	my %articles_per_year = %{ $_[4] };
	# And now, just create the date index with the articles
	my $previous_year = "";
	my $previous_month = "";
	open A, ">>$file_name" or die("create_index_with_dates(): Could not open $file_name for addition!\n");
	#print A "<tr><td style=\"width: 200px; background-color:#eeeeee;\" valign=\"top\">
	print A "<html><body style=\"margin:20;padding:0;\"><head>
<link rel=\"stylesheet\" type=\"text/css\" href=\"css/blogstyle.css\">
<script type=\"text/javascript\" src=\"js/jquery-1.4.2.min.js\"></script>
<script type=\"text/javascript\" src=\"js/archive_anim.js\"></script>
</head><body style=\"margin:20;padding:0;\">
<div id=\"listContainer\" valign=\"top\">
<ul id=\"expList\">\n";
  foreach my $epoch_article (reverse sort keys %post_epoch_date) {
    my ($sec, $min, $hour, $day,$month,$year) = (localtime($epoch_article))[0,1,2,3,4,5];
    $year += 1900;
    $month += 1;
    if ($previous_year ne $year) {
      if ($previous_year ne "") {
        print A "\t</li></ul>\n";
        $previous_month = "";
      }
      $previous_year = $year;
      print A "<li id=\"ayear\">$year&nbsp;(";
      print A $articles_per_year{$year};
      print A ")\n";
    }
	if ($previous_month ne $month) {
		if ($previous_month ne "") {
			print A "\t</li></ul>\n";
		}
		$previous_month = $month;
		print A "\t<!--month--><ul><li id=\"amonth\">";
		print A $month_num{$month} . "&nbsp;(" . $articles_per_year_month{$year}{$month} . ")\n";
		foreach my $md5 (keys $post_epoch_date{$epoch_article}) {
			my $title = $post_epoch_title{$epoch_article}{$md5};
			#my $file_name = uri_escape($title);
        		#$title =~ s/\.//g;
        		$title =~ s/\///g;
        		$title =~ s/,//g;
			$title =~ s/#//g;
        		$title =~ s/\s$//g;
			$file_name = $title;
        		#$file_name =~ s/ /%20/g;
        		print A "\t\t<ul><li><img src=\"css/posticon.gif\" />";
			print A "<a href=\"$file_name.html\" id=\"alink\" target=\"central\">";
			print A $post_epoch_title{$epoch_article}{$md5} . "</a></li></ul>\n";
		}
        } else {
		foreach my $md5 (keys $post_epoch_date{$epoch_article}) {
			my $title = $post_epoch_title{$epoch_article}{$md5};
                        #$title =~ s/\.//g;
                        $title =~ s/\///g;
                        $title =~ s/,//g;
                        $title =~ s/#//g;
                        $title =~ s/\s$//g;
                        $file_name = $title;
                        #$file_name =~ s/ /%20/g;
			print A "\t\t<ul><li><img src=\"css/posticon.gif\" />";
			print A "<a href=\"$file_name.html\" id=\"alink\" target=\"central\">";
                        print A $post_epoch_title{$epoch_article}{$md5} . "</a></li></ul>\n";
                        #print A "\t\t<ul><li>" . $post_epoch_title{$epoch_article}{$md5} . "</li></ul>\n";
      		}
	}
  }
  #print A "</ul></div></td>\n";
  print A "</ul></div></body></html>\n";
  close A;
}


sub traer_imagen
{
	my $ff = @_[0];
	my $pid = @_[1];
	my $fname = $ff;
	if ($fname =~ /\//) {
		$fname =~ s/.*\///g;
	}
	$client = LWP::UserAgent->new();
	$client->agent("Mozilla/4.0 (compatible; MSIE 5.5; Windows 98)");
	$request = HTTP::Request->new(GET => "$ff");
	$response = $client->request($request);
        if ($response->is_error()) {
		return("");
		printf("%s\n", $response->status_line);
	} else {
		my $file = $response->content();
		$fname =~ s/\?/-/g;
		$fname =~ s/\%/-/g;
		$fname =~ s/\&/-/g;
		open (L, ">>externos/${pid}_${fname}") or die("Could not create externos/${pid}_${fname}\n");
		print L $file;
		close L;
	}
	return ("externos/${pid}_${fname}");
}


sub sub_procesamiento
{
	my $htmldata = $_[0];
	my $pid = @_[1];
	binmode STDOUT, ':utf8';

        my $line = $htmldata;
#       $line =~ s/position: absolute;//g;
#       $line =~ s/border: 1px/border: 0px/g;
        $line =~ s/\r//g;
        my $lcline = lc $line;
        if ($lcline =~ /<img /) {
                my (@items) = $line =~ m/ src="(.*?)"/g;
                foreach my $i (@items) {
#                       print "\n=== $i ===[ ";
                        my $tt = traer_imagen($i, $pid);
                        #print "$tt ]===";
                        $i =~ s/\//\\\//g;
                        $i =~ s/\?/\\\?/g;
                        $i =~ s/\&/\\\&/g;
                        $line =~ s/$i/$tt/g;
#                       print "$tt ]===\n$line";
                        #print " $tt\n";
                }
        }
        if ($lcline =~ / href="/) {
                my (@items) = $line =~ m/ href="(.*?)"/g;
                foreach my $i (@items) {
                        #print "\n=== $i ===[ ";
                        $i =~ s/\//\\\//g;
                        $i =~ s/\?/\\\?/g;
                        $i =~ s/\&/\\\&/g;
                        $line =~ s/href=\"$i/href=\"\#/g;
                        #print "$line]===\n";
                }
                #print "$line\n";
        }
        return("$line");
}


1;
