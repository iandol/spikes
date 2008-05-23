/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../../shared/toolkit_c.h"
#include "binless.h"
/* #define DEBUG */

int BinlessOpenComp(struct input *X,
		       struct options_binless *opts,
		       int N,
		       int *n_vec,
		       int *a,
		       double **times)
{
  int m,p_total,p;
  int cur_Q;
  int q_start,q_end;

  /* Next, unroll the categories */
  /* Really, just get the addresses of all of the spike times */
  p_total=0;
  for(m=0;m<(*X).M;m++)
    {
      for(p=0;p<(*X).categories[m].P;p++)
	{
	  a[p_total] = m;
	  cur_Q = (*X).categories[m].trials[p][0].Q;
	  GetLims((*X).categories[m].trials[p][0].list,(*opts).t_start,(*opts).t_end,cur_Q,&q_start,&q_end);
#ifdef DEBUG
	  printf("p=%d q_start=%d q_end=%d\n",p_total,q_start,q_end);
#endif
	  n_vec[p_total] = q_end - q_start + 1;
	  memcpy(times[p_total],
		 &((*X).categories[m].trials[p][0].list[q_start]),
		 n_vec[p_total]*sizeof(double));
	  p_total++;
	}
    }
  return EXIT_SUCCESS;
}
