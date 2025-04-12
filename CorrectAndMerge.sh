#!/bin/bash
# Author: Stefano Piacentini
# Date: 2025-04-12
# Description: This script downloads, corrects, removes the redpix from, and merges reco_run files.
# Usage: sh CorrectAndMerge.sh <runlist_filename> <tag>

# Check if there are two arguments (runlist_filename and the tag)
if [ $# -ne 2 ]; then
  echo "Error. Usage: $0 \"runlist_filename\" \"tag\""
  exit 1
fi
string="$1"
tag="$2"

# Check if runlist_filename exists
if [ ! -f "$string" ]; then
  echo "Error. File $string not found."
  exit 1
fi

# Read file into an array (line by line)
runlist=(`cat $string`)

# Remove prefix and suffix from string
tmpstr="${string#runlist_}"
outfilename="${tmpstr%.txt}"
#echo "Output filename: $outfilename" # DEBUG

# Save into a variable the first run of the list
firstrun="${runlist[0]}"
# Loop through the array and print each element
for i in "${runlist[@]}"; do
    echo "Downloading RecoRun: $i"
    wget https://s3.cloud.infn.it/v1/AUTH_2ebf769785574195bde2ff418deac08a/cygno-analysis/RECO/${tag}/reco_run${i}_3D.root

    # Check if the download was successful, otherwise skip to the next iteration
    if [ ! -f "./reco_run${i}_3D.root" ]; then
        echo "Error downloading reco_run${i}_3D.root"
        if [ $i -ne $firstrun ]; then
            continue
        else
            echo "Error downloading the first run. Exiting."
            exit 1
        fi
    else
        echo "Correcting RecoRun: $i"
        cd map-correction
        # Run the correction script
        ./correct.exe ../reco_run${i}_3D.root maps/map-final.root ./reco_run${i}_3D_corrected.root

        # Remove the redpix from the corrected reco_run
        cd ..
        root -l './RemoveRedpix.C("map-correction/reco_run'${i}'_3D_corrected.root", "map-correction/reco_run'${i}'_3D_corrected_no_redpix.root")'
        rm "map-correction/reco_run${i}_3D_corrected.root"
        mv "map-correction/reco_run${i}_3D_corrected_no_redpix.root" "map-correction/reco_run${i}_3D_corrected.root"
    
        # Merge the corrected reco_run with the previous ones
        cd map-correction
        if [ $i -ne $firstrun ]; then
            mv ./${outfilename}.root ./${outfilename}_tmp.root
            hadd ./${outfilename}.root ./${outfilename}_tmp.root ./reco_run${i}_3D_corrected.root
            rm ./${outfilename}_tmp.root
            rm ./reco_run${i}_3D_corrected.root
        else
            mv ./reco_run${i}_3D_corrected.root ./${outfilename}.root
        fi

        # Remove the reco_run
        cd ..
        echo "Removing RecoRun: $i"
        rm ./reco_run${i}_3D.root
    fi
done

# Move the final merged and corrected file to the current directory
mv ./map-correction/${outfilename}.root ./${outfilename}_corrected.root