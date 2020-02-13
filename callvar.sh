#!/bin/bash
#author:Zelin Li
#date:2020.02.13
#utility:search for snp and indel from paired-end clean data(reads,fastq format)
cd /public/home/lizelin/data/Pg/Pgcleandata
for i in $(cat list);do
echo "#BSUB -L /bin/bash
#BSUB -J run_${i}.sh
#BSUB -q fat
#BSUB -n 4
#BSUB -o run_${i}.out
#BSUB -e run_${i}.err

mkdir ${i}
cd ${i}
bwa mem /public/home/lizelin/data/Pg/Pgcleandata/CNS00067.fa /public/home/lizelin/data/Pg/Pgcleandata/tar/${i}_1_clean.fq /public/home/lizelin/data/Pg/Pgcleandata/tar/${i}_2_clean.fq -o aln.sam
samtools view -bS -F 12 aln.sam -o aln.bam
samtools sort aln.bam -o aln_sort.bam
samtools index aln_sort.bam
samtools mpileup -f /public/home/lizelin/data/Pg/Pgcleandata/CNS00067.fa aln_sort.bam -o aln.mpileup
java -jar /public/home/lizelin/align/VarScan.v2.4.4.jar mpileup2cns aln.mpileup --output-vcf 1 --variants 1 > all.vcf
java -jar /public/home/lizelin/align/VarScan.v2.4.4.jar mpileup2snp aln.mpileup --output-vcf 1 > snp.vcf
grep -n "HOM=1" snp.vcf > snv_${i}.txt
rm -rf aln.sam
cp snv_${i}.txt ../
" > run_${i}.sh
done
for j in $(cat list);do
bsub < run_${j}.sh
done
