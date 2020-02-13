#!/bin/bash
#author:Zelin Li
#date:2020.02.13
#utility:assemble paired-end clean data(reads,fastq format), use platanus and abyss.
cd /PATH/TO/WHERE/YOU/WANT/TO/GET/RESULT
for i in $(cat list);do
echo "#BSUB -L /bin/bash
#BSUB -J run_${i}.sh
#BSUB -q fat
#BSUB -n 4
#BSUB -o run_${i}.out
#BSUB -e run_${i}.err

mkdir ${i}
cd ${i}
/PATH/TO/platanus/platanus_allee assemble -f /PATH/TO/cleandata/${i}_1.fq /PATH/TO/cleandata/${i}_2.fq -o p
/PATH/TO/platanus/platanus_allee phase -c p_contig.fa -IP1 ../cleandata/${i}_1.fq ../cleandata/${i}_2.fq -o p
/PATH/TO/platanus/platanus_allee consensus -c p_consensusInput.fa -IP1 /PATH/TO/cleandata/${i}_1.fq /PATH/TO/cleandata/${i}_2.fq -o ${i}-p
/PATH/TO/script/n50.sh ${i}-p_consensusScaffold.fa > p-stats
/PATH/TO/platanus/platanus_allee consensus -c p_contig.fa -IP1 /PATH/TO/cleandata/${i}_1.fq /PATH/TO/cleandata/${i}_2.fq -o ${i}-p-nophase
/PATH/TO/script/n50.sh ${i}-p-nophase_consensusScaffold.fa > p-nophase-stats
abyss-pe name=${i}-a k=96 in='/PATH/TO/cleandata/${i}_1.fq /PATH/TO/cleandata/${i}_2.fq'
" > run_${i}.sh
done
for j in $(cat list);do
bsub < run_${j}.sh
done
