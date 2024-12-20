

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
paramWaveformFMCWM.PRF = 1/paramWaveformFMCWM.T;
paramWaveformFMCWM.NumSweeps = 24;

paramWaveformFMCWM.lambda = c/paramWaveformFMCWM.Fc;

%Transmiter Parameters
paramTransmiter.P = 0.00316; % Watts - Power
paramTransmiter.Av = 36; % dB - Gain


%FreeSpace Parameters 
paramFreeSpace.maxDist = 200; % meters - Maximum one way distance



%Physical Parameters
paramGeometry.RadarVel = [0; 0; 0]; % meters - Radars position
paramGeometry.RadarPos = [0; 0; 0]; % meters/sec - Radars velocity

paramGeometry.TargetVel = [-1; 0; 0]; % -8 to 8  m/s
paramGeometry.TargetPos = [10; 0; 0]; %  0 to 10  m
paramGeometry.TargetArea = 5; % m^2 -  Mean radar cross section 

%Reciver Parameters
paramReciver.Av = 42; % dB - Gain
paramReciver.Nf = 0; % dB - Noise Figure
paramReciver.Temp = 300; % kelvin - Reference temperature


% Range Processing Interval
rangeProcessLimits = [0.1 200]; % Only process from 1 m to 200 m 
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

%R/D Ploting
paramDetection.RngLims = [rngVec(idxRangeProcessMin) rngVec(idxRangeProcessMax)]; % m
%paramDetection.RngLims = [0 10];
dopVec = fftshiftfreqgrid(paramDetection.NumDop,paramWaveformFMCWM.PRF); % Hz
speedVec = sort(-dop2speed(dopVec,paramWaveformFMCWM.lambda)/2); % m/s
paramDetection.SpeedLims = [speedVec(1) speedVec(end)]; % m/s
%paramDetection.SpeedLims = [-3 3];

function freq_grid = fftshiftfreqgrid(N,Fs)

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

