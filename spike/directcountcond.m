%DIRECTCOUNTCOND Count spike train words in each class and disregarding class.
%   Y = DIRECTCOUNTCOND(X,OPTS) counts the words in cell array X and
%   stores the results in a HISTCOND data structure Y. Y consists of
%   two substructures. Y.TOTAL is a HIST1D structure that contains the
%   results of counting all of the words in X. Y.CLASS is a HIST1DVEC
%   array that contains the results of counting the words in X
%   segregated by category.
%
%   There are currently no user-specified options or parameters for
%   this function. Therefore OPTS is ignored.
%
%   Y = DIRECTCOUNTCOND(X) has exactly the same behavior as above.
%
%   [Y,OPTS_USED] = DIRECTCOUNTCOND(X,OPTS) copies OPTS into OPTS_USED.
% 
%   See also DIRECTBIN, DIRECTCONDCAT, DIRECTCONDTIME,
%   DIRECTCONDFORMAL, DIRECTCOUNTCLASS, DIRECTCOUNTTOTAL, INFOCOND.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
