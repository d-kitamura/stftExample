function [specgram, fAxis, tAxis, fig] = calcStft(sig, args)
% calcStft: apply short-time Fourier transform and calculate spectrogram
% 
% [Syntax]
%   Using traditional name-value pair expression:
%   [specgram, fAxis, tAxis]
%          = calcStft(sig, "winLen", 1024, "shiftLen", 512, "winType", "h",
%                     "fs", 44100, "isPlot", true, "minColor", -30, 
%                     "freqRange", [], "isAllOut", false)
%   Using pythonic expression (later R2021a):
%   [specgram, fAxis, tAxis]
%          = calcStft(sig, winLen=1024, shiftLen=512, winType="h", 
%                     fs=44100, isPlot=true, minColor=-30, 
%                     freqRange=[], isAllOut=false)
% 
% [Input]
%        sig: time-domain signal (sigLen x nCh)
%     winLen: window length used in STFT (scalar, default: 1024)
%   shiftLen: shift length used in STFT (scalar, default: 512)
%    winType: window type used in STFT (string, default: "h")
%             "h": Hann window
%             "b": Blackman window
%             "f": flat-top window
%             "r": rectangular window
%         fs: sampling frequency [Hz] for plotting spectrogram 
%             (scalar, default: 44100)
%     isPlot: plot spectrogram (true/false, default: false)
%   minColor: minimum power [dB] of color map range for plotting
%             spectrogram (scalar, default: -30)
%  freqRange: frequency range for potting spectrogram (1 x 2, default: [])
%   isAllOut: output spectrogram with over-Nyquist frequency bins 
%             (true/false, default: false)
% 
% [Output]
%   specgram: complex-valued spectrogram
%             (winLen/2+1 x nFrame x nCh or winLen x nFrame x nCh)
%      fAxis: frequency axis (winLen/2+1 x 1 or winLen x 1)
%      tAxis: time axis (nFrame x 1)
%        fig: figure object
% 

% Check arguments and set default values
arguments
    sig (:,:) double
    args.winLen (1,1) double {mustBeInteger, mustBeNonnegative} = 1024
    args.shiftLen (1,1) double {mustBeInteger, mustBePositive} = 512
    args.winType (1,1) string {mustBeMember(args.winType, ["h", "b", "f", "r"])} = "h"
    args.fs (1,1) double {mustBeNonnegative} = 44100
    args.isPlot (1,1) logical = false
    args.minColor (1,1) double {mustBeNumeric} = -30
    args.freqRange (1,2) double {mustBeNonnegative} = []
    args.isAllOut (1,1) logical = false
end
winLen = args.winLen;
shiftLen = args.shiftLen;
fs = args.fs;
winType = args.winType;
isPlot = args.isPlot;
minColor = args.minColor;
freqRange = args.freqRange;
isAllOut = args.isAllOut;

% Slicing whole signal into banch of short-time signal pieces
shortTimeSigs = local_calcShortTimeSig(sig, winLen, shiftLen); % winLen x nFrame x nCh

% Multiply window to each of short-time signals
win = local_getWindow(winType, winLen);
winSigs = shortTimeSigs .* win; % using implicit expansion

% Apply discrete Fourier transform to each of short-time signals
specgram = fft(winSigs, winLen, 1); % apply DFT to first dimension

% Calculate frequency and time axes
[nFreq, nFrame] = size(specgram);
fAxis = linspace(0, fs, nFreq);
tAxis = linspace(0, size(sig, 1)/fs, nFrame);

% Discard redundant over-Nyquist frequency components
if ~isAllOut
    specgram = specgram(1:floor(winLen/2)+1, :, :);
    fAxis = fAxis(1:floor(nFreq/2)+1);
end

% Plot spectrogram
if isPlot; fig = local_plotSpecgram(specgram, fAxis, tAxis, minColor, freqRange); 
else; fig = []; end
end

%% Local function
%--------------------------------------------------------------------------
function shortSig = local_calcShortTimeSig(sig, winLen, shiftLen)
[sigLen, nCh] = size(sig, [1, 2]); % singal length
sigZeroPad = [sig; zeros(winLen-1, nCh)]; % pad zeros
nFrame = ceil(sigLen/shiftLen); % number of short-time signals (frames)
shortSig = zeros(winLen, nFrame, nCh); % memory allocation

% Slicing
for iFrame = 1:nFrame
    beginPoint = (iFrame-1)*shiftLen+1; % beginning point of a short-time signal
    endPoint = beginPoint+winLen-1; % end point of a short-time signal
    shortSig(:, iFrame, :) = sigZeroPad(beginPoint:endPoint, :); % extract i-th short-time signal
end
end

%--------------------------------------------------------------------------
function win = local_getWindow(type, len)
if type == "h" % Hann
    win = hann(len, "periodic");
elseif type == "b" % Blackman
    win = blackman(len, "periodic");
elseif type == "f" % flat-top
    win = flattopwin(len, "periodic");
else % rectangular
    win = ones(len, 1);
end
end

%--------------------------------------------------------------------------
function figObj = local_plotSpecgram(S, fAx, tAx, minColor, fRange)
nCh = size(S, 3);
logS = 20*log10(abs(S)); % [dB]
maxVal = max(logS, [], "all");
if nCh == 1
    figObj = figure("Position", [50, 50, 750, 500]); % [left, bottom, width, height]; 
    imagesc(tAx, fAx, logS);
    axis tight; % set axis ranges
    box on; % display outer box
    set(gca, "YDir", "normal");
    set(gca, "FontSize", 12); % inverte virtical axis
    if ~isempty(fRange); ylim(fRange); end % set frequency range
    clim([minColor, maxVal]); % color map range
    cbHdl = colorbar("FontName", "Arial", "FontSize", 13); % display color bar
    cbHdl.Label.String = "Power [dB]"; % set label of color bar
    xlabel("Time [s]", "FontSize", 12); ylabel("Frequency [Hz]", "FontSize", 12);
else
    figObj = figure("Position", [50, 50, 750, 500]); % [left, bottom, width, height]; 
    tiledlayout(1, nCh, "TileSpacing", "compact", "Padding", "compact"); % 1 x nCh tiled layout
    for iCh = 1:nCh
        ax(iCh) = nexttile; imagesc(tAx, fAx, logS(:, :, iCh));
        axis tight; % set axis ranges
        box on; % display outer box
        set(gca, "YDir", "normal");
        set(gca, "FontSize", 12); % inverte virtical axis
        if ~isempty(fRange); ylim(fRange); end % set frequency range
        clim([minColor, maxVal]); % color map range
        xlabel("Time [s]", "FontSize", 12);
        if iCh == 1; ylabel("Frequency [Hz]", "FontSize", 12);
        else; yticklabels([]); end
    end
    linkaxes(ax);
    cbHdl = colorbar("FontSize", 12); % display color bar
    cbHdl.Label.String = "Power [dB]"; % set label of color bar
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EOF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%