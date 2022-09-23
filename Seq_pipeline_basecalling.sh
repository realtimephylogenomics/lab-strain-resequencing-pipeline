#!/bin/bash

#SBATCH --time=48:00:00
# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL
# send mail to this address
#SBATCH --mail-user=server.outputs@gmail.com
#SBATCH --mail-user=jp1e18@soton.ac.uk
#SBATCH --nodes=1
#SBATCH -p gpu
#SBATCH --gres=gpu:2

module load ont-guppy #Loads guppy into iridis5 

module load cuda #Loads cuda libraries 

#bash Seq_pipeline_basecalling.sh <sample name and barcode file> <basecalling yes/no> <path to fast5 (if basecalling, if not just type 'no')> <path to kraken database> <path to barcodes or desired barcode folder save location>

list=$(cut -f 1 < $1)
list1=$1
basecalling=$2
Path_to_fast5=$3
Path_to_kraken_database=$4
barcodeDir=$5

echo $0 $@

echo -e 'checking for installed programs...\n'

if ! [ -x "$(command -v flye)" ]; then
    echo -e 'Error: flye is not on path. See manual.txt for help\n' >&2
  exit 1
fi

if ! [ -x "$(command -v kraken2)" ]; then
  echo -e 'Error: kraken2 is not on path.See manual.txt for help\n' >&2
  exit 1
fi

if ! [ -d "$Path_to_kraken_database" ]; then
    echo -e 'Kraken2 database not found. See manual.txt for help\n'
    exit 1
fi

if [ $basecalling == *"yes"* ] && ! [ -x "$(command -v guppy_basecaller)" ] ; then
  echo -e 'Error: guppy is not on path. See manual.txt for help\n' >&2
  exit 1
fi 

if [[ $basecalling == *"yes"* ]] ; then
    echo -e 'performing simplex basecalling and barcoding for SQK-NBD112-24 with sup configuration. This could take several hours\n' ;
    guppy_basecaller --device cuda:all:100% -i $Path_to_fast5/ -s basecalled_sup -c dna_r10.4_e8.1_sup.cfg
    cat basecalled_sup/pass/*.fastq > basecalled_sup/all-simplex.fastq
    guppy_barcoder -i basecalled_sup/ -s $barcodeDir/ --barcode_kits "SQK-NBD112-24" --trim_barcodes --trim_adapters ;
else
    echo -e 'basecalling argument not supplied, proceeding without basecalling\n' ;
    sbatch Seq_pipeline_computation.sh $list1 no $Path_to_fast5 $Path_to_kraken_database $barcodeDir 
fi

sbatch Seq_pipeline_computation.sh $list1 no $Path_to_fast5 $Path_to_kraken_database $barcodeDir #Takes the data forward from this step into the computation step (different steps as the compute capacity of the gpu nodes is very low)
