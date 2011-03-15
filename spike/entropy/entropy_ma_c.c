/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

#include "../shared/toolkit_c.h"

int entropy_ma(struct hist1d *in,struct options_entropy *opts,struct estimate *entropy)
{
	int *cnt,*cnt_sorted,*cnt_sort_idx,*N_sp,*cnt_uni_i,*cnt_uni_j,*num_unique_with_N_sp;
	int n,c,u,U;
	double cur_wordcnt;
	double *N_obs,*N_c,*P_N_sp;
	double H;

	/* For each unique word, extract the spike counts by summing the subwords */
	/* This is only possible if there's no hashing */

	cnt = (int *)calloc((*in).C,sizeof(int));

	for(c=0; c<(*in).C; c++)
		for(n=0; n<(*in).N; n++)
			cnt[c] += (int)(*in).wordlist[c][n];

	/* Now we want to sort the wordcnts by the spike count. */
	/* num_unique_with_N_sp[u] is the number of *unique* words that have N_sp[u] spikes. */ 

	cnt_sorted = (int *)malloc((*in).C*sizeof(int));
	cnt_sort_idx = (int *)malloc((*in).C*sizeof(int));
	N_sp = (int *)malloc((*in).C*sizeof(int));
	cnt_uni_i =  (int *)malloc((*in).C*sizeof(int));
	cnt_uni_j =  (int *)malloc((*in).C*sizeof(int));
	num_unique_with_N_sp = (int *)calloc((*in).C,sizeof(int));

	/* First, find cnt_sort_idx and num_unique_with_N_sp */
	SortInt((*in).C,cnt,cnt_sorted,cnt_sort_idx);

#ifdef DEBUG
	for(c=0; c<(*in).C; c++)
		printf("cnt[%d]=%d cnt_sorted[%d]=%d\n",c,cnt[c],c,cnt_sorted[c]);
#endif

	U = CountSortedInt((*in).C,cnt_sorted,cnt_sort_idx,N_sp,cnt_uni_i,cnt_uni_j,num_unique_with_N_sp);

	N_obs = (double *)calloc(U,sizeof(double));
	P_N_sp = (double *)malloc(U*sizeof(double));
	N_c = (double *)calloc(U,sizeof(double));

	/* Next, calculate N_obs[u], which is the *total* number of words
		 that have N_sp[u] spikes */
	/* and N_c[u], which is the number of possible coincidences among
		 words that have N_sp[u] spikes */
	c = 0;
	H = 0;
	for(u=0; u<U; u++)
	{
		/* For each unique word with N_sp[u] spikes, */
		for(n=0; n<num_unique_with_N_sp[u]; n++)
		{
			cur_wordcnt = (*in).wordcnt[cnt_sort_idx[c]];
			N_obs[u] += cur_wordcnt;
			N_c[u] += (cur_wordcnt*(cur_wordcnt-1))/2;
#ifdef DEBUG
			printf("cnt_sorted[%d]=%d cur_wordcnt=%f num_coin=%f\n",c,cnt_sorted[c],cur_wordcnt,(cur_wordcnt*(cur_wordcnt-1))/2);
#endif
			c++;
		}
		if(N_obs[u]>1)
		{
			P_N_sp[u] = N_obs[u]/(double)(*in).P;
			H -= P_N_sp[u] * LOG2Z(P_N_sp[u]*(2*N_c[u]/(N_obs[u]*(N_obs[u]-1))));
		}
#ifdef DEBUG
		printf("N_sp[%d]=%d num_unique=%d N_obs[%d]=%f P_N_sp[%d]=%f N_c[%d]=%f\n",u,N_sp[u],num_unique_with_N_sp[u],u,N_obs[u],u,P_N_sp[u],u,N_c[u]);
#endif
	}
 
	free(cnt_sorted);
	free(cnt_sort_idx);
	free(N_sp);
	free(cnt_uni_i);
	free(cnt_uni_j);
	free(N_obs);
	free(N_c);
	free(num_unique_with_N_sp);
	free(P_N_sp);

	entropy->value = H;
	return EXIT_SUCCESS;
}

