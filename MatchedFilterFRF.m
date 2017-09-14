function [] = MatchedFilterFRF(DAQObject)
%MatchedFilterFRF - Controls DAQ hardware to send a matched filter sweep
%and computes the Frequency Response Function of the return signal
%
% Syntax:  [output1,output2] = function_name(input1,input2,input3)
%
% Inputs:
%    input1 - Description
%    input2 - Description
%    input3 - Description
%
% Outputs:
%    output1 - Description
%    output2 - Description
%
% Example: 
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Craig Dolder
% University of Southampton
% email: C.N.Dolder@soton.ac.uk
% Website: http://www.
% Aug 2019; Last revision: 13-Aug-2017

%------------- BEGIN CODE --------------

[data,time] = DAQObject.startForeground;


%------------- END OF CODE --------------
