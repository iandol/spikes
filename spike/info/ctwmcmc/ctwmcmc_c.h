/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#define DEFAULT_BETA 0.5
#define DEFAULT_GAMMA 0.5
#define DEFAULT_NMC 199
#define DEFAULT_MAX_TREE_DEPTH 1000
#define DEFAULT_H_ZERO 1
#define DEFAULT_TREE_FORMAT 2
#define DEFAULT_MEMORY_EXPANSION 1.61
#define DEFAULT_MCMC_ITER 100
#define DEFAULT_MCMC_MAX_ITER 10000
#define DEFAULT_MCMC_MIN_ACCEPT 20

#ifdef DEBUG
#include <iostream>
#endif

struct options_ctwmcmc
{
	double beta; int beta_flag; //Krischevsky-Trofimov ballast parameter/Dirichlet prior parameter
	double gamma; int gamma_flag; //weighting between tree node and its children
	int nmc; int nmc_flag; //number of Monte-Carlo samples
	int max_tree_depth; int max_tree_depth_flag; //maximum tree depth
	int h_zero; int h_zero_flag; //boolean to indicate use of H_zero estimator for deterministic nodes
	int tree_format; int tree_format_flag; //format in which tree is returned (i.e., "none", "struct", or "cell")
	double memory_expansion; int memory_expansion_flag; //factor used in reallocation of memory
	int mcmc_iter; int mcmc_iter_flag; //absolute number of MCMC iterations
	int mcmc_max_iter; int mcmc_max_iter_flag; //maximum number of iterations
	int mcmc_min_accept; int mcmc_min_accept_flag; //minimum number of acceptances
};

struct ctwnode
{
	int id; //unique node ID
	int tail; //index to the tail location in the data (if terminal node)

	double Le; //local estimated codelength
	double Lw; //weighted codelength

	double w1; //weighting for this node
	double w2; //weighting for child(ren) node(s)
};

struct ctwtree
{
	int S; //number of symbols from which to build tree
	int A; //alphabet size (predictable)
	int Ap1; //alphabet size including epsilon nodes (usually A+1)
	int epsilon; //identity of epsilon symbol (usually A)
	bool h_zero; //flag to indicate use of H_zero estimator for deterministic nodes (are deterministic counts always zero entropy)
	int maxdepth; //maximum tree depth
	int nodesused; //number of nodes currently in use
	int nodesallocated; //number of nodes currently allocated

	double beta; //KT ballast parameter or Dirichlet prior parameter
	double gamma, log2gamma, log21mgamma; //weighting parameter and precomputed derivatives
	double log2A; //precomputed log2 of alphabet size

	struct ctwnode *root; //pointer to the root node

	int *epsilon_barrier; //array of integer-valued times which would be considered "before" the beginning of a time-contiguous segment
	int *countstorage; //array of storage counts for all nodes
	struct ctwnode **nodestorage; //array of pointers to child nodes
};

/* CTWMCMCTreeComp.cpp */
extern int CTWMCMCTreeComp(int **ppbins, struct ctwtree **pptree, int ntrees, int nsymbols, int A, struct options_ctwmcmc *popts);
extern int update_tree(struct ctwtree *ptree, int **ppbins, int symbol, int time, double memory_expansion);
extern bool node_is_tail(struct ctwnode *pnode);
extern void expand_tail(struct ctwtree *ptree, struct ctwnode *pnode, int **ppbins, double memory_expansion);
extern bool node_child_exists(struct ctwtree *ptree, struct ctwnode *pnode, int symbol);
extern void node_inc_count(struct ctwtree *ptree, struct ctwnode *pchild, int symbol);
extern void node_copy_counts(struct ctwtree *ptree, struct ctwnode *pnode, struct ctwnode *pchild);
extern int symbol_or_epsilon(struct ctwtree *ptree, int **ppbins, int time);
extern void node_attach_child(struct ctwtree *ptree, struct ctwnode *pnode, struct ctwnode *pchild, int symbol);
extern int compute_codelength_weightings(struct ctwtree *ptree, struct ctwnode *pnode);
extern double get_KT_codelength(int *counts, int A, double beta);
extern double lngamma(int k, double a);
extern int compute_weighted_codelength(struct ctwtree *ptree, struct ctwnode *pnode);
extern int compute_relative_weightings(struct ctwtree *ptree, struct ctwnode *pnode);
extern double get_sum_children_Lw(struct ctwtree *ptree, struct ctwnode *pnode);

/* CTWMCMCSampleComp.cpp */
extern int CTWMCMCSampleComp(struct ctwtree **pptree, struct options_ctwmcmc *popts, struct options_entropy *pentropy, int ntrees, struct estimate **ppest, double **ppsamples);
extern int compute_weighted_entropy(struct ctwtree *ptree, struct ctwnode *pnode, struct options_entropy *pentropy, struct estimate *pest);
extern struct hist1d *node_to_hist1d(struct ctwtree *ptree, struct ctwnode *pnode, struct options_entropy *popts);
extern double mcmc_tree_sample(struct ctwtree *ptree, struct ctwnode *pnode, int niter, int maxiter, int minaccept);
extern double mcmc_node_sample(struct ctwtree *ptree, struct ctwnode *pnode, int niter, int maxiter, int minaccept);
extern double log_likelihood_multinomial(int A, int *counts, double *p, double beta);

/* ctwmcmc_c.cpp */
extern struct ctwtree *CAllocCTWTree(int ntrees, int nsymbols, int A, bool h_zero, int maxdepth, double beta, double gamma, double memory_expansion);
extern void CFreeCTWTree(struct ctwtree *ptree);
extern struct ctwnode *CAllocCTWNode(struct ctwtree *ptree, double memory_expansion);
extern void CReallocCTWTree(struct ctwtree *ptree, int nodes);
extern int node_count_total(struct ctwtree *ptree, struct ctwnode *pnode);
extern struct ctwnode *get_node_child(struct ctwtree *ptree, struct ctwnode *pnode, int symbol);
extern bool node_is_terminal(struct ctwtree *ptree, struct ctwnode *pnode);
