# hcDMR caller

## What is hcDMR caller?

* hcDMR caller is for calling high confidence DMRs by comparing with multiple controls using whole genome bisulfite sequencing data. For details, see Ref. [1].

## Run hcDMR caller

1) Step 1 - generate methratio file from aligned bam file:

Required files:

input_file_name.bam # WGBS mapped read file
Ath_ChrAll.fa # It is a fasta file of A. thaliana genome (TAIR10), which can be found in the folder /Reference

Required scripts:
methratio_alt.py #This scirpt was from Package of BSMAP, generating methratio file. 

example usage:
python methratio_alt.py --Steve --ref=Ath_ChrAll.fa --out=input_file_name -u -z -r input_file_name.bam

This step will output a methratio file: input_file_name.gz

2) Step 2 - count the C and CT count at every position in the genome

Required files:
input_file_name.gz # output from methratio_alt.py script
TAIR10_v2.cytosine.gz # can be found in the folder /Reference

Input scripts:
BSmap2cytosine.pl

Example usage:
perl BSmap2cytosine.pl --input_file input_file_name.gz --reference_cytosine input_file_name.cytosine.gz

This step will output a C and CT count file: input_file_name.cytosine.gz

3) Step 3 - Bin the genome into 100bp bins.

Required files:
output_methratio.cytosine.gz #output from BSmap2cytosine.pl

Required scripts:
Cytosine_2_100bp.pl

Example usage:
perl Cytosine_2_100bp.pl output_methratio.cytosine.gz

This step will output three files (types of CHH, CHG, CG methylation) containing methylation level along the genome in 100bp bin:
input_file_name.CHH.100.gz
input_file_name.CHG.100.gz
input_file_name.CG.100.gz










-----------------------------------------------------------------------------
4) Step 4 - Call hcDMRs against 54 WT dataset:

required files:

A folder containing 100bp bin files (DMR_folder), including: 
Three 100bp processed WGBS files #output from Cytosin_2_100bp.pl
All_WT_54_libs # processed 54 WT libraries, which can be found in the folder /Reference. 

54WT.list # a list containing library names of 54 WT controls, which can be found in the folder /Reference. 
MU.list # a list containing library names of test, format same as 54WT.list, making by the usr, for example

input_file_name

required scripts:
multiple_DMR_WTvsMUTANT.pl
DMRFtest_Allchr_commnad.R (comparing using Fisher exact test) or DMR_Allchr_commnad_noFtest.R (comparing without test)

Example usage:
perl multiple_DMR_WTvsMUTANT.pl -seqdir DMR_folder -wtlist 54WT.list -mulist MU.list -Rscript DMR_Allchr_commnad_noFtest.R
                                   
Generating A folder containing the comparision file: 


## Feedbacks:

You can e-mail (XXXXX) if you find errors in the manual or bugs in the source code, or have any suggestions/questions about the manual and code. Thank you!

## Citations & Ackgnowlegement

XXX

If you use MOD in your published work, we kindly ask you to cite the following paper which describes the central algorithms used in MOD:
* [1] xxx


