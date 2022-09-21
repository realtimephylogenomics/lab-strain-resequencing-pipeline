#!/bin/bash

#SBATCH --time=48:00:00
# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL
# send mail to this address
#SBATCH --mail-user=server.outputs@gmail.com
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40

#bash Seq_pipeline_computation.sh <sample name and barcode file> <basecalling yes/no> <path to fast5 (if basecalling)> <path to kraken database> <path to barcodes or desired barcode folder save location>

list=$(cut -f 1 < $1)
list1=$1
basecalling=$2
Path_to_fast5=$3
Path_to_kraken_database=$4
barcodeDir=$5

#Identifies which sample has which barcode and labels the variables accordingly while naming the folders with the sample name
barcode01=$(awk '$2 == 01 {print $1}' $list1)
barcode02=$(awk '$2 == 02 {print $1}' $list1)
barcode03=$(awk '$2 == 03 {print $1}' $list1)
barcode04=$(awk '$2 == 04 {print $1}' $list1)
barcode05=$(awk '$2 == 05 {print $1}' $list1)
barcode06=$(awk '$2 == 06 {print $1}' $list1)
barcode07=$(awk '$2 == 07 {print $1}' $list1)
barcode08=$(awk '$2 == 08 {print $1}' $list1)
barcode09=$(awk '$2 == 09 {print $1}' $list1)
barcode10=$(awk '$2 == 10 {print $1}' $list1)
barcode11=$(awk '$2 == 11 {print $1}' $list1)
barcode12=$(awk '$2 == 12 {print $1}' $list1)
barcode13=$(awk '$2 == 13 {print $1}' $list1)
barcode14=$(awk '$2 == 14 {print $1}' $list1)
barcode15=$(awk '$2 == 15 {print $1}' $list1)
barcode16=$(awk '$2 == 16 {print $1}' $list1)
barcode17=$(awk '$2 == 17 {print $1}' $list1)
barcode18=$(awk '$2 == 18 {print $1}' $list1)
barcode19=$(awk '$2 == 19 {print $1}' $list1)
barcode20=$(awk '$2 == 20 {print $1}' $list1)
barcode21=$(awk '$2 == 21 {print $1}' $list1)
barcode22=$(awk '$2 == 22 {print $1}' $list1)
barcode23=$(awk '$2 == 23 {print $1}' $list1)
barcode24=$(awk '$2 == 24 {print $1}' $list1)

echo -e 'assigning barcodes to samples...\n'

mv $barcodeDir/barcode01 "${barcode01}"
mv $barcodeDir/barcode02 "${barcode02}"
mv $barcodeDir/barcode03 "${barcode03}"
mv $barcodeDir/barcode04 "${barcode04}"
mv $barcodeDir/barcode05 "${barcode05}"
mv $barcodeDir/barcode06 "${barcode06}"
mv $barcodeDir/barcode07 "${barcode07}"
mv $barcodeDir/barcode08 "${barcode08}"
mv $barcodeDir/barcode09 "${barcode09}"
mv $barcodeDir/barcode10 "${barcode10}"
mv $barcodeDir/barcode11 "${barcode11}"
mv $barcodeDir/barcode12 "${barcode12}"
mv $barcodeDir/barcode13 "${barcode13}"
mv $barcodeDir/barcode14 "${barcode14}"
mv $barcodeDir/barcode15 "${barcode15}"
mv $barcodeDir/barcode16 "${barcode16}"
mv $barcodeDir/barcode17 "${barcode17}"
mv $barcodeDir/barcode18 "${barcode18}"
mv $barcodeDir/barcode19 "${barcode19}"
mv $barcodeDir/barcode20 "${barcode20}"
mv $barcodeDir/barcode21 "${barcode21}"
mv $barcodeDir/barcode22 "${barcode22}"
mv $barcodeDir/barcode23 "${barcode23}"
mv $barcodeDir/barcode24 "${barcode24}"

echo -e 'concatenating fastq files...\n'

#Combines all fastq's for each sample
for i in $list ; do
    cat $i/*.fastq > $i/$i-all.fastq
done

echo -e 'checking taxa using kraken2 with the standard database...\n'

#Checks the taxa using kraken2 and copies the reports into a single folder
mkdir all_kraken_reports

for i in $list ; do
    kraken2 --db $Path_to_kraken_database --threads 40 --report $i/$i-kraken-report --output $i/$i-kraken-ouput $i/$i-all.fastq
    cp $i/$i-kraken-report all_kraken_reports/$i-kraken-report
done

for i in $list;do
    echo -e $i
    awk '$1>5' all_kraken_reports/$i-kraken-report | grep  -P '\tS\t'
    echo -e '\n'
done > Kraken_species_info.txt


echo -e 'assembling genomes using flye...\n'

#Assembles genome using the flye assembler. contiguity may improve by altering certain settings (especially minimum read length), but probably not worth it for this project
for i in $list ; do
    flye --nano-hq $i/$i-all.fastq --out-dir $i/$i-genome --genome-size 7m --threads 40 --iterations 3 --meta  #40 threads for IRIDIS
done

echo -e 'printing single circular contigs...\n'

#Looks for contigs marked as circular in the assembly info file and prints them to a file
for i in $list ; do
    awk '$4 ~ /^Y/ { print $1}' $i/$i-genome/assembly_info.txt > $i/$i-genome/$i-circular_contigs.txt 
    echo -e $i
    cat < $i/$i-genome/$i-circular_contigs.txt
    echo -e '\n'
done > circular_summary.txt

echo -e 'printing all assembly_info outputs...\n'

#Combines all assembly info's together and prints them to a file
for i in $list ; do
    echo -e $i
    cat < $i/$i-genome/assembly_info.txt
    echo -e '\n'
done > All_assembly_info_summary.txt
