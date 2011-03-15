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

int MetricDistSingleQKComp(struct options_metric *opts,
				 int L,
				 int P_total,
				 int *counts,
				 double **times,
				 int **labels,
				 double ***d)
{
  int i,j,k,l;
  double *a,*b;
  int *r,*s;
  int M,N;

  /* for each pair of spike trains, compute the distance */
  /* These measures are symmetric, and also D(x,x)=0,
     so we need to do P_total*(P_total-1)/2 comparisons */

  l=0;
  for (i=0;i<P_total;i++)
    for (j=i+1;j<P_total;j++)
      for (k=0;k<(*opts).num_q;k++)
      {
	a = times[i];
	r = labels[i];
	M = counts[i];
	b = times[j];
	s = labels[j];
	N = counts[j];

#ifdef DEBUG
	if(l%10000==0)
	  printf("i=%d j=%d M=%d N=%d %d/%d=%3.1f %%\n",i,j,M,N,l,P_total*(P_total-1)/2,((double)k)/((double)(P_total*(P_total-1)/2))*100);
#endif

	d[i][j][k]=DistSingleQK(a,b,r,s,M,N,L,(*opts).q[k],(*opts).k[k]);
#ifdef DEBUG
	printf("i=%d j=%d k=%d d[%d][%d][%d]=%f\n",i,j,k,i,j,k,d[i][j][k]);
#endif
	d[j][i][k]=d[i][j][k]; /* Exploit symmetry of distance matrix */
	l++;
      }

  return EXIT_SUCCESS;
}

double DistSingleQK(
			  double *a,  /* a: vector of spike times in S_a */
			  double *b,  /* b: vector of spike times in S_b */
			  int *r,     /* r: vector of labels in S_a */
			  int *s,     /* s: vector of labels in S_b */
			  int M,      /* M: number of spikes in S_a */
			  int N,      /* N: number of spikes in S_b */
			  int L,      /* Number of labels */
			  double q,
			  double k)
{
  /* Would it be better to just use the number of neurons in the
     experiment, or is there a gain from limiting the procedure to
     those neurons that contributed to spike trains a and b. Is it
     reasonable to assume that every neuron fires at least once on
     every trial? */
  
  int *m, *n;
  int prod_n,prod_m;
  int m1,n1,w;
  double **b_sub;
  int **j_mat, **j_mat_sorted, *j_sum_sorted;
  int **j_prev_mat_sorted;
  double d;
  double *temp_double_ptr;
  int temp_int;
  int *temp_int_ptr;

  /* m: number of spikes in a with label w (indexed by w) */
  /* n: number of spikes in b with label w (indexed by w) */
  m = (int *)calloc(L,sizeof(int));
  n = (int *)calloc(L,sizeof(int));
      
  /********************************************************************************/
  /*** Step 1: Assign labels in the form 1,2,...,L and count spikes of each label */
  /********************************************************************************/

  for (m1=0;m1<M;m1++)
    m[r[m1]]++;
  for (n1=0;n1<N;n1++)
    n[s[n1]]++;
  
#ifdef DEBUG
  for(w=0;w<L;w++)
    printf("m[%d]=%d n[%d]=%d\n",w,m[w],w,n[w]);
#endif
  
  /********************************************************************************/
  /*** Step 2: Choose the spike train to separate to subtrains.
       If prod(n+1) < prod(m+1) then swap: a<->b, r<->s, m<->n. */
  /********************************************************************************/
  
  /* Compute prod_m and prod_n */
  prod_m = m[0]+1;
  prod_n = n[0]+1;
  for(w=1;w<L;w++)
    {
      prod_m *= m[w]+1;
      prod_n *= n[w]+1;
    }
  
#ifdef DEBUG
  printf("prod_m=%d prod_n=%d\n",prod_m,prod_n);
#endif
  
  if(prod_n < prod_m)
    {
      temp_double_ptr = a; a = b;           b = temp_double_ptr;
      temp_int = M;        M = N;           N = temp_int;
      temp_int_ptr = r;    r = s;           s = temp_int_ptr;
      temp_int_ptr = m;    m = n;           n = temp_int_ptr;
      temp_int = prod_m;   prod_m = prod_n; prod_n = temp_int;
    }

  b_sub = MatrixDouble(L,N);
  MakeSubtrains(b,s,N,L,b_sub);
  
  j_mat = MatrixInt(prod_n,L);
  j_mat_sorted = (int **)calloc(prod_n,sizeof(int *));
  j_sum_sorted = (int *)calloc(prod_n,sizeof(int));
  j_prev_mat_sorted = MatrixInt(prod_n,L);
  
  MakeIndex(prod_n,L,n,j_mat,j_mat_sorted,j_prev_mat_sorted,j_sum_sorted);
  
  d=ComputeDist(prod_n,M,L,j_sum_sorted,j_mat_sorted,j_prev_mat_sorted,r,a,b_sub,k,q);
  
  FreeMatrixDouble(b_sub);
  FreeMatrixInt(j_mat);
  free(j_mat_sorted);
  FreeMatrixInt(j_prev_mat_sorted);
  free(j_sum_sorted);
  free(m);
  free(n);
  
  return d;
}

double ComputeDist(int prod_n,int M,int L,int *j_sum_sorted,int **j_mat_sorted,int **j_prev_mat_sorted,int *r,double *a,double **b_sub,double k,double q)
{
  /********************************************************************************/
  /*** Step 5: Compute G matrix */
  /********************************************************************************/

  double **g;
  double d;
  int i,j,w,min_cnt;
  int *j_vec,*prev_j_idx;
  double *min_vec;
  double qcost,kcost;

  /* Initialize G matrix */
  g = MatrixDouble(prod_n,M+1);
  
  for (i=0;i<M+1;i++)
    g[0][i] = (double)i;

  for(j=0;j<prod_n;j++)
    g[j][0] = (double)j_sum_sorted[j];

  min_vec = (double *)malloc((2*L+1)*sizeof(double));

  /* For each possible combination of contributions from the subtrains */
  for (j=1;j<prod_n;j++)
    {
      j_vec = j_mat_sorted[j];
      prev_j_idx = j_prev_mat_sorted[j];

#ifdef DEBUG
      for(w=0;w<L;w++)
	printf("%d ",j_vec[w]);
      printf("\n");
#endif
      
      /* For each spike in a */
      for (i=1;i<M+1;i++)
	{
	  /* OPTION 1: Delete the spike in a */
	  min_cnt=0;
	  min_vec[min_cnt] = g[j][i-1] + 1;
	  min_cnt++;
  
	  /* Which of the L subtrains did we arrive here from?
	     For each subtrain */
	  for(w=0;w<L;w++)
	    {
	      /* Include only subtrains with a non-zero count */
	      if(j_vec[w]>0)
		{
		  /* OPTION 2: Delete the last spike one of L subtrains because the
		     last spike in a is linked to a non-last spike in one of the
		     subtrains and we must prevent crossing of trajectories */
		  min_vec[min_cnt] = g[prev_j_idx[w]][i] + 1;
		  min_cnt++;

		  /* OPTION 3: Link the spike in a to the last spike in one of L subtrains */
		  qcost = q*fabs(a[i-1] - b_sub[w][j_vec[w]-1]); /* account for time shifting */
		  kcost = k*((double)(1-(r[i-1]==w))); /* account for label-swapping */
		  min_vec[min_cnt] = g[prev_j_idx[w]][i-1] + qcost + kcost;
		  min_cnt++;
		} /*end if(j_vec[w]>0) */
	    } /* end for(w=0;w<L;w++) */
	  g[j][i] = MinVectorDouble(min_vec,min_cnt);
	}		 
    }
  
#ifdef DEBUG
  for (j=0;j<prod_n;j++)
    {
      for (i=0;i<M+1;i++)
	printf("%2.4f ",g[j][i]);
      printf("\n");
    }
#endif  

  d = g[prod_n-1][M];

  free(min_vec);
  FreeMatrixDouble(g);

  return d;
}
