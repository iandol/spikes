/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Supports ctwmcmc method gateway routines.
 * This file contains C code that supports the ctwmcmc method
 * MEX-file gateway routines, but which is not directly compiled.
 * @see ctwmcmctree.cpp, ctwmcmcsample.cpp, ctwmcmcinfo.cpp.
 */

#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "ctwmcmc_c.h"
#include "ctwmcmc_mx.h"

/**
 * @brief Read ctwmcmc method options.
 * This function reads options for ctwmcmc method routines from a
 * Matlab struct (*pmx), and returns a pointer to a C struct of type
 * options_ctwmcmc.
 * @param[in] pmx Pointer to a Matlab array of options.
 * @return Pointer to a C struct of type options_ctwmcmc.
 * @see ctwmcmc_c.h.
 */
struct options_ctwmcmc *ReadOptionsCTWMCMC(const mxArray *pmx)
{
	/* declare variables */
	struct options_ctwmcmc *popts;
	mxArray *tmp;
	int stringLength;
	char *str;

	/* allocate options C struct */
	popts = (struct options_ctwmcmc *)mxMalloc(sizeof(struct options_ctwmcmc));

	/* read options */
	popts->beta_flag = ReadOptionsDoubleMember(pmx,"beta",&(popts->beta));
	popts->gamma_flag = ReadOptionsDoubleMember(pmx,"gamma",&(popts->gamma));
	popts->nmc_flag = ReadOptionsIntMember(pmx,"nmc",&(popts->nmc));
	popts->max_tree_depth_flag = ReadOptionsIntMember(pmx,"max_tree_depth",&(popts->max_tree_depth));
	popts->h_zero_flag = ReadOptionsIntMember(pmx,"h_zero",&(popts->h_zero));
	popts->memory_expansion_flag = ReadOptionsDoubleMember(pmx,"memory_expansion",&(popts->memory_expansion));
	popts->mcmc_iter_flag = ReadOptionsIntMember(pmx,"mcmc_iterations",&(popts->mcmc_iter));
	popts->mcmc_max_iter_flag = ReadOptionsIntMember(pmx,"mcmc_max_iterations",&(popts->mcmc_max_iter));
	popts->mcmc_min_accept_flag = ReadOptionsIntMember(pmx,"mcmc_min_acceptances",&(popts->mcmc_min_accept));
	
	popts->tree_format_flag = 0; //assume field is empty
	tmp = mxGetField(pmx,0,"tree_format");
	if(tmp && mxIsChar(tmp)) //field is string
	{
		/* copy string and set to lowercase */
		stringLength = mxGetNumberOfElements(tmp) + 1;
		str = (char *)mxCalloc(stringLength,sizeof(char));
		if(mxGetString(tmp,str,stringLength)!=0)
			mexErrMsgIdAndTxt("STAToolkit:ReadOptionsCTWMCMC:invalidValue","Option tree_format is not valid string data.");
		for(int i=0; str[i]; i++)
			str[i] = tolower(str[i]);

		/* use string to set member value */
		if(strcmp(str,"none")==0)
			popts->tree_format = 0;
		else if(strcmp(str,"struct")==0)
			popts->tree_format = 1;
		else if(strcmp(str,"cell")==0)
			popts->tree_format = 2;
		else
		{
			mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsCTWMCMC:invalidValue","Unrecognized option \"%s\" for tree_format. Using default \"cell\".",str);
			popts->tree_format = (int)DEFAULT_TREE_FORMAT;
		}
		popts->tree_format_flag = 1;
	}

	return popts;
}

/**
 * @brief Write ctwmcmc method options.
 * This function writes options for ctwmcmc method routines to a
 * Matlab struct from values stored in a C struct (*popts).
 * @param[in] pmx Pointer to a Matlab array of default options structure.
 * @param[in] popts Pointer to a C struct containing option values.
 * @return Pointer to a Matlab array of the copied options.
 * @see ctwmcmc_c.h.
 */
mxArray *WriteOptionsCTWMCMC(const mxArray *pmx,struct options_ctwmcmc *popts)
{
	/* declare variables */
	mxArray *pmx_out;

	/* copy options Matlab structure */
	pmx_out = mxDuplicateArray(pmx);

	/* write options */
	WriteOptionsDoubleMember(pmx_out,"beta",popts->beta,popts->beta_flag);
	WriteOptionsDoubleMember(pmx_out,"gamma",popts->gamma,popts->gamma_flag);
	WriteOptionsIntMember(pmx_out,"nmc",popts->nmc,popts->nmc_flag);
	WriteOptionsIntMember(pmx_out,"max_tree_depth",popts->max_tree_depth,popts->max_tree_depth_flag);
	WriteOptionsIntMember(pmx_out,"h_zero",popts->h_zero,popts->h_zero_flag);
	WriteOptionsDoubleMember(pmx_out,"memory_expansion",popts->memory_expansion,popts->memory_expansion_flag);
	WriteOptionsIntMember(pmx_out,"mcmc_iterations",popts->mcmc_iter,popts->mcmc_iter_flag);
	WriteOptionsIntMember(pmx_out,"mcmc_max_iterations",popts->mcmc_max_iter,popts->mcmc_max_iter_flag);
	WriteOptionsIntMember(pmx_out,"mcmc_min_acceptances",popts->mcmc_min_accept,popts->mcmc_min_accept_flag);

	if(popts->tree_format_flag)
		if(popts->tree_format==0)
			mxAddAndSetField(pmx_out,0,"tree_format",mxCreateString("none"));
		else if(popts->tree_format==1)
			mxAddAndSetField(pmx_out,0,"tree_format",mxCreateString("struct"));
		else if(popts->tree_format==2)
			mxAddAndSetField(pmx_out,0,"tree_format",mxCreateString("cell"));
		else
			mxAddAndSetField(pmx_out,0,"tree_format",mxCreateString("error"));

	/* free options C struct */
	mxFree(popts);

	return pmx_out;
}

/**
 * @brief Write CTW tree(s) from C struct to Matlab array.
 * This function writes the CTW tree(s) in the C structs pointed to by pptree
 * to a Matlab array (structure or cell array depending on format).
 * @param[in] pptree Pointer to CTW tree C struct pointers.
 * @param[in] ntrees Number of trees in pptree.
 * @param[in] format Tree format specifier (1=structure or 2=cell array).
 * @return Pointer to Matlab CTW tree array.
 * @see ctwmcmctree.cpp.
 */
mxArray *WriteCTWTree(struct ctwtree **pptree, int ntrees, int format)
{
	/* declare variables */
	mxArray *pmx;

	if(format==1) //option "struct"
	{
		/* declare variables */
		mxArray *pstruct;
		const char *treefields[] = {"nsymbols", "alphabet", "h_zero", "maxdepth", "beta", "gamma", "nodes"};
		const char *nodefields[] = {"id", "tail", "Le", "Lw", "w1", "w2", "counts", "children"};

		/* create tree structure */
		pmx = mxCreateStructMatrix(ntrees,1,sizeof(treefields)/sizeof(char *),treefields);
		for(int i=0; i<ntrees; i++)
		{
			/* write tree values */
			mxSetField(pmx,i,"nsymbols",mxCreateInt32Scalar(pptree[i]->S));
			mxSetField(pmx,i,"alphabet",mxCreateInt32Scalar(pptree[i]->A));
			mxSetField(pmx,i,"h_zero",mxCreateLogicalScalar(pptree[i]->h_zero));
			mxSetField(pmx,i,"maxdepth",mxCreateInt32Scalar(pptree[i]->maxdepth));
			mxSetField(pmx,i,"beta",mxCreateDoubleScalar(pptree[i]->beta));
			mxSetField(pmx,i,"gamma",mxCreateDoubleScalar(pptree[i]->gamma));

			/* create node structure */
			pstruct = mxCreateStructMatrix(pptree[i]->nodesused,1,sizeof(nodefields)/sizeof(char *),nodefields);
			mxSetField(pmx,i,"nodes",pstruct);
			WriteCTWNode(pstruct,pptree[i],pptree[i]->root);
		}
	}
	else if(format==2) //option "cell"
	{
		/* declare variables */
		mxArray *pmatrix;
		double *pdouble;
		int *pint, columns, current_root, current_node = 0, total_nodes = 0;
		struct ctwnode *pnode, *pchild;

		/* create cell array */
		pmx = mxCreateCellMatrix(3,1);

		/* populate with tree information */
		pmatrix = mxCreateDoubleMatrix(1,6,mxREAL);
		mxSetCell(pmx,0,pmatrix);
		pdouble = (double *)mxGetData(pmatrix);
		pdouble[0] = (double)pptree[0]->S;
		pdouble[1] = (double)pptree[0]->A;
		pdouble[2] = (double)pptree[0]->h_zero;
		pdouble[3] = (double)pptree[0]->maxdepth;
		pdouble[4] = pptree[0]->beta;
		pdouble[5] = pptree[0]->gamma;

		/* populate with node information */
		for(int i=0; i<ntrees; i++)
			total_nodes += pptree[i]->nodesused; //get total nodes used
		columns = 3+2*pptree[0]->A;
		pmatrix = mxCreateNumericMatrix(total_nodes,columns,mxINT32_CLASS,mxREAL); //matrix of integers
		mxSetCell(pmx,1,pmatrix);
		pint = (int *)mxGetData(pmatrix);
		pmatrix = mxCreateDoubleMatrix(total_nodes,4,mxREAL); //matrix of doubles
		mxSetCell(pmx,2,pmatrix);
		pdouble = (double *)mxGetData(pmatrix);
		for(int i=0; i<ntrees; i++) //for each tree
		{
			/* copy root node */
			current_root = current_node;
			pint[current_root] = pptree[i]->root->id; //id
			pint[current_root+total_nodes] = pptree[i]->root->tail; //tail
			for(int j=0; j<pptree[i]->A; j++)
				pint[current_root+(2+j)*total_nodes] = pptree[i]->countstorage[j]; //counts
			for(int j=0; j<pptree[i]->Ap1; j++)
			{
				pchild = pptree[i]->nodestorage[j];
				pint[current_root+(2+pptree[i]->A+j)*total_nodes] = (pchild) ? pchild->id : 0; //children
			}
			pdouble[current_root] = pptree[i]->root->Le; //Le
			pdouble[current_root+total_nodes] = pptree[i]->root->Lw; //Lw
			pdouble[current_root+2*total_nodes] = pptree[i]->root->w1; //w1
			pdouble[current_root+3*total_nodes] = pptree[i]->root->w2; //w2
			current_node++;

			/* copy other nodes */
			for(int j=0; j<pptree[i]->nodesused*pptree[i]->Ap1; j++)
			{
				pnode = pptree[i]->nodestorage[j];
				if(pnode)
				{
					pint[current_root+pnode->id-1] = pnode->id; //id
					pint[current_root+pnode->id-1+total_nodes] = pnode->tail; //tail
					for(int k=0; k<pptree[i]->A; k++)
						pint[current_root+pnode->id-1+(2+k)*total_nodes] = pptree[i]->countstorage[(pnode->id-1)*pptree[i]->A+k]; //counts
					for(int k=0; k<pptree[i]->Ap1; k++)
					{
						pchild = pptree[i]->nodestorage[(pnode->id-1)*pptree[i]->Ap1+k];
						pint[current_root+pnode->id-1+(2+pptree[i]->A+k)*total_nodes] = (pchild) ? pchild->id : 0; //children
					}
					pdouble[current_root+pnode->id-1] = pnode->Le; //Le
					pdouble[current_root+pnode->id-1+total_nodes] = pnode->Lw; //Lw
					pdouble[current_root+pnode->id-1+2*total_nodes] = pnode->w1; //w1
					pdouble[current_root+pnode->id-1+3*total_nodes] = pnode->w2; //w2
					current_node++;
				}
			}
		}
	}
	else
		pmx = mxCreateEmptyMatrix();

	return pmx;
}

/**
 * @brief Write CTW nodes recursively from C struct to Matlab structure.
 * This function writes the CTW nodes in the C struct ptree to a Matlab
 * structure pstruct, recursively, beginning with pnode.
 * @param[in,out] pstruct Pointer to Matlab structure of CTW nodes.
 * @param[in] ptree Pointer to C struct of a CTW tree.
 * @param[in] pnode Pointer to C struct of a CTW node.
 * @see WriteCTWTree.
 */
void WriteCTWNode(mxArray *pstruct, struct ctwtree *ptree, struct ctwnode *pnode)
{
	/* declare variables */
	int *pdata, index = pnode->id - 1;
	mxArray *pmatrix;
	struct ctwnode *pchild;

	/* write node values */
	mxSetField(pstruct,index,"id",mxCreateInt32Scalar(pnode->id));
	mxSetField(pstruct,index,"tail",mxCreateInt32Scalar(pnode->tail));
	mxSetField(pstruct,index,"Le",mxCreateDoubleScalar(pnode->Le));
	mxSetField(pstruct,index,"Lw",mxCreateDoubleScalar(pnode->Lw));
	mxSetField(pstruct,index,"w1",mxCreateDoubleScalar(pnode->w1));
	mxSetField(pstruct,index,"w2",mxCreateDoubleScalar(pnode->w2));

	/* write node counts */
	pmatrix = mxCreateNumericMatrix(1,ptree->A,mxINT32_CLASS,mxREAL);
	memcpy(mxGetData(pmatrix),ptree->countstorage+ptree->A*index,ptree->A*sizeof(int));
	mxSetField(pstruct,index,"counts",pmatrix);

	/* write node children */
	pmatrix = mxCreateNumericMatrix(1,ptree->Ap1,mxINT32_CLASS,mxREAL);
	pdata = (int *)mxGetData(pmatrix);
	for(int i=0; i<ptree->Ap1 && pdata; i++, pdata++)
	{
		pchild = ptree->nodestorage[index*ptree->Ap1 + i];
		if(pchild)
		{
			*pdata = pchild->id;
			WriteCTWNode(pstruct,ptree,pchild); //recurse over children
		}
		else
			*pdata = 0;
	}
	mxSetField(pstruct,index,"children",pmatrix);
}

/**
 * @brief Read CTW tree(s) from Matlab array.
 * This function reads the CTW tree(s) in the Matlab array pmx, and creates
 * the corresponding C structs. The Matlab array may have one of two formats:
 * (1) structure, or (2) cell array (see ctwmcmcsample.m for details).
 * @param[in] pmx Pointer to Matlab CTW tree array.
 * @param[out] ntrees Number of trees in pptree.
 * @param[in] format Tree format specifier (1=structure or 2=cell array).
 * @return Pointer to CTW tree C struct pointers.
 * @see ctwmcmcsample.cpp.
 */
struct ctwtree **ReadCTWTree(const mxArray *pmx, int &ntrees, int format, double memory_expansion)
{
	/* declare variables */
	struct ctwtree **pptree;
	struct ctwnode *pnode, *pchild;
	int nsymbols, A, maxdepth, nnodes, *index = NULL;
	bool h_zero;
	double beta, gamma;

	ntrees = 0; //initialize
	if(format==1) //struct
	{
		/* declare variables */
		mxArray *pstruct;
		int tail, *counts, *children;
		double Le, Lw, w1, w2;

		/* get fields */
		ntrees = mxGetNumberOfElements(pmx);
		nsymbols = ((int *)mxGetData(mxGetField(pmx,0,"nsymbols")))[0];
		A = ((int *)mxGetData(mxGetField(pmx,0,"alphabet")))[0];
		h_zero = ((bool *)mxGetData(mxGetField(pmx,0,"h_zero")))[0];
		maxdepth = ((int *)mxGetData(mxGetField(pmx,0,"maxdepth")))[0];
		beta = ((double *)mxGetData(mxGetField(pmx,0,"beta")))[0];
		gamma = ((double *)mxGetData(mxGetField(pmx,0,"gamma")))[0];

		/* allocate tree(s) */
		pptree = (struct ctwtree **)malloc(ntrees*sizeof(struct ctwtree *));
		for(int i=0; i<ntrees; i++)
		{
			pptree[i] = CAllocCTWTree(ntrees,nsymbols,A,h_zero,maxdepth,beta,gamma,memory_expansion);
			pstruct = mxGetField(pmx,i,"nodes");
			nnodes = mxGetNumberOfElements(pstruct);
			CReallocCTWTree(pptree[i],nnodes);
			index = (int *)realloc(index,nnodes*sizeof(int)); //temporary node index

			/* copy node data */
			for(int j=0; j<nnodes; j++)
			{
				/* get data from Matlab structure */
				tail = ((int *)mxGetData(mxGetField(pstruct,j,"tail")))[0];
				Le = ((double *)mxGetData(mxGetField(pstruct,j,"Le")))[0];
				Lw = ((double *)mxGetData(mxGetField(pstruct,j,"Lw")))[0];
				w1 = ((double *)mxGetData(mxGetField(pstruct,j,"w1")))[0];
				w2 = ((double *)mxGetData(mxGetField(pstruct,j,"w2")))[0];
				counts = (int *)mxGetData(mxGetField(pstruct,j,"counts"));
				children = (int *)mxGetData(mxGetField(pstruct,j,"children"));

				/* get node */
				if(j) //non-root node
					pnode = pptree[i]->nodestorage[index[j]];
				else //root node
					pnode = pptree[i]->root;
				for(int k=0; k<pptree[i]->Ap1; k++)
					if(children[k]) //allocate children
					{
						pchild = CAllocCTWNode(pptree[i],memory_expansion);
						pchild->id = children[k];
						index[pchild->id-1] = (pnode->id - 1)*pptree[i]->Ap1 + k; //get node index
						pptree[i]->nodestorage[index[pchild->id-1]] = pchild; //attach child
					}

				/* copy data */
				pnode->tail = tail;
				pnode->Le = Le;
				pnode->Lw = Lw;
				pnode->w1 = w1;
				pnode->w2 = w2;
				memcpy(pptree[i]->countstorage+(pnode->id-1)*pptree[i]->A,counts,pptree[i]->A*sizeof(int));
			}
		}
		free(index);
	}
	else if(format==2) //cell array
	{
		/* declare variables */
		mxArray *pmatrix;
		int *pint, total_nodes, id, current_node = 0;
		double *pdata, *pdouble;

		/* get fields */
		pmatrix = mxGetCell(pmx,0);
		pdata = (double *)mxGetData(pmatrix); //tree information
		nsymbols = (int)pdata[0];
		A = (int)pdata[1];
		h_zero = (int)pdata[2];
		maxdepth = (int)pdata[3];
		beta = pdata[4];
		gamma = pdata[5];
		pmatrix = mxGetCell(pmx,1);
		pint = (int *)mxGetData(pmatrix); //node list
		total_nodes = mxGetM(pmatrix);
		for(int i=0; i<total_nodes; i++)
			if(pint[i]==1)
				ntrees++;
		pmatrix = mxGetCell(pmx,2);
		pdouble = (double *)mxGetData(pmatrix); //node weights

		/* allocate tree(s) */
		pptree = (struct ctwtree **)malloc(ntrees*sizeof(struct ctwtree *));
		for(int i=0; i<ntrees; i++)
		{
			pptree[i] = CAllocCTWTree(ntrees,nsymbols,A,h_zero,maxdepth,beta,gamma,memory_expansion);
			nnodes = 0;
			do //count nodes
				nnodes++;
			while((pint[current_node+nnodes]!=1) && (current_node+nnodes<total_nodes));
			CReallocCTWTree(pptree[i],nnodes); //make space in tree

			/* copy node data */
			index = (int *)realloc(index,nnodes*sizeof(int)); //temporary node index
			for(int j=0; j<nnodes; j++)
			{
				/* get node */
				if(j) //non-root node
					pnode = pptree[i]->nodestorage[index[j]];
				else //root node
					pnode = pptree[i]->root;
				for(int k=0; k<pptree[i]->Ap1; k++)
				{
					id = pint[current_node+(2+pptree[i]->A+k)*total_nodes];
					if(id) //allocate children
					{
						pchild = CAllocCTWNode(pptree[i],memory_expansion);
						pchild->id = id; //reset id
						index[id-1] = (pnode->id - 1)*pptree[i]->Ap1 + k; //get node index
						pptree[i]->nodestorage[index[id-1]] = pchild; //attach child
					}
				}

				/* copy data */
				pnode->tail = pint[current_node+total_nodes];
				pnode->Le = pdouble[current_node];
				pnode->Lw = pdouble[current_node+total_nodes];
				pnode->w1 = pdouble[current_node+2*total_nodes];
				pnode->w2 = pdouble[current_node+3*total_nodes];
				for(int k=0; k<pptree[i]->A; k++)
					pptree[i]->countstorage[(pnode->id-1)*pptree[i]->A+k] = pint[current_node+(2+k)*total_nodes];

				current_node++;
			}
		}
		free(index);
	}
	else
		pptree = NULL;

	return pptree;
}
