#!/u/home/j/jxzhai/install/R-2.13.1/bin/RScript
library(plyr)
library(utils)

# read input from command input
args <- commandArgs(TRUE)

#args[1] <- "Sample3_methratio"
#args[2] <- "Sample4_methratio"
#args[3] <- "./"
args[4] <- "./output_DMRs/"

###############compare ALL-chr control vs. mutant###############################
#input data
#CG
control.CG=read.delim(gzfile(paste(args[3],args[1], ".CG.100.gz", sep="")),header=T)
mutant.CG=read.delim(gzfile(paste(args[3],args[2], ".CG.100.gz", sep="")),header=T)
#CHG
control.CHG=read.delim(gzfile(paste(args[3],args[1], ".CHG.100.gz", sep="")),header=T)
mutant.CHG=read.delim(gzfile(paste(args[3],args[2], ".CHG.100.gz", sep="")),header=T)
#CHH
control.CHH=read.delim(gzfile(paste(args[3],args[1], ".CHH.100.gz", sep="")),header=T)
mutant.CHH=read.delim(gzfile(paste(args[3],args[2], ".CHH.100.gz", sep="")),header=T)

#bins with at least 4 cytosines and each one have at least 4 coverage in both libraries, make dataframe
CG=data.frame(control.CG[,1:6],mutant.CG[,3:6])
CG.final=subset(CG, CG[,5]>=4 & CG[,6]>=4 & CG[,9]>=4 & CG[,10]>=4)
CG.final = CG.final[-c(5,6,9,10) ]

CHG=data.frame(control.CHG[,1:6],mutant.CHG[,3:6])
CHG.final=subset(CHG, CHG[,5]>=4 & CHG[,6]>=4 & CHG[,9]>=4 & CHG[,10]>=4)
CHG.final = CHG.final[-c(5,6,9,10) ]

CHH=data.frame(control.CHH[,1:6],mutant.CHH[,3:6])
CHH.final=subset(CHH, CHH[,5]>=4 & CHH[,6]>=4 & CHH[,9]>=4 & CHH[,10]>=4)
CHH.final = CHH.final[-c(5,6,9,10) ]

#as.numeric
CG.numeric=apply(CG.final[,3:6],2,as.numeric)
CHG.numeric=apply(CHG.final[,3:6],2,as.numeric)
CHH.numeric=apply(CHH.final[,3:6],2,as.numeric)

#########Absolute methylation difference function
amd=function(a){
  a=matrix(a,nrow=2,dimnames=list(meth=c("meth","unmeth"),genotype=c("C","M")))
  amd=abs((a[1,1]/(a[1,1]+a[2,1]))-(a[1,2]/(a[1,2]+a[2,2])))
}
CG.amd=apply(CG.numeric,1,amd)
CHH.amd=apply(CHH.numeric,1,amd)
CHG.amd=apply(CHG.numeric,1,amd)

#filter absolute methylation difference based on CG>=0.4 CHG>=0.2 CHH>=0.1
CG.amd.df=data.frame(CG.final,CG.amd)
#dim(CG.amd.df)
CG.amd.df=subset(CG.amd.df,CG.amd.df[,7]>=0.4)
#dim(CG.amd.df)

CHG.amd.df=data.frame(CHG.final,CHG.amd)
#dim(CHG.amd.df)
CHG.amd.df=subset(CHG.amd.df,CHG.amd.df[,7]>=0.2)
#dim(CHG.amd.df)

CHH.amd.df=data.frame(CHH.final,CHH.amd)
#dim(CHH.amd.df)
CHH.amd.df=subset(CHH.amd.df,CHH.amd.df[,7]>=0.1)
#dim(CHH.amd.df)

#Fisher test
Ftest=function(a){
  p.value=fisher.test(matrix(a,nrow=2,dimnames=list(meth=c("meth","unmeth"),genotype=c("C","M"))),alternative="two.side")$p.value
}
CG.numeric=apply(CG.amd.df[,3:6],2,as.numeric)
CHG.numeric=apply(CHG.amd.df[,3:6],2,as.numeric)
CHH.numeric=apply(CHH.amd.df[,3:6],2,as.numeric)

CG.p.value=apply(CG.numeric,1,Ftest)
CG.p.adj=p.adjust(CG.p.value,metho=c("BH"))
CHG.p.value=apply(CHG.numeric,1,Ftest)
CHG.p.adj=p.adjust(CHG.p.value,metho=c("BH"))
CHH.p.value=apply(CHH.numeric,1,Ftest)
CHH.p.adj=p.adjust(CHH.p.value,metho=c("BH"))

CG.padj.df=data.frame(CG.amd.df,CG.p.value,CG.p.adj)
#dim(CG.padj.df)
#head(CG.padj.df)
CHG.padj.df=data.frame(CHG.amd.df,CHG.p.value,CHG.p.adj)
#dim(CHG.padj.df)
#head(CHG.padj.df)
CHH.padj.df=data.frame(CHH.amd.df,CHH.p.value,CHH.p.adj)
#dim(CHH.padj.df)
#head(CHH.padj.df)

#padj < 0.01
CG.DMR.mutant.control=subset(CG.padj.df,CG.padj.df[,9]<=0.01)
#dim(CG.DMR.mutant.control)
#head(CG.DMR.mutant.control)
CHG.DMR.mutant.control=subset(CHG.padj.df,CHG.padj.df[,9]<=0.01)
#dim(CHG.DMR.mutant.control)
CHH.DMR.mutant.control=subset(CHH.padj.df,CHH.padj.df[,9]<=0.01)
#dim(CHH.DMR.mutant.control)

dir.create(file.path(args[4]))

write.table(CG.DMR.mutant.control,file=paste(args[4], "CG.DMR.", args[1], "_VS_", args[2], ".txt", sep=""),sep="\t",row.names=F)
write.table(CHG.DMR.mutant.control,file=paste(args[4], "CHG.DMR.", args[1], "_VS_", args[2], ".txt", sep=""),sep="\t",row.names=F)
write.table(CHH.DMR.mutant.control,file=paste(args[4], "CHH.DMR.", args[1], "_VS_", args[2], ".txt", sep=""),sep="\t",row.names=F)

