#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

# ========== parameters ==========

#my $dir="../local_behaviour/11-node-weights/archive/aps";
my $dir="../../aps";

my $cite_scale=13;
my $time_scale=6;

# ========== load citation count ==========

my @citation_count=split/\n/, `cat $dir/aps_citation_count.txt`;
my %citation_count;

for my $citation_count (@citation_count) {
	$citation_count=~/ /;
	$citation_count{$`}=$';
}

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

# ========== align to articles ==========

my %cite_time_count;
my %cite_time_max;
my %cite_time;

initialize_heatmap(\%cite_time_count);
initialize_heatmap(\%cite_time_max);

open IN, "<boosting.txt";
while (<IN>) {
	chomp;
	my ($to, $from, $boosting)=split/ /, $_;
	
	if ($boosting > 0 && $doi_year{$from} >= 1900 && $doi_year{$to} >= 1900) {
		my $cite=$citation_count{$to};
		my $time=$doi_year{$from}-$doi_year{$to};
		
		if ($time >= 0) {
			my $cite_box=int(log_base($cite, 2));
			my $time_box=which_box($time, 5);
			
			$cite_time_count{$cite_box}->{$time_box}++;
			
			my $boosting_f=sprintf("%.3f", $boosting);
			push @{$cite_time{$cite_box}->{$time_box}}, "$boosting_f $to $from $cite $time";
			
			if ($boosting > $cite_time_max{$cite_box}->{$time_box}) {
				$cite_time_max{$cite_box}->{$time_box}=$boosting;
			}
		}
	}
}
close IN;

# ========== log10 count ==========

for my $cite (0..$cite_scale) {
	for my $time (0..$time_scale) {
		$cite_time_count{$cite}->{$time}=log_base($cite_time_count{$cite}->{$time}, 10);
	}
}

# ========== save heatmaps ==========

#print Dumper \%cite_time_count;

open OUT, ">heatmap-count.txt";
print OUT heatmap_output(\%cite_time_count);
close OUT;

open OUT, ">heatmap-max.txt";
print OUT heatmap_output(\%cite_time_max);
close OUT;

open OUT, ">heatmap.txt";
for my $cite (0..$cite_scale) {
	for my $time (0..$time_scale) {
		my $cb=2**$cite;
		my $tb=5*$time;

		print OUT "($cb, $tb):\n";
		
		if ($cite_time{$cite}->{$time}) {
			for my $rec (sort { $b cmp $a } @{$cite_time{$cite}->{$time}}) {
				print OUT "$rec\n";
			}
		}
	}
}
close OUT;

# ========== functions ==========

# ordering by 3rd parameter
sub ord_par {
	my $string=shift;
	my @a=split/ /, $string;
	return $a[2];
}

sub log_base {
	my ($num, $base)=@_;
	
	if ($num > 0) {
		return log($num)/log($base);
	} else {
		return -1;
	}
}

sub which_box {
	my ($value, $box_size)=@_;
	
	return int($value / $box_size);
}

sub heatmap_output {
	my $heatmap=shift;
	my $out="";
	
	for my $cite (0..$cite_scale) {
		my @a;
		for my $time (0..$time_scale) {
			push @a, $heatmap->{$cite}->{$time};
		}
		
		$out.=(join " ", @a)."\n";
	}
	
	return $out;
}

sub initialize_heatmap {
	my $heatmap=shift;
	
	for my $cite (0..$cite_scale) {
		for my $time (0..$time_scale) {
			$heatmap->{$cite}->{$time}=0;
		}
	}
	
	#return $out;
}
