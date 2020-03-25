#!/bin/bash
#author:Zelin Li
#date:2020/03/25
#usage:bash assembly+_prerequisites_install.sh hpcloginname(for example:lizelin)
#noted that this shell script only can be used in IOCAS-Marine Ecological and Environmental Genomics Lab.

yourname=$1
cd
mkdir assembly
cd assembly
cp /public/sharefolder/chennansheng/lzl_data/software/abyss-*.*.*.tar.gz ./
#or wget https://github.com/bcgsc/abyss/releases/download/2.2.4/abyss-2.2.4.tar.gz
tar -zxvf abyss-*.*.*.tar.gz
cd abyss*
./configure --prefix=/public/home/${yourname}/assembly/abyss --with-boost=/usr/include/boost --with-mpi=/public/software/mpi/openmpi/intel2019/4.0.0 --with-sparsehash=/public/sharefolder/chennansheng/lzl_data/software/sparsehash --with-sqlite=/bin/sqlite3 --enable-maxk=160
make AM_CXXFLAGS=-Wall
make install
cd ..
rm -rf abyss-*.*.*
#get abyss(https://github.com/bcgsc/abyss/releases)

cp /public/sharefolder/chennansheng/lzl_data/software/Platanus_allee_v*.*.*_Linux_x86_64.tgz ./
#can't wget, you have to download it from http://platanus.bio.titech.ac.jp/platanus2 
tar -zxvf Platanus_allee_v*.*.*_Linux_x86_64.tgz
mv Platanus_allee_v*.*.*_Linux_x86_64 platanus
rm -rf Platanus_allee_v*.*.*_Linux_x86_64.tgz
#get platanus(http://platanus.bio.titech.ac.jp/platanus2)

cp /public/sharefolder/chennansheng/lzl_data/software/SPAdes-*.*.*-Linux.tar.gz ./
#or wget http://cab.spbu.ru/files/release3.14.0/SPAdes-3.14.0-Linux.tar.gz
tar -zxvf SPAdes-*.*.*-Linux.tar.gz
mv SPAdes-*.*.*-Linux spades
rm -rf SPAdes-*.*.*-Linux.tar.gz
#get spades(http://cab.spbu.ru/software/spades/)

cp /public/sharefolder/chennansheng/lzl_data/software/circos-*.tgz ./
#or wget http://circos.ca/distribution/circos-current.tgz
tar -zxvf circos-*.tgz
rm -rf circos-*.tgz
#get circos(http://circos.ca/software/download/)

#下面是按照circos必备perl模块的步骤：
#cd circos-*/bin
#./circos -module
#根据显示缺失的模块补充安装。或者按照下面内容查看缺失的模块也可以：
#./circos -help
#出现很多error，每个error上一句是missing XXXX（比如Font::TTF::Font、Clone、Config::General、Math::Round等等）。根据./circos -module、./circos -help发现缺失的module，使用cpan安装perl module：
#cd
#cpan
#yes
#yes
#install Font::TTF::Font
#install Config::General
#install Math::Bezier
#install Math::Round
#install SVG
#install Readonly
#install Math::VecStat
#install Set::IntSpan
#install Statistics::Basic
#install Regexp::Common
#install Text::Format
#install List::MoreUtils::XS
#install Exporter::Tiny
#install ExtUtils::PkgConfig
#install Clone
#exit
#使用perldoc perllocal可以查看perl module的安装情况。进入cd circos-*/bin然后./circos -module查看是否所有circos需要的perl module都安装完毕。

cd
echo "source /public/software/profile.d/apps_ncbi-blast-2.10.0+.sh
export PATH=/public/home/${yourname}/assembly/abyss/bin:\$PATH
export PATH=/public/home/${yourname}/assembly/platanus:\$PATH
export PATH=/public/home/${yourname}/assembly/spades/bin:\$PATH
export PATH=/public/home/${yourname}/assembly/circos-0.69-9/bin:\$PATH
" > addtobashrc
mv .bashrc origbashrc
cat origbashrc addtobashrc > .bashrc
rm -rf addtobashrc
#rm -rf origbashrc
source .bashrc
#forming environmental variables configuration to '.bashrc'
