#!/usr/bin/perl
#
# The MIT License (MIT)
# 
# Copyright (c) 2015 Walter Marcelo Lamagna (wlamagna@gmail.com)
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
# These packages are needed to do the obtention of images
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use URI::Heuristic;

# These are other packages
use Encode qw(decode encode);
use Digest::MD5 qw(md5_base64);
use HTML::TreeBuilder;

require "funcion.pl" or die ("funcion.pl not found");

binmode(OUT, ":utf8");
my $html  = HTML::TreeBuilder->new;

open (A, $ARGV[0]) or die("file $ARGV[0] not found\n");

my $root  = $html->parse_file( $ARGV[0] );
my $blogtitle = $root->look_down(_tag => 'h1', class => 'title');
my $date = $root->look_down(_tag => 'h2', class => 'date-header');
print "blog-title: " . $blogtitle->as_text . "\n";
print "begin-template-date: " . $date->as_text . "\n";
my $title = $root->look_down(_tag => 'h3', class => 'post-title entry-title');

print "template-title: " . $title->as_text . "\n";

my $article = $root->look_down(_tag => 'div', class => 'post-body entry-content');

print "Begin Article ===\n";
my $article_html = $article->as_HTML;
my $article_digest = md5_base64($article_html);
$article_digest =~ s/-//g;
$article_digest =~ s/\///g;
$article_html = sub_procesamiento($article_html, $article_digest);
$article_html =~ s/<div class=\"post-body .*?\">//g;
$article_html =~ s/<\/div>$//g;
$article_html =~ s/\n/<br>/g;
#<div class="post-body entry-content" id="post-body-2204394603832579925" itemprop="description articleBody">
print "$article_html\nEnd Article ===\n";
close A;
