#!/bin/bash

if test "$#" -ne 1; then
    echo "################################"
    echo "Usage:"
    echo "./01_setup.sh <voice_name>"
    echo ""
    echo "<voice_name>: DE_doriangray_demo or DE_doriangray_full"
    echo "################################"
    exit 1
fi

if [ ! -d "${TUNDRA_DB}" ]; then
    echo "ERROR: Variable TUNDRA_DB must be set to the roger database."
    echo "       Use: export TUNDRA_DB=path/to/db/"
    # export TUNDRA_DB=/idiap/temp/bschnell/databases/tundra/
    exit 1
fi

IFS='_' read -ra voice_param <<< "$1"
corpus="${TUNDRA_DB}/${voice_param[0]}_${voice_param[1]}/" # Select another corpus here, but frontend must match the language.
export FRONTEND_DIR=/idiap/user/bschnell/tts_frontend/German/ # Frontend must match the language of the corpus. This variable is written to global_settings.cfg.
echo "Corpus is ${corpus}"
echo "frontend is ${FRONTEND_DIR}"

if [ "${voice_param[2]}" = "demo" ]; then
    corpus_select_rgx="*_01_*" # Use only chapter one for all demos.
else
    corpus_select_rgx="*" # Use all other chapters here.
fi


### Step 1: setup directories and the training data files ###
echo "Step 1:"

current_working_dir=$(pwd)
merlin_dir=$(dirname $(dirname $(dirname $current_working_dir)))
experiments_dir=${current_working_dir}/experiments
data_dir=${current_working_dir}/database

voice_name=$1
voice_dir=${experiments_dir}/${voice_name}

acoustic_dir=${voice_dir}/acoustic_model
duration_dir=${voice_dir}/duration_model
synthesis_dir=${voice_dir}/test_synthesis

mkdir -p ${data_dir}
mkdir -p ${experiments_dir}
mkdir -p ${voice_dir}
mkdir -p ${acoustic_dir}
mkdir -p ${duration_dir}
mkdir -p ${synthesis_dir}
mkdir -p ${acoustic_dir}/data
mkdir -p ${duration_dir}/data
mkdir -p ${synthesis_dir}/txt


audio_dir=database/wav
txt_dir=database/txt
label_dir=database/labels

# Collect utterances ids of necessary audio files.
utts=($(find "${corpus}"/train/txtWithPunctuation/${corpus_select_rgx}.txt -exec basename {} .txt \;))
# Remove duplicates.
utts=($(printf "%s\n" "${utts[@]}" | sort -u))

# Audios have to be removed because demo/full could have been changed.
rm -rf $audio_dir
# Leave this check for fast testing, when $audio_dir does not have to be removed.
if [ ! -e $audio_dir ]; then
    mkdir -p $audio_dir
    # Collect necessary audio files.
    for utt in "${utts[@]}"; do
        # cp $ROGER_DB/wav/${utt:0:7}/${utt}.wav $audio_dir/${utt}.wav
        ln -sf "${corpus}"/train/wav/${utt}.wav $audio_dir/${utt}.wav
    done
fi

# Get labels.
rm -rf $txt_dir
if [ ! -e $txt_dir ]; then
    mkdir -p $txt_dir
    for filename in "${corpus}"/train/txtWithPunctuation/${corpus_select_rgx}.txt; do
        # This prints the file name followed by the file content.
        # echo $(basename "${filename}")' \t '$(cat "${filename}")
        printf '%s\t%s\n' "$(basename "${filename}")" "$(cat "${filename}")"
    done >| ${txt_dir}/utts.data
fi
# Turn every line of utts.data into a txt file using the utterance id as file name.
awk -F ' |\t' -v outDir=${txt_dir} '{print substr($0,length($1)+2,length($0)) > outDir"/"$1""}' ${txt_dir}/utts.data
# Do not remove utts.data here because it is used by the Idiap frontend.
# rm ${txt_dir}/utts.data

rm -rf $label_dir

### create some test files ###
echo "Hello world." > ${synthesis_dir}/txt/test_001.txt
echo "Hi, this is a demo voice from Merlin." > ${synthesis_dir}/txt/test_002.txt
echo "Hope you guys enjoy free open-source voices from Merlin." > ${synthesis_dir}/txt/test_003.txt
printf "test_001\ntest_002\ntest_003" > ${synthesis_dir}/test_id_list.scp

global_config_file=conf/global_settings.cfg

### default settings ###
echo "######################################" > $global_config_file
echo "############# PATHS ##################" >> $global_config_file
echo "######################################" >> $global_config_file
echo "" >> $global_config_file

echo "MerlinDir=${merlin_dir}" >>  $global_config_file
echo "WorkDir=${current_working_dir}" >>  $global_config_file
echo "" >> $global_config_file

echo "######################################" >> $global_config_file
echo "############# PARAMS #################" >> $global_config_file
echo "######################################" >> $global_config_file
echo "" >> $global_config_file

echo "Voice=${voice_name}" >> $global_config_file
echo "Labels=state_align" >> $global_config_file
echo "QuestionFile=questions-radio_dnn_416.hed" >> $global_config_file
echo "Vocoder=WORLD" >> $global_config_file
echo "SamplingFreq=16000" >> $global_config_file
echo "SilencePhone='sil'" >> $global_config_file
echo "FileIDList=file_id_list.scp" >> $global_config_file
echo "" >> $global_config_file

echo "######################################" >> $global_config_file
echo "######### No. of files ###############" >> $global_config_file
echo "######################################" >> $global_config_file
echo "" >> $global_config_file

num_files=$(ls -1 $audio_dir | wc -l)
num_dev_set=$(awk "BEGIN { pc=${num_files}*0.05; print(int(pc)) }")
num_train_set=$(($num_files-2*$num_dev_set))
echo "Train=$num_train_set" >> $global_config_file 
echo "Valid=$num_dev_set" >> $global_config_file 
echo "Test=$num_dev_set" >> $global_config_file 
echo "" >> $global_config_file

echo "######################################" >> $global_config_file
echo "############# TOOLS ##################" >> $global_config_file
echo "######################################" >> $global_config_file
echo "" >> $global_config_file

echo "ESTDIR=${merlin_dir}/tools/speech_tools" >> $global_config_file
echo "FESTDIR=${merlin_dir}/tools/festival" >> $global_config_file
echo "FESTVOXDIR=${merlin_dir}/tools/festvox" >> $global_config_file
echo "" >> $global_config_file
echo "HTKDIR=${merlin_dir}/tools/bin/htk" >> $global_config_file
echo "" >> $global_config_file
echo "FRONTEND_DIR=${FRONTEND_DIR}" >> $global_config_file

echo "Merlin default voice settings configured in \"$global_config_file\""
echo "Modify these params as per your data..."
echo "eg., sampling frequency, no. of train files etc.,"
echo "setup done...!"

