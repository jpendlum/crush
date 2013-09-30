%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CRUSH
%  Cognitive Radio Universal Software Hardware
%  http://www.coe.neu.edu/Research/rcl//projects/CRUSH.php
%  
%  CRUSH is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%  
%  CRUSH is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%  
%  You should have received a copy of the GNU General Public License
%  along with CRUSH.  If not, see <http://www.gnu.org/licenses/>.
%  
%  
%  
%  File: udp_config_crush.vhd
%  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
%  Description: Configure CRUSH through UDP packets.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User configuration, change only these values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UDP packet payload size, Max 1472
udp_payload_size = 1472;
% FFT Size, Max 8192
fft_size = 8192;
% FFT threshold in dB
threshold_dB = 200;
threshold = round(10^(threshold_dB/20));
% Enable which data the FPGA will send over UDP. Note: For now, keep FFT, 
% treshold, and magnitude squared data enabled as this script does not 
% handle the other combinations yet.
send_fft = 1;
send_threshold = 1;
send_mag_squared = 1;
send_counting_pattern = 0; % Debug only

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Counters
i = 0;
k = 0;
% USRP sampling rate
Fs = 100e6;
% Total number of bytes sent via UDP
total_payload_length = ceil(((2+2+2+4)*fft_size + 4)/udp_payload_size)*udp_payload_size;
% Preallocate variables to hold data sent from the FPGA
udp_payload_data = zeros(1,total_payload_length,'uint8');
fft_index = linspace(-1,1,fft_size)*Fs;
fft_real = zeros(1,fft_size,'int16');
fft_imag = zeros(1,fft_size,'int16');
fft_mag_squared = zeros(1,fft_size,'uint32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Send a command to configure the spectrum sensing
% Byte 0: 0xA5, Header integrity check byte
%      1: Set configuration command
%      2: Configuration word
%           Bit 0: Enable sending fft data 
%                  (complex, real 14 bits sign extend to 16 bits, imag 14 bits sign 
%                  extend to 16 bits)
%               1: Enable sending fft magnitude squared data (29 bits sign extended 
%                  to 32 bits)
%               2: Enable sending threshold data (16 bits)
%               3: Enable counting pattern. Debug linear counting pattern useful for
%                  determining if data is missing.
%             4-7: Unused
%      3: Set FFT size command
%      4: FFT size control word is 5 bits
%           01101 (0xD): 8192
%           01100 (0xC): 4096
%           01011 (0xB): 2048
%           01010 (0xA): 1024
%           01001 (0x9): 512
%           01000 (0x8): 256
%           00111 (0x7): 128
%           00110 (0x6): 64
%           00101 (0x5): 32
%           00100 (0x4): 16
%           00011 (0x3): 8
%      5: Set threshold command
%      6: Threshold is a 32 bit unsigned value
%      7: Start Spectrum Sensing command. Initiates the spectrum sensing algorithm.
commands = uint8([hex2dec('A5') ...
    2 (send_threshold+send_fft*2+send_mag_squared*2^2+send_counting_pattern*2^3) ...
    3 log2(fft_size) ...
    4 fliplr(typecast(uint32(threshold),'uint8')) ...
    1]);

% Open UDP connection with CRUSH. The IP address, port address, etc are configurable in 
% the FPGA via the serial debug terminal or modifying the reset value in the VHDL code. 
udp_crush = udp('192.168.10.10',9090,'LocalPort',34672,'InputBufferSize',total_payload_length,'Timeout',1);
fopen(udp_crush);

% Send command to configure and start spectrum sensing
fwrite(udp_crush,commands);

% Receive spectrum sensing data from CRUSH. Make sure to close the UDP
% connection on error if a UDP packet is not received.
try
    n = 0;
    udp_payload_data(n*udp_payload_size+1:(n+1)*udp_payload_size) = fread(udp_crush,udp_payload_size,'uint8');
    n = n + 1;
    while (udp_crush.BytesAvailable > 0)
        udp_payload_data(n*udp_payload_size+1:(n+1)*udp_payload_size) = fread(udp_crush,udp_payload_size,'uint8');
        n = n + 1;
    end
catch exception
    fclose(udp_crush);
    delete(udp_crush);
    return;
end
byte_count = n*udp_payload_size;
fclose(udp_crush);
delete(udp_crush);

% Header data
config_word = udp_payload_data(1);
fft_size_config = udp_payload_data(2);
threshold_data_count = uint16(udp_payload_data(3))*2^8 + uint16(udp_payload_data(4));
i = 4;

% Remaining data in the following order (depending on what is sent):
% 1. FFT bins that exceeded the threshold (32 bits per bin, variable
% length)
% 2. FFT real, imag data interleaved (16 bits, fft_size)
% 4. FFT magnitude data (32 bits, fft_size)
% 5. Zero padding to complete the UDP payload, as the payload size is
%    kept constant

% Grab FFT bins that exceeded the threshold. 16 bits unsigned.
% Note: It is possible that no FFT bins exceeded the threshold, so
% there may not be any data.
if (threshold_data_count > 0)
    fft_threshold_exceeded = zeros(1,threshold_data_count);
    k = 1;
    for l = 1:threshold_data_count
        fft_threshold_exceeded(l) = double(uint16(udp_payload_data(i+k))*2^8 + uint16(udp_payload_data(i+k+1)));
        k = k + 2;
    end
    % Correct bin location
    for n = 1:length(fft_threshold_exceeded)
        if (fft_threshold_exceeded(n) >= fft_size/2)
            fft_threshold_exceeded(n) = fft_threshold_exceeded(n) - fft_size;
        end
    end
    fft_threshold_exceeded = sort(fft_threshold_exceeded);
    i = i + k - 1;  % Update byte counter
else
    fft_threshold_exceeded = [];    
end

% Grab FFT bins, real & imag, 16 bits signed
k = 1;
for l = 1:fft_size
    fft_real(l) = typecast(uint16(udp_payload_data(i+k))*2^8 + uint16(udp_payload_data(i+k+1)),'int16');
    fft_imag(l) = typecast(uint16(udp_payload_data(i+k+2))*2^8 + uint16(udp_payload_data(i+k+3)),'int16');
    k = k + 4;
end
i = i + k - 1;

% Grab FFT bins, magnitude squared, 32 bits unsigned
k = 1;
for l = 1:fft_size
    fft_mag_squared(l) = uint32(udp_payload_data(i+k))*2^24 + ...
                         uint32(udp_payload_data(i+k+1))*2^16 + ...
                         uint32(udp_payload_data(i+k+2))*2^8 + ...
                         uint32(udp_payload_data(i+k+3));
    k = k + 4;
end
i = i + k - 1;

% Plot data
hold on;
grid on;
freq = linspace(-(Fs/2)*(1/1e6),(Fs/2)*(1/1e6),fft_size);
freq_exceeded = freq(fft_threshold_exceeded+fft_size/2+1);
plot(freq,20*log10(fftshift(double(fft_real).^2+double(fft_imag).^2)+1)); % Add offset to avoid log10(0)
%plot(freq,20*log10(double((fftshift(fft_mag_squared)))+1)); % Add offset to avoid log10(0)
plot(freq,20*log10(double(threshold*ones(1,fft_size))),'g'); 
scatter(freq_exceeded,20*log10(double(threshold*ones(1,threshold_data_count))),'r','fill');
legend('FFT Magnitude Squared','Threshold','Threshold Exceeded');
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('Spectrum Sensing');