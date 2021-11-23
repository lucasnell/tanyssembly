#!/bin/bash


# #### If doing this on your laptop, use this code:
#
# docker pull ezlabgva/busco:v5.2.2_cv1
#
# export wd=~/_data/busco_wd
#
# docker run \
#     -v $wd:/busco_wd \
#     -u $(id -u) \
#     ezlabgva/busco:v5.2.2_cv1 \
#     busco \
#         -m genome \
#         -l diptera_odb10 \
#         -i busco_wd/polished_hap1.purged.fasta \
#         -o busco_wd/busco_out \
#         --cpu 6
#
#



# For the cluster, use this:

# have job exit if any command returns with non-zero exit status (aka failure)
set -e

# for GENOME in contigs_shasta polished_hap1 polished_hap2
# do
    # cp /staging/lnell/${GENOME}.fasta.gz ./
    # gunzip ${GENOME}.fasta.gz
    # OUTDIR=busco__${GENOME}


cp /staging/lnell/haploid_purge_dups.tar.gz ./
tar -xzf haploid_purge_dups.tar.gz
rm haploid_purge_dups.tar.gz


for G in purged hap
do

    export GENOME=pepper_haps.${G}.fa
    mv ./haploid_purge_dups/seqs/${GENOME} ./
    echo $GENOME
    echo -e "\n\n"
    OUTDIR=busco__${G}

    busco \
        -m genome \
        -l diptera_odb10 \
        -i ${GENOME} \
        -o ${OUTDIR} \
        --cpu 24

    echo -e "\n\n\n\n"
    echo -e "============================================================"
    echo -e "============================================================"
    echo -e "\n\n\n\n"

    tar -czf ${OUTDIR}.tar.gz ${OUTDIR}
    mv ${OUTDIR}.tar.gz /staging/lnell/
    rm -r ${OUTDIR} ${GENOME}
done



