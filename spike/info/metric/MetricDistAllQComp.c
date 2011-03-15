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

int MetricDistAllQComp(struct options_metric *opts,
			  int P_total,
			  int *counts,
			  double **times,
			  double ***d)
{
  int i,j;
  double *a,*b;
  int M,N,R;
  double *lcrits;
  int p,q,max_counts;
  double **intervals;
#ifdef DEBUG
  int k;
#endif

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

	R = MIN(M,N);

#ifdef DEBUG	
	printf("i=%d j=%d M=%d N=%d R=%d\n",i,j,M,N,R);
#endif

	lcrits = (double *)malloc((R+1)*sizeof(double));
	
	/*** Step 1a: Get the critical lengths and costs ***/
	DistAllQCritical(a,M,b,N,R,lcrits,(*opts).metric);

#ifdef DEBUG
	for(k=0;k<R+1;k++)
	  printf("%f ",lcrits[k]);
	printf("\n");
#endif

	/*** Step 1b: Find the distances for the user-specified q
	     values. ***/
	DistAllQFinal(M,N,R,lcrits,(*opts).q,(*opts).num_q,d[i][j]);

#ifdef DEBUG
	for(k=0;k<(*opts).num_q;k++)
	  printf("%f ",d[i][j][k]);
	printf("\n");
#endif

	/* Exploit symmetry of distance matrix */
	memcpy(d[j][i],d[i][j],((*opts).num_q)*sizeof(double));
      
	/* free up memory inside the loop */
	free(lcrits);
      }

  if((*opts).metric==1)
    FreeMatrixDouble(intervals);

  return EXIT_SUCCESS;
}

void DistAllQCritical(double *a,int M,
		      double *b,int N,
		      int R,
		      double *lcrits,
		      int metric_type)
{
  int i,j,k;
  int U,V;
  double temp;
  double *lprev,*lcur,*temp2;
  double *l,*li,*lj,*lij;
  double *A,*B,*C,*D;
  int iend,jend;

  lcrits[0] = 0;

  A = (double *)calloc((M+1)*(N+1),sizeof(double));
  B = (double *)calloc((M+1)*(N+1),sizeof(double));
  
  C = A; D = B;
  for(i=0;i<M+1;i++)
    { 
      *C = HUGE_VAL;
      *D = HUGE_VAL;
      C+=N+1; D+=N+1; 
    } 

  C = A; D = B;
  for(j=0;j<N+1;j++)
    {
      *C++ = HUGE_VAL;
      *D++ = HUGE_VAL;
    } 

  lprev = A; lcur = B;
  U=M+1; V=N+1;

  for(k=1;k<R+1;k++)
    {
      /* Swap the pointers */
      temp2 = lprev; lprev = lcur; lcur = temp2;

      /* Initialize the pointers */
      l = &lcur[N+2]; li = &lcur[1]; lj = &lcur[N+1]; lij = &lprev[N+2];

      for(i=1;i<U;i++)
	{
	  for(j=1;j<V;j++)
	    { 
	      if(metric_type==1)
		{
		  iend = 0;
		  if((i+k==2) | (i+k==M+1))
		    iend=1;
		  jend = 0;
		  if((j+k==2) | (j+k==N+1))
		    jend=1;
		
		  if(iend & jend)
		    temp=0;
		  else if(iend)
		    temp = MAX(0,a[i+k-2]-b[j+k-2]);
		  else if(jend)
		    temp = MAX(0,b[j+k-2]-a[i+k-2]);
		  else
		    temp = fabs(a[i+k-2]-b[j+k-2]);
		}
	      else
		temp = fabs(a[i+k-2]-b[j+k-2]);	 

	      if(k==1)
		*l = MIN3(*li,*lj,temp);
	      else
		{
		  *l = MIN3(*li,*lj,temp+(*lij));
		  *lij++;
		}
	      l++; li++; lj++;
	    }
	  l+=N-V+2; li+=N-V+2; lj+=N-V+2; lij+=N-V+2;
	}
      U--; V--;
      lcrits[k]=lcur[U*(N+1)+V];
    }
  free(A);
  free(B);
}
  
void DistAllQFinal(int M,
		  int N,
		  int R,
		  double *lcrits,
		  double *q, int num_q,
		  double *d)
{
  int r,q_idx;
  double cur_dist;

  for(q_idx=0;q_idx<num_q;q_idx++)
    {
      d[q_idx]=q[q_idx]*lcrits[0] + M + N;
      for(r=1;r<R+1;r++) 
	{
	  cur_dist = q[q_idx]*lcrits[r] + M + N - 2*r;
	  if (cur_dist<d[q_idx])
	    d[q_idx] = cur_dist;
	}
    }
}
