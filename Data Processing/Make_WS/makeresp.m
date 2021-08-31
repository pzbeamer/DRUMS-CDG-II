function Rdata = makeresp(Tdata,ECG,figureson)
%{
Makes continuous respiration signal. Loads in 
    Tdata - Time points in seconds (sec)
    ECG   - ECG data must be in millivolts (mV)
    figureson - If 1, it plots a bunch of figures 
%}
Tdata = Tdata - min(Tdata);
dt = mean(diff(Tdata)); 
Fs = round(1/dt); 

if figureson == 1
    %Plot original ECG signal 
    figure(1)
    clf
    plot(Tdata,ECG,'k','linewidth',1)
    xlabel('Time (sec)')
    ylabel('ECG (mV)')
    set(gca,'FontSize',16)
end 

%% Correct baseline of ECG signal with medfilt1

%Filter out P waves and QRS complex with a window of 200 ms
smoothECG = medfilt1(ECG,round(.2/dt)); 

if figureson == 1
    %Plot 200 ms filter on top of ECG
    figure(1); hold on;
    plot(Tdata,smoothECG,'r','linewidth',2)
end 
 
%Filter out T waves with a window of 600 ms 
smoothECG2 = medfilt1(smoothECG,round(.6/dt)); 

if figureson == 1
    %Plot 600 ms filter on top of ECG
    figure(1); hold on;
    plot(Tdata,smoothECG2,'c','linewidth',2)
end

%Baseline corrected ECG signal
BaselineCorrectedECG = ECG - smoothECG2; 

if figureson == 1
    %Plot baseline-correctd ECG 
    figure(2); clf;
    plot(Tdata,BaselineCorrectedECG,'k','linewidth',1)
end  

%% Savitsky-Golay Filter 

%Savitsky-Golay Filter filters out VERY low frequency signals. The window
%must be odd and within .15 sec 
SVGwindow = round(.15/dt); 
if mod(SVGwindow,2) == 0
    SVGwindow = SVGwindow + 1;
end 
%Check to ensure order is less than window size 
if SVGwindow > 5
    SVGorder = 3; 
else
    SVGorder = 3; 
end 
smoothECG3 = sgolayfilt(BaselineCorrectedECG,SVGorder,SVGwindow); 

if figureson == 1
    %Plot SVG filter on top of baseline-corrected ECG 
    figure(2); hold on;
    plot(Tdata,smoothECG3,'r','linewidth',2)
end  

%% Accentuate peaks to easily find them 

%Can now extract Q and R peaks 
accentuatedpeaks = BaselineCorrectedECG - smoothECG3; 

if figureson == 1
    %Plot of baseline-corrected ECG with accentuated peaks 
    figure(3)
    clf
    plot(Tdata,accentuatedpeaks,'k','linewidth',1)
    xlabel('Time (sec)')
    ylabel('Filtered ECG (mV)')
    set(gca,'FontSize',16)
end  

%Finds Q and R points with minimum peak distance of 200 ms 
[~,z] = findpeaks(accentuatedpeaks,'MinPeakDistance',round(.2/dt)); 
zz = mean(accentuatedpeaks(z)); 
[~,iR] = findpeaks(accentuatedpeaks,'MinPeakHeight',zz,'MinPeakDistance',round(.2/dt)); 
[~,y] = findpeaks(-accentuatedpeaks,'MinPeakDistance',round(.2/dt)); 
yy = -mean(accentuatedpeaks(y));
[~,iQ] = findpeaks(-accentuatedpeaks,'MinPeakHeight',yy,'MinPeakDistance',round(.2/dt)); 

R  = accentuatedpeaks(iR);
TR = Tdata(iR); 
Q  = accentuatedpeaks(iQ);
TQ = Tdata(iQ); 

%Check to ensure all peaks are >= 25% of the mean or <= 200% of the mean
mR = mean(R);
mQ = mean(Q);
xR = find(R <= 2*mR & R >= .25*mR);
xQ = find(Q >= 2*mQ & Q <= .25*mQ);
R  = R(xR);
TR = TR(xR);
iR = iR(xR);
Q  = Q(xQ);
TQ = TQ(xQ);
iQ = iQ(xQ); 

%Check for first peak -  Q before R 
if TR(1) - TQ(1) < 0 
    R  = R(2:end); 
    TR = TR(2:end); 
    iR = iR(2:end); 
end  

%Check to ensure lengths of vectors are the same 
nR = length(R);
nQ = length(Q); 
if nR ~= nQ
    if nR > nQ 
        [~,i] = sort(R,'descend');      %Sort R vector max to min 
        nn = nR - nQ;
        iR = iR(i(floor(1+nn/2):floor(end-nn/2))); %Take middle nQ peaks
        TR = Tdata(iR);                 %Find times at those peaks
        [TR,ii] = sort(TR,'ascend');    %Sort time vector to ascending
        iR = iR(ii);                    %Resort index vector 
    else 
        [~,i] = sort(Q,'ascend');       %Sort Q vector min to max
        nn = nQ - nR; 
        iQ = iQ(i(floor(1+nn/2):floor(end-nn/2))); %Take middle nR peaks
        TQ = Tdata(iQ);                 %Find times at those peaks 
        [TQ,ii] = sort(TQ,'ascend');    %Sort time vector to ascending 
        iQ = iQ(ii);                    %Resort index vector 
    end 
end

if figureson == 1
    %Plot of baseline-corrected ECG with accentuated peaks with R- and Q-
    %points
    figure(3)
    hold on
    plot(TQ,accentuatedpeaks(iQ),'ro',TR,accentuatedpeaks(iR),'bo','linewidth',2)
end  

%% Plot original ECG with R- and Q-points found 

if figureson == 1 
    %Plot original ECG with R- and Q-points 
    figure(4)
    clf
    plot(Tdata,ECG,'k','linewidth',1)
    hold on 
    plot(TR,ECG(iR),'bo',TQ,ECG(iQ),'ro')
    xlabel('Time (sec)')
    ylabel('ECG (mV)')
    set(gca,'FontSize',16)
end  

%% Find amplitude of R- and Q-points and average time points 

%Find amplitude as difference of R- and Q-waves
RQ = BaselineCorrectedECG(iR) - BaselineCorrectedECG(iQ); 

%Take average time between Q-and R-waves 
TRQ = (TR + TQ)/2;

%Check for positive amplitudes 
xRQ = find(RQ > 0); 
RQ  = RQ(xRQ); 
TRQ = TRQ(xRQ); 

%Check to ensure amplitudes are <= 25% or >= 200% mean amplitude
mRQ = mean(RQ); 
xRQ = find(RQ >= .25*mRQ & RQ <= 2*mRQ);
RQ  = RQ(xRQ);
TRQ = TRQ(xRQ);

%% Interpolate through amplitude points 

%Include first and last time points for piecewise cubic Hermite splines 
RQ  = [RQ(1); RQ; RQ(end)];
TRQ = [Tdata(1); TRQ; Tdata(end)]; 

%Use PCHIP algorithm to interpolate through amplitudes (this algorithm
%preserves derivative behavior)
S    = griddedInterpolant(TRQ,RQ,'pchip'); 
QRamplitudes = S(Tdata); %Evaluate at the time points 

if figureson == 1 
    %Plot interpolated QR amplitudes 
    figure(5);
    clf
    plot(Tdata,QRamplitudes,'k',TRQ,RQ,'ro','linewidth',2);
    set(gca,'fontsize',20);
    ylabel('QR amplitude (mV)');
    xlabel('Time (sec)');
end  

%% Find peaks and valleys minimum peak distance of 1.5 sec 

[p,ploc] = findpeaks(QRamplitudes,Fs,'MinPeakDistance',1.5); 
[v,vloc] = findpeaks(-QRamplitudes,Fs,'MinPeakDistance',1.5);
v = -v;

if figureson == 1
    %Plot QR amplitude interopation with filtered peaks and valleys 
    figure(6)
    clf
    plot(Tdata,QRamplitudes,'b',ploc,p,'ro',vloc,v,'ko','linewidth',2)
    set(gca,'fontsize',20);
    legend('','End Expiration','End Inspiration');
    ylabel('QR amplitude (mV)');
    xlabel('Time (sec)');
end  

%Reorganize time vector and sort filtered peaks and valleys of QR amp
%signal
Tloc = [ploc; vloc]; 
[Tloc,ii] = sort(Tloc,'ascend'); 
Points = [p; v]; 
Points = Points(ii);
Tloc = [Tdata(1); Tloc; Tdata(end)];
Points = [QRamplitudes(1); Points; QRamplitudes(end)];
ss = griddedInterpolant(Tloc,Points,'pchip'); 

[Ex,T_Ex] = findpeaks(ss(Tdata),Fs); 
[In,T_In] = findpeaks(-ss(Tdata),Fs); 
In = -In; 

%Check to ensure first time point is included
if T_Ex(1) < T_In(1) 
    T_In = [Tdata(1); T_In]; 
    In = [ss(Tdata(1)); In]; 
end 
%Check to ensure last time point is included 
if T_In(end) > T_Ex(end) 
    T_Ex = [T_Ex; Tdata(end)];
    Ex = [Ex; ss(Tdata(end))];
end 

%% Impose restrictions from Widjaja paper 

%Amplitude of each breath 
Ramp = Ex - In;
%Difference in previous and subsequent amplitudes 
surroundingampdiff = abs(Ramp(3:end) - Ramp(1:end-2));
%Find 15% amplitude difference 
Ramp15diff = .15*surroundingampdiff; 
F = [Ramp(1); Ramp15diff; Ramp(end)]; 
%Remove amplitudes less than 15% of difference of the surrounding
%amplitudes
ii = [];
for i = 1:length(Ramp)
    if Ramp(i) >= F(i)
        ii = [ii i];
    end 
end 

%Combine filtered expiration and inspiration signals and sort
Ex = Ex(ii);
T_Ex = T_Ex(ii);
In = In(ii);
T_In = T_In(ii);
[newT,i] = sort([T_Ex; T_In],'ascend'); 
newR = [Ex; In];
newR = newR(i); 

%Tack on end time points for PCHIP interpolation
if isempty(find(newT == Tdata(1),1)) == 1
    newT = [Tdata(1); newT];
    newR = [ss(Tdata(1)); newR];
end 
if isempty(find(newT == Tdata(end),1)) == 1
    newT = [newT; Tdata(end)];
    newR = [newR; ss(Tdata(end))]; 
end
if isempty(find(newT == Tdata(1) | newT == Tdata(end),1)) == 1 
    newT = [Tdata(1); newT; Tdata(end)];
    newR = [ss(Tdata(1)); newR; ss(Tdata(end))]; 
end  
Rspline = griddedInterpolant(newT,newR,'pchip'); 
Rdata = Rspline(Tdata); 

if figureson == 1
    %Plot filtered respiratory signal on QR amplitude 
    figure(6); hold on;
    plot(Tdata,Rdata,'g--','linewidth',2)
    set(gca,'fontsize',20);
    legend('','End Expiration','End Inspiration');
    ylabel('QR amplitude (mV)');
    xlabel('Time (sec)');
end 

if figureson == 1
    %Plot respiration alone 
    figure(7)
    plot(Tdata,Rdata,'k','linewidth',3)
    set(gca,'FontSize',20)
    xlabel('Time (sec)')
    ylabel('QR Amplitude (mV)')
end 


end 