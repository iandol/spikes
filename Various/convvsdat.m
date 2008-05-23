function data=convvsdat()
[lfile,lpath]=uigetfile('*.*','VS-RFPlot V1.0: Choose File'); 
   if ~lfile
      errordlg('No File Specified', version)
   else      
      cd (lpath)
      load(lfile)
      i = find(lfile == '.');      
      a = eval(lfile(1:(i-1))); %Assigns data to variable a 
      XValues=unique(a(:,2));    %2nd column contains range of X variables      
      YValues=XValues;           %thus Y variables is total/X values
      startblock=1;
      endblock=size(XValues,1);         %Chunk data in terms of x
      PlotData=ones(endblock,endblock); %Initialise data matrix
      a=a(:,3);                 %Firing data is stored in the 3rd Col 
      for i=startblock:endblock
         PlotData(:,i)=a(startblock:endblock);
         startblock=startblock+size(XValues,1);
         endblock=endblock+size(XValues,1);
      end 
   end
   
      data=PlotData