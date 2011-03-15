/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */

/** @file
 * @brief Supports toolkit-wide gateway routines.
 * This file contains C code that supports MEX-file gateway
 * routines, but which is not directly compiled. The functions
 * herein are useful for processing strings and allocating memory
 * for multidimensional arrays.
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

/**
 * @brief Allocate memory for a matrix of integers.
 * This function allocates memory for a Matlab-managed M-by-N matrix
 * of integers, and returns a pointer to an array of M pointers,
 * which each refer to a (consecutive) block of N integers.
 */
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

/**
 * @brief Converts a Matlab string to a C string
 * Converts a Matlab string pointed to by the mxArray pointer in to a null
 * terminated C string. This function is the reverse of the function
 * CStringTomxString.
 */
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

/**
 * @brief Converts a single-element cell array into a C string
 * Under the assumption that the first element of the cell array pointed to by
 * in is a string, converts the representation to a null terminated C string.
 * This function is the reverse of CStringToSingleCellArray.
 */
void SingleCellArrayToCString(mxArray *in,char *out)
{
  mxArray *temp_cell;

  if(mxIsCell(in))
  {
    temp_cell = mxGetCell(in,0);
    mxStringToCString(temp_cell,out);
  }
  else
    mexErrMsgIdAndTxt("STAToolkit:SingleCellArrayToCString:badInput","Input is not a cell array");
}

/**
 * @brief Converts a particular element in a cell array into a C string
 * Under the assumption that the element indexed by n of the cell array
 * pointed to by in is a string, converts the representation to a null
 * terminated C string.
 */
void CellArrayElementToCString(mxArray *in,int n,char *out)
{
  mxArray *temp_cell;
  
  if(mxIsCell(in))
  {
    temp_cell = mxGetCell(in,n);
    mxStringToCString(temp_cell,out);
  }
  else
    mexErrMsgIdAndTxt("STAToolkit:SingleCellArrayToCString:badInput","Input is not a cell array");
}

/**
 * @brief Converts a cell array into an array of C strings
 * Under the assumption that the elements of the cell array pointed to by in
 * are strings, converts each Matlab string to a null terminated C string.
 * This function is the reverse of the function CStringArrayToCellArray.
 */
void CellArrayToCStringArray(mxArray *in,int N,char **out)
{
  int n;

  for(n=0;n<N;n++)
    CellArrayElementToCString(in,n,out[n]);
}

/**
 * @brief Converts a C string to a Matlab string 
 * Converts the null terminated C string in to a Matlab string, returning its
 * pointer. This function is the reverse of the function mxStringToCString.
 */
mxArray *CStringTomxString(char *in)
{
  mxArray *out;

  out = mxCreateString(in);

  return out;
}

/**
 * @brief Converts a C string to a single-element cell array
 * Converts the null terminated C string in to a cell array containing just
 * one Matlab string, returning its pointer. This function is the reverse of
 * the function SingleCellArrayToCString.
 */
mxArray *CStringToSingleCellArray(char *in)
{
  mxArray *out,*temp;

  out = mxCreateCellMatrix(1,1);

  temp = CStringTomxString(in);
  mxSetCell(out,0,temp);
  
  return out;
}

/**
 * @brief Converts an array of C strings to a cell array of strings
 * Converts an array of null terminated C strings to a Matlab cell array of
 * strings, returning its pointer. This function is the reverse of the
 * function CellArrayToCStringArray.
 */
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
  if(mxGetField(in,n,field_name)==NULL)
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

mxArray *mxCreateEmptyMatrix(void)
{
  mxArray *out;

  out = mxCreateDoubleScalar(0.0);
  mxSetM(out,0);
  mxSetN(out,0);

  return out;
}

mxArray *mxCreateInt32Scalar(int value)
{
	return ConvertIntScalar(value);
}

/**
 * @brief Read in the option possible_words.
 * Reads the option possible_words, converting string data into its numerical
 * representation, and returning a flag to indicate the status.
 */
int ReadOptionPossibleWords(const mxArray *in,const char *field_name,double *member)
{
  /* declare local variables */
  mxArray *tmp;
  double num;
  int stringLength, flag, i;
  char *str;

  tmp = mxGetField(in,0,field_name);
  if((tmp==NULL) || mxIsEmpty(tmp)) /* field is empty */
    flag = 0;
  else
  {
    if(mxIsChar(tmp)) /* field is string */
    {
      /* copy string and set to lowercase */
      stringLength = mxGetNumberOfElements(tmp) + 1;
      str = mxCalloc(stringLength,sizeof(char));
      if(mxGetString(tmp,str,stringLength)!=0)
        mexErrMsgIdAndTxt("STAToolkit:ReadOptionPossibleWords:invalidValue","Could not convert string data.");
      for(i=0;str[i];i++)
        str[i] = tolower(str[i]);

      /* use string to set member value */
      flag = 1;
      if(strcmp(str,"recommended")==0)
        *member = (double)(-1.0);
      else if(strcmp(str,"unique")==0)
        *member = (double)(-2.0);
      else if(strcmp(str,"total")==0)
        *member = (double)(-3.0);
      else if(strcmp(str,"possible")==0)
        *member = (double)(-4.0);
      else if(strcmp(str,"min_tot_pos")==0)
        *member = (double)(-5.0);
      else if(strcmp(str,"min_lim_tot_pos")==0)
        *member = (double)(-6.0);
      else
      {
        mexWarnMsgIdAndTxt("STAToolkit:ReadOptionPossibleWords:invalidValue","Unrecognized option \"%s\" for possible_words. Using default \"recommended\".",str);
        *member = (double)(-1.0);
      }
    }
    else /* field is scalar */
    {
      flag = 2;
      num = mxGetScalar(tmp);
      if(num==mxGetInf())
        *member = (double)(0.0);
      else if((num<1.0) || (fmod(num,1.0)>mxGetEps()))
        mexErrMsgIdAndTxt("STAToolkit:ReadOptionPossibleWords:invalidValue","possible_words must be a positive integer. Current value is %f.",num);
      else
        *member = num;
    }
  }
  return flag;
}

int ReadOptionsDoubleMember(const mxArray *in,const char *field_name,double *member)
{
  mxArray *tmp;
  int flag;
  
  tmp = mxGetField(in,0,field_name);
  if((tmp==NULL) || mxIsEmpty(tmp))
    flag = 0;
  else
    {
      flag = 1;
      *member = mxGetScalar(tmp);
    }  
  return flag;
}

int ReadOptionsIntMember(const mxArray *in,const char *field_name,int *member)
{
  mxArray *tmp;
  int flag;

  tmp = mxGetField(in,0,field_name);
  if((tmp==NULL) || mxIsEmpty(tmp))
    flag = 0;
  else
    {
      flag = 1;
      *member = (int)mxGetScalar(tmp);
    }  
  return flag;
}

/**
 * @brief Write the option possible_words.
 * Writes the option possible_words, converting from certain numerical
 * representations to their corresponding strings.
 */
void WriteOptionPossibleWords(mxArray *out,const char *field_name,double member,int flag)
{
  if(flag)
    switch((int)member) /* use value to set string */
    {
      case 0:
        mxAddAndSetField(out,0,field_name,mxCreateDoubleScalar(mxGetInf()));
        break;
      case -1:
        mxAddAndSetField(out,0,field_name,mxCreateString("recommended"));
        break;
      case -2:
        mxAddAndSetField(out,0,field_name,mxCreateString("unique"));
        break;
      case -3:
        mxAddAndSetField(out,0,field_name,mxCreateString("total"));
        break;
      case -4:
        mxAddAndSetField(out,0,field_name,mxCreateString("possible"));
        break;
      case -5:
        mxAddAndSetField(out,0,field_name,mxCreateString("min_tot_pos"));
        break;
      case -6:
        mxAddAndSetField(out,0,field_name,mxCreateString("min_lim_tot_pos"));
        break;
      default:
        mxAddAndSetField(out,0,field_name,mxCreateDoubleScalar(member));
    }
}

void WriteOptionsDoubleMember(mxArray *out,const char *field_name,double member,int flag)
{
  if(flag)
    mxAddAndSetField(out,0,field_name,mxCreateDoubleScalar(member));
}

void WriteOptionsIntMember(mxArray *out,const char *field_name,int member,int flag)
{
  if(flag)
    mxAddAndSetField(out,0,field_name,mxCreateDoubleScalar((double)member));
}
