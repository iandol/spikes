function [ff,cv,af,time,position]=fanogram(cell,window,shift,wrapped,position)

%window=window*10;
%shift=shift*10;

if ~exist('position','var') || isempty(position)
	position = 3; %measure time as end of window
end

if wrapped==1
	maxtime=(cell.maxtime/cell.nummods)/10;	
else
	maxtime=cell.maxtime/10;	
end

halfwindow = floor(window/2);
maxtime = maxtime - window;
shifts=floor(maxtime/shift)-1;
mint=0;
maxt=window;

time=zeros(shifts,1);
ff=zeros(shifts,1);
cv=zeros(shifts,1);
af=zeros(shifts,1);

for i=1:shifts	
	if position == 3
		time(i)=maxt;
	elseif position == 2
		time(i)=mint+halfwindow;
	else
		time(i) = mint;
	end
	ff(i)=finderror(cell,'Fano Factor',mint,maxt,wrapped,0);
	cv(i)=finderror(cell,'Coefficient of Variation',mint,maxt,wrapped,0);
	af(i)=finderror(cell,'Allan Factor',mint,maxt,wrapped,0);
	mint=mint+shift;
	maxt=maxt+shift;
end


