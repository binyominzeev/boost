#!/usr/bin/perl
use strict;
use warnings;

use Set::Scalar;
use Data::Dumper;

# ============== parameters ==============

my $dir="../archive/aps";

my $nodes_file="$dir/aps_doi_year_title.txt";
my $nodes_count=463347;

my $edges_file="$dir/citing_cited.csv";
my $edges_count=4710548;

#my $boosted="10.1103/PhysRevA.57.4778";

# ============== load %uid2year, %uid2title ==============

open IN, "<$nodes_file";
open OUT, ">boosting.txt";
while (<IN>) {
	chomp;
	/ /;
	
	my $boosted=$`;
	my $boosting=boosting($boosted);
	
	print OUT "$boosted $boosting\n";
}
close IN;
close OUT;

# ============== functions ==============

sub boosting {
	my $boosted=shift;
	
	my $children=children($boosted);
	my $children_set=new Set::Scalar(@$children);

	my $max_boost_val=0;
	my $max_boosting=0;

	for my $child (@$children) {
		my $gchildren=children($child);
		my $gchildren_set=new Set::Scalar(@$gchildren);
		
		my $intersection=$children_set->intersection($gchildren_set);
		my $proportion=$intersection->size/(scalar @$children);
		
		if ($proportion > $max_boost_val) {
			$max_boost_val=$proportion;
			$max_boosting=$child;
		}
	}
	
	return "$max_boosting $max_boost_val";
}

sub children {
	my $id=shift;
	
	#my @children=split/\n/, `grep ",$id" $dir/citing_cited.csv`;
	#@children=map { /,/; $` } @children;
	
	my @children=split/\n/, `sgrep $id, $dir/cited_citing.sorted.csv`;
	@children=map { /,/; $' } @children;
	
	return \@children;
}

