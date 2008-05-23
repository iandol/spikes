function rfit(x,y)

% Given a data set it will plot out a plot of the data with the robust best fit line

c={[0 0 0];[1 0 0];[0 0 0.7];[0 .7 0];[.7 .7 0];[.5 .5 .5]};

figure;
hold on

xlim=[min(min(x)) max(max(x))];
ylim=[min(min(y)) max(max(y))];
dx = 0.1 * diff(xlim);
dy = 0.1 * diff(ylim);
xlim = [xlim(1)-dx xlim(2)+dx];
ylim = [ylim(1)-dy ylim(2)+dy];

for i=1:size(x,2)
    
    nx=x(find(isnan(x(:,i))<1),i);  %select only those points with values
    ny=y(find(isnan(y(:,i))<1),i);
    
    plot(nx,ny,'k.','Color',c{i},'Marker','o','MarkerSize',6,'MarkerFaceColor',c{i});
    b=robustfit(nx,ny)
    yy=b(1)+b(2)*xlim
    line(xlim,yy,'Color',c{i})
    
end





