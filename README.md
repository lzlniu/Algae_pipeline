# DeerBioPipeline
call_variant.sh is a bioinformatics pipeline which use BWA, SAMtools and VarScan to compare the difference of multiple genome. it can generate snp and indel .vcf files from sequencing clean data (reads, fastq format).\
assembly+.sh is for genome assembly, using platanus-allee, generating a sets of assembly results, which include most of the intermediate data (contig, etc.) and statistics (n50, max scaffold length, etc.). It also make a blast, comparing with multiple mtDNA and select the 'closest' species blast results; then select the scaffolds that may be related with mtDNA of this strand. At last, extract these scaffolds and form a new fasta file.
