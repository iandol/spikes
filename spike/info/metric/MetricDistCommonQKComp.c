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

void MakeSubtrains(double *b,int *s,int N,int L,double **b_sub)
{
  int n1,w;
  int *n_cnt;

  /********************************************************************************/
  /*** Step 3: Make subtrains */
  /********************************************************************************/
      
  /* n_cnt is a running count of the spikes in each subtrain,
     initialized to zeros */
  n_cnt = (int *)calloc(L,sizeof(int));
  for (n1=0;n1<N;n1++)
    {
      w = s[n1];
      b_sub[w][n_cnt[w]] = b[n1];
      n_cnt[w]++;
    }
      
  free(n_cnt);
}

void MakeIndex(int prod_n,int L,int *n,int **j_mat,int **j_mat_sorted,int **j_prev_mat_sorted,int *j_sum_sorted)
{
  int *j_sum,*j_sum_sorted_idx,*lookup;
  int **j_prev_mat,**j_prev_mat_temp;
  int j,w,w1;
  int temp;

  /********************************************************************************/
  /*** Step 4: Set up an indexing system. */
  /********************************************************************************/

  /* j_mat is a matrix with prod_n rows and L columns */
  /* Each row corresponds to a unique mix of spikes from each subtrain */
  /* The entries in each row give the number of spikes from each subtrain. */

  /* Make sure j_mat is calloced to zero */
  j_sum = (int *)calloc(prod_n,sizeof(int));
  j_prev_mat = MatrixInt(prod_n,L);
  
  for(j=1;j<prod_n;j++)
    {
      memcpy(j_mat[j],j_mat[j-1],L*sizeof(int));

      w = L-1; /* Start with the first column. */
  
      /* If the current column has reached its max, 
	 reset it and advance to the next column. */
      while(j_mat[j][w] == n[w])
	{
	  j_mat[j][w] = 0;
	  w--;
	}

      /* Once you reach a column that not maxed, increment it. */
      j_mat[j][w]++;

      /* Compute j_sum */
      for(w=0;w<L;w++)
	j_sum[j] += j_mat[j][w];

      /* Find the indices for the previous subtrain combo */
      temp = 1;
      for(w1=L-1;w1>=0;w1--)
	{
	  j_prev_mat[j][w1] = j - temp;
	  temp *= n[w1]+1;
	}
    }  

#ifdef DEBUG
  for(j=0;j<prod_n;j++)
    { 
      printf("%d | ",j);
      for(w=0;w<L;w++)
	printf("%d ",j_mat[j][w]);
      printf("| ");
      for(w=0;w<L;w++)
	printf("%d ",j_prev_mat[j][w]);
      printf("\n");
    }
#endif

  /* Sort these indices by the sum  */
  j_sum_sorted_idx = (int *)calloc(prod_n,sizeof(int));
  lookup = (int *)calloc(prod_n,sizeof(int));
  j_prev_mat_temp = (int **)malloc(prod_n*sizeof(int *));

  SortInt(prod_n,j_sum,j_sum_sorted,j_sum_sorted_idx);
  for(j=0;j<prod_n;j++)
    {
      j_mat_sorted[j] = j_mat[j_sum_sorted_idx[j]];
      j_prev_mat_temp[j] = j_prev_mat[j_sum_sorted_idx[j]];
      lookup[j_sum_sorted_idx[j]]=j; /* Make a reverse LUT for the prev indices */
    }

  /* Do the reverse lookup */
  for(j=0;j<prod_n;j++)
    for(w=0;w<L;w++)
      if(j_prev_mat_temp[j][w]>=0)
	j_prev_mat_sorted[j][w] = lookup[j_prev_mat_temp[j][w]];

#ifdef DEBUG
  for(j=0;j<prod_n;j++)
    printf("j_sum[%d]=%d j_sum_sorted[%d]=%d j_sum_sorted_idx[%d]=%d\n",j,j_sum[j],j,j_sum_sorted[j],j,j_sum_sorted_idx[j]);
#endif

  FreeMatrixInt(j_prev_mat);
  free(j_prev_mat_temp);
  free(lookup);
  free(j_sum);
  free(j_sum_sorted_idx);
}

