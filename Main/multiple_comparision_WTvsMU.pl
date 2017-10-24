#!/usr/bin/perl
use Getopt::Long;
use Data::Dumper;

# take the list of commands as input and run through qsub
############# qsub parameter ################
$PM =
'#!/bin/sh
#$ -cwd 
#$ -m a
#$ -V
#$ -S /bin/bash
#$ -l h_data=4G,h_rt=23:55:00
# -pe shared 4
';

$job_split = 10;



#################### open folder contains all input files#################
my $USAGE = "\nUSAGE: multiple_DMR_WTvsMUTANT.pl 
                                   -seqdir DMR_folder
                                   -wtlist file containing the list of WT library 
                                   -mulist file containing the list of mutant library 
                                   -Rscript selection scripts for comparision 
                                   ";
my $options = {};
GetOptions($options, "-seqdir=s", "-wtlist=s", "-mulist=s"); #, "-out=s" 
die $USAGE unless defined ($options->{seqdir});
die $USAGE unless defined ($options->{wtlist});
die $USAGE unless defined ($options->{mulist});
die $USAGE unless defined ($options->{Rscript});

############################# Grobal Variables #############################
my $seqdir = $options->{seqdir};
my $wtlist = $options->{wtlist};
my $mulist = $options->{mulist};
my $Rscript = $options->{Rscript};

#################### input command ###################################

$user_input = "Rscript  $Rscript ";


opendir (DIR, $seqdir) or die "Couldn't open $seqdir: $!\n";


# obtain the list of WT libraries and save as hash
open (WT,$wtlist);
my %WT_hash;
# my %mutant_hash;
while (<WT>){
    chomp;
    next if (length($_)<1);
    $WT_hash{$_}++;
}

open (MU,$mulist);
my %MU_hash;

while (<MU>){
    chomp;
    next if (length($_)<1);
    $MU_hash{$_}++;
}

$WT_size = keys %WT_hash;
$MU_size = keys %MU_hash;

print "total number of WT libraries: $WT_size , total number of MU libraries: $MU_size , \n";


# $nameDIR = "/u/home/j/jxzhai/SCRATCH/ALL_log/";
$nameDIR = $seqdir;
opendir (NAMEDIR, $nameDIR) or die "Couldn't open $nameDIR: $!\n";

while (defined(my $seqfile = readdir(NAMEDIR))) {
    next if (($seqfile =~ m/^\.$/) or ($seqfile =~ m/^\.\.$/));
    next if !($seqfile =~ m/100\.gz$/);
    # next if !($seqfile =~ m/\.BSMAP_log$/);
    $seqfile =~ m/(\S+?)\./;
    $name = $1;
    $name =~ s/#\d+//;
    next if (!(exists($WT_hash{$name})) && !(exists($MU_hash{$name})));
    $hash{$name} ++;    
}

my @name_array;

foreach my $key (sort keys %hash) {
   push @name_array, $key;
   #print "$key\n";
}

my $count_command =0;
my $command="";
while (my $current = shift @name_array) {
#    print "$current\n";
#    $n1 ++;
    $n2 = 0;
    foreach $remain (@name_array) {
        next if (exists($WT_hash{$current}) && exists($WT_hash{$remain}));
        next if (exists($MU_hash{$current}) && exists($MU_hash{$remain}));
        next if (!(exists($WT_hash{$current})) && !(exists($WT_hash{$remain})));
        next if (!(exists($MU_hash{$current})) && !(exists($MU_hash{$remain})));
        # print "$current\t$remain\n";die;
        $n1++;
        $n2++;
        $count_command++;
        $command = "$command" . 
    "$user_input  $current $remain $seqdir\n";
    # print "$n1\n";
    if ($count_command % $job_split == 0){
        print "$command\n";
        open(SH, ">DMR\_$current\_$remain\_DMR.sh");
        print SH "$PM";
        print SH "$command\n";
        system "qsub DMR\_$current\_$remain\_DMR.sh\n";
        close SH;
        system "rm DMR\_$current\_$remain\_DMR.sh";    
        $command = "";
        }
    }
}
print "$command";
# die;
open(SH, ">DMR\_$current\_$remain\_DMR.sh");
print SH "$PM";
print SH "$command\n";
system "qsub DMR\_$current\_$remain\_DMR.sh\n";
close SH;
system "rm DMR\_$current\_$remain\_DMR.sh";    


print "total: $n1\n";


