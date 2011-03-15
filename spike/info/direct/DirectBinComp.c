/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Bin spike trains for direct method analysis.
 * This file contains the computational routines required by the
 * MEX-file directbin.c. 
 * @see directbin.c.
 */

#include "../../shared/toolkit_c.h"
#include "direct_c.h"

int GetNumWords(struct input *X,struct options_direct *opts)
{
  int m;
  int P_total=0;
  
  for(m=0;m<(*X).M;m++)
    P_total+=(*X).categories[m].P;

  return (*opts).words_per_train*P_total;
}

int GetWindowSize(struct options_direct *opts)
{
  int W;

  if((*opts).legacy_binning==1)
    W = floor(((*opts).t_end - (*opts).t_start)/((*opts).words_per_train*(*opts).Delta)) + 1;
  else
    W = ceil(((*opts).t_end - (*opts).t_start)/((*opts).words_per_train*(*opts).Delta));
  
  return W;
}

int DirectBinComp(struct input *X,struct options_direct *opts,int P_total,int W,int *P_vec,int **binned)
{
  double *cur_times;
  int q_start,q_end;
  int m,p,p_total,n,q,z;
  int cur_Q;
  double word_len,cur_start,cur_end;
  int ***binned3,***sort_binned3;
  int *temp_list;
  int temp_N;

  for(m=0;m<(*X).M;m++)
    P_vec[m]=(*X).categories[m].P;

  if(opts[0].sum_spike_trains)
    temp_N = 1;
  else
    temp_N = (*X).N;

  binned3 = Matrix3Int(P_total,temp_N,W);

  /* W is the number of letters in a word */
  /* word_len is the length of a word in seconds */
  word_len = ((*opts).t_end - (*opts).t_start)/(*opts).words_per_train;

  p_total = 0;
  for(m=0;m<(*X).M;m++)
    for(z=0;z<(*opts).words_per_train;z++)
      {
	cur_start = (*opts).t_start + z*word_len;
	cur_end = (*opts).t_start + (z+1)*word_len;
	for(p=0;p<(*X).categories[m].P;p++)
	  {
	    for(n=0;n<(*X).N;n++)
	      {
		cur_Q = (*X).categories[m].trials[p][n].Q;
		cur_times = (double *)malloc(cur_Q*sizeof(double));
		
		for(q=0;q<cur_Q;q++)
		  cur_times[q] = (*X).categories[m].trials[p][n].list[q]*(*X).sites[n].time_scale;
		
		GetLims(cur_times,cur_start,cur_end,cur_Q,&q_start,&q_end);
	      
		if(opts[0].sum_spike_trains)
		  BinTimes(cur_times,q_start,q_end,binned3[p_total][0],(*opts).Delta,cur_start,opts->letter_cap);
		else
		  BinTimes(cur_times,q_start,q_end,binned3[p_total][n],(*opts).Delta,cur_start,opts->letter_cap);
		
		free(cur_times);
	      }
	    p_total++;
	  }
      }

  /* We've got binned[p][n][w] */

  /*** Allocate memory for sort_binned3 ***/
  sort_binned3 = (int ***)calloc(P_total,sizeof(int **));
  sort_binned3[0] = (int **)calloc(P_total*temp_N,sizeof(int *));
  sort_binned3[0][0] = binned[0];
  
  for(p=1;p<P_total;p++)
    {
      sort_binned3[p]=sort_binned3[p-1]+temp_N;
      sort_binned3[p][0]=sort_binned3[p-1][0]+temp_N*W;
    }

  for(p=0;p<P_total;p++)
    for(n=1;n<temp_N;n++)
      sort_binned3[p][n]=sort_binned3[p][n-1]+W;

  /* Now we've got a 3-D matrix of binned words */
  /* Here's where we make the decision to concatenate or sort then concatenate */
  if((opts->permute_spike_trains==1) && (opts->sum_spike_trains==0))
    {
      temp_list = (int *)malloc(temp_N*sizeof(int));
      for(p=0;p<P_total;p++)
	SortRowsInt((*X).N,W,binned3[p],sort_binned3[p],temp_list);
      free(temp_list);
    }    
  else
    /* Copy the unsorted words into the space allocated for the output */
    memcpy(sort_binned3[0][0],binned3[0][0],P_total*temp_N*W*sizeof(int));
  
  FreeMatrix3Int(binned3);
  free(sort_binned3[0]);
  free(sort_binned3);

  return EXIT_SUCCESS;
}

/* This function doesn't know if binned is empty or not */
void BinTimes(double *t,int q_start,int q_end,int *binned,double Delta,double t_start,int letter_cap)
{
  int q,w;
      
  /* Assign the spike times to a bin */
  for (q=q_start;q<=q_end;q++)
    {
      w = floor((t[q]-t_start)/Delta);
      if((letter_cap==0) | (binned[w]<letter_cap))
        binned[w]++;
    }
}

