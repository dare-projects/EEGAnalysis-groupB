# EEGAnalysis-groupB

This is the solution proposed by Group B to the EEG Analysis case study given in the Da.Re Residential School. The repository contains the following groups:

### Raw Dataset (chb05_12.edf, chb05_13s.edf, chb05_14.edf)

These files contains EEG signals of a single patient in three different hours. You can find more details at https://physionet.org/pn6/chbmit/ .

### Data Preparation (feature_extracion.R)

R code containing the procedure of the feature extraction and the creation of the final dataset.

### Final Dataset (dataset_eeg.csv)

Csv dataset produced by the R script: every row contains the time window, mean, standard deviation, hurst exponent and sample entropy of the raw signal.

### Data Visualization (clustering.py)

Python script that performs a K-Means clustering to the dataset and produces plots to visualize results.
