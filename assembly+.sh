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
makeblastdb -in ${i}-p_consensusScaffold.fa -dbtype nucl -parse_seqids -out scaf
blastn -query ../mt.fa -db scaf -outfmt '6 qseqid qlen sseqid slen pident length mismatch gapopen gaps qstart qend sstart send evalue bitscore' -out p_mt_blast.txt
awk -F '\t' '\$5>=95' p_mt_blast.txt | awk -F '\t' '\$6>=2000' > p_mt_blast-pid95-len2000.txt
sort -t\$'\t' -k 1fi,1 -k 15rn,15 p_mt_blast.txt | uniq -w 9 | sort -t\$'\t' -k 15rn,15 | awk 'NR==1{print \$1}' > spp
grep \$(cat spp) p_mt_blast.txt > p_mt_spp.txt
rm -rf spp
rm -rf p_intermediateResults
rm -rf *_consensusIntermediateResults
find . -name \"*\" -type f -size 0c | xargs -n 1 rm -f
" > run_${i}.sh
done
for j in $(cat list);do
bsub < run_${j}.sh
done
