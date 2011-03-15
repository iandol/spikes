/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Count spike train words disregarding class.
 * This file contains C code that is compiled into the MEX-file
 * directcounttotal.mex*. Its functionality may be accessed in
 * Matlab by calling the function directcounttotal. Additional
 * documentation resides in directcounttotal.m, and can be found
 * by typing "help directcounttotal" at the Matlab command prompt.
 * @see DirectCountComp.c.
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
  int m,n,p; /* loop counters */
  int N,S,M,P_total,Z; /* data dimensions */
  int **binned,*binned_temp,**hashed; /* data arrays */
  mxArray *mxbinned; /* Matlab cell elements */
  int *P_vec; /* data dimensions */
  struct hist1d *hist; /* data arrays */
  int p_total; /* data dimensions */
  int status; /* status code */
  struct options_direct *opts; /* options array */
  int B,L; /* data dimensions */

  /* check number of inputs (nargin) and outputs (nargout) */
  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcounttotal:numArgs","2 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcounttotal:numArgs","1 or 2 output argument required.");

  /* get or set options */
  if(nrhs<2)
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else
    opts = ReadOptionsDirect(prhs[1]);

  /* check and bin input */
  M = mxGetM(prhs[0]);
  Z = mxGetN(prhs[0]); /* Number of words per train */
  if(Z>1)
  {
    mxFree(opts);
    mexErrMsgIdAndTxt("STAToolkit:directcounttotal:badInput","The input is not conditioned properly. It must be a column vector of cells.");
  }
  P_vec = (int *)mxMalloc(M*sizeof(int));
  P_total = 0;
  for(m=0;m<M;m++)
  {
    mxbinned = mxGetCell(prhs[0],m);
    if(!mxIsInt32(mxbinned)) /* check data format */
    {
      mxFree(opts);
      mxFree(P_vec);
      mexErrMsgIdAndTxt("STAToolkit:directcounttotal:badInput","The input cell array elements are required to be int32.");
    }
    P_vec[m] = mxGetM(mxbinned);
    P_total += P_vec[m];
  }

  mxbinned = mxGetCell(prhs[0],0);
  N = mxGetN(mxbinned); /* assume each element of the cell array has the same number of columns */
  binned = mxMatrixInt(P_total,N); /* Allocate memory for binned */

  /* Read in binned cell array */
  p_total = 0;
  for(m=0;m<M;m++)
  {
    mxbinned = mxGetCell(prhs[0],m);
    binned_temp = mxGetData(mxbinned);

    for(p=0;p<P_vec[m];p++)
      for(n=0;n<N;n++)
	binned[p_total+p][n] = binned_temp[n*P_vec[m]+p];

    p_total += P_vec[m];
  }

  /* Allocate memory for hists */
  hist = (struct hist1d *)mxMalloc(sizeof(struct hist1d));
  plhs[0] = AllocHist1D(1,hist,&P_total,N);

  /* Do computation */
  GetBSL(binned,P_total,N,&B,&S,&L);
  hashed = mxMatrixInt(P_total,S);
  HashWords(binned,P_total,N,B,S,L,hashed);

  status = DirectCountTotalComp(binned,hashed,P_total,N,S,hist);

  /* Copy scalar results from C hists to mx hists */
  /* Free memory from C hists */
  WriteHist1D(1,hist,plhs[0]);

  /* assign second output */
  if(nrhs<2)
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsDirect(prhs[1],opts);

  /* free (un)managed memory */
  mxFree(hist);
  mxFree(P_vec);
  mxFreeMatrixInt(binned); 
  mxFreeMatrixInt(hashed);

  return;
}
