/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../../shared/toolkit_c.h"
#include "../../shared/toolkit_mx.h"
#include "binless_c.h"
#include "binless_mx.h"

struct options_binless *ReadOptionsBinless(const mxArray *in)
{
  struct options_binless *opts;
  mxArray *tmp;
  int stringLength, i;
  char *str;

  opts = (struct options_binless *)mxMalloc(sizeof(struct options_binless));

  opts->t_start_flag = ReadOptionsDoubleMember(in,"start_time",&(opts->t_start));
  opts->t_end_flag = ReadOptionsDoubleMember(in,"end_time",&(opts->t_end));
  opts->w_start_flag = ReadOptionsDoubleMember(in,"start_warp",&(opts->w_start));
  opts->w_end_flag = ReadOptionsDoubleMember(in,"end_warp",&(opts->w_end));
  opts->D_min_flag = ReadOptionsIntMember(in,"min_embed_dim",&(opts->D_min));
  opts->D_max_flag = ReadOptionsIntMember(in,"max_embed_dim",&(opts->D_max));
  opts->warp_strat_flag = ReadOptionsIntMember(in,"warping_strategy",&(opts->warp_strat));
  opts->single_strat_flag = ReadOptionsIntMember(in,"singleton_strategy",&(opts->single_strat));
  opts->strat_strat_flag = ReadOptionsIntMember(in,"stratification_strategy",&(opts->strat_strat));
  opts->D_min_cont_flag = ReadOptionsIntMember(in,"cont_min_embed_dim",&(opts->D_min_cont));
  opts->D_max_cont_flag = ReadOptionsIntMember(in,"cont_max_embed_dim",&(opts->D_max_cont));

  opts->rec_tag_flag = 0; /* assume field is empty */
  tmp = mxGetField(in,0,"recording_tag");
  if(tmp && mxIsChar(tmp)) /* field is string */
  {
    /* copy string and set to lowercase */
    stringLength = mxGetNumberOfElements(tmp) + 1;
    str = (char *)mxCalloc(stringLength,sizeof(char));
    if(mxGetString(tmp,str,stringLength)!=0)
      mexErrMsgIdAndTxt("STAToolkit:ReadOptionsBinless:invalidValue","Option recording_tag is not valid string data.");
    for(i=0; str[i]; i++)
      str[i] = tolower(str[i]);

    /* use string to set member value */
    if(strcmp(str,"episodic")==0)
      opts->rec_tag = 0;
    else if(strcmp(str,"continuous")==0)
      opts->rec_tag = 1;
    else
    {
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsBinless:invalidValue","Unrecognized option \"%s\" for recording_tag. Using default \"episodic\".",str);
      opts->rec_tag = (int)DEFAULT_REC_TAG;
    }
    opts->rec_tag_flag = 1;

    mxFree(str);
  }

  return opts;
}

mxArray *WriteOptionsBinless(const mxArray *in,struct options_binless *opts)
{
  mxArray *out;

  out = mxDuplicateArray(in);

  WriteOptionsDoubleMember(out,"start_time",opts->t_start,opts->t_start_flag);
  WriteOptionsDoubleMember(out,"end_time",opts->t_end,opts->t_end_flag);
  WriteOptionsDoubleMember(out,"start_warp",opts->w_start,opts->w_start_flag);
  WriteOptionsDoubleMember(out,"end_warp",opts->w_end,opts->w_end_flag);
  WriteOptionsIntMember(out,"min_embed_dim",opts->D_min,opts->D_min_flag);
  WriteOptionsIntMember(out,"max_embed_dim",opts->D_max,opts->D_max_flag);
  WriteOptionsIntMember(out,"warping_strategy",opts->warp_strat,opts->warp_strat_flag);
  WriteOptionsIntMember(out,"singleton_strategy",opts->single_strat,opts->single_strat_flag);
  WriteOptionsIntMember(out,"stratification_strategy",opts->strat_strat,opts->strat_strat_flag);
  WriteOptionsIntMember(out,"cont_min_embed_dim",opts->D_min_cont,opts->D_min_cont_flag);
  WriteOptionsIntMember(out,"cont_max_embed_dim",opts->D_max_cont,opts->D_max_cont_flag);

  if(opts->rec_tag_flag)
    if(opts->rec_tag==0)
      mxAddAndSetField(out,0,"recording_tag",mxCreateString("episodic"));
    else if(opts->rec_tag==1)
      mxAddAndSetField(out,0,"recording_tag",mxCreateString("continuous"));
    else
      mxAddAndSetField(out,0,"recording_tag",mxCreateString("error"));

  mxFree(opts);

  return out;
}
void ReadOptionsWarpRange(struct options_binless *opts)
{
  if(opts->w_start_flag==0)
    {
      opts->w_start = (double)DEFAULT_START_WARP;
      opts->w_start_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsWarpRange:missingParameter","Missing parameter start_warp. Using default value %f.\n",(*opts).w_start);
    }

  if(opts->w_end_flag==0)
    {
      opts->w_end = (double)DEFAULT_END_WARP;
      opts->w_end_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsWarpRange:missingParameter","Missing parameter end_warp. Using default value %f.\n",(*opts).w_end);
    }

  if((*opts).w_start>(*opts).w_end)
     mexErrMsgIdAndTxt("STAToolkit:ReadOptionsWarpRange:badRange","Lower limit greater than upper limit for start_warp and end_warp.\n");
}

void ReadOptionsEmbedRange(struct options_binless *opts)
{
  if(opts->rec_tag_flag && (opts->rec_tag==1)) /* continuous data */
    {
      if(opts->D_min_cont_flag==0)
        {
          opts->D_min_cont = (int)DEFAULT_CONT_MIN_EMBED_DIM;
          opts->D_min_cont_flag=1;
          mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEmbedRange:missingParameter","Missing parameter cont_min_embed_dim. Using default value %d.\n",(*opts).D_min_cont);
        }

      if(opts->D_max_cont_flag==0)
        {
          opts->D_max_cont = (int)DEFAULT_CONT_MAX_EMBED_DIM;
          opts->D_max_cont_flag=1;
          mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEmbedRange:missingParameter","Missing parameter cont_max_embed_dim. Using default value %d.\n",(*opts).D_max_cont);
        }

      if((*opts).D_min_cont>(*opts).D_max_cont)
        mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEmbedRange:badRange","Lower limit %d greater than upper limit %d for cont_min_embed_dim and cont_max_embed_dim.\n",(*opts).D_min_cont,(*opts).D_max_cont);
    }
  else /* episodic (or unspecified) data */
    {
      if(opts->D_min_flag==0)
        {
          opts->D_min = (int)DEFAULT_MIN_EMBED_DIM;
          opts->D_min_flag=1;
          mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEmbedRange:missingParameter","Missing parameter min_embed_dim. Using default value %d.\n",(*opts).D_min);
        }

      if(opts->D_max_flag==0)
        {
          opts->D_max = (int)DEFAULT_MAX_EMBED_DIM;
          opts->D_max_flag=1;
          mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsEmbedRange:missingParameter","Missing parameter max_embed_dim. Using default value %d.\n",(*opts).D_max);
        }

      if((*opts).D_min>(*opts).D_max)
        mexErrMsgIdAndTxt("STAToolkit:ReadOptionsEmbedRange:badRange","Lower limit %d greater than upper limit %d for min_embed_dim and max_embed_dim.\n",(*opts).D_min,(*opts).D_max);
    }
}

void ReadOptionsBinlessTimeRange(struct options_binless *opts,struct input *X)
{
  if(opts->t_start_flag==0)
    {
      opts->t_start = GetStartTime(X);
      opts->t_start_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsTimeRange:missingParameter","Missing parameter start_time. Extracting from input: %f.\n",opts->t_start);
    }

  if(opts->t_end_flag==0)
    {
      opts->t_end = GetEndTime(X);
      opts->t_end_flag=1;
      mexWarnMsgIdAndTxt("STAToolkit:ReadOptionsTimeRange:missingParameter","Missing parameter end_time. Extracting from input: %f.\n",opts->t_end);
    }

  if((opts->t_start)>(opts->t_end))
      mexErrMsgIdAndTxt("STAToolkit:ReadOptionsTimeRange:badRange","Lower limit greater than upper limit for start_time and end_time.\n");
}

