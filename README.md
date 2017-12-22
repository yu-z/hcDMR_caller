# hcDMR caller

## What is hcDMR caller?

* hcDMR caller is for calling high confidence DMRs by comparing with multiple controls using whole genome bisulfite sequencing data. For details, see Ref. [1].

## Download hcDMR

You can download all the scripts from above link /main. The /reference files can be downloaded from googledrive: https://drive.google.com/open?id=12gNDSECm289dTL2ys6AA8SzB88drmMhW 

## Run hcDMR caller

### Step 1 - generate methratio file from aligned bam file:

##### Required files:

* input_file_name.bam *WGBS mapped read file*
* Ath_ChrAll.fa *It is a fasta file of A. thaliana genome (TAIR10), which can be found in the folder /Reference*

##### Required scripts:
* methratio_alt.py *This scirpt was from Package of BSMAP, generating methratio file*

##### Example usage:
```
python methratio_alt.py --Steve --ref=Ath_ChrAll.fa --out=input_file_name -u -z -r input_file_name.bam
```
##### This step will output a methratio file: input_file_name.gz

### Step 2 - count the C and CT count at every position in the genome

##### Required files:
* input_file_name.gz *output from methratio_alt.py script*
* TAIR10_v2.cytosine.gz *can be found in the folder /Reference*

##### Input scripts:
* BSmap_to_cytosine.pl

##### Example usage:
```
perl BSmap_to_cytosine.pl --input_file input_file_name.gz --reference_cytosine TAIR10_v2.cytosine.gz
```
##### This step will output a C and CT count file: input_file_name.cytosine.gz

### Step 3 - Bin the genome into 100bp bins.

##### Required files:
* input_file_name.cytosine.gz *output from BSmap2cytosine.pl*

##### Required scripts:
* Cytosine_to_100bp.pl

##### Example usage:
```
perl Cytosine_to_100bp.pl input_file_name.cytosine.gz
```
##### This step will output three files (types of CHH, CHG, CG methylation) containing methylation level along the genome in 100bp bin:
* input_file_name.CHH.100.gz
* input_file_name.CHG.100.gz input_file_name.CG.100.gz

### Step 4 - Call hcDMRs against 54 WT dataset:

##### Required files:
* 100bp bin files: input_file_name.CHH.100.gz input_file_name.CHG.100.gz input_file_name.CG.100.gz
* 54 WT dataset: CHH.100.54WT.Ref.gz CHG.100.54WT.Ref.gz CG.100.54WT.Ref.gz *can be found in the folder /Reference*

##### Required scripts:
* hcDMR_caller.pl

##### Example usage:
* CHH DMR: 
```
perl hcDMR_caller.pl -ref CHH.100.54WT.Ref.gz -input input_file_name.CHH.100.gz -dif 0.1 -n 33
```
* CHG DMR: 
```
perl hcDMR_caller.pl -ref CHG.100.54WT.Ref.gz -input input_file_name.CHG.100.gz -dif 0.2 -n 33
```
* CG DMR: 
```
perl hcDMR_caller.pl -ref CG.100.54WT.Ref.gz -input input_file_name.CG.100.gz -dif 0.4 -n 33
```
##### This step will generate three DMR list files:
* input_file_name.CHH.DMR
* input_file_name.CHG.DMR
* input_file_name.CG.DMR

##### For this step, you can use Fisher exact test during the comparision between test library and WT controls, but it will increase the computational time greatly:

##### Required files:
* 100bp bin files: input_file_name.CHH.100.gz input_file_name.CHG.100.gz input_file_name.CG.100.gz
* 54 WT dataset: CHH.100.54WT.Ref.FET.gz CHG.100.54WT.Ref.FET.gz CG.100.54WT.Ref.FET.gz *can be found in the folder /Reference*

##### Required scripts:
* hcDMR_caller_FET.pl

##### Example usage:
* CHH DMR: 
```
perl hcDMR_caller_FET.pl -ref CHH.100.54WT.Ref.FET.gz -input input_file_name.CHH.100.gz -dif 0.1 -n 33 -p 0.01
```
* CHG DMR: 
```
perl hcDMR_caller_FET.pl -ref CHG.100.54WT.Ref.FET.gz -input input_file_name.CHG.100.gz -dif 0.2 -n 33 -p 0.01
```
* CG DMR: 
```
perl hcDMR_caller_FET.pl -ref CG.100.54WT.Ref.FET.gz -input input_file_name.CG.100.gz -dif 0.4 -n 33 -p 0.01
```
##### This step will generate three DMR list files:
* input_file_name.CHH.FET.DMR
* input_file_name.CHG.FET.DMR
* input_file_name.CG.FET.DMR

## Feedbacks:

You can create an issue if you find errors in the manual or bugs in the source code, or have any suggestions/questions about the manual and code. Thank you!

## Citations & Acknowlegement

We thank Christopher J Hale for modifying methratio.py from BSMAP and generating TAIR10_v2.cytosine.gz. 

If you use hcDMR caller in your published work, we kindly ask you to cite the following paper which describes the central algorithms used in hcDMR caller:
* [1] Large-scale comparative epigenomics reveals hierarchical regulation of non-CG methylation in Arabidopsis. 2017. XXX
* [2] BSMAP: whole genome bisulfite sequence MAPping program. BMC Bioinformatics. 2009 Jul 27;10:232.




