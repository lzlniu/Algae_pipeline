# Algae_pipeline [![GitHub license](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://github.com/lzlniu/NGS_pipeline/blob/master/LICENSE)
## 1 assembly+

assembly+ is for genome assembly, using abyss, platanus and spades, generating a sets of assembly results, which include most of the intermediate data (contig, etc.) and statistics (n50, max scaffold length, etc.). It also make a blast, comparing with multiple mtDNA and select the 'closest' species blast results; then select the scaffolds that may be related with mtDNA of this strand. At last, extract these scaffolds and form a new fasta file. Finally, it automatically draw a CIRCOS graph from hsp information of the final selection sets of blast results.

#### softs that you need: ABySS(2.2.4, GPL3), Platanus(v2.2.2, GPL3), SPAdes(v3.14.0, GPL2), BLAST, CIRCOS(0.69-9, GPL3).

### 1.1 assembly+.sh

main bash shell script file, which you can use like:"bash assembly+.sh /PATH/TO/WHERE/YOU/WANT/TO/GET/RESULT/ /PATH/TO/CLEAN/DATA/READS/ /PATH/TO/BLAST/QUERY/SEQS.fa". noted that your reads name should be like 'XXX_1_clean.fq, XXX_2_clean.fq', and the list(defult is automatically generate, but you can write it by yourself) should only contain 'XXX' in one row.

### 1.2 n50.sh

statistical script, count for N50, N90, largest scaffolds/contigs, assembly size and number of scaffolds/contigs.

### 1.3 blast_and_circos.sh

analytical script, automatically do blast and select the suspective mtDNA scaffolds from the assembly results and draw circos graph base on the selected blast results.

### 1.4 assembly_a.sh, assembly_p.sh and assembly_s.sh

softs seperated assembly pipeline, while 'a' mean abyss; 'p' mean platanus; 's' mean spades. You might not use them directly, but use them through the assembly+.sh.

### 1.5 lzl-assembly+_20.03.01.pptx

an principle introduction of assembly+ (in Chinese).

### 1.6 mtDNAppt.py

a python script which need python-pptx to operate. It is used to collect the information from the data outputs of assembly+ (including n50.sh stats, CIRCOS graph, closest species and it mtDNA length, suspective mtDNA scaffolds number and sum of length).

## 2 call_variant.sh

call_variant.sh is a bioinformatics pipeline which use BWA, SAMtools and VarScan to identity the difference of multiple genome. It can automatically call snp and indel, forming .vcf files from sequencing clean data (reads, fastq format).

#### what you need: BWA, SAMtools, VarScan.
