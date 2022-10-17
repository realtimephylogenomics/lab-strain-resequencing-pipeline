# lab-strain-resequencing-pipeline
# Pipeline for internal lab resequencing projects

This is a pipeline that will: 
- Take raw fast5 data from Oxford Nanopore Kit12 chemistry 
- Basecall using guppy on the sup configuration 
- Label the outputs of all processes using the strain names provided in a .txt file
- Analyse the taxonimic profile of the sample using Kraken2
- Assemble genomes using Flye
- Export the best/most complete contig to a single file

## Installing programs:

Flye and Kraken2 can be installed into a conda environment. If conda is not installed then goto https://conda.io/projects/conda/en/latest/user-guide/install/linux.html

```bash
conda create -n Seq_pipeline
conda activate Seq_pipeline
conda install -c conda-forge -c bioconda flye
conda install -c conda-forge -c bioconda kraken2
```
guppy must be installed directly to path and requires sudo access. This will install the gpu version. (guppy is already installed on iridis5)

```bash
sudo apt-get update
sudo apt-get install wget lsb-release
export PLATFORM=$(lsb_release -cs)
wget -O- https://cdn.oxfordnanoportal.com/apt/ont-repo.pub | sudo apt-key add -
echo "deb http://cdn.oxfordnanoportal.com/apt ${PLATFORM}-stable non-free" | sudo tee /etc/apt/sources.list.d/nanoporetech.sources.list
sudo apt-get update
sudo apt-get install ont-guppy
```

The standard Kraken2 database is available here; https://benlangmead.github.io/aws-indexes/k2, or can be downloaded with; wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20220607.tar.gz

The resulting file must then be decompressed using; 

```bash
tar -xvzf <file_name>
```

This database will require at least **60GB** of RAM to run, download one of the smaller standard databases if this is not practical for you (you will lose some sensitivity) 

The conda environment *MUST* be activated before submitting the job to iridis5

## Basecalling and computation step-1:

The pipeline will be expecting two columns of information for the basecalling step and the first computation step.

The layout should be the sample names in the first column and the barcode number in the second column. The barcode number must be exactly as it is on the kit e.g. 01 not 1 

Do not include table headers

Example below: This can be copy and pasted straight from excel into the text editor you want to use (I use emacs). It does not matter if the names and numbers are not perfectly aligned provided they are seperated by a 'tab'

|strain | barcode|
|---|---|
|PaSS1 | 01|
|PaLU1 | 02|
|PaSF1 | 03|
|PaRS1 | 04|
|PaRS2 | 05|
|PaRS3 | 06|
|PaES1 | 07|
|PaES2 | 08|
|PaES3 | 09|
|PaRS4 | 10|
|ANT_PA50	| 11|
|ANT_PA66	| 12|
|ANT_PA28	| 13|
|ANT_PA30	| 14|
|ANT_PA38	| 15|
|ANT_PA43	| 16|
|ANT_PA47	| 17|
|ANT_PA67	| 18|
|ANT_PA146	| 19|
|ANT_PA147	| 20|


For the first basecalling step, which automatically includes the first the computation step use the below format replacing the words surrounded by <  > for the actual information 
```
sbatch Seq_pipeline_basecalling.sh <sample name and barcode file> <basecalling yes/no> <path to fast5 (if basecalling, if not just type 'no')> <path to kraken database> <path to barcodes or desired barcode folder save location>
```
e.g. 
```bash
sbatch Seq_pipeline_basecalling.sh Batch_1.txt yes raw_data/fast5 kraken_database barcoded
```
The basecalling will take several hours 

The first computation step will take place automatically after the basecalling step and will typically be done in around 5 hours

The ultimate outputs are:
- Kraken report files that will tell you the taxonomy of the sample
- Genome assemblies of the samples

It is important to view the kraken reports before continuing to the 'best contig' step, as we must know what the organism is to determine the expected size of the contig from the assembly. This will be visible in the file **'Kraken_species_info.txt'** 

There will be a file produced at the end of the genome assembly step that will show all the assembly_info reports together. This will be titled **'All_assembly_info_summary.txt'**

This will be the easiest way to determine what the best contigs are required for the next step

The file will look like below:

6S2
|#seq_name|length|  cov.|    circ.|   repeat|  mult.|   alt_group|       graph_path|
|---|---|---|---|---|---|---|---|
|contig_1|        6723309| 59|      Y|       N|       1|       *|       1|
|contig_3|       43585|   5|       N|       N|       1|       *|       *,3,*|
|contig_11|       38227|   5|       N|       N|       1|       *|       *,11,*|

PA44_NOV19
|#seq_name|length|  cov.|    circ.|   repeat|  mult.|   alt_group|       graph_path|
|---|---|---|---|---|---|---|---|
|contig_1|        6844862| 57|      N|       N|       1|       *|       -5,1,-5|
|contig_29|       104573|  58|      N|       N|       1|       *|       5,29,5|
|contig_11|       99728|   3|       N|       N|       1|       *|       *,11,*|



We can see that because the first contig of 6S2 is circualr and of the expected size (for pseudomonas), that this is a completed genome and is the best contig. For PA44_NOV19, we can see a contig of the expected size (contig_1), however it is not circular. Despite not being circular, contig_1 is the best contig for PA44_NOV19 and will be carried forward for the next step.

With this information, you can update the best_contig column on the excel spreadsheet and copy and paste the data (without headers) into a new txt document 

|strain| barcode| best_contig|
|---|---|---|
|6S2|    21|  contig_1|
|PA44_NOV19| 12|	contig_1|

## Computation step 2:

Computation step 2 can be run on the login node and will export the best contig into a single .fasta file that can be used for downstream processing 
```bash
Seq_pipeline_computation_step-2.sh <list with strain name, barcode and best contig>
```
This will be exported to the directory 'best_contigs'
