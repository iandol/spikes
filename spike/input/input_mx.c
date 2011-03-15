/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Contains code for processing the input data structure.
 * This file contains C code to read from and write to a Matlab
 * input data structure.
 * @see staread.c.
 */

#include "../shared/toolkit_c.h"
#include "../shared/toolkit_mx.h"
/* #define DEBUG */

/**
 * @brief Reads in an mxArray structure and stores it in a C input structure.
 */
struct input *ReadInput(const mxArray *in)
{
  mxArray *in_sites,*in_categories,*in_trials;
  int m,n,p;
#ifdef DEBUG
  int q;
#endif
  int cur_P,cur_Q;
  mxArray *tmp;
  struct input *X;

  /*****************/
  /*** Top level ***/
  /*****************/

  X = (struct input *)mxMalloc(sizeof(struct input));

  /* Get number of categories */
  tmp = mxGetField(in,0,"M");
  if((tmp==NULL) || mxIsEmpty(tmp))
    mexErrMsgIdAndTxt("STAToolkit:ReadInput:missingParameter","Missing parameter M.");
  if(mxIsClass(tmp,"int32")==0)
    mexWarnMsgIdAndTxt("STAToolkit:ReadInput:wrongType","M is not int32.");
  (*X).M = (int)mxGetScalar(tmp);
#ifdef DEBUG
  mexPrintf("(*X).M=%d\n",(*X).M);
#endif  

  /* Get number of sites */
  tmp = mxGetField(in,0,"N");
  if((tmp==NULL) || mxIsEmpty(tmp))
    mexErrMsgIdAndTxt("STAToolkit:ReadInput:missingParameter","Missing parameter N.");
  if(mxIsClass(tmp,"int32")==0)
    mexWarnMsgIdAndTxt("STAToolkit:ReadInput:wrongType","N is not int32.");
  (*X).N = (int)mxGetScalar(tmp);
#ifdef DEBUG
  mexPrintf("(*X).N=%d\n",(*X).N);
#endif

  /*************/
  /*** Sites ***/
  /*************/

  (*X).sites = (struct site *)mxMalloc((*X).N*sizeof(struct site));

  in_sites = mxGetField(in,0,"sites");
  if(mxGetNumberOfElements(in_sites) != (*X).N)
    mexErrMsgIdAndTxt("STAToolkit:ReadInput:sizeMismatch","Size mismatch between N and sites.");
  
  for(n=0;n<(*X).N;n++)
    {
      SingleCellArrayToCString(mxGetField(in_sites,n,"label"),(*X).sites[n].label);
#ifdef DEBUG
      mexPrintf("(*X).sites[%d].label=\"%s\"\n",n,(*X).sites[n].label);
#endif

      SingleCellArrayToCString(mxGetField(in_sites,n,"recording_tag"),(*X).sites[n].recording_tag);
#ifdef DEBUG
      mexPrintf("(*X).sites[%d].recording_tag=\"%s\"\n",n,(*X).sites[n].recording_tag);
#endif

      tmp = mxGetField(in_sites,n,"time_scale");
      if((tmp==NULL) || mxIsEmpty(tmp))
	mexErrMsgIdAndTxt("STAToolkit:ReadInput:missingParameter","Missing parameter time_scale.");
      (*X).sites[n].time_scale = mxGetScalar(tmp);

      tmp = mxGetField(in_sites,n,"time_resolution");
      if((tmp==NULL) || mxIsEmpty(tmp))
	mexErrMsgIdAndTxt("STAToolkit:ReadInput:missingParameter","Missing parameter time_resolution.");
      (*X).sites[n].time_resolution = mxGetScalar(tmp);

      mxStringToCString(mxGetField(in_sites,n,"si_unit"),(*X).sites[n].si_unit);

      tmp = mxGetField(in_sites,n,"si_prefix");
      if((tmp==NULL) || mxIsEmpty(tmp))
	mexErrMsgIdAndTxt("STAToolkit:ReadInput:missingParameter","Missing parameter si_prefix.");
      (*X).sites[n].si_prefix = mxGetScalar(tmp);
    }
  
  /****************/
  /*** Categories ***/
  /****************/

  (*X).categories = (struct category *)mxMalloc((*X).M*sizeof(struct category));

  /* For each category */
  in_categories = mxGetField(in,0,"categories");
  if(mxGetNumberOfElements(in_categories) != (*X).M)
    mexErrMsgIdAndTxt("STAToolkit:ReadInput:sizeMismatch","Size mismatch between M and categories.");

  for(m=0;m<(*X).M;m++)
    {
      /* Get the number of trials */
      tmp = mxGetField(in_categories,m,"P");
      if((tmp==NULL) || mxIsEmpty(tmp))
	mexErrMsgIdAndTxt("STAToolkit:ReadInput:missingParameter","Missing parameter P.");
      if(mxIsClass(tmp,"int32")==0)
	mexWarnMsgIdAndTxt("STAToolkit:ReadInput:wrongType","P is not int32.");
      cur_P = (int)mxGetScalar(tmp); 
      (*X).categories[m].P = cur_P;

      SingleCellArrayToCString(mxGetField(in_categories,m,"label"),(*X).categories[m].label);
#ifdef DEBUG
      mexPrintf("m=%d P=%d label=\"%s\"\n",m,(*X).categories[m].P,(*X).categories[m].label);
#endif

      /* Now we deal with multi-site categories */
      (*X).categories[m].trials = (struct trial **)mxMalloc(cur_P*sizeof(struct trial *));
      for(p=0;p<(*X).categories[m].P;p++)
	(*X).categories[m].trials[p] = (struct trial *)mxMalloc((*X).N*sizeof(struct trial));

      /* For each trial */
      in_trials = mxGetField(in_categories,m,"trials");
      if(mxGetM(in_trials) != cur_P)
	mexErrMsgIdAndTxt("STAToolkit:ReadInput:sizeMismatch","Size mismatch between P and trials.");
      
      if(mxGetN(in_trials) != (*X).N)
	mexErrMsgIdAndTxt("STAToolkit:ReadInput:sizeMismatch","Size mismatch between N and sites in trials.");

      for(p=0;p<cur_P;p++)
	for(n=0;n<(*X).N;n++)
	  {
	    /* Get the number of spikes */
	    tmp = mxGetField(in_trials,n*cur_P+p,"Q");
            if((tmp==NULL) || mxIsEmpty(tmp))
	      mexErrMsgIdAndTxt("STAToolkit:ReadInput:missingParameter","Missing parameter Q.");
	    if(mxIsClass(tmp,"int32")==0)
	      mexWarnMsgIdAndTxt("STAToolkit:ReadInput:wrongType","Q is not int32.");
	    cur_Q = (int)mxGetScalar(tmp);
	    (*X).categories[m].trials[p][n].Q = cur_Q;
	    
	    tmp = mxGetField(in_trials,n*cur_P+p,"start_time");
            if((tmp==NULL) || mxIsEmpty(tmp))
	      mexErrMsgIdAndTxt("STAToolkit:ReadInput:missingParameter","Missing parameter start_time.");
	    (*X).categories[m].trials[p][n].start_time = mxGetScalar(tmp);
	    
	    tmp = mxGetField(in_trials,n*cur_P+p,"end_time");
            if((tmp==NULL) || mxIsEmpty(tmp))
	      mexErrMsgIdAndTxt("STAToolkit:ReadInput:missingParameter","Missing parameter end_time.");
	    (*X).categories[m].trials[p][n].end_time = mxGetScalar(tmp);
	    
#ifdef DEBUG
	    mexPrintf("p=%2d Q=%d start_time=%1.2f end_time=%1.2f\n",n*cur_P+p,cur_Q,(*X).categories[m].trials[p][n].start_time,(*X).categories[m].trials[p][n].end_time);
#endif
	    tmp = mxGetField(in_trials,n*cur_P+p,"list");
	    if(mxGetNumberOfElements(tmp) != cur_Q)
	      mexErrMsgIdAndTxt("STAToolkit:ReadInput:sizeMismatch","Size mismatch between Q and list.");
	    (*X).categories[m].trials[p][n].list = (double *)mxMalloc(cur_Q*sizeof(double));
	    memcpy((*X).categories[m].trials[p][n].list,mxGetPr(tmp),cur_Q*sizeof(double));

	    /* This is where I would check to see if the spike times are in order. */
	    if((strcmp((*X).sites[n].recording_tag,"episodic")==0) && (IsSortedDouble(cur_Q,(*X).categories[m].trials[p][n].list)==0))
	       mexErrMsgIdAndTxt("STAToolkit:ReadInput:outOfOrder","Spike times are not sorted.");
	    
#ifdef DEBUG
	    for(q=0;q<cur_Q;q++)
	      mexPrintf("%1.3f ",(*X).categories[m].trials[p][n].list[q]);
	    mexPrintf("\n");
#endif
	  }
    }
  return X;
}

void mxFreeInput(struct input *X)
{
  int m,n,p;

  mxFree((*X).sites);
  
  for(m=0;m<(*X).M;m++)
    {
      for(p=0;p<(*X).categories[m].P;p++)
	for(n=0;n<(*X).N;n++)
	  mxFree((*X).categories[m].trials[p][n].list);
      mxFree((*X).categories[m].trials);
    }
  
  mxFree((*X).categories);
  
  mxFree(X);
}

/**
 * @brief Reads in a C input structure and writes it to an mxArray structure.
 */
mxArray *WriteInput(struct input *X, int L)
{
  mxArray *out,*mx_sites,*mx_categories,*mx_trials,*mx_list;
  double *list_c;
  const char *input_field_names[] = {"M","N","sites","categories"};
  const char *site_field_names[] = {"label","recording_tag","time_scale","time_resolution","si_unit","si_prefix"};
  const char *category_field_names[] = {"label","P","trials"};
  const char *trial_field_names[] = {"start_time","end_time","Q","list"};
  int cur_P,cur_Q;
  int l,m,n,p;
  
  out = mxCreateStructMatrix(L,1,4,input_field_names);
  
  /* for each array element */
  for(l=0;l<L;l++)
    {
      /* for each site */
      mx_sites = mxCreateStructMatrix(X[l].N,1,6,site_field_names);
      for(n=0;n<X[l].N;n++)
	{
	  mxSetField(mx_sites,n,"recording_tag",CStringToSingleCellArray(X[l].sites[n].recording_tag));
	  mxSetField(mx_sites,n,"label",CStringToSingleCellArray(X[l].sites[n].label));
	  mxSetField(mx_sites,n,"time_scale",mxCreateDoubleScalar(X[l].sites[n].time_scale));
	  mxSetField(mx_sites,n,"time_resolution",mxCreateDoubleScalar(X[l].sites[n].time_resolution));
	  mxSetField(mx_sites,n,"si_unit",CStringTomxString(X[l].sites[n].si_unit));
	  mxSetField(mx_sites,n,"si_prefix",mxCreateDoubleScalar(X[l].sites[n].si_prefix));
	}
      
#ifdef DEBUG
      printf("X[l].M=%d\n",X[l].M);
#endif
      
      mx_categories = mxCreateStructMatrix(X[l].M,1,3,category_field_names);
      /* for each category */
      for(m=0;m<X[l].M;m++)
	{
	  cur_P = X[l].categories[m].P;
#ifdef DEBUG
	  printf("X[%d].categories[%d].P=%d\n",l,m,cur_P);
#endif
	  mxSetField(mx_categories,m,"P",ConvertIntScalar(cur_P));
	  mxSetField(mx_categories,m,"label",CStringToSingleCellArray(X[l].categories[m].label));
	  mx_trials = mxCreateStructMatrix(cur_P,X[l].N,4,trial_field_names);
	  
	  /* for each trial */
	  for(p=0;p<cur_P;p++)
	    for(n=0;n<X[l].N;n++)
	      {
		mxSetField(mx_trials,n*cur_P+p,"start_time",mxCreateDoubleScalar(X[l].categories[m].trials[p][n].start_time));
		mxSetField(mx_trials,n*cur_P+p,"end_time",mxCreateDoubleScalar(X[l].categories[m].trials[p][n].end_time));
		cur_Q = X[l].categories[m].trials[p][n].Q;
#ifdef DEBUG
		printf("X[%d].categories[%d].trials[%d][%d].Q=%d\n",l,m,p,n,cur_Q);
#endif
		mxSetField(mx_trials,n*cur_P+p,"Q",ConvertIntScalar(cur_Q));
		mx_list = mxCreateDoubleMatrix(1,cur_Q,mxREAL);
		list_c = mxGetPr(mx_list);
		memcpy(list_c,X[l].categories[m].trials[p][n].list,cur_Q*sizeof(double));
		mxSetField(mx_trials,n*cur_P+p,"list",mx_list);
	      }
	  mxSetField(mx_categories,m,"trials",mx_trials);
	}
      
      mxSetField(out,l,"M",ConvertIntScalar(X[l].M));
      mxSetField(out,l,"N",ConvertIntScalar(X[l].N));
      mxSetField(out,l,"sites",mx_sites);
      mxSetField(out,l,"categories",mx_categories);
    }

  return out;
}
