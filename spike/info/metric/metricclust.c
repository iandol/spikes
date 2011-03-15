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
#include "metric_c.h"
#include "metric_mx.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  double *d,*cm;
  int m,M,P_total;
  int p,*m_list;
  struct options_metric *opts;
  double **d_in,**cm_in;
  int status;

  if( (nrhs<3) | (nrhs>4) )
    mexErrMsgIdAndTxt("STAToolkit:metricclust:numArgs","3 or 4 input arguments required.");
  if( (nlhs<1) | (nlhs>2) )
    mexErrMsgIdAndTxt("STAToolkit:metricclust:numArgs","1 or 2 output arguments required.");

  if(nrhs<4)
    opts = ReadOptionsMetric(mxCreateEmptyStruct());
  else if(mxIsEmpty(prhs[3]))
    opts = ReadOptionsMetric(mxCreateEmptyStruct());
  else
    opts = ReadOptionsMetric(prhs[3]);

  if(opts->z_flag==0)
    {
      opts->z = (double) DEFAULT_CLUSTERING_EXPONENT;
      opts->z_flag = 1;
      mexWarnMsgIdAndTxt("STAToolkit:metricclust:missingParameter","Missing parameter clustering_exponent. Using default value %f.\n",(*opts).z);
    }
  
  if(mxGetM(prhs[0])!=mxGetN(prhs[0]))
    {
      mxFree(opts->q);
      mxFree(opts->k);
      mxFree(opts);
      mexErrMsgIdAndTxt("STAToolkit:metricclust:sizeMismatch","D matrix must be square.");
    }

  P_total = mxGetM(prhs[0]);
  
  if(mxGetNumberOfElements(prhs[1])!=P_total)
    {
      mxFree(opts->q);
      mxFree(opts->k);
      mxFree(opts);
      mexErrMsgIdAndTxt("STAToolkit:metricclust:sizeMismatch","The number of elements in CATEGORIES must match the number of rows and columns in D.");
    }

  if(mxIsClass(prhs[1],"int32")==0)
    mexWarnMsgIdAndTxt("STAToolkit:metricclust:wrongType","CATEGORIES is not int32.");
  m_list = mxGetData(prhs[1]);

  /* Also will have to make sure that the M is one greater than the elements of CATEGORIES. 
     Is this going too far? */

  M = (int) mxGetScalar(prhs[2]);

  /* Make d_in into a 2-D array */
  d = mxGetPr(prhs[0]);
  d_in = (double **)mxCalloc(P_total,sizeof(double *));
  d_in[0]=d;
  for(p=1;p<P_total;p++)
    d_in[p]=d_in[p-1]+P_total;
  
  /* Make cm_in into a 2-D array */
  plhs[0] = mxCreateDoubleMatrix(M,M,mxREAL);

  cm = mxGetPr(plhs[0]);
  cm_in = (double **)mxCalloc(M,sizeof(double *));
  cm_in[0]=cm;
  for(m=1;m<M;m++)
    cm_in[m]=cm_in[m-1]+M;

  status = MetricClustComp(opts,d_in,m_list,M,P_total,cm_in);
  if(status==EXIT_FAILURE)
    {
      mxFree(opts->q);
      mxFree(opts->k);
      mxFree(opts);
      mxFree(cm_in);
      mxFree(d_in);
      mexErrMsgIdAndTxt("STAToolkit:metricclust:failure","metricclust failed.");
    }

  if(nrhs<4)
    plhs[1] = WriteOptionsMetric(mxCreateEmptyStruct(),opts);
  else if(mxIsEmpty(prhs[3]))
    plhs[1] = WriteOptionsMetric(mxCreateEmptyStruct(),opts);
  else
    plhs[1] = WriteOptionsMetric(prhs[3],opts);

  mxFree(cm_in);
  mxFree(d_in);

  return;
}
