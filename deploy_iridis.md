## install to iridis cluster

### set up a conda environment

```
module load conda
conda create -n conor_resequencing_pipeline
conda init bash
```

this will create a conda environment called `conor_resequencing_pipeline`


then 

```
conda activate conor_resequencing_pipeline
conda install -c bioconda -c conda-forge  flye
```

### each login, activate said conda environment
