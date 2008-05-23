function geom2(d,sf,tf)

%this computes a slope function for the geometric model, giving deltat for a given phi

if length(d)>1 %see if we want a graph or just raw values
    for j=1:length(d)
        
        phi=radians(-15:1:15);
        
        for i=1:length(phi)
            t(i)=(d(j)*sin(phi(i))*sf(j))/tf(j);
        end
        
        phi=degs(phi);
        t=t*1000;
        
        slope=(max(t)-min(t))/(max(phi)-min(phi));
        
        vals(j)=[slope];
        
    end
    vals'
    
else %want a plot
    
    phi=radians(-15:1:15);
    
    for i=1:length(phi)
        t(i)=(d*sin(phi(i))*sf)/tf;
    end
    
    phi=degs(phi);
    t=t*1000;
    
    slope=(max(t)-min(t))/(max(phi)-min(phi));
    figure
    plot(phi,t);
    
    title(['Slope is: ' num2str(slope) 'ms/deg | Sep: ' num2str(d) 'degs | SF: ' num2str(sf) ' | TF: ' num2str(tf) 'hz'])
    xlabel('Orientation (degs)')
    ylabel('Time (ms)')
    
    axis([-inf inf -300 300])
    
    
    
end