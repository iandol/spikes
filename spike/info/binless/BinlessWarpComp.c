/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../../shared/toolkit_c.h"
#include "binless_c.h"
/* #define DEBUG */

int BinlessWarpComp(struct options_binless *opts,
		     double **times,
		     int *n_vec,
		     int N,
		     double **tau_j)
{
  double **j;
  double *all_times,*all_times_unique,*all_times_sorted;
  int *all_times_unique_i,*all_times_unique_j,*all_times_sorted_idx;
  int *cnt;
  double *mean_ranks,*ranks_vec;
  int u,p,m,q;
  int U;
  int cur_idx;
  int cum_cnt;
  double min_time,max_time;
  int M;

  /* How many spikes do we have? */
  M=0;
  for(p=0;p<N;p++)
    M+=n_vec[p];

  all_times = (double *)calloc(M,sizeof(double));
  all_times_unique = (double *)malloc(M*sizeof(double));
  all_times_unique_i=(int *)calloc(M,sizeof(int));
  all_times_unique_j=(int *)calloc(M,sizeof(int));
  all_times_sorted = (double *)malloc(M*sizeof(double));
  all_times_sorted_idx=(int *)calloc(M,sizeof(int));
  cnt = (int *)calloc(M,sizeof(double));

  /* If there are no spikes anywhere, we can bypass all of this */
  if(M==0)
    return EXIT_SUCCESS;

  /* Concatenate all of the spike trains */
  cur_idx = 0;
  for(p=0;p<N;p++)
    {
      memcpy(&all_times[cur_idx],times[p],n_vec[p]*sizeof(double));
      cur_idx += n_vec[p];
    }

  /* Get a vector of all of the unique spike times */
  U = UniqueDouble(M,all_times,all_times_unique,all_times_unique_i,all_times_unique_j,cnt);

  min_time = all_times_unique[0];
  max_time = all_times_unique[U-1];
#ifdef DEBUG
  printf("M=%d U=%d min_time=%f max_time=%f\n",M,U,min_time,max_time);
#endif

  mean_ranks = (double *)malloc(U*sizeof(double));

  /* Find the mean ranks within each group */
  cum_cnt = 0;
  for(u=0;u<U;u++)
    {
      mean_ranks[u] = (((double)(cnt[u]+1))/2) + cum_cnt;
#ifdef DEBUG
      printf("idx[%d]=%d mean_ranks[%d]=%f cnt[%d]=%d cum_cnt=%d\n",u,all_times_unique_j[u],u,mean_ranks[u],u,cnt[u],cum_cnt);
#endif
      cum_cnt += cnt[u];
    }

  /* Now get the rankings back to their original spike train */
  ranks_vec = (double *)malloc(M*sizeof(double));
  for(m=0;m<M;m++)
    ranks_vec[m] = mean_ranks[all_times_unique_j[m]];

  /* Deconcatenate the ranks */
  /* and do the time warping (Eq. 17) */
  j = (double **)malloc(N*sizeof(double *));

  cur_idx = 0;
  for(p=0;p<N;p++)
    {
      j[p] = &ranks_vec[cur_idx];
      for(q=0;q<n_vec[p];q++)
	{
	  if((*opts).warp_strat==0) /* Non-uniform warping */
	    tau_j[p][q] = (*opts).w_start + (((*opts).w_end-(*opts).w_start)/(max_time-min_time))*times[p][q];
	  else
	    tau_j[p][q] = (*opts).w_start + (((*opts).w_end-(*opts).w_start)*(j[p][q]-0.5)/((double)M));

#ifdef DEBUG
	  printf("times[%d][%d]=%.3f j[%d][%d]=%.1f tau_j[%d][%d]=%.3f\n",p,q,times[p][q],p,q,j[p][q],p,q,tau_j[p][q]);
#endif
	}
#ifdef DEBUG
      printf("\n");
#endif
      cur_idx += n_vec[p];
    }

  free(all_times);
  free(all_times_unique);
  free(all_times_unique_i);
  free(all_times_unique_j);
  free(cnt);
  free(mean_ranks);
  free(ranks_vec);
  free(j);  

  return EXIT_SUCCESS;
}
