#!/bin/bash -e

global_config_file=conf/global_settings.cfg
source $global_config_file

if test "$#" -ne 1; then
    echo "################################"
    echo "Usage:"
    echo "./03_train_duration_model.sh <path_to_duration_conf_file>"
    echo ""
    echo "Default path to duration conf file: conf/duration_${Voice}.conf"
    echo "################################"
    exit 1
fi

duration_conf_file=$1

### Step 3: train duration model ###
echo "Step 3:"
echo "training duration model..."
./scripts/${cuda_cmd} "experiments/slt_arctic_demo/duration_model/log/_train.log" "./scripts/submit.sh" "${MerlinDir}/src/run_merlin.py" "${duration_conf_file}"


