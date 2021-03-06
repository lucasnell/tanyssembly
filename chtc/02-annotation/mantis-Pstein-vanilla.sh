#!/bin/bash

#' Using mantis for functional annotations on Pstein assembly using
#' non-Docker ("vanilla") environment on CHTC cluster.
#' This means I have to build my conda environment myself.


wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh
sh Miniconda3-py39_4.12.0-Linux-x86_64.sh
# say yes to running `conda init`

. .bashrc

conda create -y -c conda-forge -c bioconda -n mantis-env mantis_pfa=1.5.5


conda install -y -c conda-forge conda-pack

conda pack -n mantis-env
chmod 644 mantis-env.tar.gz
ls -sh mantis-env.tar.gz
cp mantis-env.tar.gz /staging/lnell/annotation/

conda activate mantis-env



#'
#' Functional annotations using mantis.
#'


export THREADS=$(grep "^Cpus = " $_CONDOR_MACHINE_AD | sed 's/Cpus\ =\ //')

# Memory available:
export MEMORY=$(grep "^Memory = " $_CONDOR_MACHINE_AD | sed 's/Memory\ =\ //')
# In GB, with 5 GB overhead:
MEMORY=$(( MEMORY / 1000 - 5 ))

export OUT_DIR=Pstein_mantis

mkdir working
cd working

# For databases:
mkdir dbs
# For references:
mkdir refs


cp /staging/lnell/annotation/Pstein_proteins.fasta.gz ./ \
    && gunzip Pstein_proteins.fasta.gz


#' Setup MANTIS.cfg based on default from
#' https://github.com/PedroMTQ/mantis/blob/a59937d23979372c65188cf2358b69485099dc68/config/MANTIS.cfg
#' downloaded on 14 June 2022.
#' The only differences are that comments are removed and
#' default_ref_folder and resources_folder are set.
cat << EOF > MANTIS.cfg
default_ref_folder=$(pwd)/dbs
resources_folder=$(pwd)/refs
nog_ref=dmnd
nog_weight=0.8
pfam_weight=0.9
EOF


#' Download and setup databases:
mantis setup -mc MANTIS.cfg --cores ${THREADS} --memory ${MEMORY}

tar -czf mantis-downloads.tar.gz dbs refs
mv mantis-downloads.tar.gz /staging/lnell/annotation/



#' Run mantis:
mantis run -mc MANTIS.cfg -i Pstein_proteins.fasta -o ${OUT_DIR} -od 315571 \
    --verbose_kegg_matrix \
    --cores ${THREADS} --memory ${MEMORY} --hmmer_threads 2


rm -rf refs dbs


tar -czf ${OUT_DIR}.tar.gz ${OUT_DIR}
mv ${OUT_DIR}.tar.gz /staging/lnell/annotation/

cd ..
rm -r working






