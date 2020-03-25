#!/bin/bash
#author:Zelin Li
#date:2020.03.23
#usage:bash assembly_a.sh /PATH/TO/CLEAN/DATA/READS/ /PATH/TO/BLAST/QUERY/SEQS.fa
#utility:assemble paired-end clean data(reads,fastq format), use abyss, do blast search and make circos graph.

readsfq_path=$1
query=$2
for i in $(cat list); do
echo "#BSUB -L /bin/bash
#BSUB -J abyss_${i}.sh
#BSUB -q fat
#BSUB -o abyss_${i}.out
#BSUB -e abyss_${i}.err

cd ${i}
mkdir abyss
cd abyss
abyss-pe name=${i}-a k=96 in='${readsfq_path}${i}_1_clean.fq ${readsfq_path}${i}_2_clean.fq'
cp ${i}-a-8.fa ../${i}_a_scaffolds.fa
cp ${i}-a-stats.tab ../${i}_a_stats.txt
cd ..
../blast_and_circos.sh ${i}_a_scaffolds.fa ${query}
" > abyss_${i}.sh
done
for j in $(cat list); do
bsub < abyss_${j}.sh
done
