# Introduction

This repository is for the EEGLAB sessions of the [practical MEEG 2022 workshop](https://practicalmeeg2022.org/). There are 5 sessions:
* Preprocessing
* Single sensor analysis (ERP/ERF)
* Single and distributed sources
* Time-frequency domain
* Group-level analysis

For each session, we have prepared a script detailed below.

# Data

We will use data from the multimodal face recognition dat. BIDS dataset containing a pruned version of the OpenNeuro dataset ds000117. It is available [here](https://zenodo.org/record/7410278).

The dataset above only contains one subject. For group level analysis, please use the following BIDS repository [here](https://openneuro.org/datasets/ds002718/versions/1.0.5).

# Preprocessing

For this presentation, we will first import the data with the [PracticalMEEG_Import_Data_Session_1.m](PracticalMEEG_Import_Data_Session_1.m) script. This script has 11 steps. 

* Step 1: Importing MEG data files with FileIO
* Step 2: Adding fiducials and rotating montage
* Step 3: Recomputing head center (for display only)
* Step 4: Re-import events from STI101 channel (the original ones are incorect)
* Step 5: Selecting EEG or MEG data 
* Step 6: Cleaning artefactual events (keep only valid event codes)
* Step 7: Fix button press info
* Step 8: Renaming button press events
* Step 9: Correcting event latencies (events have a shift of 34 ms as per the authors)
* Step 10: Replacing original imported channels
* Step 11: Creating folder to save data if does not exist yet

After importing the data, it is preprocessed using the [PracticalMEEG_Preprocess_Data_Session_1.m](PracticalMEEG_Preprocess_Data_Session_1.m) script. This script itself has several steps.

* Re-Reference the data
* Resampling the data (for speed)
* Filter the data
* Automatic rejection of bad channels
* Re-Reference again
* Repair bursts and reject bad portions of data
* run ICA to detect brain and artifactual components
* automatically classify Independent Components using IC Label
* Save dataset

# Single sensor analysis (ERP/ERF)

For this presentation, we will use different vizualization techniques using the [PracticalMEEG_ERP_Analysis_Session_2.m](PracticalMEEG_ERP_Analysis_Session_2.m) script. The script first further process the data as follow.

* Extract data epochs for the famous, scrambled, and unfamiliar face stimuli
* Remove the baseline from -1000 ms to 0 pre-stimulus
* Apply a threshold methods to remove spurious epochs
* Resave the data

Then it plots the data using the following methods:

* Plot ERP butterfly plot and scalp distribution at different latencies
* Plot ICA component contribution to the ERP
* Remove ICA artifactual components and replot
* Plot series of scalp topography at different latencies
* Plot conditions overlaid on each other
* Plot ERPimages

# Single and distributed sources

For this presentation, we will the script [PracticalMEEG_Source_Reconstruction_Session_4.m](PracticalMEEG_Source_Reconstruction_Session_4.m). It performs the following steps.

* Definition of head model and source model
* Localization of ICA components
* Plotting of ICA components overlaid on 3-D template MRI

# Time-frequency decomposition

For this presentation, we will the script [PracticalMEEG_Time_Frequency_Analysis_Session_3.m](PracticalMEEG_Time_Frequency_Analysis_Session_3.m). It performs the following steps.

* Spectral analysis for each of the conditions
* Time-frequency analysis for each of the conditions

# Group-level analysis

The script []()
