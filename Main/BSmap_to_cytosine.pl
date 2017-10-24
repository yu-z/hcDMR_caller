#!/usr/bin/perl -w
use strict;
use Getopt::Long;

###BSmap2cytosine.pl
###Takes BSmap ratio output (methratio.py) and makes a "cytosine" format file - must pass it the reference cytosine file (list of all cytosines)
###"cytosine" format == position\tstrand\tcontext(x,y,z)\tmethylated\tunmethylated


# How to execute this script - Getopt options straight from Jixian Zhai
my $USAGE = "\nUSAGE: BSmap2cytosine.pl 
                                   --input_file /input/directory/file.ratio
				   --reference_cytosine /reference/directory/file.cytosine
                                   ";


my $input_file;
my $reference_cytosines;

GetOptions('input_file=s'=>\$input_file,
	   'reference_cytosine=s'=>\$reference_cytosines
	   );
die $USAGE unless (defined($input_file) && defined($reference_cytosines));


my $meth_output_file;

my $chromosome=1;
my $current_chromosome=1;
my $reference_chromosome=1;


my $position;
my $strand;
my $context;
my $ratio;
my $eff_CT_count;
my $C_count;
my $CT_count;

my $line;
my $unmethylated;

my $methylation_data;
my $old_line="empty";

my @data_point;
my @meth_array;



if ($input_file=~/(.+)/){
    $meth_output_file = $1;
    $meth_output_file =~ s/\.gz//i;
    $meth_output_file .= ".cytosine";
};

if ($input_file=~/\.gz$/){
    open INPUT, "gunzip -c $input_file |" or die "Cannot open $input_file\n";
}else{
    open INPUT, "$input_file" or die "Cannot open $input_file\n";
};

if ($reference_cytosines=~/\.gz$/){
	open REFERENCE, "gunzip -c $reference_cytosines |" or die "Cannot open $reference_cytosines\n";
}else{
	open REFERENCE, "$reference_cytosines" or die "Cannot open $reference_cytosines\n";
}


$line=<INPUT>;

open OUTPUT, ">$meth_output_file" or die "Cannot open $meth_output_file\n";


while(!eof(REFERENCE)){
    @meth_array=();
    while(($current_chromosome==$chromosome) && !(eof(INPUT))){
	if($old_line eq "empty"){
	    $line=<INPUT>;
	    #print "$line";
	    #<STDIN>;
	}else{
	    $line=$old_line;
	};
        ($current_chromosome,$position,$strand,$context,$ratio,$eff_CT_count,$C_count,$CT_count) = split '\t' , $line;
	if ($current_chromosome=~/chr(\S)/i){
            $current_chromosome=$1;
        };
	$current_chromosome=~tr/CM/67/;
	#print "$current_chromosome\n";
	#<STDIN>;
        $unmethylated=$CT_count-$C_count;
	if($current_chromosome==$chromosome){
	    $meth_array[$position]="$C_count\t$unmethylated";
	    $old_line="empty";
        }else{
            $old_line=$line;
        }
    }
    
    ###Output
    while(($reference_chromosome==$chromosome) && !(eof(REFERENCE))){
        $line=<REFERENCE>;
        if ($line=~/^#(\S+)\n/){
            $reference_chromosome=$1;
            $reference_chromosome=~tr/CM/67/;
            if ($reference_chromosome=~/(\d)/){
                $reference_chromosome=$1;
            };
            print OUTPUT "$line";
        };
        if ($line=~/^(\d+)/){
            $position=$1;
            chomp($line);
            if (defined($meth_array[$position])){
                $methylation_data=$meth_array[$position];
		print OUTPUT "$line\t$methylation_data\n";
            }else{
		print OUTPUT "$line\t0\t0\n";
	    }
            
        };
    };  
    $chromosome++;
};

close OUTPUT;
close INPUT;

system ("gzip $meth_output_file");


