#!/bin/bash
#author:Zelin Li
#date:2020.03.23
#utility:assemble paired-end clean data(reads,fastq format), use spades, do blast search and make circos graph.

readsfq_path=$1
for i in $(cat list); do
echo "#BSUB -L /bin/bash
#BSUB -J spades_${i}.sh
#BSUB -q fat
#BSUB -n 4
#BSUB -o spades_${i}.out
#BSUB -e spades_${i}.err

cd ${i}

../blast_and_circos.sh ${i}_s_scaffolds.fa
" > spades_${i}.sh
done
for j in $(cat list);do
bsub < spades_${j}.sh
done
