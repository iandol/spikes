/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Count spike train words disregarding class.
 * This file contains the computational routines required by the
 * MEX-file directcounttotal.c. 
 * @see directcounttotal.c.
 */

#include "../../shared/toolkit_c.h"
#include "direct_c.h"

int DirectCountCondComp(int **binned,int P_total,int N,
		     int *P_vec,int M,
		     struct histcond *cond_hist)
{
  int **sorted1;
  int *sort_idx1;
  int status;
  int B,S,L;
  int **hashed;

  GetBSL(binned,P_total,N,&B,&S,&L);
  hashed = MatrixInt(P_total,S);
  HashWords(binned,P_total,N,B,S,L,hashed);

  sorted1 = MatrixInt(P_total,S);
  sort_idx1 = (int *)malloc(P_total*sizeof(int));
 
  status = DirectCountClassComp(binned,hashed,P_total,N,S,P_vec,M,(*cond_hist).classcond,sorted1,sort_idx1);
  status = DirectCountTotal2Comp(binned,P_total,N,S,P_vec,M,(*cond_hist).total,sorted1,sort_idx1);

  FreeMatrixInt(sorted1);
  free(sort_idx1);
  FreeMatrixInt(hashed);

  return EXIT_SUCCESS;
}

int DirectCountClassComp(int **binned,int **hashed,int P_total,int N,int S,
		     int *P_vec,int M,
		     struct hist1dvec *class_hist,
		     int **sorted1,int *sort_idx1)
{
  int **uni_list1,*uni_i1,*uni_j1;
  int *cnt1;
  int U;
  int u,m,p_total;

  /*******************************************/
  /*** Step 3: Do the in-class counts ********/
  /*******************************************/

  (*class_hist).P=P_total;
  (*class_hist).M=M;

  p_total=0;
  for(m=0;m<M;m++)
    {
      uni_list1 = MatrixInt(P_vec[m],S);
      uni_i1 = (int *)malloc(P_vec[m]*sizeof(int));
      uni_j1 = (int *)malloc(P_vec[m]*sizeof(int));
      cnt1 = (int *)calloc(P_vec[m],sizeof(int));
      
      /* Sort rows */
      SortRowsInt(P_vec[m],S,&hashed[p_total],&sorted1[p_total],&sort_idx1[p_total]);
      
      /* Count sorted rows */
      U = CountSortedRowsInt(P_vec[m],S,&sorted1[p_total],&sort_idx1[p_total],uni_list1,uni_i1,uni_j1,cnt1);
      
      /*** Now assemble a 1-D hist ***/
      for(u=0;u<U;u++)
	memcpy((*class_hist).vec[m].wordlist[u],binned[p_total + uni_i1[u]],N*sizeof(int));
      (*class_hist).vec[m].P = P_vec[m];
      (*class_hist).vec[m].C = U;
      (*class_hist).vec[m].N = N;

      /* This is not efficient: convert counts to double */
      for(u=0;u<U;u++)
	(*class_hist).vec[m].wordcnt[u] = (double) cnt1[u];

      p_total+=P_vec[m];
      
      FreeMatrixInt(uni_list1);
      free(uni_i1);
      free(uni_j1);
      free(cnt1);
    }
  return EXIT_SUCCESS;
}

int DirectCountTotal2Comp(int **binned,int P_total,int N,int S,
		     int *P_vec,int M,
		     struct hist1d *total_hist,
		     int **sorted1,int *sort_idx1)
{
  int **sorted2;
  int *sort_idx2;
  int **uni_list2,*uni_i2,*uni_j2;
  int *cnt2;
  int U;
  int u;

  /************************************/
  /*** Step 4: Count ALL of the words */
  /************************************/

  /* We've got M sorted lists, and we want to merge them into a single
     sorted list */

  sorted2 = MatrixInt(P_total,S);
  sort_idx2 = (int *)malloc(P_total*sizeof(int));
  uni_i2 = (int *)malloc(P_total*sizeof(int));
  uni_j2 = (int *)malloc(P_total*sizeof(int));
  cnt2 = (int *)calloc(P_total,sizeof(int));
  uni_list2 = MatrixInt(P_total,S);

  Merge(sorted1,sort_idx1,P_total,S,M,P_vec,sorted2,sort_idx2);
  U = CountSortedRowsInt(P_total,S,sorted2,sort_idx2,uni_list2,uni_i2,uni_j2,cnt2);

  /* Now assemble a 1-D hist */
  /* Not sure what's going on here...Do we index into the original list directly? */
  for(u=0;u<U;u++)
    memcpy((*total_hist).wordlist[u],binned[uni_i2[u]],N*sizeof(int));
  (*total_hist).P = P_total;
  (*total_hist).C = U;
  (*total_hist).N = N;
 
  /* This is not efficient: convert counts to double */
  for(u=0;u<U;u++)
    (*total_hist).wordcnt[u] = (double) cnt2[u];

  free(cnt2);
  FreeMatrixInt(sorted2);
  free(uni_i2);
  free(uni_j2);
  free(sort_idx2);
  FreeMatrixInt(uni_list2);

  return EXIT_SUCCESS;
}

void Merge(int **sorted1,int *sort_idx1,int P_total,int N,
	   int M,int *P_vec,
	   int **sorted2, int *sort_idx2)
{
  int *pos,*P_end;
  int m,n;
  int P_count=0;
  int min_m,start_m;
  int temp;

  /* we need a vector of pointers, one for each list in sorted1 */
  pos = (int *)malloc(M*sizeof(int));
  P_end = (int *)malloc(M*sizeof(int));
  pos[0]=0;
  P_end[0]=P_vec[0];
  for(m=1;m<M;m++)
    {
      pos[m]=P_end[m-1];
      P_end[m]=P_end[m-1]+P_vec[m]; 
    }

  /* as long as there are unsorted elements remaining */
  while(P_count<P_total)
    {
      /* Find the first (perhaps only) class that has an eligible word */
      m=0;
      while(m<M)
	{
	  /* as long as there are elements left in this class */
	  if(pos[m]<P_end[m])
	    {
	      start_m = m;
	      break;
	    }
	  m++;
	}
      
      /* Find the class that has the smallest word */
      min_m = start_m;
      for(m=start_m+1;m<M;m++)
	{
	  /* as long as there are elements left in this class */
	  if(pos[m]<P_end[m])
	    {
	      temp = CompWords(sorted1[pos[min_m]],sorted1[pos[m]],N);
	      if(temp)
		min_m = m;
	    }
	}
      
      /* Copy that word to the output list */
      for(n=0;n<N;n++)
	sorted2[P_count][n] = sorted1[pos[min_m]][n];
      sort_idx2[P_count] = sort_idx1[pos[min_m]];

      pos[min_m]++; /* Increment the pointer for the word we chose */
      P_count++; /* Increment the total words we have dealt with */
    }

  free(pos);
  free(P_end);
}

/* This function takes the addresses of two words and returns 0 is the first one is the same or if they are equal and 1 if the second one is the same */
int CompWords(int *a,int *b,int N)
{
  int n=0;
  int out=0;

  while(n<N)
    {
      /* printf("a[%d]=%d b[%d]=%d ",n,a[n],n,b[n]); */
      if(b[n]<a[n])
	{
	  out=1;
	  break;
	}
      else if(a[n]<b[n])
	break;

      n++;
    }
  /* printf("out=%d\n",out); */
  
  return out;
}

int DirectCountTotalComp(int **binned,int **hashed,int P_total,int N,int S,struct hist1d *hist)
{
  int **uni_list1,*uni_i1,*uni_j1;
  int *cnt1;
  int U;
  int u;
  int **sorted1;
  int *sort_idx1;

  /* So, we discard any class distinctions and just sort and count the whole thing together */

  sorted1 = MatrixInt(P_total,S);
  sort_idx1 = (int *)malloc(P_total*sizeof(int));
  uni_list1 = MatrixInt(P_total,S);
  uni_i1 = (int *)malloc(P_total*sizeof(int));
  uni_j1 = (int *)malloc(P_total*sizeof(int));
  cnt1 = (int *)calloc(P_total,sizeof(int));
  
  /* Sort rows */
  SortRowsInt(P_total,S,hashed,sorted1,sort_idx1);
  
  /* Count sorted rows */
  U = CountSortedRowsInt(P_total,S,sorted1,sort_idx1,uni_list1,uni_i1,uni_j1,cnt1);
  
  /* Now assemble a 1-D hist */
  for(u=0;u<U;u++)
    memcpy((*hist).wordlist[u],binned[uni_i1[u]],N*sizeof(int));
  (*hist).P = P_total;
  (*hist).C = U;
  (*hist).N = N;
  
  /* This is not efficient: convert counts to double */
  for(u=0;u<U;u++)
    (*hist).wordcnt[u] = (double) cnt1[u];
  
  FreeMatrixInt(sorted1);
  free(sort_idx1);
  FreeMatrixInt(uni_list1);
  free(uni_i1);
  free(uni_j1);
  free(cnt1);
  
  return EXIT_SUCCESS;
}

/**
 * @brief Gets the base, subwords, and letters from binned data.
 * This function gets the base (*B_ptr) of the words, number of subwords (*S_ptr)
 * in a word, and number of letters (*L_ptr) in a subword, from binned data
 * (**binned) whose dimension is determined from the total number of rows of data
 * (P_total), and the number of columns (N).
 */
void GetBSL(int **binned,int P_total,int N,int *B_ptr,int *S_ptr,int *L_ptr)
{
  int B,D,S,L;

  /* Convert words of B-ary words of length W into L-ary words of length S */
  B = MaxMatrixInt(binned,P_total,N)+1; /* Base of the words */
  if(B<2)
    B=2;
  /* D = floor((sizeof(unsigned)*BITS_IN_A_BYTE)*(log(2)/log((double)B))); */
  D = floor((log((double)INT_MAX)/log(2))/(log(B)/log(2)));
  S = ceil((double)N/(double)D);  /* S: Number of subwords in a word. */
  L = ceil((double)N/(double)S);  /* L: Number of letters in a subword */

  *B_ptr = B;
  *S_ptr = S;
  *L_ptr = L;
}

/**
 * @brief Parse binned data.
 * This function parses data (**binned), based on dimensional parameters
 * (P, N), and words (B, S, L), and gets the hashed result (**hashed).
 */
void HashWords(int **binned,int P,int N,int B,int S,int L,int **hashed)
{
  int p,n,s,l;

  l=0;
  for(p=0;p<P;p++)
      {
	s=-1;
	/* Scroll through all of the letters */
	for(n=0;n<N;n++)
	  {
	    /* if we are beginning a new subword */
	    if(n%L==0)
	      {
		s++;
		hashed[p][s]=0;
		l=0;
	      }
	    hashed[p][s]+=binned[p][n]*((int)pow((double)B,(double)l));
	    l++;
	  }
      }
}
