

% Constant
c = 3e8;


%Waveform Parameters
paramWaveformFMCWM.Bw = 4e9;  % Hetz - Bandwidth
paramWaveformFMCWM.Fs = 2 * paramWaveformFMCWM.Bw; % Hertz - nyquist rate - Sampling rate
paramWaveformFMCWM.T = 1e-6; % Sec - Sampling Time
paramWaveformFMCWM.Fc = 77e9; % Hertz - Carrier Frequecy 


%Transmiter Parameters
paramTransmiter.P = 5000; % Watts - Power
paramTransmiter.Av = 20; % dB - Gain


%FreeSpace Parameters 
paramFreeSpace.maxDist = 10; % meters - Maximum one way distance


%Physical Parameters
paramGeometry.RadarVel = [0; 0; 0]; % meters - Radars position
paramGeometry.RadarPos = [0; 0; 0]; % meters/sec - Radars velocity

paramGeometry.TargetVel = [1; 0; 0]; % meters - Targets position
paramGeometry.TargetPos = [5; 0; 0]; % meters/sec - Targets velocity
paramGeometry.TargetArea = 1; % m^2 -  Mean radar cross section 

%Reciver Parameters
paramReciver.Av = 20; % dB - Gain
paramReciver.Nf = 0; % dB - Noise Figure
paramReciver.Temp = 300; % kelvin - Reference temperature