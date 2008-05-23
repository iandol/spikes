%DIRECTCONDFORMAL Condition data on both category and time slice.
%   Y = DIRECTCONDFORMAL(X,OPTS) reorganizes a 2-D cell array (such as
%   is given by the output of DIRECTBIN) into a 1-D cell column vector
%   where each element corresponds to a particular category-time slice
%   combination
%
%   There are currently no user-specified options or parameters for
%   this function. Therefore OPTS is ignored.
%
%   Y = DIRECTCONDFORMAL(X) has exactly the same behavior as above.
%
%   [Y,OPTS_USED] = DIRECTCONDFORMAL(X,OPTS) copies OPTS into OPTS_USED.
% 
%   See also DIRECTBIN, DIRECTCONDCAT, DIRECTCONDTIME,
%   DIRECTCOUNTCLASS, DIRECTCOUNTCLASS, DIRECTCOUNTCOND.
