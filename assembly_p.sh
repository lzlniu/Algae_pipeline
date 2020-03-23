#!/bin/bash
#author:Zelin Li
#date:2020.03.23
#utility:assemble paired-end clean data(reads,fastq format), use platanus, do blast search and make circos graph.

readsfq_path=$1
for i in $(cat list); do
echo "#BSUB -L /bin/bash
#BSUB -J platanus_${i}.sh
#BSUB -q fat
#BSUB -n 4
#BSUB -o platanus_${i}.out
#BSUB -e platanus_${i}.err

cd ${i}
platanus_allee assemble -f ${readsfq_path}${i}_1_clean.fq ${readsfq_path}${i}_2_clean.fq -o p
platanus_allee phase -c p_contig.fa -IP1 ${readsfq_path}${i}_1_clean.fq ${readsfq_path}${i}_2_clean.fq -o p
platanus_allee consensus -c p_consensusInput.fa -IP1 ${readsfq_path}${i}_1_clean.fq ${readsfq_path}${i}_2_clean.fq -o ${i}_p
../n50.sh ${i}_p_consensusScaffold.fa > ${i}_p_stats.txt
#platanus_allee consensus -c p_contig.fa -IP1 ${readsfq_path}${i}_1_clean.fq ${readsfq_path}${i}_2_clean.fq -o ${i}_p_nophase
#../n50.sh ${i}_p_nophase_consensusScaffold.fa > ${i}_p_nophase_stats.txt
rm -rf p_intermediateResults
rm -rf *_consensusIntermediateResults
rm -rf p_nonBubble*
rm -rf p_allPhasedScaffold.fa
mv ${i}_p_consensusScaffold.fa ${i}_p_scaffolds.fa
../blast_and_circos.sh ${i}_p_scaffolds.fa
" > platanus_${i}.sh
done
for j in $(cat list);do
bsub < platanus_${j}.sh
done
