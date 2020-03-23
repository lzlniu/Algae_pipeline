#!/bin/bash
#author:Zelin Li
#date:2020.03.23
#utility:make blast search and make circos graph.
#usage:bash blast_and_circos.sh scaffolds.fa
#output:
#1.scaffolds.fa_mt_blast.txt
#2.scaffolds.fa_mt_spp.txt
#3.scaffolds.fa_mt_spp.sel.txt
#4.scaffolds.fa_mt_spp.sel.info.txt
#5.scaffolds.fa_mt_scaf.fa
#6.scaffolds.fa_mt.svg
#7.scaffolds.fa_mt.png

scafs=$1
makeblastdb -in ${scafs} -dbtype nucl -parse_seqids -out ${scafs}.db
blastn -query ../../mt.fa -db ${scafs}.db -outfmt '6 qseqid qlen sseqid slen pident length mismatch gapopen gaps qstart qend sstart send evalue bitscore' -out ${scafs}_mt_blast.txt
rm -rf ${scafs}.db.*

#make blast search for mtDNA

#awk -F '\t' '\$5>=95' p_mt_blast.txt | awk -F '\t' '\$6>=2000' > p_mt_blast-pid95-len2000.txt
sort -t$'\t' -k 15rn,15 ${scafs}_mt_blast.txt | awk 'NR==1{print $1}' > ${scafs}.spp
grep $(cat ${scafs}.spp) ${scafs}_mt_blast.txt > ${scafs}_mt_spp.txt
rm -rf ${scafs}.spp

#extract the cloest mtDNA species(spp) blast results

uniq -f 2 -w 20 ${scafs}_mt_spp.txt > ${scafs}_mt_scaf.all
awk '{print $4}' ${scafs}_mt_scaf.all > ${scafs}.scaflen
awk '{print $3}' ${scafs}_mt_scaf.all  > ${scafs}.scafname
grep -n "" ${scafs}_mt_scaf.all | awk -F ':' '{print $1}' > ${scafs}.scafline
rm -rf ${scafs}_mt_scaf.all
sed -n 1p ${scafs}.scafname > ${scafs}.scafname.sel
for line1 in $(cat ${scafs}.scafline); do
        ((line2=$line1+1))
        linemax=`echo $(awk END'{print $1}' ${scafs}.scafline)`;
        if ((line2 > linemax)); then
                let line2=line2-1
        fi
        #n=`echo $(sed -n ${line1}p ${scafs}.scaflen) | awk NR==1'{print $1}'`;
        n=`echo $(awk NR==1'{print $1}' ${scafs}.scaflen)`;
        m=`echo $(sed -n ${line2}p ${scafs}.scaflen) | awk NR==1'{print $1}'`;
        if ((m >= n)) || ((m < 1000)); then
                break
        else
                sed -n ${line2}p scafname >> ${scafs}.scafname.sel
        fi
done
rm -rf ${scafs}.scaflen
rm -rf ${scafs}.scafline
rm -rf ${scafs}.scafname
for scafnamesel in $(cat ${scafs}.scafname.sel); do
        grep ${scafnamesel} ${scafs}_mt_spp.txt >> ${scafs}_mt_spp.sel.txt
done

#select the mtDNA scaffolds from cloest mtDNA spp blast results

awk NR==1'{print "closest diatom species:"$1}' ${scafs}_mt_spp.sel.txt > ${scafs}_mt_spp.sel.info.txt
awk NR==1'{print "closest diatom species mtDNA length:"$2}' ${scafs}_mt_spp.sel.txt >> ${scafs}_mt_spp.sel.info.txt
uniq -f 2 -w 20 ${scafs}_mt_spp.sel.txt | wc -l | awk '{print "number of mtDNA scaffolds:"$1}' >> ${scafs}_mt_spp.sel.info.txt
uniq -f 2 -w 20 ${scafs}_mt_spp.sel.txt | awk '{sum += $4};END {print "sum of mtDNA scaffolds length:"sum}' >> ${scafs}_mt_spp.sel.info.txt

#collect the information about the mtDNA scaffolds

awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n }' ${scafs}  > ${scafs}_oneline_scaf.fa
for name in $(cat ${scafs}.scafname.sel);do
        grep -n ${name} ${scafs}_oneline_scaf.fa | awk -F ':' '{print $1}' >> ${scafs}.scafloc
done
for loc in $(cat ${scafs}.scafloc);do
        sed -n "${loc},$((${loc}+1))p" ${scafs}_oneline_scaf.fa >> ${scafs}_mt_scaf.fa
done
rm -rf ${scafs}.scafloc
rm -rf ${scafs}_oneline_scaf.fa

#extract the mtDNA scaffolds sequences from scaffolds.fa

mkdir ${scafs}_circos
cd ${scafs}_circos
mkdir data
mkdir etc
cd ..
#grep \$(awk 'NR==1{print \$3}' p_mt_spp.txt) p_mt_spp.txt | sort -t\$'\t' -k 10n,10 > p_mt_sppA.txt
chrcolor=1
for scafnamesel2 in $(cat ${scafs}.scafname.sel); do
        grep ${scafnamesel2} ${scafs}_mt_spp.sel.txt | sort -t$'\t' -k 10n,10 > ${scafs}_mt_spp.${scafnamesel2}.txt
        awk '{print "chr1\t"$10"\t"$11"\tfill_color=chr'"$chrcolor"'"}' ${scafs}_mt_spp.${scafnamesel2}.txt >> ${scafs}_circos/data/highlights.1.txt
        awk '{print "chr1\t"$10"\t"$11"\t"$5}' ${scafs}_mt_spp.${scafnamesel2}.txt >> ${scafs}_circos/data/labels.1.txt
        let chrcolor=chrcolor+1
        rm -rf ${scafs}_mt_spp.${scafnamesel2}.txt
done
#awk '{print "chr1\t"$10"\t"$11"\tfill_color=green"}' ${scafs}_mt_sppA.txt > ${scafs}_circos/data/highlights.1.txt
#awk '{print "chr1\t"$10"\t"$11"\t"$5}' ${scafs}_mt_sppA.txt > ${scafs}_circos/data/labels.1.txt
awk 'NR==1{print "chr\t-\tchr1\t"$1".mtDNA.circos.by.Zelin.Li\t0\t"$2"\tchry"}' ${scafs}_mt_spp.txt > ${scafs}_circos/data/mtDNAideogram.txt
#rm -rf p_mt_sppA.txt
rm -rf ${scafs}.scafname.sel

#prepare the circos data (.txt)

echo "
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
" > ${scafs}_circos/etc/circos.conf
echo "
<highlights>
<highlight>
file  = data/highlights.1.txt
r1   = conf(.,r0)+0.03r
r0   = 0.800r
</highlight>
</highlights>
" > ${scafs}_circos/etc/highlights.conf
echo "
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
" > ${scafs}_circos/etc/ideogram.conf
echo "
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
suffix = \" kb\"
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
suffix = \" kb\"
label_size     = 24p
label_offset   = 3p
format         = %d
</tick>
</ticks>
" > ${scafs}_circos/etc/ticks.conf

#prepare the circos config (.conf)

find . -name "*" -type f -size 0c | xargs -n 1 rm -f
circos -conf ./${scafs}_circos/etc/circos.conf
rm -rf ${scafs}_circos
mv circos.png ${scafs}_mt.png
mv circos.svg ${scafs}_mt.svg

#draw circos graph (.png and .svg)
