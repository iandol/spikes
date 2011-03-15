/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Condition data on both category and time slice.
 * This file contains C code that is compiled into the MEX-file
 * directcondformal.mex*. Its functionality may be accessed in
 * Matlab by calling the function directcondformal. Additional
 * documentation resides in directcondformal.m, and can be found
 * by typing "help directcondformal" at the Matlab command prompt.
 */

#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "direct_c.h"
#include "direct_mx.h"

/**
 * @brief Interfaces C and Matlab data.
 * This function is the MEX-file gateway routine. Please see the Matlab
 * MEX-file documentation (http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/f43721.html)
 * for more information.
 */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{

  /* allocate variables */
  int m,z;
  int M,Z;
  mxArray *mxbinned_in,*mxbinned_out;
  struct options_direct *opts;

  /* check number of inputs (nargin) and outputs (nargout) */
  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcondformal:numArgs","1 or 2 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcondformal:numArgs","1 or 2 output argument required.");

  /* check input type */
  if(!mxIsCell(prhs[0]))
    mexErrMsgIdAndTxt("STAToolkit:directcondformal:badInput","First input must be a cell array.");

  /* get or set options */
  if(nrhs<2)
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else
    opts = ReadOptionsDirect(prhs[1]);

  M = mxGetM(prhs[0]); /* number of stimulus classes */
  Z = mxGetN(prhs[0]); /* Number of words per train */

  /* Read in binned cell array */
  /* Make the cell array into a vector */
  plhs[0] = mxCreateCellMatrix(M*Z,1);
  for(m=0;m<M;m++)
    for(z=0;z<Z;z++)
      {
	mxbinned_in = mxGetCell(prhs[0],z*M+m);
	mxbinned_out = mxDuplicateArray(mxbinned_in);
	mxSetCell(plhs[0],z*M+m,mxbinned_out);
      }
  
  if(nrhs<2)
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsDirect(prhs[1],opts);

  return;
}
