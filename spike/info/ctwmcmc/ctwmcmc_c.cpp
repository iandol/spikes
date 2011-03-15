/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Supports ctwmcmc method C routines.
 * This file contains C code that supports the ctwmcmc method
 * C routines, but which is not directly compiled.
 * @see ctwmcmctree.cpp, ctwmcmcsample.cpp, ctwmcmcinfo.cpp.
 */

//TODO
//status checks should be made when allocating memory

#include "../../shared/toolkit_c.h"
#include "ctwmcmc_c.h"

/**
 * @brief Allocate memory for a CTW tree.
 * This function allocates memory for a C struct ctwtree.
 * @param[in] ntrees Number of trees to build.
 * @param[in] nsymbols Number of symbols from which to build tree.
 * @param[in] A Alphabet size (largest integer in data plus one).
 * @param[in] h_zero Boolean to indicate use of H_zero estimator for deterministic nodes (are deterministic counts always zero entropy).
 * @param[in] maxdepth Maximum tree depth.
 * @param[in] beta KT ballast parameter or Dirichlet prior parameter.
 * @param[in] gamma Weighting parameter.
 * @return Pointer to a C struct ctwtree.
 * @see ctwmcmc_c.h, ctwmcmctree.cpp, CTWMCMCTreeComp.cpp.
 */
struct ctwtree *CAllocCTWTree(int ntrees, int nsymbols, int A, bool h_zero, int maxdepth, double beta, double gamma, double memory_expansion)
{
	/* declare variables */
	struct ctwtree *ptree;

	ptree = (struct ctwtree *)malloc(sizeof(struct ctwtree)); //allocate memory (initial)

	/* set defaults */
	ptree->S = nsymbols;
	ptree->A = A;
	ptree->Ap1 = A + 1;
	ptree->epsilon = A;
	ptree->h_zero = h_zero;
	ptree->maxdepth = maxdepth;
	ptree->nodesused = 0;
	ptree->nodesallocated = 0;

	ptree->beta = beta;
	ptree->gamma = gamma;
	ptree->log2gamma = LOG2Z(gamma);
	ptree->log21mgamma = LOG2Z(1.0 - gamma);
	ptree->log2A = LOG2Z((double)A);

	if(ntrees>1)
	{
		ptree->epsilon_barrier = (int *)malloc(nsymbols*sizeof(int));
		for(int i=0; i<nsymbols; i++)
			ptree->epsilon_barrier[i] = i*ntrees - 1;
	}
	else
		ptree->epsilon_barrier = NULL;
	ptree->countstorage = NULL;
	ptree->nodestorage = NULL;

	CReallocCTWTree(ptree,nsymbols+1); //initial allocation of countstorage and nodestorage

	ptree->root = CAllocCTWNode(ptree,memory_expansion);

	return ptree;
}

/**
 * @brief Deallocate memory for a CTW tree.
 * This function safely deallocates memory held by a C struct ctwtree.
 * @param[in,out] ptree Pointer to a C struct ctwtree.
 * @see ctwmcmc_c.h, ctwmcmctree.cpp, CTWMCMCTreeComp.cpp.
 */
void CFreeCTWTree(struct ctwtree *ptree)
{
	if(ptree)
	{
		/* declare variables */
		int upper;

		/* free nodestorage */
		upper = ptree->nodesused*ptree->Ap1;
		for(int i=0; i<upper; i++)
			free(ptree->nodestorage[i]);
		free(ptree->nodestorage);

		free(ptree->countstorage);
		free(ptree->epsilon_barrier);
		free(ptree->root);
		free(ptree);
	}
}

/**
 * @brief Allocate memory for a CTW node.
 * This function allocates memory for a C struct ctwnode, and increments tree
 * based node storage counts, reallocated tree memory as necessary.
 * @param[in,out] ptree Pointer to a C struct ctwtree.
 * @return Pointer to a C struct ctwnode.
 * @see ctwmcmc_c.h, ctwmcmctree.cpp, CTWMCMCTreeComp.cpp.
 */
struct ctwnode *CAllocCTWNode(struct ctwtree *ptree, double memory_expansion)
{
	/* declare variables */
	struct ctwnode *pnode;
	int nodesnow, newalloc, lower, upper;

	pnode = (struct ctwnode *)malloc(sizeof(struct ctwnode));

	/* allocate space in tree */
	pnode->id = ptree->nodesused++ + 1; //get new node id then increase nodesused
	if(pnode->id > ptree->nodesallocated)
	{
		newalloc = MAX(pnode->id,int(ptree->nodesallocated*memory_expansion));
		CReallocCTWTree(ptree,newalloc); //reallocate tree nodestorage
	}

	/* set node defaults */
	pnode->tail = -2; //invalid location -2 means not a tail
	pnode->Le = pnode->Lw = pnode->w1 = pnode->w2 = 0.0;

	return pnode;
}

/**
 * @brief Reallocate memory for a CTW tree.
 * This function reallocates the memory held by a C struct ctwtree, primarily
 * by expanding the countstorage and nodestorage arrays.
 * @param[in,out] ptree Pointer to a C struct ctwtree.
 * @param[in] nodes Number of nodes for which space should be allocated.
 * @see ctwmcmc_c.h, ctwmcmctree.cpp, CTWMCMCTreeComp.cpp.
 */
void CReallocCTWTree(struct ctwtree *ptree, int nodes)
{
	/* declare variables */
	int oldalloc, lower, upper;

	oldalloc = ptree->nodesallocated;
	ptree->nodesallocated = nodes;

	/* allocate countstorage */
	lower = oldalloc*ptree->A;
	upper = nodes*ptree->A; //countstorage needs A nodes (no epsilon nodes)
	ptree->countstorage = (int *)realloc(ptree->countstorage,upper*sizeof(int));
	for(int i=lower; i<upper; i++)
		ptree->countstorage[i] = 0;

	/* allocate nodestorage */
	lower = oldalloc*ptree->Ap1;
	upper = nodes*ptree->Ap1; //nodestorage needs A+1 nodes (includes epsilon nodes)
	ptree->nodestorage = (struct ctwnode **)realloc(ptree->nodestorage,upper*sizeof(struct ctwnode *));
	for(int i=lower; i<upper; i++)
		ptree->nodestorage[i] = NULL;
}

/**
 * @brief Sums the symbol counts at a node.
 * This function returns the sum of all symbol counts for the current node.
 * @param[in] ptree Pointer to C-style CTW tree.
 * @param[in] pnode Pointer to CTW node.
 * @return Total count.
 */
int node_count_total(struct ctwtree *ptree, struct ctwnode *pnode)
{
	/* declare variables */
	int count=0;

	if(pnode)
		for(int i=0; i<ptree->A; i++)
			count += ptree->countstorage[(pnode->id-1)*ptree->A+i];

	return count;
}

/**
 * @brief Gets the node child for a symbol.
 * This function returns the child node of the current node at the given
 * symbol, or NULL if no child exists.
 * @param[in] ptree Pointer to C-style CTW tree.
 * @param[in] pnode Pointer to CTW node.
 * @param[in] symbol Symbol at which to get child node.
 * @return Pointer to child ctwnode struct (or NULL).
 */
struct ctwnode *get_node_child(struct ctwtree *ptree, struct ctwnode *pnode, int symbol)
{
	return (pnode) ? ptree->nodestorage[(pnode->id - 1)*ptree->Ap1 + symbol] : NULL;
}

/**
 * @brief Report whether node is a terminal node.
 * This function returns a boolean to indicate whether a node is a terminal
 * node (i.e., it has no children).
 * @param[in] ptree Pointer to C-style CTW tree.
 * @param[in] pnode Pointer to CTW node.
 */
bool node_is_terminal(struct ctwtree *ptree, struct ctwnode *pnode)
{
#ifdef DEBUG
	if(!pnode)
		std::cerr << "ERROR: Node must not be NULL to use node_is_terminal.\n";
#endif

	/* declare variables */
	bool terminal = true;

	for(int i=0; i<ptree->Ap1; i++)
		if(ptree->nodestorage[(pnode->id - 1)*ptree->Ap1 + i])
		{
			terminal = false;
			break;
		}

	return terminal;
}
