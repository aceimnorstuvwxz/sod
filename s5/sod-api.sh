#!/bin/bash



wavfn=$1 #absolute path of wav
wavid=$2 #unique id usually made with uuidgen 

logf=/home/dgk/sodwp/$wavid/log

rm -rf /home/dgk/sodwp/$wavid
mkdir /home/dgk/sodwp/$wavid
cp "$wavfn" /home/dgk/sodwp/$wavid/T0_1.wav
cp /home/dgk/sodwp/T0_1.wav.trn /home/dgk/sodwp/$wavid/T0_1.wav.trn
./sod.sh $wavid > $logf
cat ./exp/tri4b_dnn_mpe/decode_${wavid}_word_it3/result.ar

