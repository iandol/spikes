/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "toolkit_c.h"
/* #define DEBUG */

int MatrixToHist2DComp(double **in,
			int M, /* rows in table input */
			int N, /* cols in table input */
			struct hist2d *out, /* output structure */
			struct options_entropy *opts /* entropy options */
			)
{
  int m,n;
  int c,C,P;
  double doubleP;
  int j,r;
  int row_flag,col_flag;
  int **row_list,**col_list;
  struct hist1d *joint_ptr,*row_ptr,*col_ptr;
  double *joint_cnt;
  int *joint_list;

  joint_ptr = (*out).joint;
  row_ptr = (*out).row;
  col_ptr = (*out).col;

  row_list = MatrixInt(M*N,1);
  col_list = MatrixInt(M*N,1);
  joint_cnt = (double *)malloc(M*N*sizeof(double));
  joint_list = (int *)malloc(M*N*sizeof(int));

  /******************************************************/
  /* Step A: Get lists of the occupied rows and columns */
  /* Also, compute the sum of all of the elements       */
  /******************************************************/

  c=0;
  doubleP=0;
  for(m=0;m<M;m++)
    for(n=0;n<N;n++)
      {
	doubleP+=in[m][n];
	if((in[m][n]>0) | (opts[0].useall==1))
	  {
	    row_list[c][0] = m;
	    col_list[c][0] = n;
	    joint_cnt[c] = in[m][n];
	    joint_list[c] = m*N+n;
	    c++;
	  }
      }
  P = (int)doubleP;
  C=c; /* C is the number of non-zero entries in the table */

  /**************************************/
  /* Step B: Handle marginal histograms */
  /**************************************/

  /* First rows */
  (*row_ptr).P = P;
  (*row_ptr).N = 1;
  if(C)
    (*row_ptr).C = MarginalProc(C,1,row_list,joint_cnt,(*row_ptr).wordlist,(*row_ptr).wordcnt);
  else
    (*row_ptr).C = 0;

#ifdef DEBUG
  for(c=0;c<(*row_ptr).C;c++)
    printf("(*row_ptr).wordlist[%d][0]=%d (*row_ptr).wordcnt[%d]=%f\n",c,(*row_ptr).wordlist[c][0],c,(*row_ptr).wordcnt[c]);
#endif

  /* Then columns */
  (*col_ptr).P = P;
  (*col_ptr).N = 1;
  if(C)
    (*col_ptr).C = MarginalProc(C,1,col_list,joint_cnt,(*col_ptr).wordlist,(*col_ptr).wordcnt);
  else
    (*col_ptr).C = 0;
  
#ifdef DEBUG
  for(c=0;c<(*col_ptr).C;c++)
    printf("(*col_ptr).wordlist[%d][0]=%d (*col_ptr).wordcnt[%d]=%f\n",c,(*col_ptr).wordlist[c][0],c,(*col_ptr).wordcnt[c]);
#endif

  /**********************************/
  /* Step C: Handle joint histogram */
  /**********************************/

  (*joint_ptr).P = P;
  (*joint_ptr).N = 1;
  
  if(opts[0].useall==1)
    {
      /* DHG: These are truly offending lines */
      memcpy((*joint_ptr).wordcnt,joint_cnt,M*N*sizeof(double));
      for(j=0;j<M*N;j++)
	(*joint_ptr).wordlist[j][0]=joint_list[j];
      (*joint_ptr).C = M*N;
    }
  else /* *(opts[0].useall)==0 | *(opts[0].useall)==-1 */
    {
      j=0;
      for(m=0;m<M;m++)
	for(n=0;n<N;n++)
	  {
	    if((in[m][n]==0) & (opts[0].useall==0))
	      {
		row_flag=0;
		col_flag=0;
	    
		/* is m in uni_row_list? */
		for(r=0;r<(*row_ptr).C;r++)
		  if((*row_ptr).wordlist[r][0]==m)
		    {
		      row_flag=1;
		      break;
		    }
	    
		/* is n in uni_col_list? */
		for(c=0;c<(*col_ptr).C;c++)
		  if((*col_ptr).wordlist[c][0]==n)
		    {
		      col_flag=1;
		      break;
		    }
	    
		/* if both are yes, then add to the list */
		if(row_flag & col_flag)
		  {
		    (*joint_ptr).wordcnt[j] = in[m][n];
		    (*joint_ptr).wordlist[j][0] = m*N+n;
		    j++;
		  }
	      }
	    else if(in[m][n]>0) /* otherwise in[m][n]>0 | *(opts[0].useall)==-1 */
	      {
		(*joint_ptr).wordcnt[j] = in[m][n]; 
		(*joint_ptr).wordlist[j][0] = m*N+n;
		j++;
	      }
	  }
      (*joint_ptr).C = j;
    }
 
  FreeMatrixInt(row_list);
  FreeMatrixInt(col_list);
  free(joint_cnt);
  free(joint_list);

  return EXIT_SUCCESS;
}

/**
 * @brief Returns the word list and word count from an array of words.
 * Uses a sorting algorithm to grab the unique words from an array whose rows
 * are words, and places the list in wordlist and the counts in wordcnt.
 * @param[in] C_in The number of rows in list.
 * @param[in] N The number of columns in list.
 * @param[in] list The array of words.
 * @param[in] cnt The list of counts.
 * @param[out] wordlist The unique words.
 * @param[out] wordcnt The word counts.
 */
int MarginalProc(int C_in,int N,int **list,double *cnt,int **wordlist,double *wordcnt)
{
  int c;
  int *uni_cnt,*uni_i,*uni_j;
  int C_out;
 
  uni_cnt = (int *)calloc(C_in,sizeof(int));
  uni_i = (int *)calloc(C_in,sizeof(int));
  uni_j = (int *)calloc(C_in,sizeof(int));
 
  C_out = UniqueRowsInt(C_in,N,list,wordlist,uni_i,uni_j,uni_cnt);

  for(c=0;c<C_in;c++)
    wordcnt[uni_j[c]]+=cnt[c];

  free(uni_cnt);
  free(uni_i);
  free(uni_j);
 
  return C_out;
}

