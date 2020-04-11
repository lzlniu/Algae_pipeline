#!/bin/bash
#author:Zelin Li
#date:2020/04/11
#utility:without assembly and only blast and make circos graph.

query=$1
for i in $(cat list); do
echo "#BSUB -L /bin/bash
#BSUB -n 4
#BSUB -J blast_${i}.sh
#BSUB -o blast_${i}.out
#BSUB -e blast_${i}.err

cd ${i}
rm -rf *.txt
rm -rf *.png
rm -rf *.svg
rm -rf *_scaf.fa
../n50.sh ${i}_a_scaffolds.fa > ${i}_a_stats.txt
../blast_and_circos.sh ${i}_a_scaffolds.fa ${query}
../n50.sh ${i}_p_scaffolds.fa > ${i}_p_stats.txt
../blast_and_circos.sh ${i}_p_scaffolds.fa ${query}
../n50.sh ${i}_s_scaffolds.fa > ${i}_s_stats.txt
../blast_and_circos.sh ${i}_s_scaffolds.fa ${query}
" > blast_${i}.sh
done
for j in $(cat list); do
bsub < blast_${j}.sh
done
