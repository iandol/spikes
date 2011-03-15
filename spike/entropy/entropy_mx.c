/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../shared/toolkit_c.h"
#include "../shared/toolkit_mx.h"
/* #define DEBUG */

extern char ent_est_meth_list[ENT_EST_METHS][MAXCHARS];
extern char var_est_meth_list[GEN_VAR_EST_METHS+SPEC_VAR_EST_METHS][MAXCHARS];

/*****************************************************/
/* The primary purpose of this functon is to populate
   (*opts).ent_est_meth[] and (*opts).var_est_meth[] */
/****************************************************/

struct options_entropy *ReadOptionsEntropy(const mxArray *in)
{
  struct options_entropy *opts;
  mxArray *ve_temp,*ent_temp;
  char temp_string[MAXCHARS],temp_string2[MAXCHARS];
  int i,j,e,v,cur_e,e_flag,cur_ent_est_meth,match_flag;
  void (*entropy_fun[ENT_EST_METHS+1])(const mxArray *,struct options_entropy *);
  void (*variance_fun[GEN_VAR_EST_METHS+SPEC_VAR_EST_METHS+1])(const mxArray *,struct options_entropy *);
  char us[] = "_";
  char *first;

  opts = (struct options_entropy *)mxMalloc(sizeof(struct options_entropy));

  /*** Entropy estimation ***/

  /* shared options */
  opts->useall_flag = ReadOptionsIntMember(in,"unoccupied_bins_strategy",&(opts->useall));
  opts->possible_words_flag = ReadOptionPossibleWords(in,"possible_words",&(opts->possible_words));

  /* Which entropy estimate methods were requested? */
  ent_temp = mxGetField(in,0,"entropy_estimation_method");
  if((ent_temp==NULL) || mxIsEmpty(ent_temp))
    opts->E = 0;
  else
    {
      opts->E = mxGetNumberOfElements(ent_temp);
      opts->ent_est_meth = (int *)mxCalloc(opts->E,sizeof(int));
      for(e=0;e<opts->E;e++)
	{
	  if(mxGetCell(ent_temp,e)!=NULL)
	    {
	      CellArrayElementToCString(ent_temp,e,temp_string);
	      for(i=0;i<ENT_EST_METHS;i++) 
		{
		  if(strcmp(temp_string,ent_est_meth_list[i])==0)
		    opts->ent_est_meth[e] = i+1;
#ifdef DEBUG
		  printf("temp_string=\"%s\" ent_est_meth_list[%d]=\"%s\" opts->ent_est_meth[%d]=%d\n",temp_string,i,ent_est_meth_list[i],e,opts->ent_est_meth[e]);
#endif
		}
	    }
	}
    }

  if(opts->E==0)
    {
      opts->E=1;
      opts->ent_est_meth = (int *)mxCalloc(1,sizeof(int));
      opts->ent_est_meth[0] = 1; /* Make plugin the default */
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:missingOption","Entropy estimation method not specified. Using \"plugin\".\n"); 
    }
  
  /* variance estimation */
  ve_temp = mxGetField(in,0,"variance_estimation_method");
  opts->V = (int *)mxCalloc(opts->E,sizeof(int));
  if((ve_temp==NULL) || mxIsEmpty(ve_temp))
    opts->var_est_meth_flag = 0;
  else
    {
      opts->var_est_meth_flag = mxGetNumberOfElements(ve_temp);
      opts->var_est_meth = mxMatrixInt(opts->E,GEN_VAR_EST_METHS+SPEC_VAR_EST_METHS);

      for(v=0;v<opts->var_est_meth_flag;v++)
	{
	  if(mxGetCell(ve_temp,v)!=NULL)
	    {
	      /* Look for the method in the master list */
	      CellArrayElementToCString(ve_temp,v,temp_string);
	      strcpy(temp_string2,temp_string);
	      match_flag = 0;
	      for(i=0;i<GEN_VAR_EST_METHS+SPEC_VAR_EST_METHS;i++)
		{
		  /* If the method is in the master list */
		  if(strcmp(temp_string,var_est_meth_list[i])==0)
		    {
		      match_flag=1;
		      /* Does it have an underscore (95) in its name? */
		      /* If so, it's a method-specific VEM */
		      if(strchr(temp_string,95)!=NULL) 
			{
			  /* Parse the name to find out which element of V to increment */
			  /* And which row of var_est_meth to populate */
			  first = strtok(temp_string,us);

			  /* Get the index from the master list */
			  cur_ent_est_meth = 0;
			  for(j=0;j<ENT_EST_METHS;j++)
			    {
			      if(strcmp(first,ent_est_meth_list[j])==0)
				cur_ent_est_meth = j+1;
			    }

			  /*  Look for entropy method in ent_est_meth */
			  e_flag=0;
			  for(e=0;e<opts->E;e++)
			    if(opts->ent_est_meth[e]==cur_ent_est_meth)
			      {
				cur_e=e;
				e_flag=1;
			      }

			  /* If you find it, add it to the appropriate
			     row in var_ent_est_meth and increment the 
			     element in V */
			  if(e_flag)
			    {
			      opts->var_est_meth[cur_e][opts->V[cur_e]] = i+1;
#ifdef DEBUG
			      printf("temp_string=\"%s\" var_est_meth_list[%d]=\"%s\" opts->var_est_meth[%d][%d]=%d\n",temp_string,i,var_est_meth_list[i],cur_e,opts->V[cur_e],opts->var_est_meth[cur_e][opts->V[cur_e]]);
#endif
			      opts->V[cur_e]++;
			    }
			  else
			    mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidMethod","The variance estimation method \"%s\" corresponds to an entropy_estimation_method \"%s\" that was not requested or is not valid.\n",temp_string2,first);
			}

		      /* If there's no underscore it's a general VEM */
		      else 
			{
			  /* Increment all elements of V */
			  /* Populate all rows of var_est_meth */
			  for(e=0;e<opts->E;e++)
			    {
			      opts->var_est_meth[e][opts->V[e]] = i+1;
#ifdef DEBUG
			      printf("temp_string=\"%s\" var_est_meth_list[%d]=\"%s\" opts->var_est_meth[%d][%d]=%d\n",temp_string,i,var_est_meth_list[i],e,opts->V[e],opts->var_est_meth[e][opts->V[e]]);
#endif
			      opts->V[e]++;
			    }
			}
		    }
		}
	      if(match_flag==0)
		mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEntropy:invalidMethod","\"%s\" is not a valid variance_estimation_method.\n",temp_string2);
	    }
	}
    }

  entropy_fun[0] = read_options_entropy_null;
  entropy_fun[1] = read_options_entropy_null;
  entropy_fun[2] = read_options_entropy_tpmc;
  entropy_fun[3] = read_options_entropy_null;
  entropy_fun[4] = read_options_entropy_null;
  entropy_fun[5] = read_options_entropy_bub;
  entropy_fun[6] = read_options_entropy_null;
  entropy_fun[7] = read_options_entropy_ww;
  entropy_fun[8] = read_options_entropy_nsb;

  variance_fun[0] = read_options_variance_null; /* unknown method */
  variance_fun[1] = read_options_variance_null; /* nsb_var */
  variance_fun[2] = read_options_variance_null; /* jack */
  variance_fun[3] = read_options_variance_boot; /* boot */

  for(e=0;e<opts->E;e++)
    {
      entropy_fun[(*opts).ent_est_meth[e]](in,opts);
      for(v=0;v<opts->V[e];v++)
	variance_fun[(*opts).var_est_meth[e][v]](in,opts);
    }

  return opts;
}

mxArray *WriteOptionsEntropy(const mxArray *in,struct options_entropy *opts)
{
  mxArray *out;
  mxArray *ve_temp,*ent_temp;
  int i,e,v,temp;
  mxArray *(*entropy_fun[ENT_EST_METHS+1])(const mxArray *,struct options_entropy *);
  mxArray *(*variance_fun[GEN_VAR_EST_METHS+SPEC_VAR_EST_METHS+1])(const mxArray *,struct options_entropy *);
  int *temp_var_est_meth,*uni_temp_var_est_meth,*uni_i,*uni_j,*cnt;
  int U;

  temp_var_est_meth = (int *)mxMalloc(ENT_EST_METHS*(GEN_VAR_EST_METHS+SPEC_VAR_EST_METHS)*sizeof(int));

  out = mxDuplicateArray(in);

  /* shared */
  WriteOptionsIntMember(out,"unoccupied_bins_strategy",opts->useall,opts->useall_flag);
  WriteOptionPossibleWords(out,"possible_words",opts->possible_words,opts->possible_words_flag);

  /* entropy estimation */
  ent_temp = mxCreateCellMatrix(1,opts->E);
  i=0;
  for(e=0;e<opts->E;e++)
    {
      if(opts->ent_est_meth[e]>0) 
	{
	  temp = opts->ent_est_meth[e]-1;
	  CStringToCellArrayElement(ent_est_meth_list[temp],e,ent_temp);
#ifdef DEBUG
	  printf("ent_est_meth_list[%d]=\"%s\"\n",temp,ent_est_meth_list[temp]);
#endif
	  for(v=0;v<opts->V[e];v++)
	    {
	      temp_var_est_meth[i] = opts->var_est_meth[e][v];
	      i++;
	    }
	}
    }

  /* Once we have the unique list, we can regenerate variance_entropy_estimate */
  if((opts->var_est_meth_flag)>0)
    {
      uni_temp_var_est_meth = (int *)mxCalloc(i,sizeof(int));
      uni_i = (int *)mxCalloc(i,sizeof(int));
      uni_j = (int *)mxCalloc(i,sizeof(int));
      cnt = (int *)mxCalloc(i,sizeof(int));
      U = UniqueInt(i,temp_var_est_meth,uni_temp_var_est_meth,uni_i,uni_j,cnt);
      ve_temp = mxCreateCellMatrix(1,U);
      for(v=0;v<U;v++)
	{
	  temp = uni_temp_var_est_meth[v]-1;
	  if(temp>=0)
	    {
	      CStringToCellArrayElement(var_est_meth_list[temp],v,ve_temp);
#ifdef DEBUG
	      printf("var_est_meth_list[%d]=\"%s\"\n",temp,var_est_meth_list[temp]);
#endif
	    }
	}
      mxFree(uni_temp_var_est_meth);
      mxFree(uni_i);
      mxFree(uni_j);
      mxFree(cnt);
    }
  mxFree(temp_var_est_meth);

  entropy_fun[0] = write_options_entropy_null;
  entropy_fun[1] = write_options_entropy_null;
  entropy_fun[2] = write_options_entropy_tpmc;
  entropy_fun[3] = write_options_entropy_null;
  entropy_fun[4] = write_options_entropy_null;
  entropy_fun[5] = write_options_entropy_bub;
  entropy_fun[6] = write_options_entropy_null;
  entropy_fun[7] = write_options_entropy_ww;
  entropy_fun[8] = write_options_entropy_nsb;

  variance_fun[0] = write_options_variance_null; /* unknown method */
  variance_fun[1] = write_options_variance_null; /* nsb_var */
  variance_fun[2] = write_options_variance_null; /* jack */
  variance_fun[3] = write_options_variance_boot; /* boot */

  /* hand off option writing to each entropy and variance function in turn */
  for(e=0;e<opts->E;e++)
    {
      out = entropy_fun[(*opts).ent_est_meth[e]](out,opts);
      for(v=0;v<opts->V[e];v++)
        out = variance_fun[(*opts).var_est_meth[e][v]](out,opts);
    }

  if((opts->E)>0) 
    {
      mxFree(opts->ent_est_meth);
      mxAddAndSetField(out,0,"entropy_estimation_method",ent_temp);
    }

  if((opts->var_est_meth_flag)>0) 
    {
      mxFreeMatrixInt(opts->var_est_meth);
      mxAddAndSetField(out,0,"variance_estimation_method",ve_temp);
    }

  mxFree(opts->V);
  mxFree(opts);
  
  return out;
}

void read_options_entropy_null(const mxArray *in,struct options_entropy *opts)
{
}

mxArray *write_options_entropy_null(const mxArray *in,struct options_entropy *opts)
{
  mxArray *out;

  out = mxDuplicateArray(in);

  return out;
}

void read_options_variance_null(const mxArray *in,struct options_entropy *opts)
{
}

mxArray *write_options_variance_null(const mxArray *in,struct options_entropy *opts)
{
  mxArray *out;

  out = mxDuplicateArray(in);

  return out;
}
