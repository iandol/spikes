%*--------------------------------------------------------------------*
%|                   FFT Harmonic Finding Function v0.1               |
%|                    (Rowland Sillito September 2001)                |
%|--------------------------------------------------------------------|
%|       Written as an accessory to Ian's Spike Analysis program      |
%|                                                                    |
%| *use fft=computefft(harmn1,harmn2,errortype,tempfreq)              |
%|                                                                    |
%| *set harmn2 to be infinity to calculate individual harmonics       |
%|  as specified by harmn1                                            |
%| *use harmn1 and harmn2 to get the values of harmonic1/harmonic2    |
%| *errortype takes the same values as those in spikes                |
%|                                                                    |
%| *output is fft.fftvalue  - a matrix of fft harmonics/ratios thereof|
%|            fft.errvalue  - a matrix of the error values            |
%|            fft.freq      - the exact frequencies for the harmonics |
%|            fft.infpoint  - arbitrary value for infinity points     |
%|            fft.nnpoint   - arbitrary value for Not-A-Number points |
%|                                                                    |
%|                                                                    |
%| [5.04.02 ian - fixed the memory bug and errorbar problems          |
%*--------------------------------------------------------------------*

function fftmatrix=computefft(harmn1,harmn2,errortype,tempfreq,infpoint,zeropoint)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------ Variable Declaration ------------------%

global data %so we can see what Spikes knows
global StartMod
global EndMod

%--------------- End of Variable Declaration ---------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------- Main Program ----------------------%

%Calculate scaling factor, so our harmonics are in Hz
if data.wrapped==1
sf=1000/(data.raw{1}.numtrials*data.raw{1}.nummods*data.binwidth); %for the data values
sf2=1000/data.binwidth; %for the error values
else
sf=1000/(data.raw{1}.numtrials*data.binwidth);  %for the data values
sf2=1000/data.binwidth; %for the error values
end

%So later on we can use one loop to deal with 1variable data & 2variable data
if data.numvars>1
   ynum=data.yrange;
else
   ynum=1;
end

time=(max(data.time{1})+data.binwidth)/1000; %time in seconds for the psths

fftmatrix.fftvalue=zeros(ynum,data.xrange);  %preparing the matrix for fft values
fftmatrix.errvalue=zeros(ynum,data.xrange);  %..and for error values


%Finding fft harmonics, or ratios of one to another
for i=1:(data.xrange*ynum) 
   if harmn2~=inf  %if we're calculating a ratio
      [a1,f1]=fftval(data.psth{i},time,harmn1,tempfreq);
      [a2,f2]=fftval(data.psth{i},time,harmn2,tempfreq);
      if a1~=0 & a2==0 & infpoint~=inf     %if its x/0 and we have specified NaN/infinity points
         val=inf;
      elseif a1==0 & a2==0 & infpoint~=inf %if its 0/0 and we have specified NaN/infinity points
         val=-1;
      elseif a2~=0 | infpoint==inf         %if its x/y or 0/x or there's no NaN/infinity point set
         val=a1/a2;
      end
      fftmatrix.fftvalue(i)=val;
   else            %if we're calculating a single harmonic
      [a,f]=fftval(data.psth{i},time,harmn1,tempfreq);      
      fftmatrix.fftvalue(i)=sf*a;
   end
end

%Find the exact freqencies we're referring to...
if harmn2~=inf  %if we're calculating a ratio
   [a1,f1]=fftval(data.psth{1},time,harmn1,tempfreq);
   [a2,f2]=fftval(data.psth{1},time,harmn2,tempfreq);
   fftmatrix.freq=[f1,f2];
else            %if we're calculating a single harmonic
   [a,f]=fftval(data.psth{1},time,harmn1,tempfreq);
   fftmatrix.freq=f;
end



%Finding error values
for i=1:(data.xrange*ynum) 
   for j=1:data.raw{i}.numtrials  
      if data.wrapped==1
         for k=1:data.raw{i}.nummods
            %get the psth for the kth modulation of the jth trial
            [tmptime,tmppsth]=binit(data.raw{i},data.binwidth*10,k,k,j,j,1);
            %find the fft harmonic/harmonic ratio for tmppsth, and store in matrix
            if harmn2~=inf
               [a1,f1]=fftval(tmppsth,time,harmn1,tempfreq);
               [a2,f2]=fftval(tmppsth,time,harmn2,tempfreq);
               if a2~=0 %just so we don't get error messages about things we'll be ignoring
                  tmpfft(j,k)=a1/a2;
               else
                  tmpfft(j,k)=0;
               end
            else
               [a,f]=fftval(tmppsth,time,harmn1,tempfreq);
               tmpfft(j,k)=sf2*a;
            end
         end
      else
         %get the psth for the jth unwapped trial
         [tmptime,tmppsth]=binit(data.raw{i},data.binwidth*10,StartMod,EndMod,j,j,1);
         %find and store fft as before
         if harmn2~=inf
            [a1,f1]=fftval(tmppsth,time,harmn1,tempfreq);
            [a2,f2]=fftval(tmppsth,time,harmn2,tempfreq);
            if a2~=0 %just so we don't get error messages about things we'll be ignoring
               tmpfft(j)=a1/a2;
            else
               tmpfft(j)=0;
            end
         else
            [a,f]=fftval(tmppsth,time,harmn1,tempfreq);
            tmpfft(j)=sf2*a;
         end
      end
   end
   %find and resize the matrix of fft values so that errorfun can use it
   a=size(tmpfft);
   tmpfft=reshape(tmpfft,[1 a(1)*a(2)]);
   %get the error value and store it
   fftmatrix.errvalue(i)=errorfun(tmpfft,errortype);
   clear tmpfft
end

if infpoint~=inf %if we've got abitrary infinity points to put in
   maxval=max(fftmatrix.fftvalue(find(fftmatrix.fftvalue~=inf)));
   fftmatrix.errvalue(find(fftmatrix.fftvalue==inf))=0;
   fftmatrix.errvalue(find(fftmatrix.fftvalue==-1))=0;
   fftmatrix.fftvalue(find(fftmatrix.fftvalue==inf))=maxval*infpoint;
   fftmatrix.fftvalue(find(fftmatrix.fftvalue==-1))=-1*zeropoint;
   fftmatrix.nnpoint=-1*zeropoint;
   fftmatrix.infpoint=maxval*infpoint;
else            %or even if we don't, we still want the error as 0 for such points
   fftmatrix.errvalue(find(~(fftmatrix.fftvalue>0) & ~(fftmatrix.fftvalue<0) & ~(fftmatrix.fftvalue==0)))=0;
end

%-------------------- End of Main Program ------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------ Extra Function Declarations ------------------%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      finds fft values, taken from fftplot2        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [findfftval,fftfreq] = fftval(y,maxtime,harmonic,tmpf)

if size(y,1) ==1
    y = y';
end
nSteps=length(y);
ffty=fft(y);
ffty = ffty(1:ceil(nSteps/2));
ffty = 2*ffty/nSteps; %now the amplitudes are correct.
amp = abs(ffty);
%ph = angle(ffty);
amp(1) = amp(1)/2;
dc=amp(1); %d.c. is the 0 harmonic
freq=(0:length(ffty)-1)/maxtime;

%Finds those harmonics at frequencies closest to those desired
a=find((freq-(harmonic*tmpf)).^2==min((freq-(harmonic*tmpf)).^2));
findfftval=amp(a);
fftfreq=freq(a); %so one can see what frequency is actually used

%--------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------
%
%
% Computes the Error Data

function error = errorfun(data,type)

switch(type)

case 'Standard Error'
   err=std(data);
   error=sqrt(err.^2/length(data));   
case 'Standard Deviation'
   error=std(data);   
case '2 StdDevs'
   error=(std(data))*2;
case '3 StdDevs'
   error=(std(data))*3;   
case '2 StdErrs'
   err=std(data);
   error=sqrt((err.^2/length(data)))*2;   
case 'Variance'
   error=std(data).^2;  
end

%------------------- End of Declarations -------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 