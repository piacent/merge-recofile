#!/bin/bash

# Verifica che sia stato passato un argomento
if [ $# -ne 1 ]; then
  echo "Error. Usage: $0 \"runlist_filename\""
  exit 1
fi

string="$1"
# Verifica che il file esista
if [ ! -f "$string" ]; then
  echo "Error. File $string not found."
  exit 1
fi

# Read file into an array (line by line)
runlist=(`cat $string`)
tag='Run4'

# Remove prefix and suffix from string
tmpstr="${string#runlist_}"
outfilename="${tmpstr%.txt}"
#echo "Output filename: $outfilename" # DEBUG

firstrun="${runlist[0]}"
# Loop through the array and print each element
for i in "${runlist[@]}"; do
    echo "Downloading RecoRun: $i"
    wget https://s3.cloud.infn.it/v1/AUTH_2ebf769785574195bde2ff418deac08a/cygno-analysis/RECO/${tag}/reco_run${i}_3D.root
    
    echo "Correcting RecoRun: $i"

    cd map-correction
    # Run the correction script
    ./correct.exe ../reco_run${i}_3D.root maps/map-final.root ./reco_run${i}_3D_corrected.root

    cd ..
    root -l './RemoveRedpix.C("map-correction/reco_run'${i}'_3D_corrected.root", "map-correction/reco_run'${i}'_3D_corrected_no_redpix.root")'
    rm "map-correction/reco_run${i}_3D_corrected.root"
    mv "map-correction/reco_run${i}_3D_corrected_no_redpix.root" "map-correction/reco_run${i}_3D_corrected.root"
    
    cd map-correction
    if [ $i -ne $firstrun ]; then
        mv ./${outfilename}.root ./${outfilename}_tmp.root
        hadd ./${outfilename}.root ./${outfilename}_tmp.root ./reco_run${i}_3D_corrected.root
        rm ./${outfilename}_tmp.root
        rm ./reco_run${i}_3D_corrected.root
    else
        mv ./reco_run${i}_3D_corrected.root ./${outfilename}.root
    fi

    cd ..


    echo "Removing RecoRun: $i"
    rm ./reco_run${i}_3D.root
done

mv ./map-correction/${outfilename}.root ./${outfilename}_corrected.root