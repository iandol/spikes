/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "direct.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  int m,z;
  int M,Z;
  mxArray *mxbinned_in,*mxbinned_out;
  struct options_direct *opts;

  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcondformal:numArgs","1 or 2 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcondformal:numArgs","1 or 2 output argument required.");

  if(nrhs<2)
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else
    opts = ReadOptionsDirect(prhs[1]);

  M = mxGetM(prhs[0]);
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
