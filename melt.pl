#!/usr/bin/perl
use strict;
use warnings;


my $directory;
while (<STDIN>) {
	my $cnt = 0;
    chomp;
    my ($chr, $start, $stop, $id, $score, $strand) = split("\t", $_);
    my $pushfile = "perExon/$id.melted.bed";
	open(FH, '>>', $pushfile) or die $!;
    for (my $meltIdx = $start; $meltIdx < $stop; $meltIdx += 1) {
        print FH $chr, "\t", $meltIdx, "\t", $meltIdx + 1,"\t", $id."!$cnt","\t", $score,"\t", $strand,"\n";
        $cnt++;
    }
    close(FH);
}
 