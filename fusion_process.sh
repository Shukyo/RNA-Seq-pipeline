#!/bin/bash

sampleName=
input=
ref=/database/annotation/annovar/humandb/hg19_refGene.txt
ens=/database/annotation/annovar/humandb/hg19_ensGene.txt
blastn=/home/public/Software/ncbi-blast/bin/blastn
blastdb=/database/blast_db
star_fusion=/home/public/Software/STAR-2.5.0b/STAR-Fusion/STAR-Fusion
star_fusion_lib=/database/star/Hg19_CTAT_resource_lib
tophat_fusion=/usr/bin/tophat-fusion-post
bowtie_index=/database/iGenome/Homo_sapiens/UCSC/hg19/Sequence/BowtieIndex/genome

help='Fusion process Pipeline for fusion output after tophat and star-fusion alignment
=======================================

Usage:   Exom_pipeline [options] -1 <Read1> -2 <Read2> -n <Sample Name>
Sample Information:
    -n    Name of the Sample                               < REQUIRED >
    -I    Input files                                      < REQUIRED >
    -w    working directory                                < default  '$wkdir' >
Programme Paths:
    -ss    Path to star-fusion (Require ver0.2.1 or above) < default: '$star_fusion' >
    -st    Path to tophat-fusion-post (Require ver2.0.9 or above) 
                                                           < default: '$tophat_fusion' >
    -bi    Path to BowtieIndex                             < default: '$bowtie_index' >
    Reference Files:
    -r    Reference gene file                              < default: '$ref' >
    -e    Ensemble gene file                               < default: '$ens' >
    -b    Blastn programe                                  < default: '$blastn' >
    -L    Genome library directory of star-fusion          < default: '$star_fusion_lib' >
    Misc:
    -M    Method for fusion calling (star|tophat;used when input file with modified names) 
                                                           < default: '$method' >
    -t    Number of thread use                             < default: '$thread' >
    -h    To display this help message
Notice:
    If you want to modify the defalut parameters of alignment or other processes,please copy this script and modified directly in the copy'

while getopts n:I:w:ss:st:bi:r:e:L:M:t:h opt; do
	        case $opt in
		n)
			sampleName=$OPTARG
			;;
		I)
			input=$OPTARG
			;;
		w)
			wkdir=$OPTARG
			;;
		ss)
			star_fusion=$OPTARG
			;;
		st)
			tophat_fusion=$OPTARG
			;;
		bi)
			bowtie_index=$OPTARG
			;;
		r)	
			ref=$OPTARG
			;;
		e)
			ens=$OPTARG
			;;
		L)
			star_fusion_lib=$OPTARG
			;;
		M)
			method=$OPTARG
			;;
		t)
			thread=$OPTARG
			;;
	esac
done

wkdir=`dirname $input`
if [[ $input =~ Chimeric.out.junction ]];then method="star";fi
if [[ $input =~ fusions.out ]];then method="tophat";fi

shift $((OPTIND - 1))
checkError="0";
if [ -z "$sampleName" ];then echo "Please provide the Sample name"; checkError="1";fi
if [ -z "$input" ];then echo "Please provide the file for processing"; checkError="1";fi
if [ -z "$method" ];then echo "Unrecognized input format, please manually provide method (star|tophat) for processing"; checkError="1";fi
if [ "$checkError" -eq "1" ];then
	echo -e "=======================================\n"
	printf '%s\n' "$help"
	exit -1
fi

echo -e \\n"The result will output into `readlink -f $wkdir`";
cd $wkdir
if [ ! -e log ]&&[ ! -e logs ];then mkdir log; fi
echo "Start analysis using the followings:"
echo ""
echo "Sample Info=====>"
echo "Current folder:  "$PWD
echo "======================================="
echo "   Sample Name:  "$sampleName
echo "    Input file:  "`readlink -f $input`
echo "        Method:  "$method
echo "       Threads:  "$thread
echo "======================================="
echo ""

processDay=`date +%Y%m%d`

if [ "$method" = "star" ];then
	echo -e [`date`]\\tStart processing fusion file from star-fusion
	$star_fusion	--genome_lib_dir $star_fusion_lib -J $input --output_dir $wkdir   >log/$sampleName.starFusion_$processDay.log 2>&1
	echo -e "`date`\\tFinished star-fusion!"
fi

if [ "$method" = "tophat" ];then 
	if [ -s tophatfusion_out_$sampleName ];then echo -e  "####tophatfusion_out_"$sampleName" already exist,please remove this folder and re-run the script!"\\n;exit -1;fi
	echo -e [`date`]\\tStart processing fusion file from tophat
	if [ ! -e refGene.txt ];then ln -s  $ref  refGene.txt;fi
	if [ ! -e ensGene.txt ];then ln -s  $ens  ensGene.txt;fi
	if [ ! -e "blastn" ];then ln -s  $blastn  blastn;fi
	if [ ! -e "blast" ];then ln -s  $blastdb  blast;fi
	if [ ! -s tophat_out ];then 
		mkdir tophat_out
		cd tophat_out 
		if [ ! -e fusions.out ];then ln -s ../`basename $input` fusions.out ;fi
		#if [ ! -e fusions.out ];then cp ../`basename $input` fusions.out ;fi
		cd ../
	fi
	if [  -e  logs ];then
	$tophat_fusion -o ./tophatfusion_out_$sampleName -p $thread  $bowtie_index >logs/$sampleName.tophatFusion_$processDay.log 2>&1
	fi
	if  [  -e  log ];then
	$tophat_fusion -o ./tophatfusion_out_$sampleName -p $thread  $bowtie_index >log/$sampleName.tophatFusion_$processDay.log 2>&1
	fi
        rm -r refGene.txt ensGene.txt blastn blast tophat_out
	mv ./tophatfusion_out_$sampleName/result.txt fusion_result.txt
	echo -e "`date`\\tFinished tophat-fusion!"
fi
echo -e `date`"\\tTask done!"
