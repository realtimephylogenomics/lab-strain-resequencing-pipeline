####
#
# Verify installation
# V0.1
# Joe Parker @lonelyjoeparker
#
# This is an MVP minimum viable product script.
# It is intended to test the basecalling (guppy), assembly (flye),
# and metagenomics classification (kraken) software is correctly installed.
#
# It assumes the install script has already run.
#
# USAGE
#   bash verify_installation.#!/bin/sh
#
# output
#   <to be decided>
#

# set up folders
mkdir ../test_dir
mkdir ../test_dir/raw_reads
mkdir ../test_dir/assembly
mkdir ../test_dir/kraken
cd ../test_dir/raw_reads

# get test data
wget https://genomics-2023-test-data.s3.eu-west-1.amazonaws.com/AMP551_14a1252d_289f5c8f_1.fast5

# run guppy to basecall
cd ..
guppy_basecaller -i ./raw_reads/ -s ./basecalled_reads --flowcell FLO-FLG001 --kit SQK-LSK111

# concatenate raw_reads
cat ./basecalled_reads/pass/*fastq > ./basecalled_reads/all_pass.fastq

# run fastQC to check read Qscores
/opt/FastQC/fastqc
# (use FastQC file browser to check  ./basecalled_reads/all_pass.fastq)

# run kraken to classify
path_to_kraken_database=/media/nbicgenomics/seq_dbs/kraken2/k2_standard_20220607/
kraken2 --db $path_to_kraken_database --threads 4 --report ./kraken/kraken2.report --output ./kraken/kraken2.out ./basecalled_reads/all_pass.fastq
less /kraken/kraken2.report

# note other Kraken DBs including smaller ones (if memory issues) are at
https://benlangmead.github.io/aws-indexes/k2

# run flye to assemble
flye --nano-hq ./basecalled_reads/all_pass.fastq --out-dir ./assembly --genome-size 7m --threads 4 --iterations 3 --meta  #40 threads for IRIDIS
# note, if using HelloWorld reduced read dataset, this may report a failed assembly (no contigs). It's cool.

# check assembly with quast
quast.py assembly/00-assembly/draft_assembly.fasta
