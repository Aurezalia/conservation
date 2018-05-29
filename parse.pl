#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
 
my $chromosome = 0;
my $start = 0;
my $end = 0;
my $ID = 0;
my $score = ".";
my $strand;
my $gene = 0;
my $index = 1;
my $pushfile = 'genes.bed';
my $push2 = 'genesreverse.bed';
my %genes;
open(FH, '>', $pushfile) or die $!;
open(BH, '>', $push2) or die $!;

my $filename = 'gencode.bed';
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";


my $firstline = <$fh>; 
if($firstline =~ m/(chr.+)\s+(\d+)\s+(\d+)\s+exon:\S+\s+(.)\s+(.)\s+.+\s+exon\s+.\s+ID=exon:.+gene_name=([^;]+).+/){
	$chromosome = $1;
	$start = $2;
	$end = $3; 
	$score = $4; 
	$strand = $5;
	$gene = $6;
	$genes{"$gene"} = 1;
	$ID = $gene."_".$genes{"$gene"};
}

while (my $line = <$fh>){
	chomp $line;
	if($line =~ m/(chr.+)\s+(\d+)\s+(\d+)\s+exon:\S+\s+(.)\s+(.)\s+.+\s+exon\s+.\s+ID=exon:.+gene_name=([^;]+).+/){
		if($6 eq $gene){ #same gene
			if($2 > $end){	#if new start is greater than the previous end, it must be a new exon
				if($strand eq "+"){ #write to forward strand file
					print FH $chromosome, "\t", $start, "\t", $end, "\t", $ID, "\t", $score, "\t", $strand, "\n";
				}
				else{				#write to reverse strand file
					print BH $chromosome, "\t", $start, "\t", $end, "\t", $ID, "\t", $score, "\t", $strand, "\n";
				}
				$chromosome = $1;	#after writing previous exon, set data for new one just read in 
				$start = $2;
				$end = $3; 
				$score = $4;
				$strand = $5;
				$gene = $6;
				if(exists($genes{"$gene"})){				#check to see if gene has been scene before
					$genes{"$gene"} = ($genes{"$gene"}+1); 	#if so, increment the index number
				}
				else{										#if not, add it to hash
					$genes{"$gene"} = 1;					#and set the number to 1
				}
				$ID = $gene."_".$genes{"$gene"};			#then set the full ID to gene_exon number
			}
		  	else{							#if new start not > than previous end, we have exon overlap. Where? 
		  		if($2 <= $start){ 				#if start <= prevstart
					if($3 <= $end){				#if end <= prevend
		  				$start = $2;			#write new start, keep end
		  			}
		  			elsif($3 > $end){			#else if end > prevend
		  				$start = $2;			#set new start to write
		  				$end = $3;				#set new end to write
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
			if(exists($genes{"$6"})){
				print "Nested gene: $6\n";
			}
			if($strand eq "+"){		#write previous stuff to forward strand file - if gene switched
				print FH $chromosome, "\t", $start, "\t", $end, "\t", $ID, "\t", $score, "\t", $strand, "\n";
			}
			else{					#write previous stuff to reverse strand file
				print BH $chromosome, "\t", $start, "\t", $end, "\t", $ID, "\t", $score, "\t", $strand, "\n";
			}
			$chromosome = $1;		#then set data for new line just read in 
			$start = $2;
			$end = $3; 
			$score = $4;
			$strand = $5;
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
close(BH);