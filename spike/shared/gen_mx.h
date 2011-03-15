/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
/* General stuff */
extern void mxStringToCString(mxArray *in,char *out);
extern void SingleCellArrayToCString(mxArray *in,char *out);
extern void CellArrayElementToCString(mxArray *in,int n,char *out);
extern void CellArrayToCStringArray(mxArray *in,int N,char **out);
extern mxArray *CStringTomxString(char *in);
extern mxArray *CStringToSingleCellArray(char *in);
extern mxArray *CStringArrayToCellArray(char **in,int N);
extern void CStringToCellArrayElement(char *in,int n,mxArray *out);
extern mxArray *ConvertIntScalar(int in);

/* Memory allocation  */
extern char **mxMatrixChar(int M,int N);
extern int **mxMatrixInt(int M,int N);
extern int ***mxMatrix3Int(int M,int N,int P);
extern double **mxMatrixDouble(int M,int N);
extern double ***mxMatrix3Double(int M,int N,int P);
extern void mxFreeMatrixChar(char **in);
extern void mxFreeMatrixInt(int **in);
extern void mxFreeMatrix3Int(int ***in);
extern void mxFreeMatrixDouble(double **in);
extern void mxFreeMatrix3Double(double ***in);

/* Options */
extern void mxAddAndSetField(mxArray *in,int n,const char *field_name,mxArray *value);
extern mxArray *mxCreateEmptyStruct(void);
extern mxArray *mxCreateEmptyMatrix(void);
extern mxArray *mxCreateInt32Scalar(int value);
extern struct options_entropy *ReadOptionsEntropy(const mxArray *in);
extern mxArray *WriteOptionsEntropy(const mxArray *in,struct options_entropy *opts);
extern int ReadOptionPossibleWords(const mxArray *in,const char *field_name,double *member);
extern int ReadOptionsDoubleMember(const mxArray *in,const char *field_name,double *member);
extern int ReadOptionsIntMember(const mxArray *in,const char *field_name,int *member);
extern void WriteOptionPossibleWords(mxArray *out,const char *field_name,double member,int flag);
extern void WriteOptionsDoubleMember(mxArray *out,const char *field_name,double member,int flag);
extern void WriteOptionsIntMember(mxArray *out,const char *field_name,int member,int flag);

