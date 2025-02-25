#!/bin/bash

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

# Set bash to 'debug' mode, it will exit on:
# -e 'error', -u 'undefined variable', -o 'error in pipeline'
set -euo pipefail

storage_dir=$1
librispeech_dir=$2
diar_dir=$3

fs=16k
fs_int=16000
num_spk="2 3"
min_max_mode="min max"

log "Data preparation started"

# Install dependencies (ignore failure if already installed)
pip install -q -r ./requirements.txt || true

# Download and Generate Libri2Mix and Libri3Mix
bash ./test_generate_librimix_sd.sh $storage_dir $librispeech_dir

# Get Diarization Annotation
rttm_dir=./metadata/LibriSpeech  # Fixed assignment

for i in $num_spk; do
    for mode in $min_max_mode; do
        python3 scripts/prepare_kaldifiles.py \
            --target_dir $diar_dir \
            --source_dir $storage_dir/Libri${i}Mix/wav${fs}/${mode}/metadata \
            --rttm_dir $rttm_dir \
            --fs $fs_int \
            --num_spk $i
    done
done
