/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Sample CTW tree functionals (e.g., entropy) by MCMC.
 * This file contains C code that is compiled into the MEX-file
 * ctwmcmcsample.mex*. Its functionality may be accessed in Matlab by
 * calling the function ctwmcmcsample. Additional documentation resides
 * in ctwmcmcsample.m, and can be found by typing "help ctwmcmcsample" at
 * the Matlab command prompt.
 * @see CTWMCMCSampleComp.cpp.
 */

//TODO
//additional status checks should be made (especially when allocating memory)

#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "ctwmcmc_c.h"
#include "ctwmcmc_mx.h"

#ifdef DEV
#include <iostream>
#endif

/**
 * @brief Interfaces C and Matlab data.
 * This function is the MEX-file gateway routine. Please see the Matlab
 * MEX-file documentation (http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/f43721.html)
 * for more information.
 * @param[in] nlhs Number of left-hand side arguments.
 * @param[in,out] plhs Array of pointers to left-hand side Matlab arrays (outputs).
 * @param[in] nrhs Number of right-hand side arguments.
 * @param[in] prhs Array of pointers to right-hand side Matlab arrays (inputs).
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* declare variables */
	int status, ntrees;
	struct options_ctwmcmc *popts; //pointer to options C struct
	struct options_entropy *pentropy; //pointer to options C struct
	struct ctwtree **pptree; //pointers to CTW trees
	mxArray **ppmxstruct, **ppmxsamples; //pointers to Matlab arrays
	struct estimate **ppest; //pointers to estimate C structs
	double **ppsamples = NULL; //pointers to MCMC samples

	/* check number of inputs (nargin) and outputs (nargout) */
	if((nrhs<1) || (nrhs>2))
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcsample:numArgs","1 or 2 input arguments required.");
	if((nlhs<1) || (nlhs>2))
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcsample:numArgs","1 or 2 output arguments required.");

	/* get or set options */
	if((nrhs<2) || mxIsEmpty(prhs[1]))
	{
		popts = ReadOptionsCTWMCMC(mxCreateEmptyStruct());
		pentropy = ReadOptionsEntropy(mxCreateEmptyStruct());
	}
	else
	{
		popts = ReadOptionsCTWMCMC(prhs[1]);
		pentropy = ReadOptionsEntropy(prhs[1]);
	}

	/* check input */
	if(mxIsStruct(prhs[0]))
		popts->tree_format = 1; //struct (don't write flag in case option not set)
	else if(mxIsCell(prhs[0]) && (mxGetM(prhs[0])==3) && (mxGetN(prhs[0])==1))
		popts->tree_format = 2; //cell array (don't write flag in case option not set)
	else
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcsample:badInput","Input must be a CTW tree struct or cell array.");
	}
	pptree = ReadCTWTree(prhs[0],ntrees,popts->tree_format,popts->memory_expansion);

	/* check options (entropy options need not be checked as this is already done) */
	if(popts->nmc_flag==0)
	{
		popts->nmc = (int)DEFAULT_NMC;
		popts->nmc_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcsample:missingParameter","Missing parameter nmc. Using default value %d.\n",popts->nmc);
	}
	if(popts->nmc<0)
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		for(int i=0; i<ntrees; i++)
			CFreeCTWTree(pptree[i]);
		free(pptree);
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcsample:invalidValue","Option nmc must be greater than or equal to zero. It was set to %d.\n",popts->nmc);
	}
	if((popts->nmc<100) && (popts->nmc>0))
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcsample:fewSamples","Option nmc is recommended to be at least 100. It is set to %d.\n",popts->nmc);
	if(popts->memory_expansion_flag==0)
	{
		popts->memory_expansion = (double)DEFAULT_MEMORY_EXPANSION;
		popts->memory_expansion_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmctree:missingParameter","Missing parameter memory_expansion. Using default value %f.\n",popts->memory_expansion);
	}
	if(popts->memory_expansion<1.0)
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		for(int i=0; i<ntrees; i++)
			CFreeCTWTree(pptree[i]);
		free(pptree);
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmctree:invalidValue","Parameter memory_expansion must be greater than or equal to 1.0. It was set to %f.\n",popts->memory_expansion);
	}
	if(popts->mcmc_iter_flag==0)
	{
		popts->mcmc_iter = (int)DEFAULT_MCMC_ITER;
		popts->mcmc_iter_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcsample:missingParameter","Missing parameter mcmc_iterations. Using default value %d.\n",popts->mcmc_iter);
	}
	if(popts->mcmc_iter<1)
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		for(int i=0; i<ntrees; i++)
			CFreeCTWTree(pptree[i]);
		free(pptree);
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcsample:invalidValue","Option mcmc_iterations must be greater than zero. It was set to %d.\n",popts->mcmc_iter);
	}
	if(popts->mcmc_max_iter_flag==0)
	{
		popts->mcmc_max_iter = (int)DEFAULT_MCMC_MAX_ITER;
		popts->mcmc_max_iter_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcsample:missingParameter","Missing parameter mcmc_max_iterations. Using default value %d.\n",popts->mcmc_max_iter);
	}
	if(popts->mcmc_max_iter<popts->mcmc_iter)
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		for(int i=0; i<ntrees; i++)
			CFreeCTWTree(pptree[i]);
		free(pptree);
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcsample:invalidValue","Option mcmc_max_iterations must be greater than or equal to mcmc_iterations. It was set to %d.\n",popts->mcmc_max_iter);
	}
	if(popts->mcmc_min_accept_flag==0)
	{
		popts->mcmc_min_accept = (int)DEFAULT_MCMC_MIN_ACCEPT;
		popts->mcmc_min_accept_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcsample:missingParameter","Missing parameter mcmc_min_acceptances. Using default value %d.\n",popts->mcmc_min_accept);
	}
	if(popts->mcmc_min_accept<1)
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		for(int i=0; i<ntrees; i++)
			CFreeCTWTree(pptree[i]);
		free(pptree);
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcsample:invalidValue","Option mcmc_min_acceptances must be greater than zero. It was set to %d.\n",popts->mcmc_min_accept);
	}
  
	/* allocate estimates and samples */
	ppest = (struct estimate **)mxMalloc(ntrees*sizeof(struct estimate *));
	ppmxstruct = (mxArray **)mxMalloc(ntrees*sizeof(mxArray *));
	if(popts->nmc)
	{
		ppmxsamples = (mxArray **)mxMalloc(ntrees*sizeof(mxArray *));
		ppsamples = (double **)mxMalloc(ntrees*sizeof(double *));
	}

	for(int i=0; i<ntrees; i++)
	{
		ppest[i] = (struct estimate *)mxMalloc(pentropy->E*sizeof(struct estimate));
		ppmxstruct[i] = AllocEst(ppest[i],pentropy);
		if(popts->nmc)
		{
			ppmxsamples[i] = mxCreateDoubleMatrix(1,popts->nmc,mxREAL);
			ppsamples[i] = (double *)mxGetData(ppmxsamples[i]);
		}
	}
  

	/* sample tree(s) */
	status = CTWMCMCSampleComp(pptree,popts,pentropy,ntrees,ppest,ppsamples);
	if(status!=EXIT_SUCCESS)
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcsample:failed","Tree sampling encountered errors. Results may be unreliable.");

	/* write samples */
	const char *fieldnames[] = {"h_analytical", "h_mcmc"};
	plhs[0] = mxCreateStructMatrix(ntrees,1,sizeof(fieldnames)/sizeof(char *),fieldnames);
	for(int i=0; i<ntrees; i++)
	{
		WriteEst(ppest[i],ppmxstruct[i]); //ppest[i] memory freed
		mxSetField(plhs[0],i,fieldnames[0],ppmxstruct[i]); //ppmxstruct[i] memory under Matlab management (hence don't free ppmxstruct[i])
		if(popts->nmc)
			mxSetField(plhs[0],i,fieldnames[1],ppmxsamples[i]); //ppmxsamples[i] memory under Matlab management (hence don't free ppsamples[i])
	}

	/* write options (frees options struct memory) */
	if((nrhs<2) || mxIsEmpty(prhs[1]))
	{
		plhs[1] = WriteOptionsCTWMCMC(mxCreateEmptyStruct(),popts);
		plhs[1] = WriteOptionsEntropy(plhs[1],pentropy);
	}
	else
	{
		plhs[1] = WriteOptionsCTWMCMC(prhs[1],popts);
		plhs[1] = WriteOptionsEntropy(plhs[1],pentropy);
	}

	/* free memory */
	for(int i=0; i<ntrees; i++)
		CFreeCTWTree(pptree[i]);
	free(pptree);
	mxFree(ppest);
	mxFree(ppmxstruct);
	if(popts->nmc)
	{
		mxFree(ppmxsamples);
		mxFree(ppsamples);
	}

	return;
}
