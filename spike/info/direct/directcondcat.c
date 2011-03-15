/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "direct_c.h"
#include "direct_mx.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  int m,n,p,z;
  int N,M,P_total,Z;
  int *binned_in,*binned_out;
  mxArray *mxbinned_in,*mxbinned_out;
  int *P_vec;
  struct options_direct *opts;

  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcondcat:numArgs","1 or 2 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcondcat:numArgs","1 or 2 output argument required.");

  if(nrhs<2)
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else
    opts = ReadOptionsDirect(prhs[1]);

  M = mxGetM(prhs[0]);
  Z = mxGetN(prhs[0]); /* Number of words per train */

  P_vec = (int *)mxMalloc(M*sizeof(int));
  P_total = 0;
  for(m=0;m<M;m++)
  {
    mxbinned_in = mxGetCell(prhs[0],m);
    P_vec[m] = mxGetM(mxbinned_in);
    P_total += P_vec[m];
  }

  /* Will we eventually have to check an make sure that
     trials in each category have the same number of words? */

  mxbinned_in = mxGetCell(prhs[0],0);
  N = mxGetN(mxbinned_in);

  /* Read in binned cell array */
  /* For a given category, merge all of the time slices into a single word */
  plhs[0] = mxCreateCellMatrix(M,1);
  for(m=0;m<M;m++)
    {
      /* For each category, we have a P_vec[m] x (Z*N) matrix */
      mxbinned_out = mxCreateNumericMatrix(P_vec[m],Z*N,mxINT32_CLASS,mxREAL);
      binned_out = mxGetData(mxbinned_out);
      for(z=0;z<Z;z++)
	{
	  mxbinned_in = mxGetCell(prhs[0],z*M+m);
	  binned_in = mxGetData(mxbinned_in);
	  
	  for(n=0;n<N;n++)
	    for(p=0;p<P_vec[m];p++)
	      binned_out[z*N*P_vec[0] + n*P_vec[0] + p] = binned_in[n*P_vec[0]+p];
	}
      mxSetCell(plhs[0],m,mxbinned_out);
    }
  
  if(nrhs<2)
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsDirect(prhs[1],opts);

  mxFree(P_vec);

  return;
}
