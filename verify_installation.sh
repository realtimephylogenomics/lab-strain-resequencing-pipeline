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
wget https://s3.console.aws.amazon.com/s3/object/genomics-2023-test-data?region=eu-west-1&prefix=AMP551_14a1252d_289f5c8f_0.fast5

# run guppy to basecall
cd ..
guppy_basecaller -i ./raw_reads -s basecalled_sup -c dna_r10.4_e8.1_sup.cfg # check for a newer pore model!

# concatenate raw_reads
cat ./raw_reads/*q > ./all-basecalled.fastq

# run flye to assemble
  flye --nano-hq ./all-basecalled.fastq --out-dir ./assembly --genome-size 7m --threads 4 --iterations 3 --meta  #40 threads for IRIDIS
# run kraken to classify
path_to_kraken_database=/media/nbicgenomics/seq_dbs/kraken2/standard/
kraken2 --db $path_to_kraken_database --threads 4 --report ./kraken/kraken2.report --output ./kraken/kraken2.out ./all-basecalled.fastq
