#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

my $dir="../archive/aps";

# ========== load citation count ==========

my @citation_count=split/\n/, `cat $dir/aps_citation_count.txt`;
my %citation_count;

for my $citation_count (@citation_count) {
	$citation_count=~/ /;
	$citation_count{$`}=$';
}

# ========== align to articles ==========

open IN, "<boosting.txt";
open OUT, ">scatter.txt";
while (<IN>) {
	chomp;
	my ($boosted, $boosting, $boost)=split/ /, $_;
	
	if ($boost > 0) {
		print OUT "$boosted $citation_count{$boosted} $boost\n";
	}
}
close IN;
close OUT;
