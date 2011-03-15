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

int MetricDistAllQKComp(struct options_metric *opts,
			int L,
			int P_total,
			int *counts,
			double **times,
			int **labels,
			double ***d)
{
  int i,j,k;
  double *a,*b;
  int *r,*s;
  int M,N;

  /* for each pair of spike trains, compute the distance */
  /* These measures are symmetric, and also D(x,x)=0,
     so we need to do P_total*(P_total-1)/2 comparisons */

  k=0;
  for (i=0;i<P_total;i++)
    for (j=i+1;j<P_total;j++)
      {
	a = times[i];
	r = labels[i];
	M = counts[i];
	b = times[j];
	s = labels[j];
	N = counts[j];

#ifdef DEBUG
	if(k%1000==0)
	  printf("i=%d j=%d M=%d N=%d %d/%d=%3.1f %%\n",i,j,M,N,k,P_total*(P_total-1)/2,((double)k)/((double)(P_total*(P_total-1)/2))*100);
#endif

	/* d[i][j] is num_q long! */

	DistAllQK(a,b,r,s,M,N,L,(*opts).q,(*opts).k,(*opts).num_q,d[i][j]);

	/* Exploit symmetry of distance matrix */
	memcpy(d[j][i],d[i][j],((*opts).num_q)*sizeof(double));
	k++;
      }

  return EXIT_SUCCESS;
}

void DistAllQK(
	       double *a,  /* a: vector of spike times in S_a */
	       double *b,  /* b: vector of spike times in S_b */
	       int *r,     /* r: vector of labels in S_a */
	       int *s,     /* s: vector of labels in S_b */
	       int M,      /* M: number of spikes in S_a */
	       int N,      /* N: number of spikes in S_b */
	       int L,     /* Number of labels */
	       double *q,
	       double *k,
	       int num_qk,
	       double *d
	       )
{
  int *m, *n;
  int prod_n,prod_m;
  int m1,n1,w;
  double **b_sub;
  int **j_mat, **j_mat_sorted, *j_sum_sorted;
  int **j_prev_mat_sorted;
  double *temp_double_ptr;
  int temp_int;
  int *temp_int_ptr;
  int R,S,S1,S2;
  double **clast;
  int r1,s1;

  if(MIN(M,N)==0)
    {
      R = 0;
      S = 0;
      clast = MatrixDouble(1,1);
      clast[0][0] = 0;
    }
  else
    {
      /* m: number of spikes in a with label w (indexed by w) */
      /* n: number of spikes in b with label w (indexed by w) */
      m = (int *)calloc(L,sizeof(int));
      n = (int *)calloc(L,sizeof(int));
      
      /********************************************************************/
      /*** Step 1: Assign labels in the form 1,2,...,L and
	   count spikes of each label */
      /********************************************************************/

      for (m1=0;m1<M;m1++)
	m[r[m1]]++;
      for (n1=0;n1<N;n1++)
	n[s[n1]]++;
  
#ifdef DEBUG
      for(w=0;w<L;w++)
	printf("m[%d]=%d n[%d]=%d\n",w,m[w],w,n[w]);
#endif
  
      /**********************************************************************/
      /*** Step 2: Choose the spike train to separate to subtrains.
	   If prod(n+1) < prod(m+1) then swap: a<->b, r<->s, m<->n. */
      /*********************************************************************/
  
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
  
      if(prod_n <= prod_m)
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
  
      /* Calculate the max number of matched links and unmatched links */
      R = 0; S1 = 0; S2 = 0;
      for(w=0;w<L;w++)
	{
	  R += MIN(m[w],n[w]);
	  S1 += MIN(m[w],N-n[w]);
	  S2 += MIN(M-m[w],n[w]);
	}
      S = MIN(S1,S2);

      clast = MatrixDouble(R+1,S+1);
      for(r1=0;r1<R+1;r1++)
	for(s1=0;s1<S+1;s1++)
	  clast[r1][s1]=HUGE_VAL;
      clast[0][0]=0;

      /*** Find the critical lengths ***/
      DistAllQKCritical(a,r,M,b_sub,prod_n,L,R,S,j_sum_sorted,j_mat_sorted,j_prev_mat_sorted,clast);

      FreeMatrixDouble(b_sub);
      FreeMatrixInt(j_mat);
      free(j_mat_sorted);
      FreeMatrixInt(j_prev_mat_sorted);
      free(j_sum_sorted);
      free(m);
      free(n);
    }

  /*** Find the distances for the user-specified q values. ***/
  DistAllQKFinal(M,N,R,S,clast,q,k,num_qk,d);

  FreeMatrixDouble(clast);
}

void DistAllQKCritical(
		       double *sa,  /* times for each spike in a */
		       int *la, /* labels for each spike in a */
		       int na,      /* Number of spikes in a */
		       double **sub, /* times for each spike b, arranged by subtrains */
		       int bsize, /* Number of subtrain combos */ 
		       int L,      /* Number of labels */
		       int R,     /* Maximum number of matched links */
		       int S,     /* Maximum number of unmatched links */
		       int *sum_bv_mat,
		       int **bv_mat,
		       int **jbrec_mat,
		       double **clast
		       )
{
  int ia,jb,r,s,u,k;
  int *bv,*jbrec;
  int sum_bv,*av;
  int **maxij,**rmaxij,**smaxij,smaxij1,smaxij2;
  double ***cwn;
  double **cwii,**cwin,**cwnn;
  int min_cnt;
  double *cwvec;

  /* Initialize cw matrix */
  cwvec = (double *)malloc((3*L+1)*sizeof(double));

  /* For each spike in a */
  av = (int *)calloc(L,sizeof(int));
  maxij = MatrixInt(na+1,bsize);
  rmaxij = MatrixInt(na+1,bsize);
  smaxij = MatrixInt(na+1,bsize);

  /* Some preliminaries */
  /* Find bv_pos, maxij, smaxij, rmaxij */
  for (ia=1;ia<na+1;ia++)
    {
      /* How many spikes of each label are in the first i spikes of a? */
      u = la[ia-1]; /* u is the label of the ith spike in a */
      av[u]++;

      for(jb=0;jb<bsize;jb++)
	{
	  bv = bv_mat[jb]; /* lengths of current subtrains for b */
	  jbrec = jbrec_mat[jb];  /* indices needed for the recursion */
	  sum_bv = sum_bv_mat[jb];
	  
	  /* maxij: total number of links */
	  maxij[ia][jb] = MIN(ia,sum_bv);
	  
	  /* rmaxij: maximum number of matched links */
	  /* smaxij: maximum number of unmatched links */
	  rmaxij[ia][jb] = 0;
	  smaxij1 = 0;
	  smaxij2 = 0;
	  for(k=0;k<L;k++)
	    {
	      rmaxij[ia][jb] += MIN(av[k],bv[k]);
	      smaxij1 += MIN(av[k],sum_bv-bv[k]);
	      smaxij2 += MIN(ia-av[k],bv[k]);
	    }
	  smaxij[ia][jb] = MIN(smaxij1,smaxij2);
	}
    }
  free(av);

  /* Now compute critical lengths */

  cwn = Matrix3Double(R+1,S+1,bsize);
  cwii = MatrixDouble(S+1,bsize);
  cwin = MatrixDouble(S+1,bsize);

  for(r=0;r<R+1;r++)
    for (s=0;s<S+1;s++)
      for(jb=0;jb<bsize;jb++)
	cwn[r][s][jb] = HUGE_VAL;

  for(jb=0;jb<bsize;jb++)
    cwn[0][0][jb] = 0;
  
  for (ia=1;ia<na+1;ia++)
    {
      /* cwin = temp[0]; */
      memcpy(cwin[0],cwn[0][0],(S+1)*bsize*sizeof(double));

      u = la[ia-1]; /* u is the label of the ith spike in a */
	  
      /* For all r */
      for(r=0;r<R+1;r++)
	{
	  cwnn = cwn[r];

	  /* cwii = cwin; */
	  memcpy(cwii[0],cwin[0],(S+1)*bsize*sizeof(double));

	  /* cwin = cwnn; */
	  memcpy(cwin[0],cwnn[0],(S+1)*bsize*sizeof(double));

	  /* For all s */
	  for(s=0;s<S+1;s++)
	    {
	      /* loop over the subdivided train (b) */
	      for (jb=0;jb<bsize;jb++)
		{
		  if(r+s>maxij[ia][jb])
		    cwnn[s][jb] = HUGE_VAL;
		  else if(r>rmaxij[ia][jb])
		    cwnn[s][jb] = HUGE_VAL;
		  else if(s>smaxij[ia][jb])
		    cwnn[s][jb] = HUGE_VAL;
		  else
		    {
		      bv = bv_mat[jb]; /* lengths of current subtrains for b */
		      jbrec = jbrec_mat[jb];  /* indices needed for the recursion */
	      
		      min_cnt = 0;
		      
#ifdef DEBUG1
		      printf("ia=%d r=%d s=%d jb=%d\n",ia,r,s,jb);
#endif

		      /* OPTION 1: Unlinked */
		      cwvec[min_cnt++] = cwin[s][jb];
#ifdef DEBUG1
		      printf("opt1: cwin: cw[%d][%d][%d][%d]=%f\n",ia-1,r,s,jb,cwin[s][jb]);
#endif

		      /* Look at the subtrain with the same label */
		      if(bv[u]>0)
			{
			  if(r>0) /* Do I still need this? r>0 */
			    {
			      /* OPTION 2: Link to the last spike in B_u */
			      cwvec[min_cnt++] = cwii[s][jbrec[u]] + fabs(sa[ia-1] - sub[u][bv[u]-1]);
#ifdef DEBUG1
			      printf("opt2: cwii: cw[%d][%d][%d][%d]=%f\n",ia-1,r-1,s,jbrec[u],cwii[s][jbrec[u]]);
#endif
			    }
			  /* OPTION 4: Last spike in B_k not linked to any spike in A */
			  cwvec[min_cnt++] = cwnn[s][jbrec[u]];
#ifdef DEBUG1
			  printf("opt4: cwnn: cw[%d][%d][%d][%d]=%f\n",ia,r,s,jbrec[u],cwnn[s][jbrec[u]]);
#endif
			}

		      /* Look at the subtrains with different labels */
		      for(k=0;k<u;k++)
			if(bv[k]>0)
			  {
			    if(s>0) /* Do I still need this? s>0 */
			      {
				/* OPTION 3: Link to the last spike in B_k, where k ~= u */ 
				cwvec[min_cnt++] = cwin[s-1][jbrec[k]] + fabs(sa[ia-1] - sub[k][bv[k]-1]);
#ifdef DEBUG1
				printf("opt3: cwin: cw[%d][%d][%d][%d]=%f\n",ia-1,r,s-1,jbrec[k],cwin[s-1][jbrec[k]]);
#endif
			      }
			    /* OPTION 4: Last spike in B_k not linked to any spike in A */
			    cwvec[min_cnt++] = cwnn[s][jbrec[k]];
#ifdef DEBUG1
			    printf("opt4: cwnn: cw[%d][%d][%d][%d]=%f\n",ia,r,s,jbrec[k],cwnn[s][jbrec[k]]);
#endif
			  }
		      
		      for(k=u+1;k<L;k++)
			if(bv[k]>0)
			  {
			    if(s>0) /* Do I still need this? s>0 */
			      {
				/* OPTION 3: Link to the last spike in B_k, where k ~= u */ 
				cwvec[min_cnt++] = cwin[s-1][jbrec[k]] + fabs(sa[ia-1] - sub[k][bv[k]-1]);
#ifdef DEBUG1
				printf("opt3: cwin: cw[%d][%d][%d][%d]=%f\n",ia-1,r,s-1,jbrec[k],cwin[s-1][jbrec[k]]);
#endif
			      }
			    /* OPTION 4: Last spike in B_k not linked to any spike in A */
			    cwvec[min_cnt++] = cwnn[s][jbrec[k]];
#ifdef DEBUG1
			    printf("opt4: cwnn: cw[%d][%d][%d][%d]=%f\n",ia,r,s,jbrec[k],cwnn[s][jbrec[k]]);
#endif
			  }

		      /* Compute minimum */
		      cwnn[s][jb] = MinVectorDouble(cwvec,min_cnt);
#ifdef DEBUG1
		      printf("final: cwnn: cw[%d][%d][%d][%d]=%f\n",ia,r,s,jb,cwnn[s][jb]);
#endif
		      
		      /* Copy out the results I want */
		      /* clast is a R+1xS+1 matrix */
		      if(jb==bsize-1)
			clast[r][s] = cwnn[s][jb];
		    }
		}
	    }
	} 
    }

  free(cwvec);

  FreeMatrixInt(maxij);
  FreeMatrixInt(rmaxij);
  FreeMatrixInt(smaxij);

  FreeMatrix3Double(cwn);
  FreeMatrixDouble(cwin);
  FreeMatrixDouble(cwii);
}

void DistAllQKFinal(
		    int M,
		    int N,
		    int R,
		    int S,
		    double **clast,
		    double *q,
		    double *k,
		    int num_qk,
		    double *d)
{
  int r,s,qk_idx;
  double temp;
  double ***posscosts;

#ifdef DEBUG
  for(r=0;r<R+1;r++)
    {
      for(s=0;s<S+1;s++)
	printf("%f ",clast[r][s]);
      printf("\n");
    }
  printf("\n");
#endif  

  posscosts = Matrix3Double(num_qk,R+1,S+1);

  /* The goal is to implement this equation:
     min_r,s q*C(M,N,r,s) + ks + (M+N-2r-2s) */
  for(r=0;r<R+1;r++)
    {
      for(s=0;s<S+1;s++)
	{
	  temp = M + N - 2*r - 2*s;
	  for(qk_idx=0;qk_idx<num_qk;qk_idx++)
	    posscosts[qk_idx][r][s] = q[qk_idx]*clast[r][s] + k[qk_idx]*s + temp;
	}
    }
  
#ifdef DEBUG
  for(qk_idx=0;qk_idx<num_qk;qk_idx++)
    {
      for(r=0;r<R+1;r++)
	{
	  for(s=0;s<S+1;s++)
	    printf("%f ",posscosts[qk_idx][r][s]);
	  printf("\n");
	}
      printf("\n\n");
    }
#endif  
  
  for(qk_idx=0;qk_idx<num_qk;qk_idx++)
    d[qk_idx] = MinVectorDouble(&posscosts[qk_idx][0][0],(R+1)*(S+1));

  FreeMatrix3Double(posscosts);
}
