/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Computational routines for sampling CTW tree graphs.
 * This file contains the computational routines for sampling CTW tree graphs,
 * as required by the MEX-file ctwmcmcsample.cpp. The code herein was created
 * largely as a direct port from the original Fortran code provided by Jon
 * Shlens (http://www.snl.salk.edu/~shlens/pub/code/CTPACK-2.7.1.tgz). See
 * also the related article: Kennel, M., Shlens, J., Abarbanel, H., and
 * Chichilnisky, E.J. (2005) Estimating entropy rates with Bayesian confidence
 * intervals. Neural Computation, 2005: 17, 1531-1576.
 * @see ctwmcmcsample.cpp.
 */

//TODO
//additional status checks should be made (especially when allocating memory)

#include "../../shared/toolkit_c.h"
#include "ctwmcmc_c.h"

#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>

gsl_rng *RNG; //global random number generator

/**
 * @brief Get entropy samples from CTW tree(s).
 * This is the main computational routine responsible for calculating entropy
 * from CTW trees, both analytically via any toolkit entropy method, and via
 * Markov chain Monte Carlo (MCMC) sampling.
 * @param[in] pptree Pointer to CTW tree C struct pointers.
 * @param[in] popts Pointer to ctwmcmc options struct.
 * @param[in] pentropy Pointer to entropy options struct.
 * @param[in] ntrees Number of trees to sample.
 * @param[in,out] ppest Pointer to arrays of entropy estimate structs.
 * @param[in,out] ppsamples Pointer to memory to hold MCMC samples.
 * @return Exit status integer (e.g., EXIT_SUCCESS or EXIT_FAILURE).
 * @see ctwmcmcsample.cpp.
 */
int CTWMCMCSampleComp(struct ctwtree **pptree, struct options_ctwmcmc *popts, struct options_entropy *pentropy, int ntrees, struct estimate **ppest, double **ppsamples)
{
	/* declare variables */
	int status = EXIT_SUCCESS; //logical | (below) assumes EXIT_SUCCESS=0

	RNG = gsl_rng_alloc(gsl_rng_taus); //gsl_rng_taus is the generator used by the original Fortran code (could pick a better generator or make toolkit global option)

	for(int i=0; i<ntrees; i++)
	{
		status |= compute_weighted_entropy(pptree[i],pptree[i]->root,pentropy,ppest[i]);
		for(int j=0; j<popts->nmc; j++)
		{
#ifdef DEBUG
			std::cout << "MCMC[tree=" << i + 1 << ", sample=" << j + 1 << "] includes nodes:";
#endif

			ppsamples[i][j] = mcmc_tree_sample(pptree[i],pptree[i]->root,popts->mcmc_iter,popts->mcmc_max_iter,popts->mcmc_min_accept);

#ifdef DEBUG
			std::cout << "\n";
#endif
		}
	}

	gsl_rng_free(RNG); //free the generator

	return status;
}

/**
 * @brief Calculate analytical entropy from a CTW tree.
 * Given a CTW tree with relative weightings at each node, and local counts,
 * calculate analytical entropy via any of the toolkit entropy methods, as
 * specified by options.
 * @param[in] ptree Pointer to CTW tree C struct.
 * @param[in] popts Pointer to ctwmcmc options struct.
 * @param[in] pentropy Pointer to entropy options struct.
 * @param[in,out] pest Pointer to entropy estimate structs.
 * @return Exit status integer (e.g., EXIT_SUCCESS or EXIT_FAILURE).
 * @see CTWMCMCSampleComp.
 */
int compute_weighted_entropy(struct ctwtree *ptree, struct ctwnode *pnode, struct options_entropy *pentropy, struct estimate *pest)
{
	/*
	 * This function is most closely analogous to CTW_avg_funct in ctw.f90.
	 * However, relative weightings have already be calculated (see
	 * ctwmcmctree), and existing STAToolkit functionality (entropy estimation)
	 * has been incorporated.
	 */

	/* declare variables */
	int status = EXIT_SUCCESS;

	if(pnode->w1>0.0) //get contribution from current node
	{
		/* declare variables */
		struct hist1d *hist;
		int status;

		hist = node_to_hist1d(ptree,pnode,pentropy);
		if(hist) //node will have non-zero entropy
		{
			status = Entropy1DComp(1,hist,pentropy);
			for(int e=0; e<pentropy->E; e++)
			{
				pest[e].value = pnode->w1*hist->entropy[e].value;

				//copy messages (in case errors are thrown but do not pass variance or extras)
				if(hist->entropy[e].messages->i) //status
				{
					pest[e].messages->status = (char **)realloc(pest[e].messages->status,(pest[e].messages->i+hist->entropy[e].messages->i)*sizeof(char *));
					for(int i=0; i<hist->entropy[e].messages->i; i++)
					{
						pest[e].messages->status[pest[e].messages->i] = (char *)malloc((strlen(hist->entropy[e].messages->status[i])+1)*sizeof(char));
						strcpy(pest[e].messages->status[pest[e].messages->i],hist->entropy[e].messages->status[i]);
						pest[e].messages->i++;
					}
				}
				if(hist->entropy[e].messages->j) //warnings
				{
					pest[e].messages->warnings = (char **)realloc(pest[e].messages->warnings,(pest[e].messages->j+hist->entropy[e].messages->j)*sizeof(char *));
					for(int j=0; j<hist->entropy[e].messages->j; j++)
					{
						pest[e].messages->warnings[pest[e].messages->j] = (char *)malloc((strlen(hist->entropy[e].messages->warnings[j])+1)*sizeof(char));
						strcpy(pest[e].messages->warnings[pest[e].messages->j],hist->entropy[e].messages->warnings[j]);
						pest[e].messages->j++;
					}
				}
				if(hist->entropy[e].messages->k) //errors
				{
					pest[e].messages->errors = (char **)realloc(pest[e].messages->errors,(pest[e].messages->k+hist->entropy[e].messages->k)*sizeof(char *));
					for(int k=0; k<hist->entropy[e].messages->k; k++)
					{
						pest[e].messages->errors[pest[e].messages->k] = (char *)malloc((strlen(hist->entropy[e].messages->errors[k])+1)*sizeof(char));
						strcpy(pest[e].messages->errors[pest[e].messages->k],hist->entropy[e].messages->errors[k]);
						pest[e].messages->k++;
					}
				}
			}
			CFreeHist1D(1,hist,pentropy);
		}
		else //node is trivial
			for(int e=0; e<pentropy->E; e++)
				pest[e].value = 0.0;
	}
	else
		for(int e=0; e<pentropy->E; e++)
			pest[e].value = 0.0;

	if(pnode->w2>0.0) //get contribution from child(ren) node(s)
	{
		/* declare variables */
		int counthere, countchild;
		struct ctwnode *pchild;
		struct estimate *pest_new;

		counthere = node_count_total(ptree,pnode);
		for(int i=0; i<ptree->Ap1; i++) //includes epsilon nodes
		{
			pchild = get_node_child(ptree,pnode,i);
			countchild = (pchild) ? node_count_total(ptree,pchild) : 0;

			if(countchild>0)
			{
				//in original code this step is conditioned on "intensive" which is always set to true
				pest_new = CAllocEst(pentropy);
				status = compute_weighted_entropy(ptree,pchild,pentropy,pest_new);
				for(int e=0; e<pentropy->E; e++)
				{
					pest[e].value += pnode->w2*(double)countchild/(double)counthere*pest_new[e].value;

					//copy messages (in case errors are thrown but do not pass variance or extras)
					if(pest_new[e].messages->i)
					{
						pest[e].messages->status = (char **)realloc(pest[e].messages->status,(pest[e].messages->i+pest_new[e].messages->i)*sizeof(char *));
						for(int i=0; i<pest_new[e].messages->i; i++)
						{
							pest[e].messages->status[pest[e].messages->i] = (char *)malloc((strlen(pest_new[e].messages->status[i])+1)*sizeof(char));
							strcpy(pest[e].messages->status[pest[e].messages->i],pest_new[e].messages->status[i]);
							pest[e].messages->i++;
						}
					}
					if(pest_new[e].messages->j) //warnings
					{
						pest[e].messages->warnings = (char **)realloc(pest[e].messages->warnings,(pest[e].messages->j+pest_new[e].messages->j)*sizeof(char *));
						for(int j=0; j<pest_new[e].messages->j; j++)
						{
							pest[e].messages->warnings[pest[e].messages->j] = (char *)malloc((strlen(pest_new[e].messages->warnings[j])+1)*sizeof(char));
							strcpy(pest[e].messages->warnings[pest[e].messages->j],pest_new[e].messages->warnings[j]);
							pest[e].messages->j++;
						}
					}
					if(pest_new[e].messages->k) //errors
					{
						pest[e].messages->errors = (char **)realloc(pest[e].messages->errors,(pest[e].messages->k+pest_new[e].messages->k)*sizeof(char *));
						for(int k=0; k<pest_new[e].messages->k; k++)
						{
							pest[e].messages->errors[pest[e].messages->k] = (char *)malloc((strlen(pest_new[e].messages->errors[k])+1)*sizeof(char));
							strcpy(pest[e].messages->errors[pest[e].messages->k],pest_new[e].messages->errors[k]);
							pest[e].messages->k++;
						}
					}
				}
				CFreeEst(pest_new,pentropy);
			}
		}
	}

	return status;
}

/**
 * @brief Convert CTW tree node to hist1d struct for entropy estimation.
 * This function converts a CTW tree node into a hist1d struct. The purpose
 * is to allow the existing toolkit entropy methods to be used for entropy
 * calculations on a tree.
 * @param[in] ptree Pointer to a CTW tree.
 * @param[in] pnode Pointer to a CTW node.
 * @param[in] popts Pointer to an entropy options struct.
 * @return A hist1d struct.
 * @see compute_weighted_entropy.
 */
struct hist1d *node_to_hist1d(struct ctwtree *ptree, struct ctwnode *pnode, struct options_entropy *popts)
{
	/* declare variables */
	struct hist1d *hist;
	int nnz = 0; //number of non-zero counts

	/* check non-zero counts */
	for(int i=0; i<ptree->A; i++)
		if(ptree->countstorage[(pnode->id - 1)*ptree->A + i])
			nnz++;
	if(ptree->h_zero && (nnz<2)) //zero entropy when zero count nodes not included and one or fewer non-zero counts
		return NULL;

	/* allocate hist1d */
	hist = (struct hist1d *)malloc(sizeof(struct hist1d));
	hist->P = node_count_total(ptree,pnode); //total words akin to total counts
	hist->N = 1; //subwords are (should be) irrelevant
	hist->entropy = CAllocEst(popts);

	if(ptree->h_zero) //zero counts should not be weighted
	{
		hist->C = nnz; //unique words akin to number of non-zero counts
		hist->wordlist = MatrixInt(nnz,1);
		hist->wordcnt = (double *)malloc(nnz*sizeof(double));
		for(int i=0, j=0; i<ptree->A && j<nnz; i++)
			if(ptree->countstorage[(pnode->id - 1)*ptree->A + i])
			{
				hist->wordlist[j][0] = i;
				hist->wordcnt[j] = (double)ptree->countstorage[(pnode->id - 1)*ptree->A + i];
				j++;
			}
	}
	else //include zero count nodes
	{
		hist->C = ptree->A; //unique words akin to alphabet size
		hist->wordlist = MatrixInt(ptree->A,1);
		hist->wordcnt = (double *)malloc(ptree->A*sizeof(double));
		for(int i=0; i<ptree->A; i++)
		{
			hist->wordlist[i][0] = i;
			hist->wordcnt[i] = (double)ptree->countstorage[(pnode->id - 1)*ptree->A + i];
		}
	}

	return hist;
}

/**
 * @brief Draw one MCMC entropy sample from a CTW tree.
 * This function selects a random sub-tree from the given CTW tree, sampling
 * each terminal node in the sub-tree, and combines these samples to estimate
 * the entropy of the tree.
 * @param[in] ptree Pointer to C struct CTW tree.
 * @param[in] pnode Pointer to C struct CTW node.
 * @return Entropy sample in bits.
 */
double mcmc_tree_sample(struct ctwtree *ptree, struct ctwnode *pnode, int niter, int maxiter, int minaccept)
{
	/*
	 * This function is analogous to ctwentropy_mcmcSample in ctwentropy.f90.
	 * Lengthy comments about its functionality are contained in the original
	 * code, and discussed in the article cited at the top of this file, but
	 * not reproduced here.
	 */

	/* declare variables */
	double sample = 0.0;

	if(pnode)
		if(gsl_rng_uniform(RNG)<pnode->w1) //grab sample here
			sample = (double)node_count_total(ptree,pnode)/(double)ptree->S*mcmc_node_sample(ptree,pnode,niter,maxiter,minaccept); //other methods possible here (see Appendix B)
		else //recurse over children
			for(int i=0; i<ptree->Ap1; i++)
				sample += mcmc_tree_sample(ptree,get_node_child(ptree,pnode,i),niter,maxiter,minaccept);

	return sample;
}

/**
 * @brief Draw one MCMC entropy sample at a CTW node.
 * This function makes one sample from the MCMC Bayesian posterior estimate of
 * Shannon entropy at the given CTW node.
 * @param[in] ptree Pointer to C struct CTW tree.
 * @param[in] pnode Pointer to C struct CTW node.
 * @return Entropy sample in bits.
 */
double mcmc_node_sample(struct ctwtree *ptree, struct ctwnode *pnode, int niter, int maxiter, int minaccept)
{
	/*
	 * This function corresponds to Appendix A in the article cited above.
	 * This function is analogous to mcmc_sample_accept in mcmc.f90 in the
	 * original code. It is called from ctwentropy_mcmcSample in ctwentropy.f90
	 * 100% of the time, due to a hard-coded if-false-else logic, which was not
	 * retained in mcmc_tree_sample above.
	 */

#ifdef DEBUG
	std::cout << " " << pnode->id;
#endif

	/* declare variables */
	double sample = 0.0;
	int *counts, nnz = 0; //number of non-zero counts

	/* check non-zero counts */
	counts = ptree->countstorage + (pnode->id - 1)*ptree->A;
	for(int i=0; i<ptree->A; i++)
		if(counts[i])
			nnz++;

	/* sample node (if non-trivial) */
	if((!ptree->h_zero) || (nnz>1))
	{
		/* declare variables */
		int ncountiter = 0, naccept = 0, total_counts;
		double *sigma, *p, *pcandidate; //count variance and probabilities
		double pfinal, logL, logLcandidate, logLdiff, acceptprob;

		/* initialize variance */
		sigma = (double *)malloc((ptree->A - 1)*sizeof(double)); //ptree->A-1 because last probability value determined by constraint sum(p)=1
		total_counts = node_count_total(ptree,pnode);
		if(total_counts)
			for(int i=0; i<ptree->A-1; i++)
				sigma[i] = sqrt((double)MIN(counts[i],total_counts-counts[i]) + 0.5)/(double)total_counts;
		else
			for(int i=0; i<ptree->A-1; i++)
				sigma[i] = 1.0/(ptree->A*ptree->A);

		/* initialize probabilities */
		p = (double *)malloc(ptree->A*sizeof(double));
		pcandidate = (double *)malloc(ptree->A*sizeof(double));
		for(int i=0; i<ptree->A; i++) //initialize Markov chain at observed frequencies
			p[i] = ((double)counts[i] + ptree->beta)/((double)total_counts + ptree->A*ptree->beta);
		logL = log_likelihood_multinomial(ptree->A,counts,p,ptree->beta);

		/* simulate Markov chain */
		while((naccept<minaccept) && (ncountiter<maxiter))
			for(int i=0; i<niter; i++)
			{
				/*
				 * According to the original code, this loop bears the brunt of the
				 * computational work, and therefore should be optimized. To this
				 * end, various conditionals have been removed or changed as
				 * compared to the original code.
				 */

				ncountiter++;

				/* get candidate probabilities */
				pfinal = 1.0; //probability of final
				for(int j=0; j<ptree->A-1; j++)
				{
					pcandidate[j] = p[j] + sigma[j]*gsl_ran_gaussian(RNG,1.0); //equivalent to original code when RNG is gsl_rng_taus (via Box-Muller algorithm in polar form)
					if((pcandidate[j]<0.0) || (pcandidate[j]>1.0))
						goto continue_main_loop;
					pfinal -= pcandidate[j];
				}
				if(pfinal<0.0)
					continue;
				pcandidate[ptree->A-1] = pfinal;

				/* compute Metropolis-Hastings acceptance probability */
				logLcandidate = log_likelihood_multinomial(ptree->A,counts,pcandidate,ptree->beta);
				logLdiff = logLcandidate - logL;
				if((logLdiff<0.0) && ( (logLdiff<-7.0) || (gsl_rng_uniform(RNG)>exp(logLdiff)) ))
					/*
					 * Quote from the original code: "if logLdiff is [greater than
					 * or equal to] 0 then the acceptance probability is [greater
					 * than or equal to] 1 and the step will always be taken (c.f.
					 * simulated annealing!)". And with regards to logLdiff<-7.0,
					 * the original code comments state: "exp(-10) is 4.5e-5,
					 * assume no probability ... to save computation time", note
					 * that the original comment discussed -10 but -7 was the
					 * cutoff used in the code, therefore it is used here.
					 */
					continue;

				memcpy(p,pcandidate,ptree->A*sizeof(double));
				logL = logLcandidate;
				naccept++;

				continue_main_loop: ; //dummy statement to skip other main loop statements
			}

#ifdef DEBUG
		std::cout << "(";
		for(int i=0; i<ptree->A-1; i++)
			std::cout << p[i] << " ";
		std::cout << p[ptree->A-1] << ")";
#endif

		/* get Shannon entropy from most recent element in the chain (assume it is well mixing) */
		for(int i=0; i<ptree->A; i++)
			sample -= p[i]*LOGZ(p[i]);
		sample = NAT2BIT(sample);

		/* free dynamic memory */
		free(sigma);
		free(p);
		free(pcandidate);
	}

	return sample;
}

/**
 * @brief Calculate the logarithmic likelihood function.
 * From a vector of counts and probabilities, and a ballast parameter,
 * calculate the logarithmic likelihood of said counts.
 * @param[in] A Length of vectors counts and p (alphabet size).
 * @param[in] counts Vector of counts.
 * @param[in] p Vector of probabilities.
 * @param[in] beta Ballast parameter.
 * @return Log likelihood in nats.
 * @see mcmc_node_sample.
 */
double log_likelihood_multinomial(int A, int *counts, double *p, double beta)
{
	/* declare variables */
	double logL = 0.0;

	for(int i=0; i<A; i++)
		logL += (beta - 1.0 + (double)counts[i])*LOGZ(p[i]);

	return logL;
}
