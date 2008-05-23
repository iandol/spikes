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
  int m,n,p,z;
  int N,M,P_total,Z;
  int *binned_in,*binned_out;
  mxArray *mxbinned_in,*mxbinned_out;
  int *P_vec;
  struct options_direct *opts;
  int *uni_list,*uni_i,*uni_j,*cnt,U;

  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcondtime:numArgs","1 or 2 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcondtime:numArgs","1 or 2 output argument required.");

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
  
  /* Make sure all of the categories have the same
     number of trials */
  uni_list = (int *)mxCalloc(M,sizeof(int));
  uni_i = (int *)mxCalloc(M,sizeof(int));
  uni_j = (int *)mxCalloc(M,sizeof(int));
  cnt = (int *)mxCalloc(M,sizeof(int));
  U = UniqueInt(M,P_vec,uni_list,uni_i,uni_j,cnt);
  if(U>1)
    mexErrMsgIdAndTxt("STAToolkit:direct:directcondtime:catMismatch","All categories must have the same number of trials for this conditioning scheme.");
  mxFree(uni_list);
  mxFree(uni_i);
  mxFree(uni_j);
  mxFree(cnt);

  mxbinned_in = mxGetCell(prhs[0],0);
  N = mxGetN(mxbinned_in);

  /* Read in binned cell array */
  /* For a given time slice, put trials in all of the categories in a single word */
  plhs[0] = mxCreateCellMatrix(Z,1);
  for(z=0;z<Z;z++)
    {
      /* For each time slice, we have a P_vec[0] x (M*N) matrix */
      mxbinned_out = mxCreateNumericMatrix(P_vec[0],M*N,mxINT32_CLASS,mxREAL);
      binned_out = mxGetData(mxbinned_out);
      for(m=0;m<M;m++)
	{
	  mxbinned_in = mxGetCell(prhs[0],z*M+m);
	  binned_in = mxGetData(mxbinned_in);
	  
	  for(n=0;n<N;n++)
	    for(p=0;p<P_vec[0];p++)
	      binned_out[m*N*P_vec[0] + n*P_vec[0] + p] = binned_in[n*P_vec[0]+p];
	}
      mxSetCell(plhs[0],z,mxbinned_out);
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
