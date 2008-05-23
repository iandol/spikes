function alpha = rad2ang(alphain,rect,rot)

% copyright (c) 2006 philipp berens
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens
% distributed under GPL with no liability
% http://www.gnu.org/copyleft/gpl.html

if nargin<3
	rot=0;
end
if nargin<2
	rect=0;
end

alpha = alphain * (180/pi);

for i=1:length(alpha)	
	if rot==1
		if alpha(i)>=0
			alpha(i)=alpha(i)-180;
		else
			alpha(i)=alpha(i)+180;
		end			
		%alpha(i)=180+alpha(i);
		if alpha(i)==360
			alpha(i)=0;
		end
	end
	if rect==1 && alpha(i)<0 
		alpha(i)=360+alpha(i);
	end
end