#!/usr/bin/perl

use Getopt::Long;
use Data::Dumper;

#v1 update: skipping the splittypeche step, directly read from .cytosine.gz file
#v3 update: check last bin position

# from .cytosine.gz
##chr1
#1       +       z       0       0


########### user input ########################
my $file = $ARGV[0];
my @context = ["CG","CHG","CHH"];
#my @chr_len = (30427671, 19698289, 23459830, 18585056, 26975502 );
my $bin_size = 100;

my $min_coverage = 4;
    

########### main ##############################

if ($file =~ /\.gz$/) {
    open(IN, "gunzip -c $file |") || die "can't open pipe to $file";
}
else {
    open(IN, $file) || die "can't open $file";
}

$file =~ s/(.+)\.cytosine\.gz//g; 
$file = $1;

        
my %c_type=("x","CG","y","CHG","z","CHH");
open(CG, ">$file\.CG.$bin_size");
open(CHG, ">$file\.CHG.$bin_size");
open(CHH, ">$file\.CHH.$bin_size");

print CG "chr\tpos\tccount\tctcount\tno.cytosin\tno.coverage>=4\n";
print CHG "chr\tpos\tccount\tctcount\tno.cytosin\tno.coverage>=4\n";
print CHH "chr\tpos\tccount\tctcount\tno.cytosin\tno.coverage>=4\n";

foreach my $type ("CG","CHG","CHH"){
$ccount_total{$type}=0;
$ctcount_total{$type}=0;
$num{$type} = 0;
$cov_total{$type}=0;
$sum{$type}=0;
$total_bin{$type}=0;
$passed_bin{$type}=0;
}

my $chr = 0;

while (<IN>) {
    chomp;
    if ($_ =~  m/#chr(.+)/) {
        if ($chr==0) {
            $flag = $bin_size;
            $chr = $1;
            next;
        }
        elsif ($chr != $1) {
            foreach my $type ("CG","CHG","CHH"){
                print $type "$chr\t$flag\t$ccount_total{$type}\t$ctcount_total{$type}\t$num{$type}\t$cov_total{$type}\n";
            }
            $flag = $bin_size;
            $chr = $1;
            next;
        }
    }
    @data = split/\t/;
    $pos = $data[0];
    $strand = $data[1];
    $type = $c_type{$data[2]};
    $ccount{$type} = $data[3];
    $ctcount{$type} = $data[4];
    $sum{$type}++;
    $ccount_ALL{$type}  +=  $ccount{$type} if ($chr =~ m/1|2|3|4|5/);
    $ctcount_ALL{$type} +=  $ctcount{$type} if ($chr =~ m/1|2|3|4|5/);


    if ($pos <= $flag){
        $ccount_total{$type}  +=  $ccount{$type};
        $ctcount_total{$type} +=  $ctcount{$type};
        $num{$type} ++;
        ##### updated by Jixian to fix the bug reported by Julie
        if ($ctcount{$type} + $ccount{$type} >= $min_coverage){
            $cov_total{$type} ++;
        }
        next;
    }
    else {
        while ($pos > $flag){
            foreach my $type ("CG","CHG","CHH"){
                print $type "$chr\t$flag\t$ccount_total{$type}\t$ctcount_total{$type}\t$num{$type}\t$cov_total{$type}\n";
                $total_bin{$type}++;
                if ($cov_total{$type}>= $min_coverage) {$passed_bin{$type}++;}
                $ccount_total{$type}=0;
                $ctcount_total{$type}=0;
                $num{$type} = 0;
                $cov_total{$type}=0;
            }
            $flag=$flag+$bin_size;
        }
        next;
    }
}
foreach my $type ("CG","CHG","CHH"){
    print $type "$chr\t$flag\t$ccount_total{$type}\t$ctcount_total{$type}\t$num{$type}\t$cov_total{$type}\n";
}

foreach my $type ("CG","CHG","CHH"){
    print "$file\t$ccount_ALL{$type}\t$ctcount_ALL{$type}\t$type\t$total_bin{$type}\t$passed_bin{$type}\n";
}

close IN;
close CG;
close CHG;
close CHH;
system ("gzip $file\.CG.$bin_size");
system ("gzip $file\.CHG.$bin_size");
system ("gzip $file\.CHH.$bin_size");
