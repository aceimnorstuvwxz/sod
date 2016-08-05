#!/bin/bash

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. ./path.sh

H=`pwd`  #exp home
n=1      #parallel jobs


#index by $1 which is a uuidgen
#the target wav is store there, the name always be S0_0.wav and S0_0.wav.trn
#working path is /home/dgk/sodwp
#the useless copy source of .trn is /home/dkg/sodwp/S0_0.wav.trn


wavid=$1

#corpus and trans directory
#thchs=/nfs/public/materials/data/thchs30-openslr
thchs=/home/dgk/thchs30_ca
wavdir=/home/dgk/sodwp/$wavid



#you can obtain the database by uncommting the following lines
#[ -d $thchs ] || mkdir -p $thchs  || exit 1
#echo "downloading THCHS30 at $thchs ..."
#local/download_and_untar.sh $thchs  http://www.openslr.org/resources/18 data_thchs30  || exit 1
#local/download_and_untar.sh $thchs  http://www.openslr.org/resources/18 resource      || exit 1
#local/download_and_untar.sh $thchs  http://www.openslr.org/resources/18 test-noise    || exit 1

#data preparation 
#generate text, wav.scp, utt2pk, spk2utt
cp /home/dgk/sodwp/S0_0.wav.trn /home/dgk/sodwp/$wavid/
local/sod_data_prep.sh $H $wavdir $wavid || exit 1;

#produce MFCC features 
 cp -R data/$wavid data/mfcc || exit 1;
# for x in test; do
   #make  mfcc 
   steps/make_mfcc.sh --nj $n --cmd "$train_cmd" data/mfcc/$wavid exp/make_mfcc/$wavid mfcc/$wavid || exit 1;
   #compute cmvn
   steps/compute_cmvn_stats.sh data/mfcc/$wavid exp/mfcc_cmvn/$wavid mfcc/$wavid || exit 1;
# done
#copy feats and cmvn to test.ph, avoid duplicated mfcc & cmvn 
# cp data/mfcc/test/feats.scp data/mfcc/test_phone && cp data/mfcc/test/cmvn.scp data/mfcc/test_phone || exit 1;


#train dnn model
local/nnet/run_dnn_sod.sh --stage 0 --nj $n  exp/tri4b exp/tri4b_ali exp/tri4b_ali_cv $wavid || exit 1;  

#train dae model
#python2.6 or above is required for noisy data generation.
#To speed up the process, pyximport for python is recommeded.
#local/dae/run_dae.sh --stage 0  $thchs || exit 1;
