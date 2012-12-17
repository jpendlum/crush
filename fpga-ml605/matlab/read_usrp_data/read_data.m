clc
clear all
close all
filename = 'usrp_samples_defense.dat';
NFFT=2^8;
% for i=1:100;
%     data=read_complex_binary(filename,1e6,(i-1)*1e6);
    dataRAW=read_complex_binary(filename,1e6,0);
    %Process and display Raw data
    data=dataRAW(1024:1024*9-1);
%     data=dataRAW;
    centerFs=70e6;
    Fs=25e6;
    I=real(data);
    Q=imag(data);

    
    
    T=1/Fs;
    L=length(data);
    
    Y=fft(data,NFFT);
    f=linspace(centerFs-Fs/2,centerFs+Fs/2,NFFT);
    spec=20*log10(abs(Y));
    spec=spec-max(spec);
    spec=fftshift(spec);
    figure
%     subplot(2,2,[1 2]),
    plot(f,spec,'k')
    title('Double-Sided Amplitude Spectrum of Q(t) from Raw data')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
%     subplot(2,2,3),plot(0:length(I)-1,I,'k');
%     title('Plot of I');
%     xlim([0 1024]);
%     subplot(2,2,4),plot(0:length(Q)-1,Q,'k');
%     title('Plot of Q');
%     xlim([0 1024]);
% end