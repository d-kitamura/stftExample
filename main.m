% Calculation of power spectrogram, Daichi Kitamura 2022-04-01
clear; close all; clc;

% Set parameters
inFileDir = "./inputFile/";
inFileName = "music.wav";

% Read input .wav file
inFilePath = inFileDir + inFileName;
[inSig, sampFreq] = audioread(inFilePath);

% Convert to power spectrogram
[spec, freqAxis, timeAxis, fig] = calcStft(inSig, ...
                                           "winLen", 4096, ...
                                           "shiftLen", 512, ...
                                           "winType", "h", ...
                                           "fs", sampFreq, ...
                                           "isPlot", true, ...
                                           "minColor", -10, ...
                                           "freqRange", [0, 6000]);

% Save figure in vector .pdf format to your desktop directory
if ~isempty(fig)
    outFileName = "power_spectrogram";
    saveFigDesktop(fig, outFileName);
end