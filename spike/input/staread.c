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

/* spkRead Matlab calling sequence:
   X = spkRead(filename); */

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  struct input *X;
  char docname[MAXPATH];
  mxArray *mx_string;
  int status;

  if(nrhs != 1)
    mexErrMsgIdAndTxt("STAToolkit:staRead:numArgs","1 input argument required.");
  if(nlhs != 1)
    mexErrMsgIdAndTxt("STAToolkit:staRead:numArgs","1 output argument required.");

  /* Read in the file name from the Matlab world */
  mx_string = mxDuplicateArray(prhs[0]);
  mxStringToCString(mx_string,docname);

  /* Allocate memory for X */
  X = (struct input *)malloc(sizeof(struct input)); /* memory freed in staReadComp if it returns EXIT_FAILURE */

  /* Call fillSwatches */
  status = staReadComp(docname,X);
  if(status==EXIT_FAILURE)
    mexErrMsgIdAndTxt("STAToolkit:staRead:failure","staRead failed.");

  /* Pass X into the Matlab world */
  plhs[0] = WriteInput(X,1);

  FreeInput(X);

  return;
}
