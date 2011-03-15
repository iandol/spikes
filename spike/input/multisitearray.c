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
   Y = multisitearray(X,vec) */

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  struct input *X,*Y;
  int n,N;
  double *vec_double;
  int *vec;

  if(nrhs < 1 && nrhs > 2)
    mexErrMsgIdAndTxt("SpikeInfo:MultiSiteArray:numArgs","1 or 2 input arguments required.");
  if(nlhs != 1)
    mexErrMsgIdAndTxt("SpikeInfo:MultiSiteArray:numArgs","1 output argument required.");

  X = ReadInput(prhs[0]);

  /* If there's no vec input, use all of the sites */
  if(nrhs==1)
    {
      N = X[0].N;
      vec = (int *)mxMalloc(N*sizeof(int));
      for(n=0;n<N;n++)
	vec[n]=n;
    }
  else
    {
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
    }
    
  Y = MultiSiteArrayComp(X,vec,N);

  plhs[0]=WriteInput(Y,N);
  
  mxFreeInput(X);

  mxFree(vec);

  return;
}
