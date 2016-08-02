#!/bin/bash


#the refactored single decode tool
#single_test.sh xxx.wav 
#standard output is the result

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. ./path.sh

H=`pwd`  #exp home
n=8      #parallel jobs



#////////////Pareparing data//////////////////

#corpus and trans directory
#thchs=/nfs/public/materials/data/thchs30-openslr
thchs=/home/dgk/thchs30_ca


dir=$1
corpus_dir=$2


cd $dir

echo "creating data/{test}"
mkdir -p data/{test}

#create wav.scp, utt2spk.scp, spk2utt.scp, text
x=test
  echo "cleaning data/$x"
  cd $dir/data/$x
  rm -rf wav.scp utt2spk spk2utt word.txt phone.txt text
  echo "preparing scps and text in data/$x"
  for nn in `find  $corpus_dir/$x/*.wav | sort -u | xargs -i basename {} .wav`; do
      spkid=`echo $nn | awk -F"_" '{print "" $1}'`
      spk_char=`echo $spkid | sed 's/\([A-Z]\).*/\1/'`
      spk_num=`echo $spkid | sed 's/[A-Z]\([0-9]\)/\1/'`
      spkid=$(printf '%s%.2d' "$spk_char" "$spk_num")
      utt_num=`echo $nn | awk -F"_" '{print $2}'`
      uttid=$(printf '%s%.2d_%.3d' "$spk_char" "$spk_num" "$utt_num")
      echo $uttid $corpus_dir/$x/$nn.wav >> wav.scp
      echo $uttid $spkid >> utt2spk
      echo $uttid `sed -n 1p $corpus_dir/data/$nn.wav.trn` >> word.txt
      echo $uttid `sed -n 3p $corpus_dir/data/$nn.wav.trn` >> phone.txt
  done 
  cp word.txt text
  sort wav.scp -o wav.scp
  sort utt2spk -o utt2spk
  sort text -o text
  sort phone.txt -o phone.txt



#utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
#utils/utt2spk_to_spk2utt.pl data/dev/utt2spk > data/dev/spk2utt
utils/utt2spk_to_spk2utt.pl data/test/utt2spk > data/test/spk2utt

echo "creating test_phone for phone decoding"
(
  rm -rf data/test_phone && cp -R data/test data/test_phone  || exit 1
  cd data/test_phone && rm text &&  cp phone.txt text || exit 1
)





#data preparation 
#generate text, wav.scp, utt2pk, spk2utt
#local/thchs-30_data_prep_only_test.sh $H $thchs/data_thchs30 || exit 1;

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
#local/nnet/run_dnn_only_test.sh --stage 0 --nj $n  exp/tri4b exp/tri4b_ali exp/tri4b_ali_cv || exit 1;  



#///////////////////F-BANK////////////////////////

#fbank generation
steps/make_fbank.sh --nj $nj --cmd "$train_cmd" data/fbank/$x exp/make_fbank/$x fbank/$x || exit 1
#ompute cmvn
steps/compute_cmvn_stats.sh data/fbank/$x exp/fbank_cmvn/$x fbank/$x || exit 1

  
  echo "producing test_fbank_phone"
  cp data/fbank/test/feats.scp data/fbank/test_phone && cp data/fbank/test/cmvn.scp data/fbank/test_phone || exit 1;


#///////////////////Decoding/////////////////////

steps/nnet/decode.sh --nj $nj --cmd "$decode_cmd" --nnet $outdir/${ITER}.nnet --config conf/decode_dnn.config --acwt $acwt \
      $gmmdir/graph_word data/fbank/test $outdir/decode_test_word_it${ITER} || exit 1;
