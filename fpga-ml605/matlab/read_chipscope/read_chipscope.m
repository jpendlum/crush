close all
clear all
numVar = 8;
numBits=15;
filename = 'chipscope-74M.dat';

% outData=zeros(numVar,numVar);
fid=fopen(filename);
outData=textscan(fid,'%6.s','HeaderLines',1);
outData_raw=outData{1,1};
fclose(fid);
outData_shaped=reshape(outData_raw,numVar,length(outData_raw)/numVar);
outData_shaped=outData_shaped';
outData_cut=outData_shaped(:,3:numVar);
outData_dec=hex2dec(outData_cut);
outData_dec=reshape(outData_dec,length(outData_dec)/(numVar-2),numVar-2);
outData_shift=bitshift(outData_dec,16-numBits);
outData_us=uint16(outData_shift);
for(i=1:numVar-2)
    outData_signed(:,i)=typecast(outData_us(:,i),'int16');
end
outData_double = double(outData_signed);

figure
for(i=1:numVar-2)
    subplot(numVar/2,2,i);plot(outData_double(:,i))
end