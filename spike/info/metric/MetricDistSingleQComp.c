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

int MetricDistSingleQComp(struct options_metric *opts,
			  int P_total,
			  int *counts,
			  double **times,
			  double ***d)
{
  int i,j,k;
  double *a,*b;
  int M,N;
  int p,q,max_counts;
  double **intervals;

  /* If we are doing D_interval, compute the ISIs */
  if((*opts).metric==1)
    {
      /* What is the max of counts? */
      max_counts=0;
      for(p=0;p<P_total;p++)
	if(counts[p]>max_counts)
	  max_counts = counts[p];
      
      intervals = MatrixDouble(P_total,max_counts+1);
      
      for(p=0;p<P_total;p++)
	{
	  intervals[p][0] = times[p][0] - (*opts).t_start;
	  for(q=1;q<counts[p];q++)
	    intervals[p][q] = times[p][q] - times[p][q-1];
	  intervals[p][counts[p]] = (*opts).t_end - times[p][counts[p]-1];
	}
    }

  /* for each pair of spike trains, compute the distance */
  /* These measures are symmetric, and also D(x,x)=0,
     so we need to do P_total*(P_total-1)/2 comparisons */
  
  for (i=0;i<P_total;i++)
    for (j=i+1;j<P_total;j++)
      for (k=0;k<(*opts).num_q;k++)
	{
	  if((*opts).metric==1)
	    {
	      a = intervals[i];
	      M = counts[i]+1;
	      b = intervals[j];
	      N = counts[j]+1;
	    }
	  else
	    {
	      a = times[i];
	      M = counts[i];
	      b = times[j];
	      N = counts[j];
	    }
	  
	  d[i][j][k]=DistSingleQ(a,b,M,N,(*opts).q[k],(*opts).metric);
#ifdef DEBUG
	  printf("i=%d j=%d k=%d d[%d][%d][%d]=%f\n",i,j,k,i,j,k,d[i][j][k]);
#endif
	  d[j][i][k]=d[i][j][k]; /* Exploit symmetry of distance matrix */
	}

  if((*opts).metric==1)
    FreeMatrixDouble(intervals);

  return EXIT_SUCCESS;
}

double DistSingleQ(double *a,double *b,int M,int N,double q,int metric_type)
{
  int i,j;
  double *li,*lj,*lij,*gcur;
  double **g;
  double temp;
  double d;
  int iend,jend;

  if(M==0)
    d=N;
  else if(N==0)
    d=M;
  else if(q==0)
    d=abs(M-N);
  else
    {
      /* allocate memory for g */
      g = MatrixDouble(M+1,N+1);

      /* initialize the borders */
      for(i=0;i<M+1;i++)
	g[i][0]=i;

      for(j=1;j<N+1;j++)
	g[0][j]=j;
      
      li=&g[0][1]; lj=&g[1][0]; lij=&g[0][0]; gcur=&g[1][1];

      for(i=1;i<M+1;i++)
	{
	  for(j=1;j<N+1;j++)
	    {
	      if(metric_type==1)
		{
		  iend = 0;
		  if((i==1) | (i==M))
		    iend=1;
		  jend = 0;
		  if((j==1) | (j==N))
		    jend=1;
		
		  if(iend & jend)
		    temp=0;
		  else if(iend)
		    temp = MAX(0,a[i-1]-b[j-1]);
		  else if(jend)
		    temp = MAX(0,b[j-1]-a[i-1]);
		  else
		    temp = fabs(a[i-1]-b[j-1]);
		}
	      else
		temp = fabs(a[i-1]-b[j-1]);	 

	      *gcur = MIN3((*li)+1,(*lj)+1,(*lij)+q*temp);
	      gcur++; li++; lj++; lij++;
	    }
	  gcur++; li++; lj++; lij++;
	}
      d = g[M][N];
      FreeMatrixDouble(g);
    }
  return d;
}
