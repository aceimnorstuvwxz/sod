../../../src/bin/latgen-faster-mapped-daemon  --min-active=200 --max-active=7000 --max-mem=50000000 --beam=5.0  \
   --lattice-beam=10.0 --acoustic-scale=0.1 --allow-partial=true --word-symbol-table=exp/tri4b/graph_word/words.txt   \
     exp/tri4b_dnn_mpe/final.mdl exp/tri4b/graph_word/HCLG.fst \
      "ark:|gzip -c > exp/tri4b_dnn_mpe/decode_test001_word_it2/lat.JOB.gz" "sdfsdf"
