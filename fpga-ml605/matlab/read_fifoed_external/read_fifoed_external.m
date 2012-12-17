% close all
% clear all
prefix = 'test_data_fifoed_external_74M';
filename=[prefix '.dat'];
centerFreq = 68.75e6;
Fs=100e6;
NFFT=2^8;
inputBits=16; %number of bits represented
Ipres=1; %set to 1 if I is present
Qpres=1; %set to 1 if Q is present
decimation=1; %decimation factor on the data
fid=fopen(filename);
temp=fscanf(fid,'%x');
I2s=bitand(temp,hex2dec('ffff'));
Q2s=bitand(bitshift(temp,-16),hex2dec('ffff'));

%convert from 2's complement to double
Is=bitshift(I2s,16-inputBits);
Iu16=uint16(Is);
Is16=typecast(Iu16,'int16');
I=double(Is16)/(2^(16-inputBits));


Qs=bitshift(Q2s,16-inputBits);
Qu16=uint16(Qs);
Qs16=typecast(Qu16,'int16');
Q=double(Qs16)/(2^(16-inputBits));

%cut begining off, its normally stale
I=I(4:length(I));
Q=Q(4:length(Q));

if(Ipres==1 && Qpres==1)
    data=I+Q*1j;
elseif (Ipres==0)
    data=Q;
else
    data=I;
end

if(decimation >1)
	data=data(1:decimation:length(data));
end
        
T=1/Fs;
L=length(data);

Ys=fft(data,NFFT)/L;
fd=Fs*linspace(0,1,NFFT)+centerFreq-Fs/2;
fs=Fs/2*linspace(0,1,NFFT/2);
specs=20*log10(abs(Ys));
specs=specs-max(specs);
Yd=fftshift(Ys);
specd=20*log10(abs(Yd));
specd=specd-max(specd);

if((Ipres+Qpres)>=2)
    subplot(2,2,[1 2]),plot(fd,specd,'k')
    axis([fd(1) fd(length(fd)) -70 5])
    title('Double-sided Amplitude Spectrum of Q(t) from Raw data')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
else
     subplot(2,2,[1 2]),plot(fs,specs(1:(NFFT/2)),'k')
     axis([fs(1) fs(length(fs)) -70 5])
    title('single-sided Amplitude Spectrum of Q(t) from Raw data')
    xlabel('Frequency (Hz)')
    ylabel('Y(f)')
end
    
    
subplot(2,2,3),plot(0:length(I)-1,I,'k');
title('Plot of I');
% xlim([0 1024]);
subplot(2,2,4),plot(0:length(Q)-1,Q,'k');
title('Plot of Q');
% xlim([0 1024]);
% subplot(3,2,[5 6]),plot(abs(data))


fclose(fid);

filename=[prefix '_i.dat']
fid = fopen(filename,'w');
for i=1:length(I2s)
    fprintf(fid,'%d\r\n',I2s(i));
end
fclose(fid);
filename=[prefix '_q.dat']
fid = fopen(filename,'w');
for i=1:length(Q2s)
    fprintf(fid,'%d\r\n',Q2s(i));
end
fclose(fid);