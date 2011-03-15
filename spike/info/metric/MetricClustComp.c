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

int MetricClustComp(struct options_metric *opts,double **d,int *m_list,int M,int P,double **cm)
{
  int m,p1,p2;
  int k,K;
  int *r;
  double *zeros;
  double cur_d,*d_clus;
  double temp;
  int *temp_idx;
  int cur_m1,cur_m2;
  int zero_flag;

  /***********************/
  /*** Allocate memory ***/
  /***********************/
 
  r = (int *)calloc(M,sizeof(int));
  zeros = (double *)calloc(M,sizeof(double));
  d_clus = (double *)calloc(M,sizeof(double));
  temp_idx = (int *)malloc(M*sizeof(int));

  /* For each response (begin outer loop) */
  for(p1=0;p1<P;p1++)
    {
      /* Initialize the number of responses for each class to zero */
      zero_flag=0;
      cur_m1 = m_list[p1];

      for(m=0;m<M;m++)
	{
	  zeros[m]=0;
	  d_clus[m]=0;
	  r[m]=0;
	}
      
      for(p2=0;p2<P;p2++)
	{
	  /* Exclude the current response */
	  if(p1!=p2)
	    {
	      /* Get the class of the current response */
	      cur_m2 = m_list[p2];
	      cur_d = d[p1][p2];
	      r[cur_m2]++;
	      if(cur_d==0)
		{
		  zeros[cur_m2]++;
		  zero_flag=1;
		}
	      d_clus[cur_m2]+=pow(cur_d,opts->z);
	    }
	}

      /* Now that we've finished the inner loop */
      for(m=0;m<M;m++)
	{
	  zeros[m]/=((double) r[m]);
	  d_clus[m]/=((double) r[m]);
	  d_clus[m] = pow(d_clus[m],1/(opts->z));
	}

      /****************************************************************/
      /* if a response-to-be-classified is at a distance of 0 from only
	 one class, then it gets classified into that class. */
      
      /* if a response-to-be-classified is at a distance of 0 from
	 several classes, then it gets classified into the class with
	 which it has the greatest proportion of 0-distances */

      /* if there is an n-way tie in the above, then 1/n of it gets
	 classifed into each class (i.e., the confusion matrix has
	 non-integer entries) */
      /****************************************************************/
 
      /* Are there any zeros at all? */
      if(zero_flag)
	{
	  /* find the maximal zero rate */
	  temp = zeros[0];
	  for(m=1;m<M;m++)
	    if(zeros[m]>temp)
	      temp = zeros[m];
	  
	  /* find which classes have the maximal zero rate */
	  K=0;
	  for(m=0;m<M;m++)
	    if(zeros[m]==temp)
	      {
		temp_idx[K]=m;
		K++;
	      }

	  /* increment the confusion matrix */
	  for(k=0;k<K;k++)
	    /* cm[temp_idx[k]][cur_m1]+= 1/((double) K); */
	    cm[cur_m1][temp_idx[k]]+= 1/((double) K);
	}
      else
	{
	  /* Find the minimum distance */
	  temp = d_clus[0];
	  for(m=1;m<M;m++)
	    if(d_clus[m]<temp)
	      temp = d_clus[m];

	  /* Find the classes that have minimum distance */
	  K=0;
	  for(m=0;m<M;m++)
	    if(d_clus[m]==temp)
	      {
		temp_idx[K]=m;
		K++;
	      }

	  /* increment the confusion matrix */
	  for(k=0;k<K;k++)
	    /* cm[temp_idx[k]][cur_m1]+= 1/((double) K); */
	    cm[cur_m1][temp_idx[k]]+= 1/((double) K);
	}
    } /* end outer loop */

  free(r);
  free(zeros);
  free(d_clus);
  free(temp_idx);

  return EXIT_SUCCESS;
}
