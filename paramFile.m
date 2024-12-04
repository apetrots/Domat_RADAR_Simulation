

% Constant
c = 3e8;

maxEstimatesFMCWM = 2;

%Waveform Parameters
paramWaveformFMCWM.Bw = 4e9;  % Hetz - Bandwidth
paramWaveformFMCWM.Fs = 2 * paramWaveformFMCWM.Bw; % Hertz - nyquist rate - Sampling rate
paramWaveformFMCWM.T = 5e-6; % Sec - Sampling Time
paramWaveformFMCWM.Fc = 77e9; % Hertz - Carrier Frequecy 
paramWaveformFMCWM.NumSamplesSweep = paramWaveformFMCWM.T * paramWaveformFMCWM.Fs;
paramWaveformFMCWM.Slope = paramWaveformFMCWM.Bw/paramWaveformFMCWM.T;

paramWaveformFMCWM.NumSweeps = 64;

%Transmiter Parameters
paramTransmiter.P = 0.00316227766016838; % Watts - Power
paramTransmiter.Av = 36; % dB - Gain


%FreeSpace Parameters 
paramFreeSpace.maxDist = 10; % meters - Maximum one way distance


%Physical Parameters
paramGeometry.RadarVel = [0; 0; 0]; % meters - Radars position
paramGeometry.RadarPos = [0; 0; 0]; % meters/sec - Radars velocity

paramGeometry.TargetVel = [2.5; 0; 0]; % meters - Targets position
paramGeometry.TargetPos = [5.25; 0; 0]; % meters/sec - Targets velocity
paramGeometry.TargetArea = 5; % m^2 -  Mean radar cross section 

%Reciver Parameters
paramReciver.Av = 42; % dB - Gain
paramReciver.Nf = 4.5; % dB - Noise Figure
paramReciver.Temp = 300; % kelvin - Reference temperature


% Range Processing Interval
rangeProcessLimits = [1 15]; % Only process from 1 m to 200 m 
rngVec = beat2range(fftshiftfreqgrid(paramWaveformFMCWM.NumSamplesSweep,paramWaveformFMCWM.Fs),...
                            paramWaveformFMCWM.Slope,c);
[~,idxRangeProcessMin] = min(abs(rngVec - rangeProcessLimits(1))); 
[~,idxRangeProcessMax] = min(abs(rngVec - rangeProcessLimits(2))); 

paramDetection.IdxRangeProcessLimits = [idxRangeProcessMin idxRangeProcessMax]; 

% CFAR
numRng = idxRangeProcessMax - idxRangeProcessMin + 1;
paramDetection.NumRng = numRng;
rngOver = max(round(numRng/(paramWaveformFMCWM.T*paramWaveformFMCWM.Fs)),1);
nGuardRng = 2*rngOver;
nTrainRng = 4*rngOver;
numCUTRng = 1+nGuardRng+nTrainRng;
numDop = paramWaveformFMCWM.NumSweeps;
paramDetection.NumDop = numDop;
dopOver = round(numDop/paramWaveformFMCWM.NumSweeps);
numGuardDop = 1*dopOver;
numTrainDop = 4*dopOver;
numCUTDop = 1+numGuardDop+numTrainDop;
paramDetection.CUTSize = [(1+nGuardRng+nTrainRng) ...
    (1+numGuardDop+numTrainDop)];
paramDetection.GuardSize = [nGuardRng numGuardDop];
paramDetection.TrainSize = [nTrainRng numTrainDop];
idxRngCUT = numCUTRng:(numRng-numCUTRng+1);
idxDopCUT = numCUTDop:(numDop-numCUTDop+1);
paramDetection.NumCUTIdx = numel(idxRngCUT).*numel(idxDopCUT); 


function freq_grid = fftshiftfreqgrid(N,Fs)
%fftshiftfreqgrid   Generate frequency grid
%   freq_grid = fftshiftfreqgrid(N,Fs) generate an N point
%   frequency grid according to sample rate Fs. This grid matches
%   the operation used in fftshift.
%
%   % Example:
%   %   Create a 16 point frequency grid for a sample rate of 10
%   %   Hz.
%
%   freq_grid = fftshiftfreqgrid(16,10)
freq_res = Fs/N;
freq_grid = (0:N-1).'*freq_res;
Nyq = Fs/2;
half_res = freq_res/2;
if rem(N,2) % odd
    idx = 1:(N-1)/2;
    halfpts = (N+1)/2;
    freq_grid(halfpts) = Nyq-half_res;
    freq_grid(halfpts+1) = Nyq+half_res;
else
    idx = 1:N/2;
    hafpts = N/2+1;
    freq_grid(hafpts) = Nyq;
end
freq_grid(N) = Fs-freq_res;
freq_grid = fftshift(freq_grid);
freq_grid(idx) = freq_grid(idx)-Fs;
end

