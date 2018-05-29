#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
 
my $chromosome = 0;
my $start = 0;
my $end = 0;
my $ID = 0;
my $data;
my $gene = 0;
my $index = 1;
my $pushfile = 'genes.bed';
my $push2 = 'genesback.bed';
my %genes;
open(FH, '>', $pushfile) or die $!;

my $filename = 'gencode.bed';
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";
 
while (my $line = <$fh>){
	chomp $line;
	if($line =~ m/(chr.+)\s+(\d+)\s+(\d+)\s+exon:\S+(\s+.\s+.)\s+.+\s+exon\s+.\s+ID=exon:[^;]+;[^;]+;[^;]+;[^;]+;([^;]+);gene_name=([^;]+);transcript_type=([^;]+);.+/){
		if($6 eq $gene){ #same gene
			if($2 > $end){	#if new start is greater than the previous end, it must be a new exon
				if($start != 0){
					#my $genefile = "perGene/$gene.bed";
					#open(GH, '>>', $genefile) or die $!;
					#print GH $chromosome, "\t", $start, "\t", $end, "\t", $ID, "\t", $data, "\n";
					print FH $chromosome, "\t", $start, "\t", $end, "\t", $ID, "\t", $data, "\n";
				}
				$chromosome = $1;
				$start = $2;
				$end = $3; 
				$data = $4;
				$gene = $6;
				if(exists($genes{"$gene"})){
					$genes{"$gene"} = ($genes{"$gene"}+1);
				}
				else{
					$genes{"$gene"} = 1;
				}
				$ID = $gene."_".$genes{"$gene"};
			}
		  	else{
		  		if($2 <= $start){ 				#if start <= prevstart
					if($3 <= $end){				#if end <= prevend
		  				$start = $2;			#write new start, keep end
		  			}
		  			elsif($3 > $end){			#else if end > prevend
		  				$start = $2;
		  				$end = $3;				#write new start, new end
		  			}
		  		}

		  		elsif($2 > $start){				#else if start > prevstart
		  			if($3 > $end){				#if end > prevend
		  				$end = $3;				#keep start, write new end
		  			}
		  		}
		  	}	
		}

		else { #new gene
			if($start != 0){
				#my $genefile = "perGene/$gene.bed";
				#open(GH, '>>', $genefile) or die $!;
				#print GH $chromosome, "\t", $start, "\t", $end, "\t", $ID, "\t", $data, "\n";
				print FH $chromosome, "\t", $start, "\t", $end, "\t", $ID, "\t", $data, "\n";
			}
			$chromosome = $1;
			$start = $2;
			$end = $3; 
			$data = $4;
			$gene = $6;
			if(exists($genes{"$gene"})){
				$genes{"$gene"} = ($genes{"$gene"}+1);
			}
			else{
				$genes{"$gene"} = 1;
			}
			$ID = $gene."_".$genes{"$gene"};
		}

	}
}

close(FH);