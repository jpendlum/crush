clear all
close all

%user settable variables

%general variables
gen_numChannels = 1;
gen_spare0 = 0; %not used
gen_spare1 = 0; %not used

%plotting variables
plotData=1;
centerFreq = 70e6;
Fs=100e6;
dc=0;
shift = 0;

%channel 0
ch0_threshold = 1000000;
ch0_fftSize = 10; %256 point FFT
ch0_mode = 4; %send back raw data
ch0_freq = 0; %not used yet
ch0_spare0 = 0; %not used
ch0_spare1 = 0; %not used

if(gen_numChannels >=2)
    %channel 1
    ch1_threshold = 1e5;
    ch1_fftSize = 7; %256 point FFT
    ch1_mode = 2; %send back raw data
    ch1_freq = 0; %not used yet
    ch1_spare0 = 0; %not used
    ch1_spare1 = 0; %not used
end
if(gen_numChannels >=3)
    %channel 2
    ch2_threshold = 1e5;
    ch2_fftSize = 8; %256 point FFT
    ch2_mode = 4; %send back raw data
    ch2_freq = 0; %not used yet
    ch2_spare0 = 0; %not used
    ch2_spare1 = 0; %not used
end
if(gen_numChannels >=4)
    %channel 3
    ch3_threshold = 1e5;
    ch3_fftSize = 8; %256 point FFT
    ch3_mode = 4; %send back raw data
    ch3_freq = 0; %not used yet
    ch3_spare0 = 0; %not used
    ch3_spare1 = 0; %not used
end

%variables
packetSize = 8+12*gen_numChannels;
 
%error check values
%TODO

packet = uint8(zeros(packetSize,1));

ch0Base = 8;
ch1Base = ch0Base + 12;
ch2Base = ch1Base + 12;
ch3Base = ch2Base + 12;

%general
packet(1) = hex2dec('de');
packet(2) = hex2dec('ad');
packet(3) = hex2dec('be');
packet(4) = hex2dec('ef');
packet(5) = gen_numChannels;
packet(6) = 0;
packet(7) = 0;
packet(8) = 0;
%channel 0
packet(ch0Base + 1) = bitand(bitshift(ch0_threshold,-24),2^8-1);
packet(ch0Base + 2) = bitand(bitshift(ch0_threshold,-16),2^8-1);
packet(ch0Base + 3) = bitand(bitshift(ch0_threshold,-8),2^8-1);
packet(ch0Base + 4) = bitand(bitshift(ch0_threshold,0),2^8-1);
packet(ch0Base + 5) = ch0_fftSize;
packet(ch0Base + 6) = ch0_mode;
packet(ch0Base + 7) = bitand(bitshift(ch0_freq,-24),2^8-1);
packet(ch0Base + 8) = bitand(bitshift(ch0_freq,-16),2^8-1);
packet(ch0Base + 9) = bitand(bitshift(ch0_freq,-8),2^8-1);
packet(ch0Base + 10) = bitand(bitshift(ch0_freq,0),2^8-1);
packet(ch0Base + 11) = ch0_spare0;
packet(ch0Base + 12) = ch0_spare1;
if(gen_numChannels >=2)
    %channel 1
    packet(ch1Base + 1) = bitand(bitshift(ch1_threshold,-24),2^8-1);
    packet(ch1Base + 2) = bitand(bitshift(ch1_threshold,-16),2^8-1);
    packet(ch1Base + 3) = bitand(bitshift(ch1_threshold,-8),2^8-1);
    packet(ch1Base + 4) = bitand(bitshift(ch1_threshold,0),2^8-1);
    packet(ch1Base + 5) = ch1_fftSize;
    packet(ch1Base + 6) = ch1_mode;
    packet(ch1Base + 7) = bitand(bitshift(ch1_freq,-24),2^8-1);
    packet(ch1Base + 8) = bitand(bitshift(ch1_freq,-16),2^8-1);
    packet(ch1Base + 9) = bitand(bitshift(ch1_freq,-8),2^8-1);
    packet(ch1Base + 10) = bitand(bitshift(ch1_freq,0),2^8-1);
    packet(ch1Base + 11) = ch1_spare0;
    packet(ch1Base + 12) = ch1_spare1;
end
if(gen_numChannels >=3)
    %channel 2
    packet(ch2Base + 1) = bitand(bitshift(ch2_threshold,-24),2^8-1);
    packet(ch2Base + 2) = bitand(bitshift(ch2_threshold,-16),2^8-1);
    packet(ch2Base + 3) = bitand(bitshift(ch2_threshold,-8),2^8-1);
    packet(ch2Base + 4) = bitand(bitshift(ch2_threshold,0),2^8-1);
    packet(ch2Base + 5) = ch2_fftSize;
    packet(ch2Base + 6) = ch2_mode;
    packet(ch2Base + 7) = bitand(bitshift(ch2_freq,-24),2^8-1);
    packet(ch2Base + 8) = bitand(bitshift(ch2_freq,-16),2^8-1);
    packet(ch2Base + 9) = bitand(bitshift(ch2_freq,-8),2^8-1);
    packet(ch2Base + 10) = bitand(bitshift(ch2_freq,0),2^8-1);
    packet(ch2Base + 11) = ch2_spare0;
    packet(ch2Base + 12) = ch2_spare1;
end
if(gen_numChannels >=4)
    %channel 3
    packet(ch3Base + 1) = bitand(bitshift(ch3_threshold,-24),2^8-1);
    packet(ch3Base + 2) = bitand(bitshift(ch3_threshold,-16),2^8-1);
    packet(ch3Base + 3) = bitand(bitshift(ch3_threshold,-8),2^8-1);
    packet(ch3Base + 4) = bitand(bitshift(ch3_threshold,0),2^8-1);
    packet(ch3Base + 5) = ch3_fftSize;
    packet(ch3Base + 6) = ch3_mode;
    packet(ch3Base + 7) = bitand(bitshift(ch3_freq,-24),2^8-1);
    packet(ch3Base + 8) = bitand(bitshift(ch3_freq,-16),2^8-1);
    packet(ch3Base + 9) = bitand(bitshift(ch3_freq,-8),2^8-1);
    packet(ch3Base + 10) = bitand(bitshift(ch3_freq,0),2^8-1);
    packet(ch3Base + 11) = ch3_spare0;
    packet(ch3Base + 12) = ch3_spare1;
end
temp=instrfind;
if(~isempty(temp))
    fclose(temp);
    delete(temp);
end
%Note, for packet to be received, it has to be TOTALLY correct.  Including
%IP length, UDP length and IP checksum

u1=udp('192.168.10.255','RemotePort',9094,'LocalPort',9095,'inputbuffersize',8192);
u2=udp('192.168.10.100','RemotePort',9091,'LocalPort',9090,'InputBufferSize',65536,'Timeout',0.5); %,'DatagramTerminateMode','off'


fopen(u1);
fopen(u2);
tic;
fwrite(u1,packet);

%specific for function
popup_sel_index = 4;
% ch0_threshold
% cla;
%retrieve the application data
% data=getappdata(handles.figure1,'mydata');
% data=handles.data;

%assign variables

% ch0_threshold = str2num(get(handles.edit2,'String'));
% disp(ch0_threshold)

% ch0_fftSize=str2num(get(handles.edit3,'String'));;
% ch0_fftSize=8;
disp(ch0_fftSize)
% popup_sel_index = get(handles.popupmenu1, 'Value');
% switch popup_sel_index
%     case 1
%         ch0_mode=5;
%     case 2
%          ch0_mode=2;
%     case 3
%          ch0_mode=4;
% end

%plotting variables

% centerFreq = str2num(get(handles.edit1,'String'));

% Fs=100e6;
% dc=0;
% shift = 0;

%form packet
% packet = createPacket(ch0_threshold,ch0_fftSize,ch0_mode);

%write out command
% fwrite(data.u1,packet);



%receive data
packetLen=(2^ch0_fftSize)*4/1024;
rawData=[];
threshData=[];
fftValid=0;
if(packetLen <=1) 
    packetLen=1;
end
if (ch0_mode==4)
%     disp('reading raw data')
    rawData=zeros(1026,packetLen);
    B=zeros(1026,1);
    for i=1:packetLen
        B=fread(u2,(2^ch0_fftSize)*4+2,'uint8');
        if(isempty(B)==0)
            rawData(:,i)=B;
            fftValid=1;
        else
            fftValid=0;
        end
    end
elseif (ch0_mode==2)
%     disp('reading thresh data')
    threshData=fread(u2,(2^ch0_fftSize)*4/32+6,'uint8'); 
elseif (ch0_mode==5)
%     disp('reading thresh data')
    threshData=fread(u2,(2^ch0_fftSize)*4/32+6,'uint8'); 
%     disp('reading raw data')
    rawData=zeros(1026,packetLen);
    B=zeros(1026,1);
    for i=1:packetLen
        B=fread(u2,(2^ch0_fftSize)*4+2,'uint8');
        if(isempty(B)==0)
            rawData(:,i)=B;
        fftValid=1;
        else
            fftValid=0;
        end
    end
end

%plot data
%plot the data

f=linspace(centerFreq-((Fs)/2),((Fs)/2)+centerFreq,2^ch0_fftSize); %one sided spectrum picture
t=ch0_threshold*(ones(length(f),1));
dataFFT=[];
dataOut=[];
if(ch0_mode == 4||ch0_mode == 5)
    %TODO: fix this, have to add one because we're one short
    if(ch0_fftSize >=8)
        for i=1:packetLen
            dataFFTtemp=rawData(7:length(rawData),i);
            dataFFTtemp=dataFFTtemp(1:4:length(dataFFTtemp))*2^24+dataFFTtemp(2:4:length(dataFFTtemp))*2^16+dataFFTtemp(3:4:length(dataFFTtemp))*2^8+dataFFTtemp(4:4:length(dataFFTtemp));
            dataFFTtemp=[dataFFTtemp' 0];
            dataFFT=[dataFFT dataFFTtemp];
        end
    else
        dataFFT=rawData(7:length(rawData),:);
        dataFFT=dataFFT(1:4:length(dataFFT))*2^24+dataFFT(2:4:length(dataFFT))*2^16+dataFFT(3:4:length(dataFFT))*2^8+dataFFT(4:4:length(dataFFT));
        if(ch0_fftSize ==8)
            dataFFT=[dataFFT' 0];
        end
        if(ch0_fftSize <=7)
            dataFFT=dataFFT(1:2^ch0_fftSize);
        end
    end
    LenFFT=length(dataFFT);
    
    dataFFT=fftshift(dataFFT);
    if(dc==1)
        f=f(2:length(f));
        dataFFT=dataFFT(2:length(dataFFT)); %remove the first sample since its DC
    else
        dataFFT = dataFFT(1:length(dataFFT));%data(2:length(data)/2+1); %remove the first sample since its DC
    end

    specFPGAraw = 20*log10(dataFFT); %specFPGA = 20*log10(sqrt(dataFFT));
    specFPGA = specFPGAraw-max(specFPGAraw);
end

if((ch0_mode == 2||ch0_mode == 5)&&(length(threshData)>0))
    dataThresh=threshData(7:length(threshData));
    dataThresh=dataThresh(1:4:length(dataThresh))*2^24+dataThresh(2:4:length(dataThresh))*2^16+dataThresh(3:4:length(dataThresh))*2^8+dataThresh(4:4:length(dataThresh));
    LenThresh=length(dataThresh);
    dataOut=zeros(2^ch0_fftSize,1);
    dataBin=dec2bin(dataThresh,32);
    for i=1:2^ch0_fftSize/32
        k=32;
        for j=1:32 
            if((dataBin(i,j)-48) == 1)
                if(ch0_mode == 4||ch0_mode == 5)
                    dataOut((i-1)*32+k)=(max(dataFFT)-ch0_threshold)/2+ch0_threshold;
                else
                    dataOut((i-1)*32+k)=ch0_threshold;
                end
                
            else
                dataOut((i-1)*32+k)=100;
            end
            k=k-1;
        end
    end
    dataOut=fftshift(dataOut);
    if (shift>=1)
        dataOut(1+shift:length(dataOut)) = dataOut(1:length(dataOut)-shift);
    end
end

%check data
threshValid=~isempty(dataOut)
% fftValid =~isempty(rawData)
if((ch0_mode == 2||ch0_mode == 5)&&threshValid == 0)
   disp('threshold packet not received') 
end
if((ch0_mode == 4||ch0_mode == 5)&&fftValid == 0)
   disp('FFT packet not received') 
end
%plot data

if(fftValid)
    cla
%     hold('on')
    h=plot(f,dataFFT,'b','LineWidth',2.0);
    % First get the figure's data-cursor mode, activate it, and set some of its properties
    cursorMode = datacursormode(gcf);
    set(cursorMode, 'enable','on', 'NewDataCursorOnClick',false);

    % Create a new data tip
    hTarget = handle(h);
    hDatatip = cursorMode.createDatatip(h);

    % Create a copy of the context menu for the datatip:
    set(hDatatip,'UIContextMenu',get(cursorMode,'UIContextMenu'));
    set(hDatatip,'HandleVisibility','off');
    set(hDatatip,'Host',hTarget);
    set(hDatatip,'ViewStyle','datatip');

    % Set the data-tip orientation to top-right rather than auto
    set(hDatatip,'OrientationMode','manual');
    set(hDatatip,'Orientation','bottom-right');

    % Update the datatip marker appearance
    set(hDatatip, 'MarkerSize',5, 'MarkerFaceColor','none', ...
                  'MarkerEdgeColor','k', 'Marker','o', 'HitTest','off');

    % Move the datatip to the right-most data vertex point
    %     position = [xdata(end),ydata(end),1; xdata(end),ydata(end),-1];
    position = [f(find(dataFFT==max(dataFFT))),max(dataFFT)];
    update(hDatatip, position);
    
    hold('on')
    
    plot(f,t,'-g','LineWidth',2.0);
    drawnow;
end
hold('on')
% if(fftValid && threshValid)
%     hold
% end
if(threshValid)
    if(fftValid==0)
        cla
        plot(f,t,'-g','LineWidth',2.0);
    end
    stairs(f,dataOut,'r','LineWidth',3.0);
    drawnow;
end

%second graph
% axes(handles.axes2);
figure


if(fftValid)
tS=(20*log10(ch0_threshold)-max(specFPGAraw))*(ones(length(f),1));
    cla;
%     hold('on')
    h=plot(f,specFPGA,'b','LineWidth',2.0);
    hold('on')
    plot(f,tS,'-g','LineWidth',2.0);
    drawnow;
end
% hold('on')
% if(threshValid)
%     dataOutSpec=zeros(2^ch0_fftSize,1);
%     for i=1:2^ch0_fftSize/32
%         k=32;
%         for j=1:32 
%             if((dataBin(i,j)-48) == 1)
%                 if(ch0_mode == 4||ch0_mode == 5)
%                     dataOutSpec((i-1)*32+k)=20*log10(ch0_threshold)
%                 else
%                     dataOutSpec((i-1)*32+k)=100;
%                 end
%                 
%             else
%                 dataOutSpec((i-1)*32+k)=100;
%             end
%             k=k-1;
%         end
%     end
%     plot(f,)
% end

save('curData.mat','dataOut','dataFFT', 'rawData');
% guidata(hObject,handles)





% % packetLen=(2^ch0_fftSize)*4/1024;
% % rawData='';
% % threshData='';
% % if(packetLen <=1) 
% %     packetLen=1;
% % end
% % if (ch0_mode==4)
% %     disp('reading raw data')
% %     rawData=zeros(1026,packetLen);
% %     B=zeros(1026,1);
% %     for i=1:packetLen
% %         B=fread(u2,(2^ch0_fftSize)*4+2,'uint8');
% %         if(isempty(B)==0)
% %             rawData(:,i)=B;
% %         end
% %     end
% % elseif (ch0_mode==2)
% %     disp('reading thresh data')
% %     threshData=fread(u2,(2^ch0_fftSize)*4/32+6,'uint8'); 
% % elseif (ch0_mode==5)
% %     disp('reading thresh data')
% %     threshData=fread(u2,(2^ch0_fftSize)*4/32+6,'uint8'); 
% %     disp('reading raw data')
% %     rawData=zeros(1026,packetLen);
% %     B=zeros(1026,1);
% %     for i=1:packetLen
% %         B=fread(u2,(2^ch0_fftSize)*4+2,'uint8');
% %         if(isempty(B)==0)
% %             rawData(:,i)=B;
% %         end
% %     end
% % end
% % time=toc;
% % fprintf('writing and reading the packet took %f seconds\n',time);
% % if(isempty(rawData)==0)
% %     disp('correctly read raw data')
% % end
% % if(isempty(threshData)==0)
% %     disp('correctly read thresh data')
% % end
% % if(plotData==1)
% %     %plot the data
% %     dataFFT=rawData(7:length(rawData),:);
% %      dataFFT=dataFFT(1:4:length(dataFFT))*2^24+dataFFT(2:4:length(dataFFT))*2^16+dataFFT(3:4:length(dataFFT))*2^8+dataFFT(4:4:length(dataFFT));
% %      %TODO: fix this, have to add one because we're one short
% %      dataFFT=[dataFFT' 0];
% % 
% %     dataThresh=threshData(7:length(threshData));
% %     dataThresh=dataThresh(1:4:length(dataThresh))*2^24+dataThresh(2:4:length(dataThresh))*2^16+dataThresh(3:4:length(dataThresh))*2^8+dataThresh(4:4:length(dataThresh));
% %     LenFFT=length(dataFFT);
% %     LenThresh=length(dataThresh);
% % 
% %     f=linspace(centerFreq-((Fs)/2),((Fs)/2)+centerFreq,2^ch0_fftSize); %one sided spectrum picture
% %     dataFFT=fftshift(dataFFT);
% %     if(dc==1)
% %         f=f(2:length(f));
% %         dataFFT=dataFFT(2:length(dataFFT)); %remove the first sample since its DC
% %     else
% %         dataFFT = dataFFT(1:length(dataFFT));%data(2:length(data)/2+1); %remove the first sample since its DC
% %     end
% % 
% %     specFPGA = 20*log10(sqrt(dataFFT));
% %     specFPGA = specFPGA-max(specFPGA);
% % 
% %     dataOut=zeros(2^ch0_fftSize,1);
% %     dataBin=dec2bin(dataThresh,32);
% %     for i=1:2^ch0_fftSize/32
% %         k=32;
% %         for j=1:32 
% %             if((dataBin(i,j)-48) == 1)
% %                 dataOut((i-1)*32+k)=ch0_threshold;
% %             else
% %                 dataOut((i-1)*32+k)=ch0_threshold/2;
% %             end
% %             k=k-1;
% %         end
% %     end
% %     preShift=dataOut;
% %     dataOut=fftshift(dataOut);
% %     if (shift>=1)
% %         dataOut(1+shift:length(dataOut)) = dataOut(1:length(dataOut)-shift);
% %     end
% %     figure
% %     h=plot(f,dataFFT,'b');
% %     % First get the figure's data-cursor mode, activate it, and set some of its properties
% %     
% %     cursorMode = datacursormode(gcf);
% %     set(cursorMode, 'enable','on', 'NewDataCursorOnClick',false);
% %     
% %     % Create a new data tip
% %     hTarget = handle(h);
% %     hDatatip = cursorMode.createDatatip(h);
% %  
% %     % Create a copy of the context menu for the datatip:
% %     set(hDatatip,'UIContextMenu',get(cursorMode,'UIContextMenu'));
% %     set(hDatatip,'HandleVisibility','off');
% %     set(hDatatip,'Host',hTarget);
% %     set(hDatatip,'ViewStyle','datatip');
% % 
% %     % Set the data-tip orientation to top-right rather than auto
% %     set(hDatatip,'OrientationMode','manual');
% %     set(hDatatip,'Orientation','top-right');
% % 
% %     % Update the datatip marker appearance
% %     set(hDatatip, 'MarkerSize',5, 'MarkerFaceColor','none', ...
% %                   'MarkerEdgeColor','k', 'Marker','o', 'HitTest','off');
% % 
% %     % Move the datatip to the right-most data vertex point
% % %     position = [xdata(end),ydata(end),1; xdata(end),ydata(end),-1];
% %     position = [f(find(dataFFT==max(dataFFT))),max(dataFFT)];
% %     update(hDatatip, position);
% %     
% %     
% %     hold
% %     stairs(f,dataOut,'r');
% % end

fclose(u1);
delete(u1);
fclose(u2);
delete(u1);


