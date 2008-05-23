%*---------------------------------------------------------*
%|            Temporal Movie Creator v0.4									|
%|            (Rowland Sillito April 2002)										|
%|---------------------------------------------------------|
%| Written as an accessory to Ian's Spike Analysis program|
%| [ian]     added a movie frame summary (Mar 2001)			|
%| [rowland] timeslice choice (in spikes) & code tidyup			|
%|           & max-value display & AVI export (Apr 2002)		|
%|[ian] Updated for Matlab 7													 |
%*---------------------------------------------------------*
%

function CreateMovie(action)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Variable Declaration %%%%%%%%%%%%%%%%%%%

%----Makes variables from spikes program available.
global mint maxt automeasure data

%----Main Variables for this Program
 %Time Related Variables
persistent realtotaltime totaltime halftime
persistent timeslices stringtimeslices
persistent overlaps stringoverlaps
persistent timeslice overlap startsection endsection
global speed loops

 %Movie Holding Variable + MPEG Colormap
persistent temporalmovie mpgcmap

 %File handling variables
persistent exportfilename importfilename

 %for subsequent user rescaling 
persistent maxval minval
%%%%%%%%%%%%%%%% End of Variable Declaration %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Main Switch %%%%%%%%%%%%%%%%%%%%%%%%
if nargin<1
   action='go';
end

switch action
    
%----Initialises GUI etc     
case 'go'
    %finds out the desired timeslice
   startsection=mint;
   endsection=maxt;
    
    %loads GUI *if it's not already there*
   if isempty(findobj('tag','MovieToolFig'))
       MovieCreator;
        %sets up loop and framerate boxes
       speed=12;
       loops=1;
       sett('EditSpeed','String',num2str(speed));
       sett('EditLoops','String',num2str(loops));
        %Sets up callbacks
       sett('CreateMovieButton','Callback','CreateMovie(''create'');');
       sett('PlayMovieButton','Callback','CreateMovie(''play'');');
       sett('ExportMovieButton','Callback','CreateMovie(''export'');');
       sett('LoadMatButton','Callback','CreateMovie(''load'');');
   end 
   
    %establishes the end of the timescale to be considered  
   realtotaltime=endsection-startsection; %max(data.time{1,1});
   
    %creates a rounded (to nearest 5) value for total time 
    %so data can be easily be spanned in timeslices in multiples of 5
   totaltime = realtotaltime-rem(realtotaltime,5);
   
    %works out the largest timeslice (ie. half the total time)
   halftime=totaltime./2-(mod(totaltime./2,5));
   timeslices=5:5:halftime;
   
    %converts numbers to a cell array of strings
   stringtimeslices=[];
   stringtimeslices=nums2strs(timeslices);
   
    %sets up TimeSliceMenu list box
   sett('TimeSliceMenu','String',stringtimeslices);
   sett('TimeSliceMenu','Callback','CreateMovie(''findoverlaps'');');
         
   CreateMovie('findoverlaps');
  
   
%----Creates Movie (takes a while)
case 'create'
    %makes sure variable is empty
   temporalmovie=[];
      
    %sets up structure in which to store the movie
   temporalmovie.cdata=[];
   temporalmovie.colormap=[];  
      
    %stops spike program from 
   automeasure=1;
   overlap=overlaps(get(ghft('OverlapMenu'),'List'));
   
    %initial maximum/minimum
   maxval=0; minval=inf;
    %loops through the whole timescale
   for x=1:((totaltime-overlap)/(timeslice-overlap))
      mint=startsection+((x-1)*(timeslice-overlap));
      maxt=mint+timeslice;
       %ensures final slice includes the bit at the end that was rounded off
      if maxt==startsection+totaltime 
         maxt=startsection+realtotaltime; 
      end
       %get frame and save it
      spikes('Measure');
      temporalmovie(x)=getframe(ghft('SpikeFigMainAxes'));  
       %find/update min & max values for plotted data
      if data.plotburst == 0 & data.plottonic == 0
          zdata=data.matrix;
      elseif data.plotburst == 1 
          zdata=data.bmatrix;
      elseif data.plottonic == 1 
          zdata=data.tmatrix;
      end
      if max(max(zdata))>maxval
          maxval=max(max(zdata));
      end
      if min(min(zdata))<minval
          minval=min(min(zdata));
      end    
   end
    %stores mpeg colourmap
   mpgcmap=get(ghft('SpikeFig'),'Colormap');
   
    %shows movie start/end in spikes & turns off automeasure 
   mint=startsection; maxt=endsection;
   sett('MinEdit','String',startsection);
   sett('MaxEdit','String',endsection);
   automeasure=0;
   
    %just a little box to show the max/min values, for properly scaled reruns
   msgbox(['Max Value: ' num2str(maxval) ' Min Value: ' num2str(minval)]);
   
   
%----Finds Out The Possible Overlaps for a Chosen Timeslice   
case 'findoverlaps'
    %gets the chosen timeslice from the GUI
   timeslice=timeslices(get(ghft('TimeSliceMenu'),'List'));
   
    %finds possible overlaps that will enable given timeslice to span the total time
   overlaps = [0:5:totaltime];
   overlaps = overlaps(find(mod((totaltime-overlaps),(timeslice-overlaps))==0 & overlaps<timeslice));
   
    %converts numbers to a cell array of strings
   stringoverlaps=[];
   stringoverlaps=nums2strs(overlaps);
   
    %sets up another list box
   sett('OverlapMenu','Enable','on');
   sett('OverlapMenu','String',stringoverlaps);

   
%----Plays Movie and Plots a Frame Summary
case 'play'
     %plays movie
    movie(ghft('SpikeFigMainAxes'),temporalmovie,loops,speed);
    
     %opens figure for frame summary, and sets up subplots
    msumary=figure;
    set(msumary,'numbertitle','off');
    set(msumary,'name','Movie Frame Summary');
    steps=length(temporalmovie);
    m=0; n=0;
    for c=10:-1:4
        if c>4 
            for r=c:-1:(c-1)
                if steps<=(r*c)
                    m=c; n=r;
                end
            end
        else
            r=c;
            if steps<=(r*c)
                m=c; n=r;
            end
        end
    end
    if (m*n)>0
        subplot(m,n,1);  
    else
        errordlg('Sorry, too many movie frames for 1 figure');
        error('Too many movie frames');
    end
    
     %plots frames
    for i=1:steps
        subplot(m,n,i);
        image(temporalmovie(i).cdata);
        axis square;
        set(gca,'YTickLabel',[]);
        set(gca,'XTickLabel',[]);
    end
 
    
%----Movie Export Procedures
case 'export'
    switch 1
     %avi file (currently just uses default settings)    
    case get(ghft('ChooseAvi'),'Value')
        [tempfile, temppath] = uiputfile('*.avi', 'Save .AVI Movie File As');
        exportfilename=strcat(temppath,tempfile);
        movie2avi(temporalmovie,exportfilename);
     %mpeg file (encoding options available)    
    case get(ghft('ChooseMpeg'),'Value') 
        [tempfile, temppath] = uiputfile('*.mpg', 'Save MPEG Movie As');
        exportfilename=strcat(temppath,tempfile);
        optionstemp=mpgoptions;
        if length(optionstemp)==8
            mpgwrite(temporalmovie,mpgcmap,exportfilename,optionstemp);
        else
            msgbox('User Cancelled!');
        end
     %.MAT file containing a variable called temporalmovie    
    case get(ghft('ChooseMat'),'Value')
        [tempfile, temppath] = uiputfile('*.mat', 'Save .MAT Movie File As');
        exportfilename=strcat(temppath,tempfile);
        save(exportfilename,'temporalmovie');
	end 
    
%----For Loading Movies From Saved .MAT Files    
case 'load'
    [tempfile, temppath] = uigetfile('*.mat', 'Load .MAT Movie File');
    importfilename=strcat(temppath,tempfile);
    s=load(importfilename);
    temporalmovie=s.temporalmovie;    
end

%%%%%%%%%%%%%%%%%%%%% End of Main Switch %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Function Declarations %%%%%%%%%%%%%%%%%%%%

%GHFT GetsHandleFromTag
function [handle] = ghft(tag)
	handle=findobj('tag',tag);
   %End of handle getting routine%

%Set but with tag instead of handle
function sett(tag,setting,value)
set(findobj('tag',tag),setting,value);
   %end of function

%Converts array of numbers to a cell array of strings   
function [cellout]=nums2strs(arrayin)
	for n=1:length(arrayin)
      cellout{n}=num2str(arrayin(n));
   end
   %End of function

%%%%%%%%%%%%%%%%%%%% End of Declarations %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  