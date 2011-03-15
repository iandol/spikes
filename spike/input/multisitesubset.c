/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../shared/toolkit_c.h"
#include "../shared/toolkit_mx.h"

/* calling sequence:
   Y = multisitesubset(X,vec) */

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  struct input *X,*Y;
  int n,N;
  double *vec_double;
  int *vec;

  if(nrhs != 2)
    mexErrMsgIdAndTxt("SpikeInfo:MultiSiteSubset:numArgs","2 input arguments required.");
  if(nlhs != 1)
    mexErrMsgIdAndTxt("SpikeInfo:MultiSiteSubset:numArgs","1 output argument required.");

  X = ReadInput(prhs[0]);

  N = mxGetNumberOfElements(prhs[1]);
  vec_double = mxGetPr(prhs[1]);
  vec = (int *)mxMalloc(N*sizeof(int));
  for(n=0;n<N;n++)
    {
      vec[n] = ((int)vec_double[n])-1;
      if(vec[n]>=X[0].N)
        {
          mxFreeInput(X);
          mxFree(vec);
	  mexErrMsgIdAndTxt("SpikeInfo:MultiSiteSubset:outOfRange","Index in vec exceeds number of sites in X.");
        }
    }

  Y = MultiSiteSubsetComp(X,vec,N);

  plhs[0]=WriteInput(Y,1);
  
  mxFreeInput(X);

  mxFree(vec);

  return;
}
