function [xv,yv]=local_nearest(x,xl,y,yl)
		%Inputs:
		% x   Selected x value
		% xl  Line Data (x)
		% y   Selected y value
		% yl  Line Data (y)
		%Find nearest value of [xl,yl] to (x,y)
		%Special Case: Line has a single non-singleton value
		if sum(isfinite(xl))==1
			fin = find(isfinite(xl));
			xv = xl(fin);
			yv = yl(fin);
		else
			%Normalize axes
			xlmin = min(xl);
			xlmax = max(xl);
			ylmin = min(yl);
			ylmax = max(yl);
			%Process the case where max == min
			if xlmax == xlmin
				xln = (xl - xlmin);
				xn = (x - xlmin);
			else
				%Normalize data
				xln = (xl - xlmin)./(xlmax - xlmin);
				xn = (x - xlmin)./(xlmax - xlmin);
			end
			if ylmax == ylmin
				yln = (yl - ylmin);
				yn = (y - ylmin);
			else
				yln = (yl - ylmin)./(ylmax - ylmin);
				yn = (y - ylmin)./(ylmax - ylmin);
			end
			%Find nearest point using our friend Ptyhagoras
			a = xln - xn;       %Distance between x and the line
			b = yln - yn;       %Distance between y and the line
			c = (a.^2 + b.^2);  %Distance between point and line
			%Don't need sqrt, since we get same answer anyway
			[~,ind] = min(c);
			%Nearest value on the line
			xv = xl(ind);
			yv = yl(ind);
		end
	end