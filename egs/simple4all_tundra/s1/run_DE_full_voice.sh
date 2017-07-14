#!/bin/bash -e

source cmd.sh

if test "$#" -ne 0; then
    echo "Usage: ./run_DE_full_voice.sh"
    exit 1
fi

voice=DE_doriangray

### Step 1: setup directories and the training data files ###
./01_setup.sh ${voice}_full

### Step 2: prepare festival labels ###
./02_prepare_labels.sh database/wav database/txt database/labels

### Step 3: Extract acoustic features from audio files ###
./03_prepare_acoustic_features.sh database/wav database/feats

### Step 4: prepare config files for acoustic, duration models and for synthesis ###
./04_prepare_conf_files.sh conf/global_settings.cfg

### Step 5: train duration model ###
./05_train_duration_model.sh conf/duration_${voice}_full.conf

### Step 6: train acoustic model ###
./06_train_acoustic_model.sh conf/acoustic_${voice}_full.conf 

### Step 7: synthesize speech ###
./07_run_merlin.sh experiments/${voice}_full/test_synthesis/txt/ conf/test_dur_synth_${voice}_full.conf conf/test_synth_${voice}_full.conf 


