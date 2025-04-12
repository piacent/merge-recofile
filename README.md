# Merge recofiles

Code to hadd groups of recofiles and correct for map-corrections

## Suggested use
The code is still under development. If you find any bug or solution to a bug, or if you have suggestions for improvements, please, open an issue or fork and submit a pull-request.

### First step: compilation of `map-correction` code
Usage:
```
cd map-correction

g++ cygno-analyzer/Analyzer.cxx ApplyMapCorrection.cxx -o correct.exe `root-config --libs --cflags` -lSpectrum

cd ..
```
**N.B. to make the rest of the code compatible with your environment, remember to put the correction map in `map-correction/maps/map-final.root`**. At least for now, the maps are not present in the [map-correction](https://github.com/piacent/map-correction) repository, but you can download them from the CYGNO [wiki page](https://github.com/CYGNUS-RD/WIKI-documentation/wiki/Analysis).

### Second step: generate `runlist` file
The `runlist` file will contain the list of all the recoruns to receive map correction and to be hadd-ed.

Usage:
```
python3 GenRunlist.py <run_start> <run_end> <run_cathegory>
```
The code will automatically filter out broken runs, runs with garbage description, and all the runs not belonging to the specified `run_cathegory`.

The available run cathegories are `data`, `ped`, `parking`, `step1`, `step2`, `step3`, `step4`, and `step5`.

### Third step: download the reco files, apply map correction, remove redpix to save disk space, and hadd all the rootfiles.
All of these tasks are done by the `CorrectAndMerge.sh` script.

Usage:
```
sh CorrectAndMerge.sh <your_runlist> <tag>
```
with `your_runlist` being the output file of `GenRunlist` (see Second step), while `tag` is the name of the subdirectory in the `cygno-analysis/RECO/` supposed to contain the recofiles(e.g. for RUN3 it's `Run3`). A few notes:
* It's mandatory this file to have a `.txt` extension and have a name starting with `runlist_`
* Be sure that the `cygno-analysis/RECO/<tag>/` position contains the runs

The downloaded recofiles will be automatically deleted after usage.