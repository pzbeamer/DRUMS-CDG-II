function iR = makeR(Tdata,ECG)
%{
Makes continuous respiration signal. Loads in 
    Tdata - Time points in seconds (sec)
    ECG   - ECG data must be in millivolts (mV)
    figureson - If 1, it plots a bunch of figures 
%}
Tdata = Tdata - min(Tdata);
dt = mean(diff(Tdata)); 
Fs = round(1/dt); 

%% Correct baseline of ECG signal with medfilt1

%Filter out P waves and QRS complex with a window of 200 ms
smoothECG = medfilt1(ECG,round(.2/dt)); 
 
%Filter out T waves with a window of 600 ms 
smoothECG2 = medfilt1(smoothECG,round(.6/dt)); 

%Baseline corrected ECG signal
BaselineCorrectedECG = ECG - smoothECG2; 

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

%% Accentuate peaks to easily find them 

%Can now extract Q and R peaks 
accentuatedpeaks = BaselineCorrectedECG - smoothECG3; 

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

%% Plot original ECG with R- and Q-points found 

    %Plot original ECG with R- and Q-points 
%     figure(4)
%     clf
%     plot(Tdata,ECG,'k','linewidth',1)
%     hold on 
%     plot(TR,ECG(iR),'bo')
%     xlabel('Time (sec)')
%     ylabel('ECG (mV)')
%     set(gca,'FontSize',16)
