#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

my $dir="../archive/aps";

# ========== load citation years ==========

my %doi_year;

open IN, "<$dir/aps_doi_year_title.txt";
while (<IN>) {
	chomp;
	my @words=split/ /, $_;
	
	my $doi=shift @words;
	my $year=shift @words;
	
	$doi_year{$doi}=$year;
	
}
close IN;

# ========== align duration to articles ==========

open IN, "<boosting.txt";
open OUT, ">duration.txt";
while (<IN>) {
	chomp;
	my ($to, $from, $boosting)=split/ /, $_;
	
	if ($boosting > 0 && $doi_year{$from} >= 1900 && $doi_year{$to} >= 1900) {
		my $duration=$doi_year{$from}-$doi_year{$to};
		
		if ($duration >= 0) {
			print OUT "$duration $boosting\n";
		}
	}
}
close IN;
close OUT;
