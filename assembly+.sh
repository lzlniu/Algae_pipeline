#!/bin/bash
#author:Zelin Li
#date:2020.02.26
#utility:assemble paired-end clean data(reads,fastq format), use platanus, do blast search and make circos graph.
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
rm -rf p_intermediateResults
rm -rf *_consensusIntermediateResults
rm -rf p_nonBubble*
rm -rf p_allPhasedScaffold.fa

#Make blast search (for mtDNA)

makeblastdb -in ${i}-p_consensusScaffold.fa -dbtype nucl -parse_seqids -out scaf
blastn -query ../mt.fa -db scaf -outfmt '6 qseqid qlen sseqid slen pident length mismatch gapopen gaps qstart qend sstart send evalue bitscore' -out p_mt_blast.txt
rm -rf scaf.*

#awk -F '\t' '\$5>=95' p_mt_blast.txt | awk -F '\t' '\$6>=2000' > p_mt_blast-pid95-len2000.txt

sort -t\$'\t' -k 15rn,15 p_mt_blast.txt | awk 'NR==1{print \$1}' > spp
grep \$(cat spp) p_mt_blast.txt > p_mt_spp.txt
rm -rf spp

uniq -f 2 -w 20 p_mt_spp.txt > p_mt_scaf-all
awk '{print \$4}' p_mt_scaf-all > scaflen
awk '{print \$3}' p_mt_scaf-all  > scafname
grep -n \"\" p_mt_scaf-all | awk -F ':' '{print \$1}' > scafline
rm -rf p_mt_scaf-all
sed -n 1p scafname > scafname-sel
for line1 in \$(cat scafline); do
        ((line2=\$line1+1))
        linemax=\`echo \$(awk END'{print \$1}' scafline)\`;
        if ((line2 > linemax)); then
                let line2=line2-1
        fi
        #n=\`echo \$(sed -n \${line1}p scaflen) | awk NR==1'{print \$1}'\`;
        n=\`echo \$(awk NR==1'{print \$1}' scaflen)\`;
        m=\`echo \$(sed -n \${line2}p scaflen) | awk NR==1'{print \$1}'\`;
        if ((m >= n)) || ((m < 1000)); then
                break
        else
                sed -n \${line2}p scafname >> scafname-sel
        fi
done
rm -rf scaflen
rm -rf scafline
rm -rf scafname
for scafnamesel in \$(cat scafname-sel); do
        grep \${scafnamesel} p_mt_spp.txt >> p_mt_spp-sel.txt
done

awk '!/^>/ { printf \"%s\", \$0; n = \"\n\" } /^>/ { print n \$0; n = \"\" } END { printf \"%s\", n }' ${i}-p_consensusScaffold.fa > p_oneline_scaf.fa
for name in \$(cat scafname-sel);do
        grep -n \${name} p_oneline_scaf.fa | awk -F ':' '{print \$1}' >> scafloc
done
for loc in \$(cat scafloc);do
        sed -n \"\${loc},\$((\${loc}+1))p\" p_oneline_scaf.fa >> p_mt_scaf.fa
done
rm -rf scafloc
rm -rf p_oneline_scaf.fa

#Draw CIRCOS graph

mkdir ${i}-p_circos
cd ${i}-p_circos
mkdir data
mkdir etc
cd ..
#grep \$(awk 'NR==1{print \$3}' p_mt_spp.txt) p_mt_spp.txt | sort -t\$'\t' -k 10n,10 > p_mt_sppA.txt
chrcolor=1
for scafnamesel2 in \$(cat scafname-sel); do
        grep \${scafnamesel2} p_mt_spp-sel.txt | sort -t\$'\t' -k 10n,10 > p_mt_spp-\${scafnamesel2}.txt
        awk '{print \"chr1\t\"\$10\"\t\"\$11\"\tfill_color=chr'\"\$chrcolor\"'\"}' p_mt_spp-\${scafnamesel2}.txt >> ${i}-p_circos/data/highlights.1.txt
        awk '{print \"chr1\t\"\$10\"\t\"\$11\"\t\"\$5}' p_mt_spp-\${scafnamesel2}.txt >> ${i}-p_circos/data/labels.1.txt
        let chrcolor=chrcolor+1
        rm -rf p_mt_spp-\${scafnamesel2}.txt
done
#awk '{print \"chr1\t\"\$10\"\t\"\$11\"\tfill_color=green\"}' p_mt_sppA.txt > ${i}-p_circos/data/highlights.1.txt
#awk '{print \"chr1\t\"\$10\"\t\"\$11\"\t\"\$5}' p_mt_sppA.txt > ${i}-p_circos/data/labels.1.txt
awk 'NR==1{print \"chr\t-\tchr1\t\"\$1\".mtDNA.circos.by.Zelin.Li\t0\t\"\$2\"\tchry\"}' p_mt_spp.txt > ${i}-p_circos/data/mtDNAideogram.txt
#rm -rf p_mt_sppA.txt
rm -rf scafname-sel

echo \"
<<include etc/colors_fonts_patterns.conf>>
<<include ideogram.conf>>
<<include ticks.conf>>
karyotype = data/mtDNAideogram.txt
<image>
<<include etc/image.conf>>
</image>
chromosomes_units           = 100000
chromosomes_display_default = yes
<<include highlights.conf>>
<plots>
<plot>
type  = text
file  = data/labels.1.txt
color = black
r1    = 0.975r
r0    = 0.835r
label_size = 24p
label_font = default
padding    = 1p
rpadding   = 1p
show_links     = yes
link_dims      = 1p,2p,3p,2p,1p
link_thickness = 2p
link_color     = red
label_snuggle        = yes
max_snuggle_distance = 0.01r
snuggle_sampling     = 1
snuggle_tolerance    = 0.50r
snuggle_link_overlap_test      = yes
snuggle_link_overlap_tolerance = 0.02p
snuggle_refine                 = yes
</plot>
</plots>
<<include etc/housekeeping.conf>>
data_out_of_range* = trim
\" > ${i}-p_circos/etc/circos.conf
echo \"
<highlights>
<highlight>
file  = data/highlights.1.txt
r1   = conf(.,r0)+0.03r
r0   = 0.800r
</highlight>
</highlights>
\" > ${i}-p_circos/etc/highlights.conf
echo \"
<ideogram>
<spacing>
default = 0.005r
break   = 0.001r
</spacing>
thickness        = 25p
stroke_thickness = 2
stroke_color     = black
fill             = yes
fill_color       = black
radius         = 0.85r
show_label     = yes
label_font     = default
label_radius   = dims(ideogram,radius) + 0.1r
label_size     = 16
label_parallel = yes
#label_case     = upper
band_stroke_thickness = 2
show_bands            = yes
fill_bands            = yes
</ideogram>
\" > ${i}-p_circos/etc/ideogram.conf
echo \"
show_ticks          = yes
show_tick_labels    = yes
<ticks>
radius               = dims(ideogram,radius_outer) + 10p
multiplier           = 1e-3
<tick>
spacing        = 100b
size           = 7p
thickness      = 1p
color          = grey
show_label     = no
label_size     = 16p
label_offset   = 0p
format         = %d
</tick>
<tick>
spacing        = 500b
size           = 10p
thickness      = 1p
color          = black
show_label     = no
label_size     = 16p
label_offset   = 0p
format         = %d
</tick>
<tick>
spacing        = 1000b
size           = 12p
thickness      = 2p
color          = black
show_label     = yes
suffix = \\\" kb\\\"
label_size     = 24p
label_offset   = 3p
format         = %d
</tick>
<tick>
spacing        = 5000b
size           = 14p
thickness      = 3p
color          = black
show_label     = yes
suffix = \\\" kb\\\"
label_size     = 24p
label_offset   = 3p
format         = %d
</tick>
</ticks>
\" > ${i}-p_circos/etc/ticks.conf
find . -name \"*\" -type f -size 0c | xargs -n 1 rm -f
/PATH/TO/circos-0.69-9/bin/circos -conf ./${i}-p_circos/etc/circos.conf
rm -rf ${i}-p_circos
mv circos.png ${i}-p_mt.png
mv circos.svg ${i}-p_mt.svg
" > run_${i}.sh
done
for j in $(cat list);do
bsub < run_${j}.sh
done
