#!/bin/bash -e
dir=`dirname $0`
source $dir/rnaSeq_pipeline/rna_analysis.defineFun # defined the functions
source $dir/rnaSeq_pipeline/rna_analysis.definePath # defined the default parameters
source $dir/rnaSeq_pipeline/rna_analysis.defineHelp # defined the help document
source $dir/rnaSeq_pipeline/rna_analysis.definePara # recieve the external parameters
source $dir/rnaSeq_pipeline/rna_analysis.defineInput # check the refer/input files
source $dir/rnaSeq_pipeline/rna_analysis.defineHeader # output the basic information for the run
source $dir/rnaSeq_pipeline/rna_analysis.run # main programe
