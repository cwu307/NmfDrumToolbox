%% NMF Drum Toolbox v1.0 Demo
% This script is to demonstrate how to apply NmfDrum() for drum
% transcription. The example audio file used in this script is a short excerpt 
% from ENST Public drum dataset. The audio contains both drum and music.
% The extracted onsets of HH, BD, SD are visualized respectively.
%
% CW @ GTCMT 2015
function demo()

%read file
filePath = '../demo/test_audio.wav';
[x, fs] = audioread(filePath);
t = [0:length(x)-1]'*1/fs;

%transcription 
addpath('../src');
[hh, bd, sd] = NmfDrum(filePath, 'NmfD');
rmpath('../src');

%audio playback
sound(x, fs);

%visualization
subplot(411);
plot(t, x, 'k');
title('Original Waveform');
xlabel('Time (sec)');
ylabel('Amplitude');
subplot(412);
stem(hh, ones(length(hh),1), 'r');
title('HiHat Onsets');
xlabel('Time (sec)');
ylabel('Activity');
subplot(413);
stem(sd, ones(length(sd),1), 'g');
title('Snare Drum Onsets');
xlabel('Time (sec)');
ylabel('Activity');
subplot(414);
stem(bd, ones(length(bd),1), 'b');
title('Bass Drum Onsets');
xlabel('Time (sec)');
ylabel('Activity');


