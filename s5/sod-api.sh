#!/bin/bash



wavfn=$1 #absolute path of wav
wavid=$2 #unique id usually made with uuidgen 

logf=/home/dgk/sodwp/$wavid/log

rm -rf /home/dgk/sodwp/$wavid
mkdir /home/dgk/sodwp/$wavid
cp "$wavfn" /home/dgk/sodwp/$wavid/T0_1.wav
cp /home/dgk/sodwp/T0_1.wav.trn /home/dgk/sodwp/$wavid/T0_1.wav.trn
time ./sod.sh $wavid > $logf
pa=` pwd `
cd /home/dgk/dgkfiles/kaldi-lattice-userdict
time ./routine_lka.py $pa/exp/tri4b_dnn_mpe/decode_${wavid}_word_it3/lat.txt $pa/exp/tri4b_dnn_mpe/decode_${wavid}_word_it3/lat2.txt
source /home/dgk/enable_kaldi_tools.sh
time lattice-1best --acoustic-scale=0.1 ark:$pa/exp/tri4b_dnn_mpe/decode_${wavid}_word_it3/lat2.txt ark,t:$pa/exp/tri4b_dnn_mpe/decode_${wavid}_word_it3/1best.txt
time ./routine_tpm.py $pa/exp/tri4b_dnn_mpe/decode_${wavid}_word_it3/1best.txt $pa/exp/tri4b_dnn_mpe/decode_${wavid}_word_it3/result.txt


cat $pa/exp/tri4b_dnn_mpe/decode_${wavid}_word_it3/result.txt
echo " "
cat $pa/exp/tri4b_dnn_mpe/decode_${wavid}_word_it3/result.ar 


