// Author: Stefano Piacentini
// Date: 2025-04-12
// Usage: root -l 'RemoveRedpix.C("reco_run59281_3D.root", "reco_run59281_3D_no_redpix.root")'

void RemoveRedpix(std::string filename, std::string outfilename) {

    // Load the objects in the root file
    TFile oldfile(filename.c_str());
    TTree *oldtree;
    oldfile.GetObject("Events;1", oldtree);
    TTree *reco_par;
    oldfile.GetObject("Reco_params;1", reco_par);
    TNamed *gitH;
    oldfile.GetObject("gitHash;1", gitH);
    TNamed *tot_time;
    oldfile.GetObject("total_time;1", tot_time);

    // Deactivate all branches
    oldtree->SetBranchStatus("redpix_ix", 0);
    oldtree->SetBranchStatus("redpix_iy", 0);
    oldtree->SetBranchStatus("redpix_iz", 0);

    // Create a new file + a clone of old tree in new file
    TFile newfile(outfilename.c_str(), "recreate");
    auto newtree     = oldtree ->CloneTree(-1, "fast");
    auto newtreepars = reco_par->CloneTree(-1, "fast");
    auto newgitH     = (TNamed*)gitH    ->Clone("gitHash");
    auto newtot_time = (TNamed*)tot_time->Clone("total_time");

    newfile.WriteObject(newtree, "Events");
    newfile.WriteObject(newtreepars, "Reco_params");
    newfile.WriteObject(newgitH, "gitHash");
    newfile.WriteObject(newtot_time, "total_time");

    // Exit from root
    gApplication->Terminate(0);
}