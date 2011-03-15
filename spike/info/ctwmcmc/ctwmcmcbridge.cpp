/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Build CTW tree graph(s) and make MCMC samples.
 * This file contains C code that is compiled into the MEX-file
 * ctwmcmcbridge.mex*. Its functionality may be accessed in Matlab by
 * calling the function ctwmcmcbridge. Additional documentation resides
 * in ctwmcmcbridge.m, and can be found by typing "help ctwmcmcbridge" at
 * the Matlab command prompt.
 * @see CTWMCMCTreeComp.cpp, CTWMCMCSampleComp.cpp.
 */

//TODO
//additional status checks should be made (especially when allocating memory)

#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "ctwmcmc_c.h"
#include "ctwmcmc_mx.h"

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
	int status, ntrees, nsymbols;
	int M, N, A=0; //array dimensions and alphabet size
	struct options_ctwmcmc *popts; //pointer to ctwmcmc options C struct
	struct options_entropy *pentropy; //pointer to entropy options C struct
	mxArray *pmxcell; //pointer to Matlab cell array
	int *pbins, **ppbins; //pointers to binned input
	struct ctwtree **pptree; //pointers to CTW trees
	mxArray **ppmxstruct, **ppmxsamples; //pointers to Matlab arrays
	struct estimate **ppest; //pointers to estimate C structs
	double **ppsamples = NULL; //pointers to MCMC samples

	/* check number of inputs (nargin) and outputs (nargout) */
	if((nrhs<1) || (nrhs>2))
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:numArgs","1 or 2 input arguments required.");
	if((nlhs<1) || (nlhs>2))
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:numArgs","1 or 2 output arguments required.");

	/* check input */
	M = mxGetM(prhs[0]); //number of stimulus classes (categories)
	N = mxGetN(prhs[0]); //number of words per train
	if((M>1) || (N>1))
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:badInput","The input is not conditioned properly. It must be a single element cell array.");
	
	/* read input */
	if(mxIsCell(prhs[0]))
		pmxcell = mxGetCell(prhs[0],0);
	else
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:badInput","The input is not conditioned properly. It must be a single element cell array.");
	M = mxGetM(pmxcell); //number of repeats (trials)
	N = mxGetN(pmxcell); //number of time bins
	if(mxIsInt32(pmxcell)) //check data format
		pbins = (int *)mxGetData(pmxcell);
	else
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:badInput","The input cell array elements are required to be int32.");
	ppbins = mxMatrixInt(M,N); //allocate memory
	for(int m=0; m<M; m++)
		for(int n=0; n<N; n++)
		{
			A = (pbins[n*M+m]>A) ? pbins[n*M+m] : A; //get alphabet size
			ppbins[m][n] = pbins[n*M+m]; //Matlab stores data in column-major order thus cannot use memcpy
		}
	A++; //alphabet size is one greater than largest character (includes zero)

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

	/* check options */
	if(popts->beta_flag==0)
	{
		popts->beta = (double)1/A;
		popts->beta_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter beta. Using default value (1/A) %f.\n",popts->beta);
	}
	if(popts->beta<=0.0)
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		mxFreeMatrixInt(ppbins); 
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:invalidValue","Parameter beta must be greater than zero. It was set to %f.\n",popts->beta);
	}
	if(popts->gamma_flag==0)
	{
		popts->gamma = (double)DEFAULT_GAMMA;
		popts->gamma_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter gamma. Using default value %f.\n",popts->gamma);
	}
	if((popts->gamma<=0.0) || (popts->gamma>=1.0))
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		mxFreeMatrixInt(ppbins); 
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:invalidValue","Parameter gamma must be between 0 and 1, non-inclusive. It was set to %f.\n",popts->gamma);
	}
	if(popts->max_tree_depth_flag==0)
	{
		popts->max_tree_depth = (int)DEFAULT_MAX_TREE_DEPTH;
		popts->max_tree_depth_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter max_tree_depth. Using default value %d.\n",popts->max_tree_depth);
	}
	if(popts->max_tree_depth<=0)
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		mxFreeMatrixInt(ppbins); 
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:invalidValue","Parameter max_tree_depth must be greater than zero. It was set to %d.\n",popts->max_tree_depth);
	}
	if(popts->h_zero_flag==0)
	{
		popts->h_zero = (int)DEFAULT_H_ZERO;
		popts->h_zero_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter h_zero. Using default value %d.\n",popts->h_zero);
	}
	if(popts->tree_format_flag==0)
	{
		popts->tree_format = (int)0;
		popts->tree_format_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter tree_format. Using default value %d.\n",popts->tree_format);
	}
	if(popts->tree_format!=0)
	{
		mxFree(popts);
		if((pentropy->E)>0) 
			mxFree(pentropy->ent_est_meth);
		if((pentropy->var_est_meth_flag)>0) 
			mxFreeMatrixInt(pentropy->var_est_meth);
		mxFree(pentropy->V);
		mxFree(pentropy);
		mxFreeMatrixInt(ppbins); 
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:invalidValue","Parameter tree_format must be 'none'. See ctwmcmcbridge to output CTW tree graph(s).\n");
	}
	if(popts->memory_expansion_flag==0)
	{
		popts->memory_expansion = (double)DEFAULT_MEMORY_EXPANSION;
		popts->memory_expansion_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter memory_expansion. Using default value %f.\n",popts->memory_expansion);
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
		mxFreeMatrixInt(ppbins); 
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:invalidValue","Parameter memory_expansion must be greater than or equal to 1.0. It was set to %f.\n",popts->memory_expansion);
	}
	if(popts->nmc_flag==0)
	{
		popts->nmc = (int)DEFAULT_NMC;
		popts->nmc_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter nmc. Using default value %d.\n",popts->nmc);
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
		mxFreeMatrixInt(ppbins); 
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:invalidValue","Option nmc must be greater than or equal to zero. It was set to %d.\n",popts->nmc);
	}
	if((popts->nmc<100) && (popts->nmc>0))
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:fewSamples","Option nmc is recommended to be at least 100. It is set to %d.\n",popts->nmc);
	if(popts->mcmc_iter_flag==0)
	{
		popts->mcmc_iter = (int)DEFAULT_MCMC_ITER;
		popts->mcmc_iter_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter mcmc_iterations. Using default value %d.\n",popts->mcmc_iter);
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
		mxFreeMatrixInt(ppbins); 
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:invalidValue","Option mcmc_iterations must be greater than zero. It was set to %d.\n",popts->mcmc_iter);
	}
	if(popts->mcmc_max_iter_flag==0)
	{
		popts->mcmc_max_iter = (int)DEFAULT_MCMC_MAX_ITER;
		popts->mcmc_max_iter_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter mcmc_max_iterations. Using default value %d.\n",popts->mcmc_max_iter);
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
		mxFreeMatrixInt(ppbins); 
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:invalidValue","Option mcmc_max_iterations must be greater than or equal to mcmc_iterations. It was set to %d.\n",popts->mcmc_max_iter);
	}
	if(popts->mcmc_min_accept_flag==0)
	{
		popts->mcmc_min_accept = (int)DEFAULT_MCMC_MIN_ACCEPT;
		popts->mcmc_min_accept_flag = 1;
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:missingParameter","Missing parameter mcmc_min_acceptances. Using default value %d.\n",popts->mcmc_min_accept);
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
		mxFreeMatrixInt(ppbins); 
		mexErrMsgIdAndTxt("STAToolkit:ctwmcmcbridge:invalidValue","Option mcmc_min_acceptances must be greater than zero. It was set to %d.\n",popts->mcmc_min_accept);
	}
  
	/* build tree */
	ntrees = (M>1) ? N : M; //number of trees to build
	nsymbols = (M>1) ? M : N; //number of symbols from which to build tree(s)

#ifdef DEBUG
	std::cout << "ntrees = " << ntrees << "\n";
	std::cout << "nsymbols = " << nsymbols << "\n";
#endif

	pptree = (struct ctwtree **)malloc(ntrees*sizeof(struct ctwtree *)); //allocate memory for tree pointers
	for(int i=0; i<ntrees; i++)
		pptree[i] = CAllocCTWTree(ntrees,nsymbols,A,(bool)popts->h_zero,popts->max_tree_depth,popts->beta,popts->gamma,popts->memory_expansion);
	status = CTWMCMCTreeComp(ppbins,pptree,ntrees,nsymbols,A,popts);
	if(status!=EXIT_SUCCESS)
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:failed","Creation of the CTW tree graph(s) failed. Results may be unreliable.");

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
		mexWarnMsgIdAndTxt("STAToolkit:ctwmcmcbridge:failed","Tree sampling encountered errors. Results may be unreliable.");

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
	mxFreeMatrixInt(ppbins); 
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
