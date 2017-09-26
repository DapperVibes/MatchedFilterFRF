function [FRF,fVecFRF] = MatchedFilterFRF(fs,f1,f2,TSweep,TTotal,DAQ,type)
%MatchedFilterFRF - Controls DAQ hardware to send a matched filter sweep
%and computes the Frequency Response Function of the return signal
%
% Syntax:  [FRF,fVecFRF] = MatchedFilterFRF(fs,f1,f2,TSweep,TTotal,A,N)
%
% Inputs:
%    fs     - Sampling frequency [Hz]
%    f1     - Frequency to start sweep [Hz]
%    f2     - Frequency to end sweep [Hz]
%    TSweep - Duration of sweep [s]
%    TTotal - Total time for aquisition from start of sweep [s]
%    DAQ    - Handle for NI DAQ device with 1 input and 2 output channels
%    type   - Type of FRF, '1' - Compare DAQ Ch 1 against ideal signal
%                          '2' - Compare DAQ Ch 2 to DAQ Ch 1
%
% Outputs:
%    FRF    - Frequency response function [Ratio]
%    fVecFRF- Frequency vector for frequency response function [Ratio]
%
% Example: 
% 
% fs = 200000; % Sampling frequency [Hz]
% 
% f1 = 20000; % Lowest frequency of interest [Hz]
% f2 = 80000; % Highest frequency of interest [Hz]
% 
% TSweep = 0.005; % Total time of sweep [s]
% TTotal = 0.3;
% dt = 1/fs; % Time step [s]
% 
% %% Initialize DAQ system 
% 
% % List NI DAQ devices
% devices = daq.getDevices;
% 
% % Start NI DAQ session
% s = daq.createSession('ni');
% 
% % Add input channel
% chi0 = addAnalogInputChannel(s,'Dev3', 0, 'Voltage');
% cho0 = addAnalogOutputChannel(s,'Dev3',0,'Voltage');
% 
% % Specify sampling frequency
% s.Rate = fs;
% 
% %% Run FRF Code
% 
% [FRF,fVecFRF] =...
%     MatchedFilterFRF(fs,f1,f2,TSweep,TTotal,s);
% 
% 
% %% Figures
% 
% figure(5)
% subplot(2,1,1)
% semilogx(fVecFRF/1000,20*log10(abs(FRF)))
% axis([f1/1000 f2/1000 -50 12])
% title('FRF')
% ylabel('Amplitude [dB]')
% subplot(2,1,2)
% semilogx(fVecFRF/1000,angle(FRF)*180/pi)
% axis([f1/1000 f2/1000 -180 180])
% ylabel('Phase [degrees]')
% xlabel('Frequency [kHz]')
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author: Craig Dolder
% University of Southampton
% email: C.N.Dolder@soton.ac.uk
% Website: https://github.com/DapperVibes
% Aug 2019; Last revision: 26-Aug-2017

% Feature steps:
% Complete:
%  - File header
%  - Calculate the desired logarithmic chirp
%  - Add taper and buffer
%  - Calculate the impulse response and return
%  - Generate an artificial echo
%  - Calculate the FRF and return
%  - Send the chip via DAQ and calculate FRF of real return
%  - Take two signals in and compute FRF between them
% To do:
%  - Create an ensemble average with a coherence.

%------------- BEGIN CODE --------------

% Time Vectors
tVecSweep = 1/fs:1/fs:TSweep;
tVecTotal = 1/fs:1/fs:TTotal;

% Generate logarithmic chirp
signal = chirp(tVecSweep,f1*0.9,TSweep-1/fs,f2*1.1,'logarithmic');

% Exponential growth factor
L = TSweep/log(f2/f1); % set exponential growth rate

% Weighting of inverse signal
invsignal = fliplr(f1.*exp(tVecSweep./L).*signal);

% Buffer and taper sweep for equal energy
signal = [signal.*tukeywin(length(signal),0.05).'...
    zeros(1,length(tVecTotal) - length(tVecSweep))];

%% Impulse response of signal when match filtered

Ref = ifft(fft(signal(:),length(signal)).*fft(invsignal(:),length(signal)));

%% DAQ

queueOutputData(DAQ,signal(:));

data = DAQ.startForeground;

if type == 1
    echo = data(:,1);
elseif type == 2
    echo = data(:,2);
    signal = data(:,1);
else
    disp('Incorrect entry of type parameter, please choose either 1 or 2');
end

%% Impulse response of echo when match filtered

Response = ifft(fft(echo(:),length(signal)).*fft(invsignal(:),length(signal)));

%% Calculate FRF

FRF = fft(Response)./fft(Ref); FRF = FRF(1:end/2);

fVecFRF = (0:(length(FRF)-1))*fs/(2*length(FRF));


%------------- END OF CODE --------------
