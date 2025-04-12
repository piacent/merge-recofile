# Author: Stefano Piacentini
# Date: 2025-04-12
# Description: This script generates a list of runs from the logbook in a given
#              run_number range and of a given cathegory.
#
# Usage: python3 GenRunlist.py <run_start> <run_end> <run_cathegory>
#

import numpy as np
import pandas as pd
import cygno as cy
import argparse


def main(run_start, run_end, run_cathegory = 'data'):

    # Read the logbook
    dflog = cy.read_cygno_logbook(tag = "LNGS", start_run = run_start, end_run = run_end)

    runlist = np.array([])

    for r in range(run_start, run_end+1):
        dfinfo = dflog[dflog["run_number"]==r].copy()
        if len(dfinfo) == 0:
            #print("run", r, "skipped because not in the logbook.")
            continue
        # if np.isnat(dfinfo['stop_time'].to_numpy()):
        #     #print("run", r, "skipped because of no stop_time.")
        #     continue
        if isinstance(dfinfo["stop_time"].values[0], float):
            if math.isnan(dfinfo["stop_time"].values[0]):
                continue
        if "garbage" in dfinfo["run_description"].values[0]:
            #print("run", r, "skipped because garbage.")
            continue
        if "Garbage" in dfinfo["run_description"].values[0]:
            #print("run", r, "skipped because Garbage.")
            continue
        if dfinfo['pedestal_run'].values[0]==1 and run_cathegory == 'ped':
            runlist = np.append(runlist, r)
        elif dfinfo['pedestal_run'].values[0]==0 and "parking" in dfinfo["run_description"].values[0] and run_cathegory == 'parking':
            runlist = np.append(runlist, r)
        elif dfinfo['pedestal_run'].values[0]==0 and dfinfo["source_position"].values[0]==3.5 and run_cathegory == 'step1':
            runlist   = np.append(runlist, r)
        elif dfinfo['pedestal_run'].values[0]==0 and dfinfo["source_position"].values[0]==10.5 and run_cathegory == 'step2':
            runlist   = np.append(runlist, r)
        elif dfinfo['pedestal_run'].values[0]==0 and dfinfo["source_position"].values[0]==17.5 and run_cathegory == 'step3':
            runlist   = np.append(runlist, r)
        elif dfinfo['pedestal_run'].values[0]==0 and dfinfo["source_position"].values[0]==24.5 and run_cathegory == 'step4':
            runlist   = np.append(runlist, r)
        elif dfinfo['pedestal_run'].values[0]==0 and dfinfo["source_position"].values[0]==32.5 and run_cathegory == 'step5':
            runlist   = np.append(runlist, r)
        elif dfinfo['pedestal_run'].values[0]==0 and dfinfo["source_type"].values[0]==0 and run_cathegory == 'data':
            runlist    = np.append(runlist, r)
        else:
            #print("run", r, " of unknown type.")
            continue
        
        np.savetxt("runlist_"+run_cathegory+"_"+str(run_start)+"_"+str(run_end)+".txt", runlist, fmt='%d')


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="This script generates a list of runs from the logbook in a given run_number range and of a given cathegory.")
    parser.add_argument("run_start", help="First run of the range", type=int)
    parser.add_argument("run_end", help="Last run of the range", type=int)
    parser.add_argument("run_cathegory", help="Cathegory of the run", type=str)
  
    options = parser.parse_args()
    
    known_cathegories = ['data', 'ped', 'parking', 'step1', 'step2', 'step3', 'step4', 'step5']
    if options.run_cathegory not in known_cathegories:
        print("Unknown cathegory. Known cathegories are: ", known_cathegories)
        exit()


    main(options.run_start, options.run_end, options.run_cathegory)


