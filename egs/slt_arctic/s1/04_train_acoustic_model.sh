#!/bin/bash -e

global_config_file=conf/global_settings.cfg
source $global_config_file

if test "$#" -ne 1; then
    echo "################################"
    echo "Usage:"
    echo "./04_train_acoustic_model.sh <path_to_acoustic_conf_file>"
    echo ""
    echo "Default path to acoustic conf file: conf/acoustic_${Voice}.conf"
    echo "################################"
    exit 1
fi

acoustic_conf_file=$1

### Step 4: train acoustic model ###
echo "Step 4:"
echo "training acoustic model..."
./scripts/${cuda_cmd} "experiments/slt_arctic_demo/acoustic_model/log/_train.log" "./scripts/submit.sh" "${MerlinDir}/src/run_merlin.py" "$acoustic_conf_file"


