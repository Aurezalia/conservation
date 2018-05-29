#!/usr/bin/perl
use 5.010;
#use strict;
use warnings;

my $pushfile = 'gencode.bed';
open(FH, '>', $pushfile) or die $!;

my $filename = 'sortedgencode.bed';
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";
 
while (my $line = <$fh>){
	chomp $line;
	if($line =~ m/(chr.+)\s+(\d+)\s+(\d+)\s+(exon:\S+)\s+.\s+.\s+.+\s+exon\s+.\s+(ID=exon:[^;]+);[^;]+;([^;]+);[^;]+;[^;]+;([^;]+);.+/){ 
  		my $chromosome = $1;
  		if ($line =~ /transcript_type=protein_coding/) {
  			if($line =~ /_PAR_/){
  				#print "Removing from $chromosome\n";
  			}
  			else{
	  			print FH $line, "\n";
  			}
  		}
  	}
}

close(FH);
