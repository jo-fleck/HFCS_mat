### Converting HFCS files to .mat files

These Matlab scripts load the wave 1 and 2 .csv (ASCII) files of the HFCS user database into Matlab and save them as .mat files, separately for each implicate, country and H, P, D dataset.

The scripts have been written for machines with limited RAM; they only load slices of the full datasets into the Matlab workspace at a time. This approach makes the procedure slow but robust to hardware restrictions (I ran them on a machine with 4 GB of RAM).