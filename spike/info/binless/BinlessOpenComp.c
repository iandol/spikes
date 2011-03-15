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
  double delta;

  /* Next, unroll the categories */
  /* Really, just get the addresses of all of the spike times */
  p_total=0;
  for(m=0;m<(*X).M;m++)
    {
      for(p=0;p<(*X).categories[m].P;p++)
	{
	  a[p_total] = m;
	  cur_Q = (*X).categories[m].trials[p][0].Q;
          if(opts->rec_tag==0) /* episodic data */
	    GetLims((*X).categories[m].trials[p][0].list,(*opts).t_start,(*opts).t_end,cur_Q,&q_start,&q_end);
          else if(opts->rec_tag==1) /* continuous data */
            {
              delta = ((*X).categories[m].trials[p][0].end_time-(*X).categories[m].trials[p][0].start_time)/(cur_Q-1);
              q_start = MAX(0,(opts->t_start-(*X).categories[m].trials[p][0].start_time)/delta);
              q_end = MIN(cur_Q-1,(opts->t_end-(*X).categories[m].trials[p][0].start_time)/delta);
            }
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
