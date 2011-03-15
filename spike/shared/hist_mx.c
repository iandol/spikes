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
 * herein are useful for processing histograms and estimated
 * quantities.
 */

#include "toolkit_c.h"
#include "toolkit_mx.h"

extern char ent_est_meth_list[ENT_EST_METHS][MAXCHARS];
extern char var_est_meth_list[GEN_VAR_EST_METHS+SPEC_VAR_EST_METHS][MAXCHARS];

/*** hist1d ***/

/**
 * @brief Allocates memory for a Matlab structure.
 * This function allocates memory for an M-by-1 Matlab structure
 * with the fields "P", "C", "N", "wordlist", and "wordcnt", and
 * returns a pointer to this structure. Memory is also allocated
 * for the corresponding fields in an analogous C struct (*hist_c),
 * given data dimensions (*P_vec, N).
 */
mxArray *AllocHist1D(int M,struct hist1d *hist_c,int *P_vec,int N)
{
	mxArray *hist_mx;
	const char *hist_field_names[] = {
		"P",
		"C",
		"N",
		"wordlist",
		"wordcnt"};
	int m;

	hist_mx = mxCreateStructMatrix(M,1,5,hist_field_names);

	for(m=0;m<M;m++)
		{
			hist_c[m].wordlist = mxMatrixInt(P_vec[m],N);
			hist_c[m].wordcnt = mxCalloc(P_vec[m],sizeof(double));
		}

	return hist_mx;
}

void WriteHist1D(int M,struct hist1d *hist_c,mxArray *hist_mx)
{
	/*
	Function WriteHist1D copies scalar results from the C histogram (*hist_c)
	to the M-by-1 Matlab histogram (*hist_mx), and frees the associated memory
	from C histograms.
	*/
	int m,n,p;
	mxArray *cnt_mx,*list_mx;
	int *list_c;

	for(m=0;m<M;m++)
		{
			/* Set the scalars */
			mxSetField(hist_mx,m,"P",ConvertIntScalar(hist_c[m].P));
			mxSetField(hist_mx,m,"C",ConvertIntScalar(hist_c[m].C));
			mxSetField(hist_mx,m,"N",ConvertIntScalar(hist_c[m].N));

			/* Vectorize and transpose wordlist */
			list_c = (int *)mxMalloc(hist_c[m].C*hist_c[m].N*sizeof(int));
			for(p=0;p<hist_c[m].C;p++)
				for(n=0;n<hist_c[m].N;n++)
					list_c[n*hist_c[m].C+p]=hist_c[m].wordlist[p][n];

			list_mx = mxCreateNumericMatrix(hist_c[m].C,hist_c[m].N,mxINT32_CLASS,mxREAL);
			memcpy(mxGetData(list_mx),list_c,hist_c[m].C*hist_c[m].N*sizeof(int));
			mxSetField(hist_mx,m,"wordlist",list_mx);

			cnt_mx = mxCreateDoubleMatrix(hist_c[m].C,1,mxREAL);
			memcpy(mxGetData(cnt_mx),hist_c[m].wordcnt,hist_c[m].C*sizeof(double));
			mxSetField(hist_mx,m,"wordcnt",cnt_mx);

			/* Free the allocated memory */
			mxFree(list_c);
			mxFreeMatrixInt(hist_c[m].wordlist);
			mxFree(hist_c[m].wordcnt);
		}
}

/**
 * @brief Converts a Matlab hist1d structure to a C hist1d structure
 * Reads in the Matlab hist1d structure hist_mx, and the associated entropy
 * options, and returns a pointer to a C hist1d structure that contains the
 * same data.
 */
struct hist1d *ReadHist1D(int M,mxArray *hist_mx,struct options_entropy *opts)
{
	int m,p,n;
	int *list_c;
	mxArray *ent_mx, *temp;
	struct hist1d *hist_c;

	hist_c = (struct hist1d *)mxMalloc(M*sizeof(struct hist1d));

	mxAddField(hist_mx,"entropy");

	for(m=0;m<M;m++)
		{
			/* Read in scalars */
			temp = mxGetField(hist_mx,m,"P");
			if(temp)
				hist_c[m].P = (int)mxGetScalar(temp);
			else
				mexErrMsgIdAndTxt("STAToolkit:ReadHist1D:badInput","Missing hist1d field \"P\".");
			temp = mxGetField(hist_mx,m,"C");
			if(temp)
				hist_c[m].C = (int)mxGetScalar(temp);
			else
				mexErrMsgIdAndTxt("STAToolkit:ReadHist1D:badInput","Missing hist1d field \"C\".");
			temp = mxGetField(hist_mx,m,"N");
			if(temp)
				hist_c[m].N = (int)mxGetScalar(temp);
			else
				mexErrMsgIdAndTxt("STAToolkit:ReadHist1D:badInput","Missing hist1d field \"N\".");

			/* Read in matrices */
			temp = mxGetField(hist_mx,m,"wordcnt");
			if(temp)
				hist_c[m].wordcnt = mxGetPr(temp);
			else
				mexErrMsgIdAndTxt("STAToolkit:ReadHist1D:badInput","Missing hist1d field \"wordcnt\".");

			temp = mxGetField(hist_mx,m,"wordlist");
			if(temp)
				list_c = mxGetData(temp);
			else
				mexErrMsgIdAndTxt("STAToolkit:ReadHist1D:badInput","Missing hist1d field \"wordlist\".");

			hist_c[m].wordlist = mxMatrixInt(hist_c[m].C,hist_c[m].N);
			for(p=0;p<hist_c[m].C;p++)
				for(n=0;n<hist_c[m].N;n++)
					hist_c[m].wordlist[p][n] = list_c[n*hist_c[m].C+p];

			/* Descend and allocate memory for the entropy */
			hist_c[m].entropy = (struct estimate *)mxMalloc((*opts).E*sizeof(struct estimate));
			ent_mx = AllocEst(hist_c[m].entropy,opts);
			mxSetField(hist_mx,m,"entropy",ent_mx);
		}

	return hist_c;
}

void WriteHist1DAgain(int M,struct hist1d *hist_c,mxArray *hist_mx)
{
	int m;
	mxArray *ent_mx;

	for(m=0; m<M; m++)
	{
		ent_mx = mxGetField(hist_mx,m,"entropy");
		WriteEst(hist_c[m].entropy,ent_mx);
		mxFree(hist_c[m].entropy);
		mxFreeMatrixInt(hist_c[m].wordlist);
	}
}

/*** hist2d ***/

mxArray *AllocHist2D(struct hist2d *hist_c,int P_total,int N)
{
	mxArray *hist_mx,*joint_mx,*row_mx,*col_mx;
	const char *hist_field_names[] = {
		"joint",
		"row",
		"col"};

	hist_mx = mxCreateStructMatrix(1,1,3,hist_field_names);

	(*hist_c).joint = (struct hist1d *)mxMalloc(sizeof(struct hist1d));
	joint_mx = AllocHist1D(1,(*hist_c).joint,&P_total,N);
	mxSetField(hist_mx,0,"joint",joint_mx);

	(*hist_c).row = (struct hist1d *)mxMalloc(sizeof(struct hist1d));
	row_mx = AllocHist1D(1,(*hist_c).row,&P_total,N);
	mxSetField(hist_mx,0,"row",row_mx);

	(*hist_c).col = (struct hist1d *)mxMalloc(sizeof(struct hist1d));
	col_mx = AllocHist1D(1,(*hist_c).col,&P_total,N);
	mxSetField(hist_mx,0,"col",col_mx);

	return hist_mx;
}

void WriteHist2D(struct hist2d *hist_c,mxArray *hist_mx)
{
	mxArray *joint_mx,*row_mx,*col_mx;

	joint_mx = mxGetField(hist_mx,0,"joint");
	WriteHist1D(1,(*hist_c).joint,joint_mx);
	mxFree((*hist_c).joint);

	row_mx = mxGetField(hist_mx,0,"row");
	WriteHist1D(1,(*hist_c).row,row_mx);
	mxFree((*hist_c).row);

	col_mx = mxGetField(hist_mx,0,"col");
	WriteHist1D(1,(*hist_c).col,col_mx);
	mxFree((*hist_c).col);
}

struct hist2d *ReadHist2D(mxArray *hist_mx,struct options_entropy *opts)
{
	mxArray *joint_mx,*row_mx,*col_mx,*info_mx;
	struct hist2d *hist_c;

	hist_c = (struct hist2d *)mxMalloc(sizeof(struct hist2d));

	joint_mx = mxGetField(hist_mx,0,"joint");
	(*hist_c).joint = ReadHist1D(1,joint_mx,opts);

	row_mx = mxGetField(hist_mx,0,"row");
	(*hist_c).row = ReadHist1D(1,row_mx,opts);

	col_mx = mxGetField(hist_mx,0,"col");
	(*hist_c).col = ReadHist1D(1,col_mx,opts);

	mxAddField(hist_mx,"information");
	(*hist_c).information = (struct estimate *)mxMalloc((*opts).E*sizeof(struct estimate));
	info_mx = AllocEst((*hist_c).information,opts);
	mxSetField(hist_mx,0,"information",info_mx);

	return hist_c;
}

void WriteHist2DAgain(struct hist2d *hist_c,mxArray *hist_mx)
{
	mxArray *joint_mx,*row_mx,*col_mx,*info_mx;

	joint_mx = mxGetField(hist_mx,0,"joint");
	WriteHist1DAgain(1,(*hist_c).joint,joint_mx);
	mxFree((*hist_c).joint);

	row_mx = mxGetField(hist_mx,0,"row");
	WriteHist1DAgain(1,(*hist_c).row,row_mx);
	mxFree((*hist_c).row);

	col_mx = mxGetField(hist_mx,0,"col");
	WriteHist1DAgain(1,(*hist_c).col,col_mx);
	mxFree((*hist_c).col);

	info_mx = mxGetField(hist_mx,0,"information");
	WriteEst((*hist_c).information,info_mx);
	mxFree((*hist_c).information);
}

/*** histcond ***/

mxArray *AllocHistCond(int M,struct histcond *hist_c,int P_total,int *P_vec,int N)
{
	mxArray *hist_mx,*total_mx,*class_mx;
	const char *hist_field_names[] = {
		"class",
		"total"};

	hist_mx = mxCreateStructMatrix(1,1,2,hist_field_names);

	(*hist_c).classcond = (struct hist1dvec *)mxMalloc(sizeof(struct hist1dvec));
	class_mx = AllocHist1DVec(M,(*hist_c).classcond,P_total,P_vec,N);
	mxSetField(hist_mx,0,"class",class_mx);

	(*hist_c).total = (struct hist1d *)mxMalloc(sizeof(struct hist1d));
	total_mx = AllocHist1D(1,(*hist_c).total,&P_total,N);
	mxSetField(hist_mx,0,"total",total_mx);

	return hist_mx;
}

void WriteHistCond(struct histcond *hist_c,mxArray *hist_mx)
{
	mxArray *class_mx,*total_mx;

	class_mx = mxGetField(hist_mx,0,"class");
	WriteHist1DVec((*hist_c).classcond,class_mx);
	mxFree((*hist_c).classcond);

	total_mx = mxGetField(hist_mx,0,"total");
	WriteHist1D(1,(*hist_c).total,total_mx);
	mxFree((*hist_c).total);
}

struct histcond *ReadHistCond(mxArray *hist_mx,struct options_entropy *opts)
{
	mxArray *class_mx,*total_mx,*info_mx;
	struct histcond *hist_c;

	hist_c = (struct histcond *)mxMalloc(sizeof(struct histcond));

	class_mx = mxGetField(hist_mx,0,"class");
	if((class_mx==NULL) || mxIsEmpty(class_mx))
		mexErrMsgIdAndTxt("STAToolkit:ReadHistCond:badInput","The input data structure is ill-formed. Field \"class\" is missing.");
	(*hist_c).classcond = ReadHist1DVec(class_mx,opts);

	total_mx = mxGetField(hist_mx,0,"total");
	if((total_mx==NULL) || mxIsEmpty(total_mx))
		mexErrMsgIdAndTxt("STAToolkit:ReadHistCond:badInput","The input data structure is ill-formed. Field \"total\" is missing.");
	(*hist_c).total = ReadHist1D(1,total_mx,opts);

	mxAddField(hist_mx,"information");
	(*hist_c).information = (struct estimate *)mxMalloc((*opts).E*sizeof(struct estimate));
	info_mx = AllocEst((*hist_c).information,opts);
	mxSetField(hist_mx,0,"information",info_mx);

	return hist_c;
}

void WriteHistCondAgain(struct histcond *hist_c,mxArray *hist_mx)
{
	mxArray *class_mx,*total_mx,*info_mx;

	class_mx = mxGetField(hist_mx,0,"class");
	WriteHist1DVecAgain((*hist_c).classcond,class_mx);
	mxFree((*hist_c).classcond);

	total_mx = mxGetField(hist_mx,0,"total");
	WriteHist1DAgain(1,(*hist_c).total,total_mx);
	mxFree((*hist_c).total);

	info_mx = mxGetField(hist_mx,0,"information");
	WriteEst((*hist_c).information,info_mx);
	mxFree((*hist_c).information);
}

/*** hist1dvec ***/

mxArray *AllocHist1DVec(int M,struct hist1dvec *hist_c,int P_total,int *P_vec,int N)
{
	mxArray *hist_mx,*vec_mx;
	const char *hist_field_names[] = {
		"vec",
		"M",
		"P"};

	hist_mx = mxCreateStructMatrix(1,1,3,hist_field_names);

	(*hist_c).vec = (struct hist1d *)mxMalloc(M*sizeof(struct hist1d));
	vec_mx = AllocHist1D(M,(*hist_c).vec,P_vec,N);
	mxSetField(hist_mx,0,"vec",vec_mx);

	return hist_mx;
}

void WriteHist1DVec(struct hist1dvec *hist_c,mxArray *hist_mx)
{
	mxArray *vec_mx;

	mxSetField(hist_mx,0,"P",ConvertIntScalar(hist_c[0].P));
	mxSetField(hist_mx,0,"M",ConvertIntScalar(hist_c[0].M));

	vec_mx = mxGetField(hist_mx,0,"vec");
	WriteHist1D((*hist_c).M,(*hist_c).vec,vec_mx);
	mxFree((*hist_c).vec);
}

struct hist1dvec *ReadHist1DVec(mxArray *hist_mx,struct options_entropy *opts)
{
	mxArray *vec_mx,*ent_mx;
	struct hist1dvec *hist_c;

	hist_c = (struct hist1dvec *)mxMalloc(sizeof(struct hist1dvec));

	(*hist_c).P = (int)mxGetScalar(mxGetField(hist_mx,0,"P"));
	(*hist_c).M = (int)mxGetScalar(mxGetField(hist_mx,0,"M"));
	
	vec_mx = mxGetField(hist_mx,0,"vec");
	(*hist_c).vec = ReadHist1D((*hist_c).M,vec_mx,opts);

	mxAddField(hist_mx,"entropy");
	(*hist_c).entropy = (struct estimate *)mxMalloc((*opts).E*sizeof(struct estimate));
	ent_mx = AllocEst((*hist_c).entropy,opts);
	mxSetField(hist_mx,0,"entropy",ent_mx);

	return hist_c;
}

void WriteHist1DVecAgain(struct hist1dvec *hist_c,mxArray *hist_mx)
{
	mxArray *vec_mx,*ent_mx;

	vec_mx = mxGetField(hist_mx,0,"vec");
	WriteHist1DAgain((*hist_c).M,(*hist_c).vec,vec_mx);
	mxFree((*hist_c).vec);

	ent_mx = mxGetField(hist_mx,0,"entropy");
	WriteEst((*hist_c).entropy,ent_mx);
	mxFree((*hist_c).entropy);
}

/*** est ***/

/**
 * @brief Initializes an estimate structure
 * Allocates memory for the C estimate structure est_c, and its Matlab
 * equivalent as the return value, using the entropy options in opts.
 */
mxArray *AllocEst(struct estimate *est_c,struct options_entropy *opts)
{
	const char *est_field_names[] = {"name", "value", "messages", "extras"};
	mxArray *est_mx, *name_temp, *msg_temp, *ve_temp;
	int e;

	/* Create an estimate struct */
	est_mx = mxCreateStructMatrix((*opts).E,1,4,est_field_names);

	if((*opts).var_est_meth_flag>0)
		mxAddField(est_mx,"ve");

	for(e=0; e<(*opts).E; e++)
	{
		if((*opts).ent_est_meth[e]>0)
		{
			/* Fill in estimate name */
			memcpy(est_c[e].name,ent_est_meth_list[(*opts).ent_est_meth[e]-1],MAXCHARS*sizeof(char));
			name_temp = mxCreateCellMatrix(1,1);
			mxSetCell(name_temp,0,mxCreateString(est_c[e].name));
			mxSetField(est_mx,e,"name",name_temp);

			/* Add messages structure */
			est_c[e].messages = (struct message *)mxMalloc(sizeof(struct message));
			msg_temp = AllocMessage(est_c[e].messages);
			mxSetField(est_mx,e,"messages",msg_temp);

			/* Add extras count and structure */
			est_c[e].E = 0;
			est_c[e].extras = NULL;

			/* Add ve count and structure */
			est_c[e].V = opts->V[e];
			if((*opts).V[e]>0)
			{
				est_c[e].ve = (struct nv_pair *)mxMalloc((*opts).V[e]*sizeof(struct nv_pair));
				ve_temp = AllocNameValuePair(est_c[e].ve,var_est_meth_list,(*opts).var_est_meth[e],(*opts).V[e]);
				mxSetField(est_mx,e,"ve",ve_temp);
			}
		}
	}

	return est_mx;
}

mxArray *AllocMessage(struct message *msg_c)
{
	const char *msg_field_names[] = {"status", "warnings", "errors"};

	msg_c->i = msg_c->j = msg_c->k = 0;
	msg_c->status = msg_c->warnings = msg_c->errors = NULL;

	return mxCreateStructMatrix(1,1,3,msg_field_names);
}

mxArray *AllocNameValuePair(struct nv_pair *nv_c,char name_list[][MAXCHARS],int *name_idx,int N)
{
	int n;
	const char *nv_field_names[] = {"name", "value"};
	mxArray *nv_mx,*temp;
	char *temp_string;

	nv_mx = mxCreateStructMatrix(N,1,2,nv_field_names);
	for(n=0; n<N; n++)
	{
		if(name_idx[n]>0)
		{
			temp_string = name_list[name_idx[n]-1];
			
			/* Copy from opts to the C version of the nv structure */
			memcpy(nv_c[n].name,temp_string,MAXCHARS*sizeof(char));
			
			/* Copy from opts to the mx version of the nv structure */
			temp = mxCreateCellMatrix(1,1);
			mxSetCell(temp,0,mxCreateString(temp_string));
			mxSetField(nv_mx,n,"name",temp);
		}
	}
	
	return nv_mx;
}

/**
 * @brief Fill in Matlab estimate structure
 * Write a Matlab estimate structure est_mx with the data from the C estimate
 * structure est_c.
 */
void WriteEst(struct estimate *est_c,mxArray *est_mx)
{
	mxArray *temp_val, *temp_msg, *temp_ext, *temp_ve;
	int e, x;

	for(e=0; e<mxGetNumberOfElements(est_mx); e++)
		if(mxGetField(est_mx,e,"name")!=NULL) 
		{
			/* Set the scalars */
			temp_val = mxCreateDoubleScalar(est_c[e].value);
			mxSetField(est_mx,e,"value",temp_val);

			/* Descend to messages */
			temp_msg = mxGetField(est_mx,e,"messages");
			if(temp_msg!=NULL)
			{
				WriteMessage(est_c[e].messages,temp_msg);
				mxFree(est_c[e].messages);
			}

			/* Descend to extras */
			if(est_c[e].E)
			{
				WriteExtras(est_c[e].E,est_c[e].extras,e,est_mx);
				free(est_c[e].extras);
			}

			/* Descend to NV pairs */
			temp_ve = mxGetField(est_mx,e,"ve");
			if(temp_ve!=NULL)
			{
				WriteNameValuePair(mxGetNumberOfElements(temp_ve),est_c[e].ve,temp_ve);
				mxFree(est_c[e].ve);
			}
		}
}

void WriteMessage(struct message *msg_c,mxArray *msg_mx)
{
	int n;
	mxArray *temp_cell;

	/* Copy messages to new mxArrays */
	if(msg_c->i)
	{
		temp_cell = mxCreateCellMatrix(msg_c->i,1);
		for(n=0; n<msg_c->i; n++)
			mxSetCell(temp_cell,n,mxCreateString(msg_c->status[n]));
		mxSetField(msg_mx,0,"status",temp_cell);
	}
	if(msg_c->j)
	{
		temp_cell = mxCreateCellMatrix(msg_c->j,1);
		for(n=0; n<msg_c->j; n++)
			mxSetCell(temp_cell,n,mxCreateString(msg_c->warnings[n]));
		mxSetField(msg_mx,0,"warnings",temp_cell);
	}
	if(msg_c->k)
	{
		temp_cell = mxCreateCellMatrix(msg_c->k,1);
		for(n=0; n<msg_c->k; n++)
			mxSetCell(temp_cell,n,mxCreateString(msg_c->errors[n]));
		mxSetField(msg_mx,0,"errors",temp_cell);
	}

	/* Free messages in C struct */
	for(n=0; n<msg_c->i; n++)
		free(msg_c->status[n]);
	free(msg_c->status);
	for(n=0; n<msg_c->j; n++)
		free(msg_c->warnings[n]);
	free(msg_c->warnings);
	for(n=0; n<msg_c->k; n++)
		free(msg_c->errors[n]);
	free(msg_c->errors);
}

void WriteExtras(int X,struct nv_pair *ext_c,int e,mxArray *ext_mx)
{
	const char *ext_field_names[] = {"name", "value"};
	int x;
	mxArray *temp_struct, *temp_cell;

	temp_struct = mxCreateStructMatrix(X,1,2,ext_field_names);
	for(x=0; x<X; x++)
	{
		temp_cell = mxCreateCellMatrix(1,1);
		mxSetCell(temp_cell,0,mxCreateString(ext_c[x].name));
		mxSetField(temp_struct,x,"name",temp_cell);
		mxSetField(temp_struct,x,"value",mxCreateDoubleScalar(ext_c[x].value));
	}
	mxSetField(ext_mx,e,"extras",temp_struct);
}

void WriteNameValuePair(int N,struct nv_pair *nv_c,mxArray *nv_mx)
{
	int n;
	mxArray *temp_val;

	for(n=0; n<N; n++)
		if(mxGetField(nv_mx,n,"name")!=NULL)
		{
			temp_val = mxCreateDoubleScalar(nv_c[n].value);
			mxSetField(nv_mx,n,"value",temp_val);
		}
}

