# NGS_pipeline
## 1 call_variant.sh

call_variant.sh is a bioinformatics pipeline which use BWA, SAMtools and VarScan to identity the difference of multiple genome. It can automatically call snp and indel, forming .vcf files from sequencing clean data (reads, fastq format).

#### what you need: BWA, SAMtools, VarScan.

## 2 assembly+

assembly+ is for genome assembly, using abyss, platanus and spades, generating a sets of assembly results, which include most of the intermediate data (contig, etc.) and statistics (n50, max scaffold length, etc.). It also make a blast, comparing with multiple mtDNA and select the 'closest' species blast results; then select the scaffolds that may be related with mtDNA of this strand. At last, extract these scaffolds and form a new fasta file. Finally, it automatically draw a CIRCOS graph from hsp information of the final selection sets of blast results.

#### softs that you need: ABySS(2.2.4, GPL3), Platanus(v2.2.2, GPL3), SPAdes(v3.14.0, GPL2), BLAST, CIRCOS(0.69-9, GPL3).

### 2.1 assembly+.sh

main bash shell script file, which you can use like:"./assembly+.sh /PATH/TO/WHERE/YOU/WANT/TO/GET/RESULT/ /PATH/TO/CLEAN/DATA/READS/" or "bash assembly+.sh /PATH/TO/WHERE/YOU/WANT/TO/GET/RESULT/ /PATH/TO/CLEAN/DATA/READS/". You also need a list contain at least one or multiple reads name (characters which are in front of "_1_clean.fq" or "_2_clean.fq") in one row.

### 2.2 n50.sh

statistical script, count for N50, N90, largest scaffolds/contigs, assembly size and number of scaffolds/contigs.

### 2.3 blast_and_circos.sh

analytical script, automatically do blast and select the suspective mtDNA scaffolds from the assembly results and draw circos graph base on the selected blast results.

### 2.4 assembly_a.sh, assembly_p.sh and assembly_s.sh

softs seperated assembly pipeline, while 'a' mean abyss; 'p' mean platanus; 's' mean spades. You might not use them directly, but use them through the assembly+.sh.

### 2.5 lzl-assembly+_20.03.01.pptx

an principle introduction of assembly+ (in Chinese).

### 2.6 mtDNAppt.py

a python script which need python-pptx to operate. It is used to collect the information from the data outputs of assembly+ (including n50.sh stats, CIRCOS graph, closest species and it mtDNA length, suspective mtDNA scaffolds number and sum of length).
