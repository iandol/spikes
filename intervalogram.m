function [interv,xax]=intervalogram(cell,window,shift)

%window=window*10;
%shift=shift*10;

shifts=floor((cell.maxtime/10)/shift)-1;

fromtime=0;
totime=window;

for i=1:shifts
	isis=getisi(cell,window,fromtime,totime,0);
	fromtime=fromtime+shift;
	totime=totime+shift;
	if i==1
		[interv(i,:),xax]=hist(isis,window);
	else
		interv(i,:)=hist(isis,window);
	end
end

%figure;imagesc(interv);


