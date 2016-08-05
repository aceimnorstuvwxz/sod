#!/bin/bash
#Copyright 2016  Tsinghua University (Author: Dong Wang, Xuewei Zhang).  Apache 2.0.

#run from ../..
#DNN training, both xent and MPE


. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.

. ./path.sh ## Source the tools/utils (import the queue.pl)

stage=0
nj=1

. utils/parse_options.sh || exit 1;

gmmdir=$1
alidir=$2
alidir_cv=$3
wavid=$4

#generate fbanks
if [ $stage -le 0 ]; then
  echo "DNN training: stage 0: feature generation"
  cp -R data/$wavid data/fbank || exit 1;

    echo "producing fbank for $wavid"
    #fbank generation
    steps/make_fbank.sh --nj $nj --cmd "$train_cmd" data/fbank/$wavid exp/make_fbank/$wavid fbank/$wavid || exit 1
    #ompute cmvn
    steps/compute_cmvn_stats.sh data/fbank/$wavid exp/fbank_cmvn/$wavid fbank/$wavid || exit 1

  
fi

stage=3


#MPE training

srcdir=exp/tri4b_dnn
acwt=0.1


nj=1
if [ $stage -le 3 ]; then
  outdir=exp/tri4b_dnn_mpe
  #Re-train the DNN by 3 iteration of MPE
  #steps/nnet/train_mpe.sh --cmd "$cuda_cmd" --num-iters 3 --acwt $acwt --do-smbr false \
  #  data/fbank/train data/lang $srcdir ${srcdir}_ali ${srcdir}_denlats $outdir || exit 1
  #Decode (reuse HCLG graph)
  for ITER in 3; do
   (
    steps/nnet/decode_test.sh --nj $nj --cmd "$decode_cmd" --nnet $outdir/${ITER}.nnet --config conf/decode_dnn.config --acwt $acwt \
      $gmmdir/graph_word data/fbank/$wavid $outdir/decode_${wavid}_word_it${ITER} || exit 1;
   )
  done
fi

