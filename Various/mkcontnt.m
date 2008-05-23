%MKCONTNT Make new contents.m file in the current working directory
%
%Copies the H1 line (first comment line) of all m-files found
%in the current working directory to a file named "contents.m".
%If such a file already exists, a backup copy of it is made to
%"contents.old". 
%
%For example, if the user has written several m-files 
%in the directory C:\MATLAB\MY_MFILES, he needs to make this the
%current working directory (using either CD or the path browser) 
%and then type "mkcontnt" at the Matlab prompt.
%
%It is important to note that any fancy editing done to a previous 
%version of contents.m will be lost. Only the top two lines from the
%old version are copied to the new version, but that number can easily
%be increased by minor modifications to the code. Use the top few
%lines of your contents.m files to describe in general terms what kinds 
%of tasks are performed by your m-files.
%
%Take the habit of writing informative H1 lines!!!  

%Tested with Matlab 5.2.1 for Windows 95
%
%Author: Denis Gilbert, Ph.D., physical oceanography
%Maurice Lamontagne Institute, Department of Fisheries and Oceans Canada
%email: gilbertd@dfo-mpo.gc.ca  
%August 1998; Last revision: September 15, 1998 

tic
%Check if a contents.m file already exists in the current directory
if exist([pwd filesep 'contents.m'])==0 % Contents.m does not exist in pwd
   line1 = '%Write text describing the m-files in this directory';
   line2 = '%Write text describing the m-files in this directory (continued)';
else  %Open current version of contents.m and save its first two lines
   fid=fopen('contents.m','r');
   line1=fgetl(fid);   line2=fgetl(fid);
   fclose(fid);
   %Make backup copy before deleting contents.m
   copyfile('contents.m','contents.old');
   delete contents.m  %Delete current version of contents.m
end

files = what;  % Structure with fields files.m, files.mat, etc.
%Note: the field files.m does not include contents.m (IMPORTANT)
%Do not displace this line of code above or below its present location
%to avoid error messages.

blank_line = '%   ';  %Blank line
fcontents = fopen('contents.m','w'); %Write a new version of contents.m
fprintf(fcontents,'%s\n',line1);     %Copy descriptive header text from previous version
fprintf(fcontents,'%s\n',line2);     %Copy descriptive header text (continued)
fprintf(fcontents,'%s\n',blank_line);%Third line is blank

%Make sure all file names are in lowercase to allow proper alphabetical sorting
files.m = lower(files.m);
files.m = sort(files.m);  %Sort filenames in alphabetical order

%Write H1 lines to contents.m if they exist
for i = 1:length(files.m)
   fid=fopen(files.m{i},'r'); %Cell array of sorted file names
   %Search for first commented line (H1 line)
   count_percent = 0;
   while count_percent < 1 & feof(fid)==0; 
      %True as long as we do not encounter a line with a "%" sign 
      %or reach the end of file
      line = fgetl(fid);
      if length(line) > 0 %Allow for possibility that some lines may be empty
         if ~isempty(findstr(line,'%')) %LOOK for percent sign anywhere in the line
            count_percent = count_percent + 1;
            fprintf(fcontents,'%s\n',line); %Write H1 line to contents.m
         end
      end
      if feof(fid)==1  %End of file encountered without finding a single percent sign
         fprintf(fcontents,'%s\n',blank_line); %Write blank line to contents.m
      end
   end
   fclose(fid);
end

fclose(fcontents);
toc

