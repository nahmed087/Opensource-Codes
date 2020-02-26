%This script writes an .itf file for the Spirent simulator
%This creates and opens the file once (overwriting if it already exists) and writes your results one line at a time.
clear all
close all
clc

%% Input variables
Psource = 50; %in dB
Pref = -160; %in dB
dref = [100;100;0]; %[x;y;z]
t = 0:1:360; %time in sec
fL1 = 1575.42e6;
c = 3e8;
r = 250; %meters
v = 5; %m/s
w = 0.02; %radian per sec
alpha = 2;
theta0 = -pi;
lambda = c/fL1;
mode = 1; %1 = linear, 2 = crcular

xstart = 100;
ystart = 100;
zstart = 100;



%% Use any one case, comment the other
switch mode
    case 1
        % Linear Case
        az = pi/2;
        x = v*sin(az)*t;
        y = v*cos(az)*t;
        fid = fopen( 'RFISourceProfileLin.txt','wt' );
    case 2
        % Circular case
        theta = theta0 + (w*t);
        x = r*cos(theta);
        y = r*sin(theta);
        fid = fopen( 'RFISourceProfileCirc.txt','wt' );
    otherwise
        print('Invalid Mode selection')
end

%% Free space pass loss
for i =1:361
    [tgtrng(i),~] = rangeangle([x(i); y(i); zstart],[xstart; ystart; zstart]); %output is in the form [range,[az,el]]
    %Loss = pow2db((4*pi*tgtrng/lambda)^2); %this line and the next line work
    %same way
    L(i) = fspl(tgtrng(i),lambda);
    Prcvd(i) = Pref + Psource + L(i);
end

%% Generate time vector  [Very Important step!]
timesvec = datenum(2019,02,21,4,0,0:360); %420 seconds = 7 min
timesvecaray = datestr(timesvec,'HH:MM:SS');


%% Create and open a file

txt1 = timesvecaray(1,:);
txt2 = ',Modelled mode,1,1,1,1.0470811959131314,0.17485290222896524,50\n';
txt = strcat(txt1,txt2);  
fprintf(fid,txt);

N = 360; %number of lines also seconds
for t = 1:N
  txt1 = timesvecaray(t,:);
  txt3 = strcat(',Noise,1,1,1,-130,',num2str(Prcvd(t)),',on,1575420000.00,2.4e+007,off,on\n');
  txt = strcat(txt1,txt3);
  fprintf(fid,txt);
end
fclose(fid);
