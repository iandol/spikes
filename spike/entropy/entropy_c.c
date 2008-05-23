/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../shared/toolkit_c.h"
/* #define DEBUG */

/* Here's some global variables */

char ent_est_meth_list[ENT_EST_METHS][MAXCHARS] = {"plugin", "tpmc", "jack", "ma","bub","chaoshen","ww"};
char var_est_meth_list[GEN_VAR_EST_METHS+SPEC_VAR_EST_METHS][MAXCHARS] = {"jack","boot"};

int Entropy1DComp(int M,struct hist1d *in,struct options_entropy *opts)
{
  int m,v,e;
  double (*entropy_fun[ENT_EST_METHS+1])(struct hist1d *,struct options_entropy *);
  double (*specific_variance_fun[SPEC_VAR_EST_METHS+1])(struct hist1d *,struct options_entropy *);
  double (*general_variance_fun[GEN_VAR_EST_METHS])(struct hist1d *,
						      double (*entropy_fun)(struct hist1d *, struct options_entropy *),
						      struct options_entropy *);

  entropy_fun[0] = entropy_null;
  entropy_fun[1] = entropy_plugin;
  entropy_fun[2] = entropy_tpmc;
  entropy_fun[3] = entropy_jack;
  entropy_fun[4] = entropy_ma;
  entropy_fun[5] = entropy_bub;
  entropy_fun[6] = entropy_chaoshen;
  entropy_fun[7] = entropy_ww;

  specific_variance_fun[0] = variance_null;
  general_variance_fun[0] = variance_jack;
  general_variance_fun[1] = variance_boot;

  for(m=0;m<M;m++)
    {
      for(e=0;e<opts->E;e++)
	{
#ifdef DEBUG
	  printf("\n(*opts).ent_est_meth[%d]=%d\n",e,(*opts).ent_est_meth[e]);
#endif
	  if((*opts).ent_est_meth[e]>0) 
	    {
#ifdef DEBUG
	      printf("Applying entropy method ent_est_meth_list[%d]=\"%s\".\n",(*opts).ent_est_meth[e]-1,ent_est_meth_list[(*opts).ent_est_meth[e]-1]);
#endif
	      in[m].entropy[e].value = entropy_fun[(*opts).ent_est_meth[e]](&in[m],opts);

	      for(v=0;v<opts->V[e];v++)
		{
#ifdef DEBUG
		  printf("(*opts).var_est_meth[%d][%d]=%d\n",e,v,(*opts).var_est_meth[e][v]);
#endif
		  if((*opts).var_est_meth[e][v]<=SPEC_VAR_EST_METHS)
		    {
#ifdef DEBUG
		      if((*opts).var_est_meth[e][v]==0)
			printf("Unrecognized specific variance method.\n");
		      else if((*opts).ent_est_meth[e]==0)
			printf("Unrecognized entropy method.\n");
		      else
			printf("Applying specific method var_est_meth_list[%d]=\"%s\".\n",(*opts).var_est_meth[e][v]-1,var_est_meth_list[(*opts).var_est_meth[e][v]-1]);
#endif
		      in[m].entropy[e].ve[v].value = specific_variance_fun[(*opts).var_est_meth[e][v]](&in[m],opts);
		    }
		  else
		    {
#ifdef DEBUG
		      if((*opts).var_est_meth[e][v]==0)
			printf("Unrecognized general variance method.\n");
		      else if((*opts).ent_est_meth[e]==0)
			printf("Unrecognized entropy method.\n");
		      else
			printf("Applying general method var_est_meth_list[%d]=\"%s\" using entropy method ent_est_meth_list[%d]=\"%s\".\n",(*opts).var_est_meth[e][v]-1,var_est_meth_list[(*opts).var_est_meth[e][v]-1],(*opts).ent_est_meth[e]-1,ent_est_meth_list[(*opts).ent_est_meth[e]-1]);
#endif
		      in[m].entropy[e].ve[v].value = 
			general_variance_fun[(*opts).var_est_meth[e][v]-SPEC_VAR_EST_METHS-1](&in[m],entropy_fun[(*opts).ent_est_meth[e]],opts);
		    }
		}
	    }
	}
    }
  
  return EXIT_SUCCESS;
}

double EntropyPlugin(struct hist1d *in)
{
  double H;
  double N,*cnt;
  int i,m;

  N = (double) (*in).P;
  m = (*in).C;
  cnt = (*in).wordcnt;

  H=0;
  for(i=0;i<m;i++)
    H += XLOG2X(cnt[i]/N);
  
  return H;
}

double max_possible_words(struct hist1d *in)
{
  int max_bin,c,n;
  double m;

  max_bin = 0;
  for(c=0;c<(*in).C;c++)
    for(n=0;n<(*in).N;n++)
      if((*in).wordlist[c][n]>max_bin)
	max_bin = (*in).wordlist[c][n];
  max_bin++;
  m = MIN(pow((double)max_bin,(double)(*in).N),(double)(*in).P);

#ifdef DEBUG
  printf("(*in).P=%d (*in).C=%d max_bin=%d (*in).N=%d m=%f\n",(*in).P,(*in).C,max_bin,(*in).N,m);
#endif

  return m;
}

double entropy_null(struct hist1d *in,struct options_entropy *opts)
{
  printf("STAToolkit:entropy1d:unrecognizedOption: Unrecognized entropy estimation technique\n");
  
  return 0;
}

double variance_null(struct hist1d *in,struct options_entropy *opts)
{
  printf("STAToolkit:entropy1d:unrecognizedOption: Unrecognized variance estimation technique\n");
  
  return 0;
}

