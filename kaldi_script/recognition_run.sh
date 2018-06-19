#!/bin/bash

kaldi_root=$1
input_filename=$2  # kaldi data, wav.scp, segments, utt2spk, spk2utt for one recording
output_dir=$3  # output folder, time alignment store in output_dir/mono/$input_filename/ctm/ctm

n=1      #parallel jobs

cd "$(dirname "$0")"

export KALDI_ROOT=$kaldi_root

#exec 5> debug_output.txt
#BASH_XTRACEFD="5"

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. ./path.sh


#make  mfcc 
steps/make_mfcc.sh --nj $n --cmd "$train_cmd" $output_dir/data/$input_filename $output_dir/make_mfcc/$input_filename $output_dir/mfcc/$input_filename || exit 1;

#compute cmvn
steps/compute_cmvn_stats.sh $output_dir/data/$input_filename $output_dir/mfcc_cmvn/$input_filename $output_dir/mfcc/$input_filename || exit 1;

# decoding
steps/decode.sh --cmd "$decode_cmd" --nj $n exp/mono/graph_word $output_dir/data/$input_filename $output_dir/mono/$input_filename exp/mono || exit 1;

# get syllable time alignment
steps/get_ctm_fast.sh $output_dir/data/$input_filename data/graph/lang $output_dir/mono/$input_filename $output_dir/mono/$input_filename/ctm exp/mono || exit 1;
