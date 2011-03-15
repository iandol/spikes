/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../../shared/toolkit_c.h"
#include "metric_c.h"
/* #define DEBUG */

int MetricOpenComp(struct input *X,
		   struct options_metric *opts,
		   int P_total,
		   double **times,
		   int **labels,
		   int *counts,
		   int *categories)
{
  int p_total,q_total;
  int m,n,p,q;
  int cur_Q,*cur_Q_lim;
  int *q_start,q_end;
  double **scale_times;
  double *cur_times;
  int *cur_labels;
  int *sort_idx;

  /* Allocate memory for pointers to pointers */
  q_start = (int *)malloc((*X).N*sizeof(int));
  cur_Q_lim = (int *)malloc((*X).N*sizeof(int));
  scale_times = (double **)malloc((*X).N*sizeof(double *));

  /* Next, unroll the categories */
  /* For this technique, we want to interleave the spike trains for each trial into a single train */
  p_total=0;
  
  /* For each category */
  for(m=0;m<(*X).M;m++)
    {
      /* For each trial */
      for(p=0;p<(*X).categories[m].P;p++)
	{
	  categories[p_total] = m;
	  counts[p_total] = 0;

	  /* First pass: How many spikes in each train */
	  for(n=0;n<(*X).N;n++)
	    {
	      cur_Q = (*X).categories[m].trials[p][n].Q;
	      scale_times[n] = (double *)malloc(cur_Q*sizeof(double));
	      for(q=0;q<cur_Q;q++)
		scale_times[n][q] = (*X).categories[m].trials[p][n].list[q]*((*X).sites[n].time_scale);
	      GetLims(scale_times[n],opts->t_start,opts->t_end,cur_Q,&q_start[n],&q_end);
	      cur_Q_lim[n] = q_end - q_start[n] + 1;
	      counts[p_total] += cur_Q_lim[n];
	    }

	  cur_times = (double *)malloc(counts[p_total]*sizeof(double));
	  cur_labels = (int *)malloc(counts[p_total]*sizeof(int));

	  /* Second pass: Actually copy the data */
	  q_total = 0;
	  for(n=0;n<(*X).N;n++)
	    {
	      memcpy(&cur_times[q_total],&scale_times[n][q_start[n]],cur_Q_lim[n]*sizeof(double));
	      for(q=0;q<cur_Q_lim[n];q++)
		cur_labels[q_total+q] = n;
	      q_total += cur_Q_lim[n];

	      free(scale_times[n]);
	    }

	  /* Now that I have the spike trains for each neuron in the trial, 
	     I sort them chronologically */

	  /* It might be best just to concatenate all the spikes for each trial
	     rather than storing it as a 2-D array */
	  /* This might require two passes through the data */

	  /* Can I be assured that the n cur_times vectors are contiguous? */
	  sort_idx = (int *)malloc(counts[p_total]*sizeof(int));
	  SortDouble(counts[p_total],cur_times,times[p_total],sort_idx);

	  /* I have to use the resulting index to sort the labels as well */
	  for(q=0;q<counts[p_total];q++)
	    labels[p_total][q] = cur_labels[sort_idx[q]];

#ifdef DEBUG
	  printf("counts[%d]=%d\n",p_total,counts[p_total]);

	  printf("times[%d]:\n",p_total);
	  for(q=0;q<counts[p_total];q++)
	    printf("%.3f ",times[p_total][q]);
	  printf("\n");

	  printf("labels[%d]:\n",p_total);
	  for(q=0;q<counts[p_total];q++)
	    printf("%d ",labels[p_total][q]);
	  printf("\n");
#endif

	  free(sort_idx);
	  free(cur_labels);
	  free(cur_times);
	  p_total++;
	}
    }
  free(q_start);
  free(scale_times);
  free(cur_Q_lim);

  return EXIT_SUCCESS;
}
