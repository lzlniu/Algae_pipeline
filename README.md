# DeerBioPipeline
## 1 call_variant.sh

call_variant.sh is a bioinformatics pipeline which use BWA, SAMtools and VarScan to identity the difference of multiple genome. It can automatically call snp and indel, forming .vcf files from sequencing clean data (reads, fastq format).

#### what you need: BWA, SAMtools, VarScan.

## 2 assembly+

assembly+.sh is for genome assembly, using platanus-allee, generating a sets of assembly results, which include most of the intermediate data (contig, etc.) and statistics (n50, max scaffold length, etc.). It also make a blast, comparing with multiple mtDNA and select the 'closest' species blast results; then select the scaffolds that may be related with mtDNA of this strand. At last, extract these scaffolds and form a new fasta file. Finally, it automatically draw a CIRCOS graph from hsp information of the final selection sets of blast results.

#### what you need: Platanus-allee, BLAST, CIRCOS.

### 2.1 assembly+.sh

main bash shell script file, which you can use like:"./assembly+.sh" or "bash assembly+.sh".

### 2.2 n50.sh

statistical script, count for N50, N90, largest scaffolds/contigs, assembly size and number of scaffolds/contigs.

### 2.3 run_FDES192014350-1a_L2.sh

an example output of assembly+.sh.

### 2.4 lzl-assembly+_20.03.01.pptx

an introduction of assembly+ (in Chinese).

### 2.5 mtDNAppt.py

a python script which need python-pptx to operate. It is used to collect the information from the data outputs of assembly+ (including n50.sh stats, CIRCOS graph, closest species and it mtDNA length, suspective mtDNA scaffolds number and sum of length).
