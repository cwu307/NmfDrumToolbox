// NMF DRUM TOOLBOX V1.01
// Latest update: July 2015 

Update Notes
============
New methods included! (SA-NMF [1] and NMFD [2-4])

For more information, please refer to the following publications: 
[1] Christian Dittmar and Daniel Gärtner: Real-time transcription and separation of drum recordings based on NMF decomposition, DAFx 2014
[2] P. Smaragdis, “Non-negative matrix factor deconvolution; extraction of multiple sound sources from monophonic inputs,” in Proc. Intl. Conf. on Independent Component Analysis and Blind Signal Separation (ICA), Grenada, Spain, 2004, pp. 494–499.
[3] H. Lindsay-Smith, S. McDonald, and M. Sandler, “Drumkit transcription via convolutive NMF,” in Proc. Intl. Conf. on Digital Audio Effects (DAFx), York, UK, September 2012.
[4] C. Dittmar and M. Müller, “Reverse Engineering the Amen Break – Score-informed Separation and Restoration applied to Drum Recordings,” IEEE/ACM Transactions on Audio, Speech, and Language Processing, vol. 24, no. 9, pp. 1531–1543, 2016.

Introduction
============
NMF Drum Toolbox is a Matlab toolbox for drum transcription using Non-negative Matrix Factorization (NMF) based methods. This Toolbox is a free, open source software; you can redistribute it or modify it for educational purposes. For commercial purpose, please contact the authors.

Compatibility
=============
NMF Drum Toolbox requires Matlab 8.1 (or higher) and Signal Processing toolbox by Mathwork. 

How to Use It
=============
[hh, bd, sd] = NmfDrum(filePath) returns onset time of hh (HiHat), bd (Bass Drum) and sd (Snare Drum) of a given audio signal respectively. The filePath is a string of the path to the target audio signal. By default, the selected method is PfNmf (Partially Fixed NMF) using default parameter settings.     

[hh, bd, sd] = NmfDrum(filePath, method) returns the onset time of hh, bd and sd using user defined method. The available methods are: ‘Nmf’, basic NMF with Rh = 0; ’PfNmf’, partially fixed NMF, Rh = 50 by default;’Am1’ adaptive partially fixed NMF with correlation based template adaptation; ‘Am2’, adaptive partially fixed NMF with alternate update for template adaptation. 

[hh, bd, sd] = NmfDrum(filepath, method, param) returns the onset time of hh, bd and sd using user defined method and user defined parameters. “param” is a struct that contains various parameters necessary for the algorithm. The parameters are specified as follows: 

param.WD = float, (windowSize/2 + 1)*3 matrix, drum dictionary for hh, bd, sd, respectively.
param.windowSize = int, window size for spectrogram.
param.hopSize = int, hop size for spectrogram.
param.lambda = float, 1*3 vector, offset coefficients of adaptive median filter (0.0 ~ 1.0) for hh, bd, sd, respectively.
param.order  = float, 1*3 vector, window length of adaptive median filter (sec) for hh, bd, sd, respectively.
param.maxIter = int, max iteration for template adaptation.
param.sparsity = float, sparsity coefficient.
param.rhoThreshold = float, rho threshold for template adaptation (Am1).
param.rh = int, rank of the harmonic dictionary matrix.

For more detailed information, please refer to the following publications. 

Chih-Wei Wu, Alexander Lerch, Drum Transcription using Partially Fixed Non-Negative Matrix Factorization With Template Adaptation, in Proceedings of the International Conference on Music Information Retrieval (ISMIR), Malaga, 2015.


Potential Problems
==================
1. This toolbox currently only supports HH, BD, SD. More instruments will be supported in the upcoming updates.

Contact
=======
Chih-Wei Wu
cwu307@gatech.edu

Georgia Tech Center for Music Technology
840 McMillan Street
Atlanta, GA 30332