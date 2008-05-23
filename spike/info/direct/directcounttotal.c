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
  int m,n,p;
  int N,S,M,P_total,Z;
  int **binned,*binned_temp,**hashed;
  mxArray *mxbinned;
  int *P_vec;
  struct hist1d *hist;
  int p_total;
  int status;
  struct options_direct *opts;
  int B,L;

  if((nrhs<1) | (nrhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcounttotal:numArgs","2 input arguments required.");
  if((nlhs<1) | (nlhs>2))
    mexErrMsgIdAndTxt("STAToolkit:directcounttotal:numArgs","1 or 2 output argument required.");

  if(nrhs<2)
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[1]))
    opts = ReadOptionsDirect(mxCreateEmptyStruct());
  else
    opts = ReadOptionsDirect(prhs[1]);

  M = mxGetM(prhs[0]);
  Z = mxGetN(prhs[0]); /* Number of words per train */
  if(Z>1)
    mexErrMsgIdAndTxt("STAToolkit:directcounttotal","The input is not conditioned properly. It must be a column vector of cells.");
  P_vec = (int *)mxMalloc(M*sizeof(int));
  P_total = 0;
  for(m=0;m<M;m++)
  {
    mxbinned = mxGetCell(prhs[0],m);
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

  hist = (struct hist1d *)mxMalloc(sizeof(struct hist1d));

  /* Allocate memory for hists */
  plhs[0] = AllocHist1D(1,hist,&P_total,N);

  /* Do computation */
  GetBSL(binned,P_total,N,&B,&S,&L);
  hashed = mxMatrixInt(P_total,S);
  HashWords(binned,P_total,N,B,S,L,hashed);

  status = DirectCountTotalComp(binned,hashed,P_total,N,S,hist);

  /* Copy scalar results from C hists to mx hists */
  /* Free memory from C hists */
  WriteHist1D(1,hist,plhs[0]);

  if(nrhs<2)
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[1]))
    plhs[1] = WriteOptionsDirect(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsDirect(prhs[1],opts);

  mxFree(hist);
  mxFree(P_vec);
  mxFreeMatrixInt(binned); 
  mxFreeMatrixInt(hashed);

  return;
}
