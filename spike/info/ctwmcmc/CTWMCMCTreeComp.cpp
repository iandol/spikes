/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Computational routines for building CTW tree graphs.
 * This file contains the computational routines for building CTW tree graphs,
 * as required by the MEX-file ctwmcmctree.cpp. The code herein was created
 * largely as a direct port from the original Fortran code provided by Jon
 * Shlens (http://www.snl.salk.edu/~shlens/pub/code/CTPACK-2.7.1.tgz). See
 * also the related article: Kennel, M., Shlens, J., Abarbanel, H., and
 * Chichilnisky, E.J. (2005) Estimating entropy rates with Bayesian confidence
 * intervals. Neural Computation, 2005: 17, 1531-1576.
 * @see ctwmcmctree.cpp.
 */

//TODO
//various optimizations may be possible (search TODO)
//additional status checks should be made (especially when allocating memory)

#include "../../shared/toolkit_c.h"
#include "ctwmcmc_c.h"

#include <gsl/gsl_sf_gamma.h>

/**
 * @brief Build full CTW tree graph(s) from data.
 * This is the main computational routine responsible for building
 * CTW tree graphs from binned data. Both "single stream" and "replica (noise)"
 * data can be handled, depending on whether ppbins contains a single row of
 * data or a matrix of data, respectively. Pointer pptree must point to ntrees
 * allocated tree structures (see CAllocCTWTree). Struct ppbins should be a
 * matrix with one row and nsymbols columns when ntrees=1, or nsymbols rows and
 * ntrees columns when ntrees>1.
 * @param[in] ppbins Pointer to matrix of binned data.
 * @param[in,out] pptree Pointer to CTW tree C struct pointers.
 * @param[in] ntrees Number of trees to build.
 * @param[in] nsymbols Number of symbols from which to build tree(s).
 * @param[in] A Alphabet size (largest integer in ppbins plus one).
 * @param[in] popts Pointer to options C struct.
 * @return Exit status integer (e.g., EXIT_SUCCESS or EXIT_FAILURE).
 * @see ctwmcmctree.cpp.
 */
int CTWMCMCTreeComp(int **ppbins, struct ctwtree **pptree, int ntrees, int nsymbols, int A, struct options_ctwmcmc *popts)
{
	/* declare variables */
	int status = EXIT_SUCCESS; //logical | (below) assumes EXIT_SUCCESS==0

#ifdef DEBUG
	std::cout << "ppbins[][] =\n";
	int M = (ntrees>1)?nsymbols:ntrees; //conditional gets rows in ppbins
	int N = (ntrees>1)?ntrees:nsymbols; //conditional gets columns in ppbins
	for(int m=0; m<M; m++)
	{
		for(int n=0; n<N; n++)
			std::cout << ppbins[m][n] << " "; //as kludge ppbins[0][m+n*M] also works
		std::cout << "\n";
	}
	std::cout << "Building tree(s) ...\n";
#endif

	/* update tree(s) */
	for(int i=0; i<ntrees; i++) //loop over trees
	{
		for(int j=0; j<nsymbols; j++) //loop over symbols
			status |= update_tree(pptree[i],ppbins,ppbins[(ntrees>1)?j:i][(ntrees>1)?i:j],(ntrees>1)?i+j*ntrees:j,popts->memory_expansion); //conditional inputs segregate "single stream" from "replica (noise)" trees
		status |= compute_codelength_weightings(pptree[i],pptree[i]->root);
	}

	return status;
}

/**
 * @brief Update CTW tree graph with symbol.
 * This function updates a CTW tree with the current symbol, incrementing
 * node counts and adding node children as necessary by looking back in time
 * (i.e., lower time index) through the data.
 * @param[in,out] ptree Pointer to C-style CTW tree.
 * @param[in] ppbins Pointer to matrix of binned data.
 * @param[in] symbol Current symbol to add to tree.
 * @param[in] time Current time index into ppbins.
 * @return Exit status integer (e.g., EXIT_SUCCESS or EXIT_FAILURE).
 */
int update_tree(struct ctwtree *ptree, int **ppbins, int symbol, int time, double memory_expansion)
{
	/*
	 * Note: this function is similar in behavior to update_tree_depth_iterative
	 * in ctw.f90 (see line 1233) from CTPACK-2.7.1. However, the choice of
	 * incremental tree updating has been removed, as it was functionally
	 * obsolete in said code (see line 1123).
	 */

	/* declare variables */
	int past_time, past_symbol; //prior time and symbol
	bool at_epsilon=false, at_maxdepth=false;
	struct ctwnode *pnode, *pchild;

#ifdef DEBUG
	std::cout << "   update_tree() [time,symbol] = [" << time << "," << symbol << "]\n";
#endif

	//TODO the logic here could possibly be tighter and consider opts->maxdepth=Inf
	pnode = ptree->root; //get root node
	for(int i=0; i<=ptree->maxdepth; i++) //climb or build tree
	{
		/* handle current node */
		at_maxdepth = (i==ptree->maxdepth);
		if(node_is_tail(pnode) && !at_maxdepth)
			expand_tail(ptree,pnode,ppbins,memory_expansion); //expand tail node
		node_inc_count(ptree,pnode,symbol); //increment node count
		if(at_epsilon || at_maxdepth)
			break;

		/* get child node */
		past_time = time - 1 - i; //past_time is the time of the symbol to be processed
		past_symbol = symbol_or_epsilon(ptree,ppbins,past_time); //get symbol at past_time
		at_epsilon = (past_symbol==ptree->epsilon);
		pchild = get_node_child(ptree,pnode,past_symbol); //returns NULL if no child exists

#ifdef DEBUG
		std::cout << "      [depth=" << i << ", past=" << past_time << "] pnode->id=" << pnode->id << ", pnode->tail=" << pnode->tail << ", counts=[";
		for(int j=0; j<ptree->A-1; j++)
			std::cout << ptree->countstorage[(pnode->id-1)*ptree->A+j] << ", ";
		std::cout << ptree->countstorage[pnode->id*ptree->A-1] << "]\n";
		if(pchild)
		{
			std::cout << "      [found@" << past_symbol << "] pchild->id=" << pchild->id << ", pchild->tail=" << pchild->tail << ", counts=[";
			for(int j=0; j<ptree->A-1; j++)
				std::cout << ptree->countstorage[(pchild->id-1)*ptree->A+j] << ", ";
			std::cout << ptree->countstorage[pchild->id*ptree->A-1] << "]\n";
		}
#endif

		if(pchild) //climb tree to child
			pnode = pchild;
		else //create child and exit
		{
			pchild = CAllocCTWNode(ptree,memory_expansion);
			if(!at_epsilon)
				pchild->tail = past_time - 1; //epsilon nodes are not tail nodes and are not expanded
			node_inc_count(ptree,pchild,symbol); //increment child count
			node_attach_child(ptree,pnode,pchild,past_symbol); //attach child to parent

#ifdef DEBUG
			std::cout << "      [new@" << past_symbol << "] pchild->id=" << pchild->id << ", pchild->tail=" << pchild->tail << ", counts=[";
			for(int j=0; j<ptree->A-1; j++)
				std::cout << ptree->countstorage[(pchild->id-1)*ptree->A+j] << ", ";
			std::cout << ptree->countstorage[pchild->id*ptree->A-1] << "]\n";
#endif
			break;
		}
	}

	return EXIT_SUCCESS;
}

/**
 * @brief Report whether node is a tail node.
 * This function returns a boolean to indicate whether a node is a tail node.
 * @param[in] pnode Pointer to CTW node.
 */
bool node_is_tail(struct ctwnode *pnode)
{
	return (pnode->tail==-2) ? false : true;
}

/**
 * @brief Expand a tail node by adding a child.
 * This function expands a tail node by adding a child node.
 * @param[in,out] ptree Pointer to C-style CTW tree.
 * @param[in] pnode Pointer to current CTW node.
 * @param[in] ppbins Pointer to matrix of binned data.
 */
void expand_tail(struct ctwtree *ptree, struct ctwnode *pnode, int **ppbins, double memory_expansion)
{
#ifdef DEBUG
	if(!node_is_tail(pnode))
		std::cerr << "ERROR: Attempt to expand non-tail node.\n";
	if(node_count_total(ptree,pnode)!=1)
		std::cerr << "ERROR: Total node count must be 1 to expand tail (got " << node_count_total(ptree,pnode) << ").\n";
#endif

	/* declare variables */
	int past_symbol;
	struct ctwnode *pchild;

	/* get node tail symbol */
	past_symbol = symbol_or_epsilon(ptree,ppbins,pnode->tail);

#ifdef DEBUG
	if(node_child_exists(ptree,pnode,past_symbol))
		std::cerr << "ERROR: Tail node must not have real children.\n";
#endif

	/* create child node */
	pchild = CAllocCTWNode(ptree,memory_expansion);
	node_copy_counts(ptree,pnode,pchild);
	if(past_symbol!=ptree->epsilon)
		pchild->tail = pnode->tail - 1;
	node_attach_child(ptree,pnode,pchild,past_symbol);
	pnode->tail = -2;

#ifdef DEBUG
	std::cout << "         [expand@" << past_symbol << "] pchild->id=" << pchild->id << ", pchild->tail=" << pchild->tail << ", counts=[";
	for(int j=0; j<ptree->A-1; j++)
		std::cout << ptree->countstorage[(pchild->id-1)*ptree->A+j] << ", ";
	std::cout << ptree->countstorage[pchild->id*ptree->A-1] << "]\n";
#endif
}

/**
 * @brief Report whether a particular child node exists.
 * This function returns a boolean to indicate whether a child node exists
 * (i.e., is attached) to the current node at the given symbol.
 * @param[in] ptree Pointer to C-style CTW tree.
 * @param[in] pnode Pointer to CTW node.
 * @param[in] symbol Symbol at which to check for child node.
 */
bool node_child_exists(struct ctwtree *ptree, struct ctwnode *pnode, int symbol)
{
	return ptree->nodestorage[(pnode->id - 1)*ptree->Ap1 + symbol]!=NULL;
}

/**
 * @brief Increment the symbol count for a node.
 * This function increments the symbol count for the current node given a
 * symbol.
 * @param[in,out] ptree Pointer to C-style CTW tree.
 * @param[in] pnode Pointer to CTW node.
 * @param[in] past_symbol Symbol at which to check for child node.
 */
void node_inc_count(struct ctwtree *ptree, struct ctwnode *pnode, int symbol)
{
	ptree->countstorage[(pnode->id - 1)*ptree->A + symbol]++;
}

/**
 * @brief Copy symbol counts from one node to another.
 * This function copies the symbol counts for the current node to the given
 * child node.
 * @param[in,out] ptree Pointer to C-style CTW tree.
 * @param[in] pnode Pointer to current CTW node.
 * @param[in,out] pchild Pointer to new CTW child node.
 */
void node_copy_counts(struct ctwtree *ptree, struct ctwnode *pnode, struct ctwnode *pchild)
{
	for(int i=0; i<ptree->A; i++)
		ptree->countstorage[i + (pchild->id - 1)*ptree->A] = ptree->countstorage[i + (pnode->id - 1)*ptree->A];
}

/**
 * @brief Returns the symbol at a given time (or epsilon).
 * This function returns the symbol at a given time, or the epsilon symbol if
 * the time crosses the epsilon barrier of the tree.
 * @param[in] ptree Pointer to C-style CTW tree.
 * @param[in] ppbins Pointer to matrix of binned data.
 * @param[in] time Time index into ppbins.
 * @return Symbol value.
 */
int symbol_or_epsilon(struct ctwtree *ptree, int **ppbins, int time)
{
	/* declare variables */
	int symbol;

	//TODO logic here could probably be better if epsilon_barrier were initialized for single stream trees
	if(ptree->epsilon_barrier)
	{
		for(int i=0; i<ptree->S; i++)
			if(time==ptree->epsilon_barrier[i])
				return ptree->epsilon;
		symbol = ppbins[0][time]; //kludge to index data
	}
	else
		symbol = (time<0) ? ptree->epsilon : ppbins[0][time]; //single stream no kludge

	return symbol;
}

/**
 * @brief Attaches a child to a parent node.
 * This function attaches a child node to the current node at the given
 * symbol (i.e., places it in the nodestorage pointer list).
 * @param[in,out] ptree Pointer to C-style CTW tree.
 * @param[in] pnode Pointer to current CTW node.
 * @param[in] pchild Pointer to new CTW child node.
 * @param[in] symbol Symbol at which to attach child node.
 */
void node_attach_child(struct ctwtree *ptree, struct ctwnode *pnode, struct ctwnode *pchild, int symbol)
{
#ifdef DEBUG
	//assertchildinrange(ptree,symbol);
	if(!pchild)
		std::cerr << "ERROR: Child to attach is NULL.\n";
	if(get_node_child(ptree,pnode,symbol))
		std::cerr << "ERROR: Attempted to attach child node where one already exists.\n";
#endif

	ptree->nodestorage[(pnode->id - 1)*ptree->Ap1 + symbol] = pchild;
}

/**
 * @brief Compute the local codelength and weightings for all tree nodes.
 * For pnode and its children (recursively) compute the local codelength (Le)
 * with the batch KT estimator, their weighted values (Lw), and the relative
 * weightings for the current node (w1) and its children (w2). If the node is
 * terminal, then Lw=Le, w1=1.0, and w2=0.0. Otherwise, apply the weighting
 * formulas: w1=2^-Le/(2^-Le+2^(sum_children Lw)) and
 * w2=2^(-sum_children Lw)/(2^-Le+2^(sum_children Lw)), where w1+w2=1.
 * @param[in,out] ptree Pointer to C-style CTW tree.
 * @param[in,out] pnode Pointer to CTW node.
 * @return Exit status integer (e.g., EXIT_SUCCESS or EXIT_FAILURE).
 */
int compute_codelength_weightings(struct ctwtree *ptree, struct ctwnode *pnode)
{
	/* declare variables */
	int status = EXIT_SUCCESS; //logical | (below) assumes EXIT_SUCCESS==0
	struct ctwnode *pchild;

	/* recurse over children (includes epsilon nodes) */
	for(int i=0; i<ptree->Ap1; i++)
	{
		pchild = get_node_child(ptree,pnode,i);
		if(pchild)
			status |= compute_codelength_weightings(ptree,pchild);
	}

	/* get local (then weighted) codelength and relative weightings */
	pnode->Le = get_KT_codelength(ptree->countstorage+(pnode->id-1)*ptree->A,ptree->A,ptree->beta);
	status |= compute_weighted_codelength(ptree,pnode);
	status |= compute_relative_weightings(ptree,pnode);

	return status;
}

/**
 * @brief Get the Krischevsky-Trofimov codelength.
 * Given a distribution of A integer counts and ballast beta, return the net
 * Krischevsky-Trofimov (KT) codelength.
 * @param[in] counts Pointer to integer counts.
 * @param[in] A Number of counts to consider (alphabet size).
 * @param[in] beta Ballast parameter.
 * @return Net KT codelength.
 */
double get_KT_codelength(int *counts, int A, double beta)
{
	/*
	 * This function corresponds to equation 3.5 in the article cited above.
	 */

	/* declare variables */
	int sum_counts = 0;
	double codelength;

	for(int a=0; a<A; a++)
		sum_counts += counts[a];
	codelength = lngamma(sum_counts,A*beta);

	for(int a=0; a<A; a++)
		codelength -= lngamma(counts[a],beta);

	return NAT2BIT(codelength); //convert to bits
}

/**
 * @brief Difference between the logarithm of the Gamma function at k+a and a.
 * Returns the difference between the natural logarithm of the Gamma function
 * at k+a and a, or zero if k is zero.
 * @param[in] k Counts (in the calculation of KT codelength).
 * @param[in] a Ballast parameter (in the calculation of KT codelength).
 * @returns Computed value.
 * @see get_KT_codelength.
 */
double lngamma(int k, double a)
{
	/*
	 * Note that the C99 standard defines lgamma in math.h, and could be used
	 * here instead of gsl_sf_lngamma. However, certain compilers (e.g., Microsoft
	 * Visual C++) do not currently implement this part of the standard.
	 */
	return (k==0) ? 0 : gsl_sf_lngamma((double)k+a) - gsl_sf_lngamma(a);
}

/**
 * @brief Compute the weighted codelength for a node.
 * This function computes the weighted codelength Lw, given the local
 * codelength Le at that node, and the weighted codelength of child nodes
 * (if necessary). If the node is terminal, then Lw=Le. Otherwise, apply the
 * Willems CTW weighting formula: Pw = 1/2(Pe + \Prod Pw(children)).
 * @param[in,out] ptree Pointer to C-style CTW tree.
 * @param[in,out] pnode Pointer to CTW node.
 * @return Exit status integer (e.g., EXIT_SUCCESS or EXIT_FAILURE).
 * @see compute_local_codelength.
 */
int compute_weighted_codelength(struct ctwtree *ptree, struct ctwnode *pnode)
{
	/*
	 * This function corresponds to equation 3.7 in the article cited above.
	 * This correspondence is not immediately obvious, and bears careful
	 * investigation. In particular, the weightings that are set to 0.5 in
	 * equation 3.6, are set to gamma and 1-gamma as discussed at the end of
	 * section 3.5.
	 */

	/* declare variables */
	int status = EXIT_SUCCESS;
	double L1, L2, sum_Lw = 0.0;
	struct ctwnode *pchild;

	if(node_is_terminal(ptree,pnode))
		pnode->Lw = pnode->Le;
	else
	{
		/*
		 * Here, the option for child_elision would take effect in the original
		 * code. If true, pnode->Lw = pchild->Lw, when only one child exists.
		 * Since this option was, by default, set to false, and never explained
		 * in the original documentation, it has been removed from this version.
		 *
		 * Please note that the original code (function jacobianlogarithm in
		 * ctw.f90) has a bug in it. Here the equivalent calculation, minus the
		 * error, is the second term in the assignment to pnode->Lw. As a time-
		 * saving device, the difference L1-L2 was compared to zero (not a
		 * recommended practice for floating-point numbers), and if True the
		 * second term was set to zero. This, however, makes the function dis-
		 * continuous when L1=L2, as the true value of the function is one.
		 * See also equation 3.7 in the above cited article.
		 */

		/* get weighted codelength */
		L1 = pnode->Le - ptree->log21mgamma;
		L2 = get_sum_children_Lw(ptree,pnode) - ptree->log2gamma;
		pnode->Lw = MIN(L1,L2) - LOG2Z(1.0 + pow(2.0,-fabs(L1-L2)));
	}

	return status;
}

/**
 * @brief Compute the relative weightings for a node.
 * This function computes the relative weightings w1 and w2, given the local
 * codelength Le at that node, and the weighted codelengths Lw of child nodes.
 * If the node is terminal, then w1=1.0 and w2=0.0. Otherwise, apply the
 * weighting formulas: w1 = 2^-Le / (2^-Le + 2^(sum Lw(children))) and
 * w2 = 2^(-sum Lw(children)) / (2^-Le + 2^(sum Lw(children))), where w1+w2=1.
 * @param[in] ptree Pointer to C-style CTW tree.
 * @param[in,out] pnode Pointer to CTW node.
 * @return Exit status integer (e.g., EXIT_SUCCESS or EXIT_FAILURE).
 * @see CTWMCMCTreeComp.
 */
int compute_relative_weightings(struct ctwtree *ptree, struct ctwnode *pnode)
{
	/*
	 * This function corresponds to equation 3.8 in the article cited above.
	 * Note, in a departure from the original code, the relative weightings are
	 * calculated and saved in the tree. This was done because the weightings
	 * are calculated in both ctwentropy_weightedEntropy and
	 * ctwentropy_mcmcSample, though the correspondence may not be immediately
	 * obvious, as the routines take a slightly different approach, and each
	 * encompass further (different) analyses.
	 */

	/* declare variables */
	int status = EXIT_SUCCESS;
	struct ctwnode *pchild;

	if(node_is_terminal(ptree,pnode)) //equivalent to sum(childcounts)==0 in ctwentropy.f90 (line 330)
	{
		pnode->w1 = 1.0;
		pnode->w2 = 0.0;
	}
	else
	{
		/*
		 * Here, the option for child_elision would take effect in the original
		 * code (only in ctwentropy_weightedEntropy not ctwentropy_mcmcSample).
		 * If true, w1=0 and w2=1, when only one child exists. Since this option
		 * was not used consistently, and was, by default, set to false, without
		 * explaination in the original documentation, it has been removed from
		 * this version.
		 *
		 * The remaining code is taken from ctw_relativeWeighting in ctw.f90,
		 * wherein can be found a lengthy discussion of the weighting algorithm.
		 * However, the original code appears to have an error (see email
		 * discussion, demo_legacy_weighting notes, and note below).
		 */

		/* declare variables */
		double Ld, twotoLd, twotominusLd;

		Ld = (pnode->Le - get_sum_children_Lw(ptree,pnode))/2.0;
		if(Ld>=40.0) //roughly 2^-40 should be eps (says original code)
		{
			pnode->w1 = 0.0;
			pnode->w2 = 1.0;
		}
		else if(Ld<-40.0)
		{
			pnode->w1 = 1.0;
			pnode->w2 = 0.0;
		}
		else
		{
			/*
			 * As described in the comments to the original code and equation 3.8
			 * in the above cited article, the following calculations should
			 * get the values 2^Ld and 2^-Ld (Matlab notation). However, the
			 * original code (line 1614 in ctw.f90 from CTPACK-2.7.1) computed
			 * exp(log2e*Ld) and its inverse, where log2e=1.4427. The similarly
			 * "worded" calculation, which would be equal to 2^Ld is exp(Ld/log2e)
			 * or exp(log(2)*Ld), and provides an indication that this was a
			 * simple error (bug). The values are not calculated this way below.
			 */
			twotoLd = pow(2.0,Ld);
			twotominusLd = pow(2.0,-Ld);

			if(Ld>0.0) //always compute the smaller value from formula
			{
				pnode->w1 = twotominusLd/(twotoLd + twotominusLd);
				pnode->w2 = 1.0 - pnode->w1;
			}
			else
			{
				pnode->w2 = twotoLd/(twotoLd + twotominusLd);
				pnode->w1 = 1.0 - pnode->w2;
			}
		}
	}

	return status;
}

/**
 * @brief Sum the weighted codelengths (Lw) of all child nodes.
 * For a particular node in a tree, sums the weighted codelengths (Lw) of all
 * child nodes.
 * @param[in] ptree Pointer to C-style CTW tree.
 * @param[in] pnode Pointer to CTW node.
 * @return Sum of all child Lw.
 */
double get_sum_children_Lw(struct ctwtree *ptree, struct ctwnode *pnode)
{
	/* declare variables */
	double sum_Lw = 0;
	struct ctwnode *pchild;

	for(int i=0; i<ptree->Ap1; i++)
	{
		pchild = get_node_child(ptree,pnode,i);
		if(pchild)
			sum_Lw += pchild->Lw;
	}

	return sum_Lw;
}
