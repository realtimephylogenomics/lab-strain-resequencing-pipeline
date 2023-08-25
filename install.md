# install

# guppy, ubuntu 18
wget https://cdn.oxfordnanoportal.com/software/analysis/ont_guppy_cpu_6.5.7-1~bionic_amd64.deb

# guppy ubuntu 20
wget https://cdn.oxfordnanoportal.com/software/analysis/ont_guppy_cpu_6.5.7-1~focal_amd64.deb

# guppy install
sudo dpkg -i <location of guppy .deb file>

# Kraken2
sudo apt install kraken2

# get DBs
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20230605.tar.gz

# Flye
https://github.com/fenderglass/Flye/blob/flye/docs/INSTALL.md
git clone https://github.com/fenderglass/Flye
cd Flye
python setup.py install

# quast
pip install quast

# FastQC
https://www.bioinformatics.babraham.ac.uk/projects/download.html#fastqc
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip
unzip fastqc_v0.12.1.zip
