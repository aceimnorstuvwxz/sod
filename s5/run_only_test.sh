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

#data preparation 
#generate text, wav.scp, utt2pk, spk2utt
local/thchs-30_data_prep_only_test.sh $H $thchs/data_thchs30 || exit 1;

#produce MFCC features 
rm -rf data/mfcc/test && rm -rf data/mfcc/test_phone &&  cp -R data/{test,test_phone} data/mfcc || exit 1;
for x in test; do
   #make  mfcc 
   steps/make_mfcc.sh --nj $n --cmd "$train_cmd" data/mfcc/$x exp/make_mfcc/$x mfcc/$x || exit 1;
   #compute cmvn
   steps/compute_cmvn_stats.sh data/mfcc/$x exp/mfcc_cmvn/$x mfcc/$x || exit 1;
done
#copy feats and cmvn to test.ph, avoid duplicated mfcc & cmvn 
cp data/mfcc/test/feats.scp data/mfcc/test_phone && cp data/mfcc/test/cmvn.scp data/mfcc/test_phone || exit 1;


#train dnn model
local/nnet/run_dnn_only_test.sh --stage 0 --nj $n  exp/tri4b exp/tri4b_ali exp/tri4b_ali_cv || exit 1;  

#train dae model
#python2.6 or above is required for noisy data generation.
#To speed up the process, pyximport for python is recommeded.
#local/dae/run_dae.sh --stage 0  $thchs || exit 1;
