#!/bin/bash
#author:lizelin
#date:2020/03/03
#utility:extract the amino acids sequence from the .gb file.
#use like:gbaa.sh sequence.gb (this will generate a file call protseqs.fa which contain amino acids sequence of each CDS from this .gb file)
gbfile=$1
sed -e '/\/translation=\"/,/\"/!d' $gbfile | sed -e '/  gene  /,/\/gene=\".*\"/d' | sed -e 's/ //g' | sed -e 's/\//\n/g' | sed -e 's/translation="/>\n/g' | sed -e 's/\"//g' | awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n }' | sed -e '1d' > protseqs.fa
grep -n ">" protseqs.fa | awk -F ':' '{print $1}' > protnamelines
sed -e '/  CDS  /,/\/gene=\".*\"/!d' $gbfile | grep "/gene=" | sed -e 's/.*\/gene=//g' | sed -e 's/\"//g' > protnames
k=1
for protnameline in $(cat protnamelines); do
	sed -n "$k"p protnames > protname
	sed -i "${protnameline},${protnameline}c >$(cat protname)" protseqs.fa
	let k=k+1
done
rm -rf protname
rm -rf protnames
rm -rf protnamelines
