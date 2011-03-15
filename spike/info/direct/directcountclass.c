/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Count spike train words in each class.
 * This file contains C code that is compiled into the MEX-file
 * directcountclass.mex*. Its functionality may be accessed in
 * Matlab by calling the function directcountclass. Additional
 * documentation resides in directcountclass.m, and can be found
 * by typing "help directcountclass" at the Matlab command prompt.
 * @see DirectCountClassComp.c
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
  int m,n,p;
  int N,S,M,P_total,Z;
  int **binned,*binned_temp,**hashed;
  mxArray *mxbinned;
  int *P_vec;
  struct hist1dvec *class_hist;
  int p_total;
  int status;
  struct options_direct *opts;
  int **sorted1;
  int *sort_idx1;
  int B,L;

  /* check number of inputs (nargin) and outputs (nargout) */
  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcountclass:numArgs","2 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcountclass:numArgs","1 or 2 output argument required.");

  /* get or set options */
  if(nrhs<2)
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else
    opts = ReadOptionsDirect(prhs[1]);

  M = mxGetM(prhs[0]); /* number of stimulus classes */
  Z = mxGetN(prhs[0]); /* Number of words per train */
  if(Z>1)
  {
    mxFree(opts);
    mexErrMsgIdAndTxt("STAToolkit:directcountclass:badInput","The input is not conditioned properly. It must be a column vector of cells.");
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
      mexErrMsgIdAndTxt("STAToolkit:directcountclass:badInput","The input cell array elements are required to be int32.");
    }
    P_vec[m] = mxGetM(mxbinned);
    P_total += P_vec[m];
  }

  mxbinned = mxGetCell(prhs[0],0);
  N = mxGetN(mxbinned);
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

  class_hist = (struct hist1dvec *)mxMalloc(sizeof(struct hist1dvec));

  /* Allocate memory for hists */
  plhs[0] = AllocHist1DVec(M,class_hist,P_total,P_vec,N);

  /* Do computation */
  /* Puts results in C hists */
  GetBSL(binned,P_total,N,&B,&S,&L);
  hashed = mxMatrixInt(P_total,S);
  HashWords(binned,P_total,N,B,S,L,hashed);

  sorted1 = mxMatrixInt(P_total,S);
  sort_idx1 = (int *)mxMalloc(P_total*sizeof(int));

  status = DirectCountClassComp(binned,hashed,P_total,N,S,P_vec,M,class_hist,sorted1,sort_idx1);

  mxFreeMatrixInt(sorted1);
  mxFree(sort_idx1);

  /* Copy scalar results from C hists to mx hists */
  /* Free memory from C hists */
  WriteHist1DVec(class_hist,plhs[0]);

  if(nrhs<2)
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsDirect(prhs[1],opts);

  mxFree(class_hist);
  mxFree(P_vec);
  mxFreeMatrixInt(binned); 
  mxFreeMatrixInt(hashed);

  return;
}
