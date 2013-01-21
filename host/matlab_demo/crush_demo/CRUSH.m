function varargout = CRUSH(varargin)
% CRUSH MATLAB code for CRUSH.fig
%      CRUSH, by itself, creates a new CRUSH or raises the existing
%      singleton*.
%
%      H = CRUSH returns the handle to a new CRUSH or the handle to
%      the existing singleton*.
%
%      CRUSH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CRUSH.M with the given input arguments.
%
%      CRUSH('Property','Value',...) creates a new CRUSH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CRUSH_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CRUSH_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CRUSH

% Last Modified by GUIDE v2.5 12-Jan-2012 14:30:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CRUSH_OpeningFcn, ...
                   'gui_OutputFcn',  @CRUSH_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before CRUSH is made visible.
function CRUSH_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CRUSH (see VARARGIN)

% Choose default command line output for CRUSH
handles.output = hObject;
cla
% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using CRUSH.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

%remove old udp ports
temp=instrfind;
if(~isempty(temp))
    fclose(temp);
    delete(temp);
end

data.u1=udp('192.168.10.255','RemotePort',9094,'LocalPort',9095,'inputbuffersize',8192);
data.u2=udp('192.168.10.100','RemotePort',9091,'LocalPort',9090,'InputBufferSize',65536,'Timeout',0.5); %,'DatagramTerminateMode','off'
fopen(data.u1);
fopen(data.u2);

data.tmr=timer('Period',3);


handles.data=data;
guidata(hObject,handles)
% setappdata(hObject,'mydata',data);


% UIWAIT makes CRUSH wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function timerCallback(h,e,hObject,eventdata,handles)
%retrieve the application data
disp('timer function called')
% handles
% data=getappdata(handles.figure1,'mydata');
% handles = guidata(hObject);
plotGraphs(hObject,eventdata,handles);

function varargout = CRUSH_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function plotGraphs(hObject, eventdata, handles)
axes(handles.axes1);
% cla;
%retrieve the application data
% data=getappdata(handles.figure1,'mydata');
data=handles.data;

%assign variables

ch0_threshold = str2num(get(handles.edit2,'String'));
% disp(ch0_threshold)

ch0_fftSize=str2num(get(handles.edit3,'String'));;
% ch0_fftSize=8;
% disp(ch0_fftSize)
popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        ch0_mode=5;
    case 2
         ch0_mode=2;
    case 3
         ch0_mode=4;
end

%plotting variables

centerFreq = str2num(get(handles.edit1,'String'));

Fs=100e6;
dc=0;
shift = 0;

%form packet
packet = createPacket(ch0_threshold,ch0_fftSize,ch0_mode);

%write out command
fwrite(data.u1,packet);

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
        B=fread(data.u2,(2^ch0_fftSize)*4+2,'uint8');
        if(isempty(B)==0)
            rawData(:,i)=B;
            fftValid=1;
        else
            fftValid=0;
        end
    end
elseif (ch0_mode==2)
%     disp('reading thresh data')
    threshData=fread(data.u2,(2^ch0_fftSize)*4/32+6,'uint8'); 
elseif (ch0_mode==5)
%     disp('reading thresh data')
    threshData=fread(data.u2,(2^ch0_fftSize)*4/32+6,'uint8'); 
%     disp('reading raw data')
    rawData=zeros(1026,packetLen);
    B=zeros(1026,1);
    for i=1:packetLen
        B=fread(data.u2,(2^ch0_fftSize)*4+2,'uint8');
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
axes(handles.axes2);


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
guidata(hObject,handles)
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plotGraphs(hObject,eventdata,handles);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end


%retrieve the application data
% data=getappdata(handles.figure1,'mydata');
data=handles.data;
fclose(data.u1);
delete(data.u1);
fclose(data.u2);
delete(data.u1);
delete(data.tmr)
delete(handles.figure1)
guidata(hObject,handles)

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

% set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});

function packet = createPacket(ch0_threshold,ch0_fftSize,ch0_mode)

%general variables
gen_numChannels = 1;
gen_spare0 = 0; %not used
gen_spare1 = 0; %not used

%plotting variables
plotData=1;
% centerFreq = 70e6;
Fs=100e6;
dc=0;
shift = 0;

%channel 0
% ch0_threshold = 1000000;
% ch0_fftSize = 8; %256 point FFT
if(ch0_fftSize >13)
    ch0_fftSize=13;
end
if(ch0_fftSize <3)
    ch0_fftSize=3;
end
% ch0_mode = 5; %send back raw data
ch0_freq = 0; %not used yet
ch0_spare0 = 0; %not used
ch0_spare1 = 0; %not used

%variables
packetSize = 8+12*gen_numChannels;

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



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%retrieve the application data
% data=getappdata(handles.figure1,'mydata');
data=handles.data;
set(data.tmr,'period',str2num(get(handles.edit4,'String')));
set(data.tmr,'ExecutionMode','fixedrate','timerFcn',{@timerCallback,hObject, eventdata,handles});
start(data.tmr)
guidata(hObject,handles)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%retrieve the application data
% data=getappdata(handles.figure1,'mydata');
data=handles.data;
stop(data.tmr)


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
