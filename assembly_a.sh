#!/bin/bash
#author:Zelin Li
#date:2020.03.23
#utility:assemble paired-end clean data(reads,fastq format), use abyss, do blast search and make circos graph.

readsfq_path=$1
for i in $(cat list); do
echo "#BSUB -L /bin/bash
#BSUB -J abyss_${i}.sh
#BSUB -q fat
#BSUB -n 4
#BSUB -o abyss_${i}.out
#BSUB -e abyss_${i}.err

cd ${i}

../blast_and_circos.sh ${i}_a_scaffolds.fa
" > abyss_${i}.sh
done
for j in $(cat list);do
bsub < abyss_${j}.sh
done
