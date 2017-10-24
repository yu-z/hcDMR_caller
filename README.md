# hcDMR caller

## What is hcDMR caller?

* hcDMR caller is for calling high confidence DMRs by comparing with multiple controls. For details, see Ref. [1].

## Run hcDMR caller

1) Step 1 - generate methratio file from aligned bam file:

Required files:
input_file_name.bam # WGBS mapped read file
UCSCgenome.fa # It is a fasta file of A. thaliana genome (TAIR10), which can be found in the folder /Reference

Required scripts:
methratio_alt.py #This scirpt was from Package of BSMAP, generating methratio file. 

example usage:
python methratio_alt.py --Steve --ref=Ath_ChrAll.fa --out=output_methratio.txt -u -z -r input_WGBS.bam

2) Step 2 - count the C and CT count at every position in the genome

Required files:
output_methratio.txt # output from methratio_alt.py script
TAIR10_v2.cytosine.gz # can be found in the folder /Reference

Input scripts:
BSmap2cytosine.pl

Example usage:
perl BSmap2cytosine.pl --input_file output_methratio.txt --reference_cytosine TAIR10_v2.cytosine.gz

This step will output a output_methratio.cytosine.gz file

3) Step 3 - Bin the genome into 100bp bins.

Required files:
output_methratio.cytosine.gz

Required scripts:
Cytosine_2_100bp.pl

Example usage:
perl Cytosine_2_100bp.pl output_methratio.cytosine.gz

This step will output three 100bi bin files containing methylation level along the genome:

a output_methratio.cytosine.gz file

4) Step 4 - Call hcDMRs against 54 WT dataset:

required files:
#100bp processed WGBS file
output_methratio.cytosine.gz
All_WT_54_libs # processed 54 WT libraries, which can be found in the folder /Reference. 

required scripts:
multiple_DMR_WTvsMUTANT.pl

Example usage:
perl multiple_DMR_WTvsMUTANT.pl --input_file test.txt --reference_file All_WT_54_libs.txt --output_file hcDMRs.txt

multiple_DMR_WTvsMUTANT.pl 
                                   -seqdir DMR_folder
                                   -wtlist file containing the list of WT library 
                                   -mulist file containing the list of mutant library 
                                   -Rscript selection scripts for comparisio
                                   
Generating DMR:

## Feedbacks:

You can e-mail (zhangy9@sustc.edu.cn) if you find errors in the manual or bugs in the source code, or have any suggestions/questions about the manual and code. Thank you!

## Citations & Ackgnowlegement

XXX

If you use MOD in your published work, we kindly ask you to cite the following paper which describes the central algorithms used in MOD:
* [1] xxx


