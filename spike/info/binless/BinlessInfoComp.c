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

int BinlessInfoComp(struct options_binless *opts,
		    struct options_entropy *opts_ent,
		     double **embedded,
		     int N, /* number of spike trains */
		     int S, /* number of stimulus classes */
		     int *n_vec, /* number of spikes in each train */
		     int *a_vec, /* class id for each train */
		     struct estimate *I_part,
		     double *I_cont,
		     struct estimate *I_count,
		     struct estimate *I_total)
{
  int U; /* number of unique spike counts */
  int *n_uni, *n_uni_i,*n_uni_j,*N_n;
  int n,u,idx,u1,u2,r,R;
  double **c_mat;
  int *n_list,*a_list;
  double **C;
  int **N_n_a,*N_C_a,*C_a,*N_Z,**N_Z_a,N_C,b,**N_G_a;
  struct estimate *cur_I_part;
  struct hist2d *count_hist, *part_hist;
  double cur_I_cont;
  int **N_part;
  double **N_n_a_double,**N_part_double;
  int N_Z_tot;
  int i,s,m,single_idx;
  int N_alt,N_cur;
  int num_dims;
  int C_flag;
  int dmin, dmax;

  n_uni = (int *)malloc(N*sizeof(int));
  n_uni_i = (int *)malloc(N*sizeof(int));
  n_uni_j = (int *)malloc(N*sizeof(int));
  N_n = (int *)calloc(N,sizeof(int));

  /* Do stratification */

  /* Strategy 0: No stratification. All spike trains are in a single stratum */
  /* Strategy 1: Each unique spike count gets its own stratum */
  /* Strategy 2: Same as 1, except all spike trains with at least
     D_max-D_min+1 spikes go into one stratum */

  if(opts->rec_tag_flag && (opts->rec_tag==1))
    {
      dmax = opts->D_max_cont;
      dmin = opts->D_min_cont;
    }
  else
    {
      dmax = opts->D_max;
      dmin = opts->D_min;
    }

  switch((*opts).strat_strat)
    {
    case 0:
      for(n=0;n<N;n++)
	n_vec[n]=1;
      break;
    case 1:
      break;
    case 2:
      num_dims = dmax - dmin + 1;
      for(n=0;n<N;n++)
	if(n_vec[n]>=num_dims)
	  n_vec[n]=num_dims;
      break;
    default:
      printf("Unrecognized stratification strategy\n");
    }
  
  /* Get the unique strata */
  U = UniqueInt(N,n_vec,n_uni,n_uni_i,n_uni_j,N_n);

  N_alt = 0;
  N_n_a = MatrixInt(U,S);
  *I_cont=0; /* Initialize I_cont */ 
  ZeroEst(I_part,opts_ent); /* Initialize I_part */ 

  /* For each stratum */
  for(idx=0;idx<U;idx++)
    {
#ifdef DEBUG
      printf("***********************\n");
      printf("n_uni[%d]=%d N_n[%d]=%d\n",idx,n_uni[idx],idx,N_n[idx]);
#endif	
      
      n_list = (int *)malloc(N_n[idx]*sizeof(int));
      a_list = (int *)malloc(N_n[idx]*sizeof(int));
      c_mat = (double **)malloc(N_n[idx]*sizeof(double *));
			       
      /* Get the indices of the trains in this stratum */
      u1 = FindX(n_vec,N,n_uni[idx],n_list);
      for(u2=0;u2<u1;u2++)
	{
	  a_list[u2] = a_vec[n_list[u2]];
	  c_mat[u2] = embedded[n_list[u2]]+dmin;
	}
      
      if((n_uni[idx]==0) & (((*opts).strat_strat==1) | ((*opts).strat_strat==2))) /* if the spike trains are empty */
	{
	  countfun(a_list,N_n[idx],N_n_a[idx]);
	  N_cur = N_n[idx];
	}
      else /* else the spike trains are nonempty or we are using strat_strat=0 */
	{
	  if((*opts).strat_strat == 0)
	    r = dmax;
	  else
	    r = MIN(n_uni[idx],dmax);
	  R = r-dmin+1; /* number of embedding dimensions */

	  N_C_a = (int *)calloc(S,sizeof(int));
	  N_Z = (int *)calloc(N_n[idx],sizeof(int));
	  C_a = (int *)calloc(N_n[idx],sizeof(int));
	  C = MatrixDouble(N_n[idx],R);
	  N_Z_a = MatrixInt(N_n[idx],S);
	  N_G_a = MatrixInt(N_n[idx],S);

	  /****************************************************/
	  /* Segregate the spike trains into their categories */
	  /****************************************************/

	  segfun(N_n[idx],R,n_list,a_list,S,c_mat, /* inputs */
		 N_Z,N_Z_a,&b, /* outputs */
		 &N_C,N_C_a,C_a,C, /* outputs */
		 N_G_a,&u,N_n_a[idx],opts);

	  /********************************************************/
	  /* Make a matrix that will hold N_Z_a, N_C_a, and N_G_a */
	  /* for the computation of I_partition                   */
	  /*******************************************************/

	  C_flag = 0;
	  N_part = (int **)malloc(N_n[idx]*sizeof(int *));
	  i=0;

	  /* First, the unique spike trains */
	  if(N_C>0)
	    {
	      N_part[i] = N_C_a;
	      i++;
	      C_flag = 1;
	    }

	  /* Second, the zero-distance subsets */
	  N_Z_tot = 0;
	  for(m=0;m<b;m++)
	    {
	      N_part[i] = N_Z_a[m];
	      N_Z_tot += N_Z[m];
	      i++;
	    }
	  free(N_Z);

	  /* Finally, the singletons */
	  /* If we are ignoring singletons, segfun sets u to 0 */
	  for(single_idx=0;single_idx<u;single_idx++)
	    {
	      N_part[i] = N_G_a[single_idx];
	      i++;
	    }

	  if(i>N_n[idx])
	    printf("Warning! Badness!\n");

	  /**********************************************************/
	  /* Now, calculate I_partition, I_continuous, and I_timing */
	  /**********************************************************/

	  /* N_cur is the number of spike trains under consideration */
	  /* Takes into account any reduction due to ignorance of singletons */
	  N_cur = N_C+N_Z_tot+u; 

	  /* First, compute I_part */
	  cur_I_part = CAllocEst(opts_ent);
	  
	  /* If there are not zero-distance subsets and there are no singletons, 
	     then cur_I_part = 0 */

	  if(b+u==0)
	    ZeroEst(cur_I_part,opts_ent);
	  else
	    {
	      /* Make part_hist */

	      /* Convert N_part to double */
	      N_part_double = MatrixDouble(C_flag+b+u,S);

	      for(i=0;i<C_flag+b+u;i++)
		for(s=0;s<S;s++)
		  N_part_double[i][s] = (double) N_part[i][s];

	      part_hist = CAllocHist2D((C_flag+b+u)*S,1,opts_ent);
	      MatrixToHist2DComp(N_part_double,C_flag+b+u,S,part_hist,opts_ent);
	      FreeMatrixDouble(N_part_double);

	      /* Compute the information */
	      Info2DComp(part_hist,opts_ent);
	      
	      /* Scale I_part */
	      ScaleEst((*part_hist).information,N_cur/(double)N,cur_I_part,opts_ent);
	      CFreeHist2D(part_hist,opts_ent);
	    }

	  IncEst(I_part,cur_I_part,opts_ent);

	  /* Compute I_continuous (Eq. 14) */
	  cur_I_cont = I_cont_calc(C,N_C,R,C_a,N_C_a,S);

	  /* Add I_cont into I_timing (with appropriate scaling) (Eq. 21) */
	  *I_cont += (N_C/(double)N)*cur_I_cont;

#ifdef DEBUG
	  printf("cur_I_part=%f cur_I_cont=%f\n",cur_I_part[0].value,cur_I_cont);
#endif
	  CFreeEst(cur_I_part,opts_ent);
	  free(N_C_a);
	  FreeMatrixInt(N_G_a);
	  FreeMatrixInt(N_Z_a);
	  free(N_part);
	  free(C_a);
	  FreeMatrixDouble(C);
	} /* End "else the spike trains are nonempty" */

      N_alt += N_cur;
      
      free(n_list);
      free(a_list);
      free(c_mat);
    } /* End "For each unique spike count" */
  free(N_n);
  free(n_uni);
  free(n_uni_i);
  free(n_uni_j);
  
#ifdef DEBUG
  printf("\nN_n_a total:\n");
  for(idx=0;idx<U;idx++)
    {
      for(s=0;s<S;s++)
	printf("%d ",N_n_a[idx][s]);
      printf("\n");
    }
#endif     

  /* Convert N_n_a to double */
  N_n_a_double = MatrixDouble(U,S);
  for(u=0;u<U;u++)
    for(s=0;s<S;s++)
      N_n_a_double[u][s] = (double) N_n_a[u][s];

  /* Compute I_count (Eq. 15) */
  count_hist = CAllocHist2D(U*S,1,opts_ent);
  MatrixToHist2DComp(N_n_a_double,U,S,count_hist,opts_ent);
  Info2DComp(count_hist,opts_ent);
  ScaleEst((*count_hist).information,N_alt/(double)N,I_count,opts_ent);
  FreeMatrixDouble(N_n_a_double);
  FreeMatrixInt(N_n_a);
  CFreeHist2D(count_hist,opts_ent);
 
  /* Compute I_total (Eq. 13) */
  AddEst(I_part,I_count,I_total,opts_ent);
  IncScalarEst(I_total,*I_cont,opts_ent);

#ifdef DEBUG
  printf("I_count = %f\n",(*I_count).value);
#endif     

  return EXIT_SUCCESS;
}


/********************************************************/
/* segfun:                                              */
/* For a given stratum, segregate the spike trains into */
/* zero-distance disjoint subsets (Z),                  */
/* singleton sets (G),                                  */
/* and everything else (C)                              */
/********************************************************/

void segfun(int N_n, /* number of spike trains in this strata */
            int R, /* number of embedding dimensions */
            int *n_list, /* indices of the spike trains in this strata */
            int *a_list, /* class id of the spike trains */
            int S, /* number of stimulus classes */
            double **c_mat, /* matrix of embedding values */
	    int *N_Z,int **N_Z_a,int *b, /* Z collection arrays */
	    int *N_C,int *N_C_a,int *C_a,double **C, /* C collection arrays */
	    int **N_G_a,int *u,int *N_n_a, /* G collection etc. */
            struct options_binless *opts)
{
  int U;
  int m,q,s,ii;
  double **c_uni;
  int *c_uni_i,*c_uni_j;
  int *cnt;
  int **Z_a;
  int *G_a;
  int *C_idx;
  int *match_idx;
  int *single_a_list;
  int single_idx;
  int a_idx,in_C_idx;

  /*****************************************************************/
  /* Step A: Segregate sets of identical spike trains (Z collection) */
  /* from the main collection (C collection) */
  /*****************************************************************/

  c_uni = MatrixDouble(N_n,R);
  c_uni_i = (int *)malloc(N_n*sizeof(int));
  c_uni_j = (int *)malloc(N_n*sizeof(int));
  cnt = (int *)calloc(N_n,sizeof(int));

  U = UniqueRowsDouble(N_n,R,c_mat,c_uni,c_uni_i,c_uni_j,cnt);

  /*  for(u1=0;u1<U;u1++) */
  /*     { */
  /*       for(r1=0;r1<r;r1++) */
  /* 	printf("%f ",c_uni[u1][r1]); */
  /*       printf("\n"); */
  /*     }  */
  
  match_idx = (int *)malloc(U*sizeof(int));
  Z_a = MatrixInt(U,U);
  G_a = (int *)malloc(U*sizeof(int));
  C_idx = (int *)malloc(U*sizeof(int));

  m=0; /* m counts the number of non-singular spike trains */
  q=0; /* q counts the number of singular spike trains */

  /* for each unique spike train */
  for(ii=0;ii<U;ii++)
    {
      /* Get a list of the indices that correspond to this row in c_uni */
      s = FindX(c_uni_j,N_n,ii,match_idx);
      /* s should match cnt[ii] */

      /* If there is more than one instance, */
      /* then we have a zero-distance subset */
      if(cnt[ii]>1)
	{
	  N_Z[m] = cnt[ii]; /* the number of resps in the subset */
	  for(s=0;s<cnt[ii];s++)
	    Z_a[m][s] = a_list[match_idx[s]];
	  m++;
	}
      else
	{
	  /* we want the position in c_uni that equals ii */
	  C_idx[q] = ii;
	  C_a[q] = a_list[match_idx[0]];
	  q++;
	}
    }
  *N_C = q;
  *b = m;

  /*****************************************************************/
  /* Step B: For the Z collection, count the responses in each stimulus class. */
  /*****************************************************************/

  for(m=0;m<*b;m++)
    countfun(Z_a[m],N_Z[m],N_Z_a[m]);

  /*****************************************************************/
  /* Step C: For the C collection, count the responses in each stimulus class. */
  /*****************************************************************/

  countfun(C_a,*N_C,N_C_a);

  /*****************************************************************/
  /* Step D: Deal with singletons */
  /*****************************************************************/

  /* Removing the zero-distance spike trains creates singletons. */
  /* That's why we have to segregate the zero-distance spike trains first, */
  /* and then handle the singletons. */
  
  /* Strategy 0: Remove it from C */
  /* Strategy 1: Remove it from C and add it to G */
  
  /* Find the categories that have only one element */
  single_a_list = (int *)malloc(S*sizeof(int));
  *u = FindX(N_C_a,S,1,single_a_list);
  
  /* For each singleton */
  for(single_idx=0;single_idx<*u;single_idx++)
    {
      /* Which class was it in? a_idx */
      a_idx = single_a_list[single_idx];

      /* Where in the C list was it? in_C_idx */
      for(ii=0;ii<*N_C;ii++)
	if(C_a[ii]==a_idx)
	  in_C_idx = ii;

      /* If we use strategy 1, add the singleton to the G collection */
      /* G is for sinGleton */
      if((*opts).single_strat==1)
	{
	  G_a[single_idx] = a_idx;
	  N_G_a[single_idx][a_idx] = 1;
	}
      
      /* Remove the singleton from the C collection */
      N_C_a[a_idx]=0;
      (*N_C)--;
      for(q=in_C_idx;q<*N_C;q++)
	{
	  C_idx[q] = C_idx[q+1];
	  C_a[q] = C_a[q+1];
	}
    }
  /* end for each singleton */
  if((*opts).single_strat==0)
    *u=0;
 
  /**********************************************************/
  /* Assemble total count N_n_a                             */
  /**********************************************************/

  for(s=0;s<S;s++)
    { 
      /* Add in the Zs */
      for(m=0;m<*b;m++)
	N_n_a[s] += N_Z_a[m][s];
      
      /* Add in the Cs */
      N_n_a[s]+=N_C_a[s];
      
      /* Add in the Gs */
      for(single_idx=0;single_idx<*u;single_idx++)
	N_n_a[s] += N_G_a[single_idx][s];
    }

  /**********************************************************/
  /* Part E: Assemble the C matrix                          */
  /**********************************************************/

  for(q=0;q<*N_C;q++)
    memcpy(C[q],c_uni[C_idx[q]],R*sizeof(double));
  
  /*****************************************************************/
  /* Epilogue: Display results for debugging                       */
  /*****************************************************************/

#ifdef DEBUG
  for(m=0;m<*b;m++)
    {
      printf("N_Z_a[%d]: ",m);
      for(s=0;s<S;s++)
	printf("%d ",N_Z_a[m][s]);
      printf("\n");
      
      /* for(s=0;s<N_Z[m];s++) */
/* 	printf("Z_a[%d][%d]=%d\n",m,s,Z_a[m][s]); */
    }
  printf("N_C_a: ");
  for(s=0;s<S;s++)
    printf("%d ",N_C_a[s]);
  printf("\n");

  /*   for(q=0;q<*N_C;q++) */
  /*     printf("C_idx[%d]=%d ",q,C_idx[q]); */
  /*   printf("\n"); */

  printf("C:\n");
  for(q=0;q<*N_C;q++)
    {
      for(s=0;s<R;s++)
  	printf("%f ",C[q][s]);
      printf("\n");
    }
  
  for(single_idx=0;single_idx<*u;single_idx++)
    {
      printf("N_G_a[%d]: ",single_idx);
      for(s=0;s<S;s++)
	printf("%d ",N_G_a[single_idx][s]);
      printf("\n");
    }  

  printf("N_n_a: ");
  for(s=0;s<S;s++)
    printf("%d ",N_n_a[s]);
  printf("\n");

#endif
  
  /* Free memory */
  FreeMatrixDouble(c_uni);
  free(c_uni_i);
  free(c_uni_j);
  free(cnt);
  free(match_idx);
  FreeMatrixInt(Z_a);
  free(C_idx);
  free(G_a);
  free(single_a_list);
}

double I_cont_calc(double **C,int N_C_int,int r,int *C_a,int *N_C_a,int S)
{
  double I_cont,lambda,lambda_star;
  int i,j,s;
  double **d,*d_row;
  double term1,term2;
  double N_C;

  if(N_C_int==0)
    I_cont=0;

  else
    {
      d = MatrixDouble(N_C_int,N_C_int);
      N_C = (double) N_C_int;

      /* Make the distance matrix over all spike trains */

      /* First, handle the on-diagonal values */
      /* (We want them to be infinitely large) */
      for(i=0;i<N_C;i++)
	d[i][i] = HUGE_VAL;

      /* Now the rest */
      for(i=0;i<N_C;i++)
	for(j=i+1;j<N_C;j++)
	  {
	    d[i][j] = dist(C[i],C[j],r);
	    d[j][i] = d[i][j]; /* Exploit symmetry */
	  }

      /* Now, let's find the closest overall, */
      /* and the closest in the group */
      term1 = 0;
      for(i=0;i<N_C;i++)
	{
	  d_row = d[i];

	  lambda = HUGE_VAL;
	  lambda_star = HUGE_VAL;
	  for(j=0;j<N_C;j++)
	    {
	      /* Find the closest overall */
	      if(d_row[j]<lambda)
		lambda = d_row[j];
	      
	      /* Find the closest in the group */
	      if((C_a[j]==C_a[i]) & (d_row[j]<lambda_star))
		lambda_star = d_row[j];
	    }
	  term1 += LOG2Z(lambda/lambda_star);
	}
    	
      term1 *= (r/N_C);

      term2 = 0;
      for(s=0;s<S;s++)
	term2 -= (N_C_a[s]/N_C)*LOG2Z((N_C_a[s]-1)/(N_C-1));

      I_cont = term1 + term2;

      FreeMatrixDouble(d);
    }

  return I_cont;
}
   
double dist(double *a,double *b,int N)
{
  double d;
  int n;
  double temp1,temp2;

  temp1 = 0;
  for(n=0;n<N;n++)
    {
      temp2 = a[n]-b[n];
      temp1 += temp2*temp2;
    }
  
  d = sqrt(temp1);
  
  return d;
}

void countfun(int *list,int N,int *cnt)
{
  int n;

  for(n=0;n<N;n++)
    cnt[list[n]]++;
}

/**
 * @brief Find the value X in the vector in.
 * Finds the indices of the value X in the M-element vector in, placing these
 * indices in idx, and returning the number of times X was found in in.
 * @param[in] in The vector to search.
 * @param[in] M The length of the vector in.
 * @param[in] X The value for which to search.
 * @param[in,out] idx The vector of indices where X is found in in.
 * @return The length of idx (i.e., the number of time X was found in in).
 */
int FindX(int *in,int M,int X,int *idx)
{
  int n,m;

  n=0;

  for(m=0;m<M;m++)
    if(in[m]==X)
      {
	idx[n]=m;
	n++;
      }

  return n;
}
