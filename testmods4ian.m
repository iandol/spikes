% testmods4b.m
% 28 MAY 01 GLG; 9 JUN 01; 25 July 01; 3 Aug 01; 13 Aug 01 
% makes a gdf file of 3 uncorrelated gamma neurons modulated as specified
%	in the first section. Time resolution is 0.5ms
% time marker for period of modulation(s); 32=mo (order); 33=mr (rate)
% calls fano3b function and graphs fano vs cv^2.
%close all
clear all
ns = 8000;	% number of spikes wanted in each train
dt = .001;	% bin time in seconds
sr2 = 1000;	% 1KHz sampling rate for modulations
modlen=400000;	% length of modulation table
i=1:modlen;	% 400 seconds of modulation at 1KHz sampling rate
%ORDER MODULATION FUNCTION
%mo = 7+3.0*square(2*pi*i/5000);	% 5sec square wave period; order 7 +/-3
%mo = 5+4*sin(2*pi*i/5000);		% 5sec sine wave period; order 5 +/-4
mo = 1*ones(1,modlen);			% constant order -- Poisson in this case
%RATE MODULATION FUNCTION
%mr = 25+15*square(2*pi*i/5000);	% 5sec square wave period; rate 25 +/-15
mr = 25+15*sin(2*pi*i/5000);	% 5sec sine wave period; rate 25 +/-15
%mr = 25*ones(1,modlen);		% constant rate
%
% defines the shared modulation cycles for all three neurons.
mod = diff(mo);
tmo = (2000/sr2)*find(mod>0.01);	% time in 0.5msec
mrd = diff(mr);
tmr = (2000/sr2)*find(mrd>0.01);	% time in 0.5msec
if (~isempty(tmo))
   trainsmo = 32*ones(length(tmo),2);
   trainsmo(:,2) = tmo';
else
   trainsmo = [32 1];
end
if (~isempty(tmr))
	trainsmr = 33*ones(length(tmr),2);
   trainsmr(:,2) = tmr';
else
   trainsmr = [33 2];
end

%
clear outt1 outt2 outt3;
outt1 = modgam3(mo,mr,ns);					% gets a rate/order modulated gamma interval
train1 = 10*ones(length(outt1),2);
train1(:,2) = 2000*(outt1');				% converts seconds to 0.5ms units
outt2 = modgam3(mo,mr,ns);
train2 = 11*ones(length(outt2),2);
train2(:,2) = 2000*(outt2');				% converts seconds to 0.5ms units
outt3 = modgam3(mo,mr,ns);
train3 = 31*ones(length(outt3),2);
train3(:,2) = 2000*(outt3');				% converts seconds to 0.5ms units
%
train = [trainsmo
		   trainsmr
   		train1
   		train2
         train3];
%
%size(train)
[junk,k] = sort(train(:,2));
train = train(k,:);
%
%fdat = fopen('testdat2.gdf','w');
%fprintf(fdat,'%2.0f %10.0f\n',train');
%fclose(fdat);
%
%[f1,f2,f3,mcvt1,mcvt2,mcvt3] = fano3b(train);
%

      
