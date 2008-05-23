function [y, xsize, ysize] = loadsumh(filename, frames, sumframes)
% function y = loadsumh(filename, frames, sumframes)
%
% simple envelope to Doron's loadsum
% passes the input parameters, but first
% reads the header to determine (DATA_TYPE, XSIZE, YSIZE, HEADER_SIZE)

varlist='datatype,framewidth,frameheight,lenheader';
[datatype, xsize, ysize, header_size]=get_head(filename,varlist)

data_conv=[12, 13, 14, 99, 99, 11]; %kludgey convert to doron types
data_type=find(data_conv==datatype)-1;   % Doron numbers from 0

y = loadsum(filename, frames, sumframes, data_type, xsize, ysize, header_size);

  