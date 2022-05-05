function saveFigDesktop(figHdl, fileName)
% saveFigDesktop: save plot figure to your Desktop directory as vector PDF
% 
% [Syntax]
%   saveFigDesktop(figHandle)
%   saveFigDesktop(figHandle, fineName)
% 
% [Input]
%    figHdl: figure handle of plot graph
%  fileName: output file name WITHOUGHT ".pdf" (string)
% 

% Check arguments and set default values
arguments
    figHdl
    fileName (1,1) {mustBeNonzeroLengthText} = "out"
end

% Get user name of your PC
userName = extractBetween(userpath, "C:\Users\", "\");

% Produce file path on Desktop
outFilePath = "C:\Users\" + userName{:} + "\Desktop\" + fileName + ".pdf";

% Get paper position from input figure handle
figPos = figHdl.PaperPosition;

% Define paper size
figHdl.PaperSize = figPos(3:4);

% Save figure file as vector .pdf format
print(figHdl, outFilePath, "-bestfit", "-dpdf", "-vector");
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EOF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%