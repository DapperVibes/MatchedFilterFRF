% File for testing the Matched Filter FRF Function

clear; clc;

fs = 200000; % Sampling frequency [Hz]

f1 = 20000; % Lowest frequency of interest [Hz]
f2 = 80000; % Highest frequency of interest [Hz]

TSweep = 0.005; % Total time of sweep [s]
TTotal = 0.01;
dt = 1/fs; % Time step [s]

%% Initialize DAQ system 

% List NI DAQ devices
devices = daq.getDevices;

% Start NI DAQ session
s = daq.createSession('ni');

% Add input channel
chi0 = addAnalogInputChannel(s,'Dev3',0, 'Voltage');
chi1 = addAnalogInputChannel(s,'Dev3',2, 'Voltage');
cho0 = addAnalogOutputChannel(s,'Dev3',0,'Voltage');

% Specify sampling frequency
s.Rate = fs;

%% Run FRF Code

[FRF,fVecFRF] =...
    MatchedFilterFRF(fs,f1,f2,TSweep,TTotal,s,2);


%% Figures

figure(5)
subplot(2,1,1)
semilogx(fVecFRF/1000,20*log10(abs(FRF)))
axis([f1/1000 f2/1000 -50 12])
title('FRF')
ylabel('Amplitude [dB]')
subplot(2,1,2)
semilogx(fVecFRF/1000,angle(FRF)*180/pi)
axis([f1/1000 f2/1000 -180 180])
ylabel('Phase [degrees]')
xlabel('Frequency [kHz]')

