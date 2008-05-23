/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "toolkit_c.h"
#include "toolkit_mx.h"

char **mxMatrixChar(int M,int N)
{
  char **out;
  int m;

  out = (char **)mxMalloc(M*sizeof(char *));
  out[0] = (char *)mxMalloc(M*N*sizeof(char));
  for(m=1;m<M;m++)
    out[m] = out[m-1]+N;
  
  return out;
}

int **mxMatrixInt(int M,int N)
{
  int **out;
  int m;

  out = (int **)mxCalloc(M,sizeof(int *));
  out[0] = (int *)mxCalloc(M*N,sizeof(int));
  for(m=1;m<M;m++)
    out[m] = out[m-1]+N;

  return out;
}

double **mxMatrixDouble(int M,int N)
{
  double **out;
  int m;

  out = (double **)mxCalloc(M,sizeof(double *));
  out[0] = (double *)mxCalloc(M*N,sizeof(double));
  for(m=1;m<M;m++)
    out[m] = out[m-1]+N;

  return out;
}

int ***mxMatrix3Int(int M,int N,int P)
{
  int ***out;
  int i,j;

  /* These are pointers to the start of M+1 rows */
  out = (int ***)mxCalloc(M,sizeof(int **));
  
  /* These are pointers to the start of M+1xN+1 pokes */
  out[0] = (int **)mxCalloc(M*N,sizeof(int *));
  
  /* This is M+1xN+1xP pointers to ints */
  out[0][0] = (int *)mxCalloc(M*N*P,sizeof(int));
  
  /* This sets pointers to the start of the rows */
  for(i=1;i<M;i++)
    {
      out[i]=out[i-1]+N;
      out[i][0]=out[i-1][0]+N*P;
    }
  
  /* This sets pointers to the start of the pokes */
  for(i=0;i<M;i++)
    for(j=1;j<N;j++)
      out[i][j]=out[i][j-1]+P;

  return out;
}

double ***mxMatrix3Double(int M,int N,int P)
{
  double ***out;
  int i,j;

  /* These are pointers to the start of M+1 rows */
  out = (double ***)mxCalloc(M,sizeof(double **));
  
  /* These are pointers to the start of M+1xN+1 pokes */
  out[0] = (double **)mxCalloc(M*N,sizeof(double *));
  
  /* This is M+1xN+1xP pointers to doubles */
  out[0][0] = (double *)mxCalloc(M*N*P,sizeof(double));
  
  /* This sets pointers to the start of the rows */
  for(i=1;i<M;i++)
    {
      out[i]=out[i-1]+N;
      out[i][0]=out[i-1][0]+N*P;
    }
  
  /* This sets pointers to the start of the pokes */
  for(i=0;i<M;i++)
    for(j=1;j<N;j++)
      out[i][j]=out[i][j-1]+P;

  return out;
}

void mxFreeMatrixChar(char **in)
{
  mxFree(in[0]);
  mxFree(in);
}

void mxFreeMatrixInt(int **in)
{
  mxFree(in[0]);
  mxFree(in);
}

void mxFreeMatrix3Int(int ***in)
{
  mxFree(in[0][0]);
  mxFree(in[0]);
  mxFree(in);
}

void mxFreeMatrixDouble(double **in)
{
  mxFree(in[0]);
  mxFree(in);
}

void mxFreeMatrix3Double(double ***in)
{
  mxFree(in[0][0]);
  mxFree(in[0]);
  mxFree(in);
}

/* Converts an mx string to a C string */ 
/* Reverse of CStringTomxString */
void mxStringToCString(mxArray *in,char *out)
{
  mxChar *temp_string;
  int i,len;
  
  len = mxGetNumberOfElements(in);
  temp_string = mxGetChars(in);
  for(i=0;i<len;i++)
    out[i]=(char) temp_string[i];
  for(i=len;i<MAXCHARS;i++)
    out[i]='\0';
}

/* Converts a single-element cell array into a C string */
void SingleCellArrayToCString(mxArray *in,char *out)
{
  mxArray *temp_cell;

  temp_cell = mxGetCell(in,0);
  mxStringToCString(temp_cell,out);
}

/* Pulls out a single element from a cell array
   and converts it to a C string */
void CellArrayElementToCString(mxArray *in,int n,char *out)
{
  mxArray *temp_cell;
  
  temp_cell = mxGetCell(in,n);
  mxStringToCString(temp_cell,out);
}

/* Converts a whole cell array into an array of C strings */
void CellArrayToCStringArray(mxArray *in,int N,char **out)
{
  int n;

  for(n=0;n<N;n++)
    CellArrayElementToCString(in,n,out[n]);
}

/* Converts a C string to an mx string */
/* Reverse of mxStringToCString */
mxArray *CStringTomxString(char *in)
{
  mxArray *out;

  out = mxCreateString(in);

  return out;
}

/* Converts a C string to a single cell array */
/* Reverse of CellToCString */
mxArray *CStringToSingleCellArray(char *in)
{
  mxArray *out,*temp;

  out = mxCreateCellMatrix(1,1);

  temp = CStringTomxString(in);
  mxSetCell(out,0,temp);
  
  return out;
}

/* Converts an array of C strings to a cell array */
/* Reverse of CellArrayToCStringArray */
mxArray *CStringArrayToCellArray(char **in,int N)
{
  mxArray *out;
  int n;

  out = mxCreateCellMatrix(1,N);

  for(n=0;n<N;n++)
    CStringToCellArrayElement(in[n],n,out);
  
  return out;
}

void CStringToCellArrayElement(char *in,int n,mxArray *out)
{
  mxArray *temp;
  
  temp = CStringTomxString(in);
  mxSetCell(out,n,temp);
}

mxArray *ConvertIntScalar(int in)
{
  mxArray *out;
  
  out = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
  memcpy(mxGetData(out),&in,sizeof(int));
  
  return out;
}

void mxAddAndSetField(mxArray *in,int n,const char *field_name,mxArray *value)
{
  mxAddField(in,field_name);
  mxSetField(in,n,field_name,value);
}

mxArray *mxCreateEmptyStruct(void)
{
  const char *dummy[] = {"dummy"};
  mxArray *out;

  out = mxCreateStructMatrix(1,1,1,dummy);
  mxRemoveField(out,0);

  return out;
}

int ReadOptionsDoubleMember(const mxArray *in,char *field_name,double *member)
{
  mxArray *tmp;
  int flag;
  
  tmp = mxGetField(in,0,field_name);
  if(tmp==NULL)
    flag = 0;
  else
    {
      flag = 1;
      *member = mxGetScalar(tmp);
    }  
  return flag;
}

int ReadOptionsIntMember(const mxArray *in,char *field_name,int *member)
{
  mxArray *tmp;
  int flag;

  tmp = mxGetField(in,0,field_name);
  if(tmp==NULL)
    flag = 0;
  else
    {
      flag = 1;
      *member = (int)mxGetScalar(tmp);
    }  
  return flag;
}

void WriteOptionsDoubleMember(mxArray *out,char *field_name,double member,int flag)
{
  if(flag)
    mxAddAndSetField(out,0,field_name,mxCreateScalarDouble(member));
}

void WriteOptionsIntMember(mxArray *out,char *field_name,int member,int flag)
{
  if(flag)
    mxAddAndSetField(out,0,field_name,mxCreateScalarDouble((double)member));
}
