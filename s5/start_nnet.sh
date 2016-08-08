../../../src/nnetbin/nnet-forward-daemon --no-softmax=true --prior-scale=1.0 --feature-transform=exp/tri4b_dnn_mpe/final.feature_transform  \
--class-frame-counts=exp/tri4b_dnn_mpe/prior_counts --use-gpu=yes exp/tri4b_dnn_mpe/3.nnet  \
'ark,s,cs:copy-feats scp:data/fbank/test001/split1/1/feats.scp ark:- | apply-cmvn --norm-means=true --norm-vars=false --utt2spk=ark:data/fbank/test001/split1/1/utt2spk scp:data/fbank/test001/split1/1/cmvn.scp ark:- ark:- |'  \
ark:exp/tri4b_dnn_mpe/decode_test001_word_it3/netout.1.ar 
