#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
use Text::NSP::Measures::2D::Fisher2::twotailed;

#################### open folder contains all input files#################
my $USAGE = "\nUSAGE: hcDMR_caller_FET.pl 
                                   -ref 
                                   -input Reference
                                   -dif
                                   -n
                                   -p_fet
                                   -ref *.gz Reference of multiple WTs
                                   -input *.gz 100bin file of interesting library
                                   -dif 0.1 for CHH, 0.2 for CHG, 0.4 for CHH
                                   -n minimum number of supporting libraries for each bin
                                   -p_fet p_value cutoff for Fisher exact test
                                   ";
my $options = {};
GetOptions($options, "-ref=s", "-input=s", "-dif=s", "-n=s", "-p_fet=s"); 
die $USAGE unless defined ($options->{ref});
die $USAGE unless defined ($options->{input});
die $USAGE unless defined ($options->{dif});
die $USAGE unless defined ($options->{n});
die $USAGE unless defined ($options->{p_fet});

############################# Grobal Variables #############################
my $ref = $options->{ref};
my $input = $options->{input};
my $dif = $options->{dif};
my $n = $options->{n};
my $p_fet = $options->{p_fet};
	
	open MU, 'gzip -dc '.$input.'|';
	open WT, 'gzip -dc '.$ref.'|';
	
	my @names = split /\./, $input; 
	open OUT, '>'.$names[0].'.'.$names[1].'.FET.DMR';
	
	while ( !eof(MU) ) {
		
		#-------- WT ---------
		my(@array, $mean);	
		my $wt = <WT>;
		chomp $wt;
		my @wt = split /\s+/,$wt;	
		my $chr = $wt[0];
		my $pos = $wt[1];		
		#-------- Mutant -----
	 	my $line = <MU>;
		chomp $line;


			if($line =~ /^chr/) {
				print OUT "Chr\tPosition\tDMR\tMethylevel\n";
			} elsif ($#wt == 2) {
			#	print OUT $chr, "\t", $pos, "\tNA\tNA\n"; 
			} else {
				
				my @lines = split /\s+/,$line;
				if ($lines[5]>=4 and $lines[2]+$lines[3]>0) {

					my $hyper = 0;
					my $hypo = 0;
				  my $meth = $lines[2]/($lines[2]+$lines[3]);
				  
					for my $i(@wt[2..$#wt]) {
						my @data = split /\|/, $i;
						my $meth_wt = $data[0]/($data[0]+$data[1]);

						 if ($meth - $meth_wt >= $dif) {
						 	
								my $n11 = $lines[2];
								my $n1p = $lines[2] + $data[0];
								my $np1 = $lines[2] + $lines[3];
								my $npp = $lines[2] + $lines[3] + $data[0] + $data[1];
						
								my $p = calculateStatistic(n11=>$n11,
																				n1p=>$n1p,
																				np1=>$np1,
																				npp=>$npp);						 	
						 	
						 	
						 		if ($p <= $p_fet) {
						 			$hyper++;
						 		}
						 		
						 }  elsif ( $meth_wt - $meth >= $dif) {
						 	
								my $n11 = $lines[2];
								my $n1p = $lines[2] + $data[0];
								my $np1 = $lines[2] + $lines[3];
								my $npp = $lines[2] + $lines[3] + $data[0] + $data[1];
						
								my $p = calculateStatistic(n11=>$n11,
																				n1p=>$n1p,
																				np1=>$np1,
																				npp=>$npp);						 	
						 	
						 	
						 		if ($p <= $p_fet) {
						 			$hypo++;
						 		}						 	
						 	
						 }
					  }
				  
				  
				  if ($hyper >= $n) {
							print OUT $chr, "\t", $pos, "\thyper\t", $meth, "\n"; 
					} elsif ($hypo >= $n) {
							print OUT $chr, "\t", $pos, "\thypo\t", $meth, "\n"; 
					} 
					
				}
			}	
	}	
		
	close MU;
	close WT;
	close OUT;	
	
