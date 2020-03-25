#!/bin/bash
#author:Zelin Li
#date:2020.03.23
#usage:bash assembly_a.sh /PATH/TO/CLEAN/DATA/READS/ /PATH/TO/BLAST/QUERY/SEQS.fa
#utility:assemble paired-end clean data(reads,fastq format), use spades, do blast search and make circos graph.

readsfq_path=$1
query=$2
for i in $(cat list); do
echo "#BSUB -L /bin/bash
#BSUB -J spades_${i}.sh
#BSUB -q fat
#BSUB -n 4
#BSUB -o spades_${i}.out
#BSUB -e spades_${i}.err

cd ${i}
spades.py -1 ${readsfq_path}${i}_1_clean.fq -2 ${readsfq_path}${i}_2_clean.fq -o spades
cp spades/scaffolds.fasta ${i}_s_scaffolds.fa
../n50.sh ${i}_s_scaffolds.fa > ${i}_s_stats.txt
../blast_and_circos.sh ${i}_s_scaffolds.fa ${query}
" > spades_${i}.sh
done
for j in $(cat list); do
bsub < spades_${j}.sh
done
