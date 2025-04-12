# Merge recofiles

Code to hadd groups of recofiles and correct for map-corrections

## Suggested use

**First step**: compile map-correction:
```
cd map-correction

g++ cygno-analyzer/Analyzer.cxx ApplyMapCorrection.cxx -o correct.exe `root-config --libs --cflags` -lSpectrum

cd ..
```

N.B. to make the rest of the code compatible with your environment, remember to put the correction map in `map-correction/maps/map-final.root`

**Second step**: generate runlist:
```
python3 GenRunlist.py <run_start> <run_end> <run_cathegory>
```
The code will automatically filter out broken runs, runs with garbage description, and all the runs not belonging to the specified `run_cathegory`.

Available run cathegories are `data`, `ped`, `parking`, `step1`, `step2`, `step3`, `step4`, and `step5`.

**Third step**: download the reco files, apply map correction, remove redpix to save disk space, and hadd all the rootfiles.

```
sh CorrectAndMerge.sh <your_runlist>
```

The downloaded recofiles will be automatically deleted after usage.