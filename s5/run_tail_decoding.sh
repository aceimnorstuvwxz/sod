#!/bin/bash

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. ./path.sh

H=`pwd`  #exp home
n=8      #parallel jobs

#corpus and trans directory
#thchs=/nfs/public/materials/data/thchs30-openslr
thchs=/home/dgk/thchs30_ca

#you can obtain the database by uncommting the following lines
#[ -d $thchs ] || mkdir -p $thchs  || exit 1
#echo "downloading THCHS30 at $thchs ..."
#local/download_and_untar.sh $thchs  http://www.openslr.org/resources/18 data_thchs30  || exit 1
#local/download_and_untar.sh $thchs  http://www.openslr.org/resources/18 resource      || exit 1
#local/download_and_untar.sh $thchs  http://www.openslr.org/resources/18 test-noise    || exit 1



#train dnn model
local/nnet/run_dnn_only_test.sh --stage 0 --nj $n  exp/tri4b exp/tri4b_ali exp/tri4b_ali_cv || exit 1;  

#train dae model
#python2.6 or above is required for noisy data generation.
#To speed up the process, pyximport for python is recommeded.
#local/dae/run_dae.sh --stage 0  $thchs || exit 1;
