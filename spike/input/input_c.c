/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
#include "../shared/toolkit_c.h"

#define LEN 10000
#define TRACE_ATTR 5
#define SITE_ATTR 6
#define SITE_ATTR_REQ 4
#define CAT_ATTR 1
/* #define DEBUG */

int GetNumTrials(struct input *X)
{
  int m;
  int P_total=0;
  
  for(m=0;m<(*X).M;m++)
    P_total+=(*X).categories[m].P;

  return P_total;
}

int GetMaxSpikes(struct input *X)
{
  int m,p,n,max_Q;
  
  max_Q=0;
  for(m=0;m<(*X).M;m++)
    for(p=0;p<(*X).categories[m].P;p++)
      for(n=0;n<(*X).N;n++)
	if((*X).categories[m].trials[p][n].Q>max_Q)
	  max_Q = (*X).categories[m].trials[p][n].Q;

  return max_Q;
}

double GetStartTime(struct input *X)
{
  int m,p,n;
  double t_start,cur_t_start;
  
  t_start = -HUGE_VAL;
  for(m=0;m<(*X).M;m++)
    for(p=0;p<(*X).categories[m].P;p++)
      for(n=0;n<(*X).N;n++)
	{
	  cur_t_start = (*X).categories[m].trials[p][n].start_time*(*X).sites[n].time_scale;
	  if(cur_t_start>t_start)
	    t_start = cur_t_start;
	}
  
  return t_start;
}

double GetEndTime(struct input *X)
{
  int m,p,n;
  double t_end,cur_t_end;
  
  t_end = HUGE_VAL;
  for(m=0;m<(*X).M;m++)
    for(p=0;p<(*X).categories[m].P;p++)
      for(n=0;n<(*X).N;n++)
	{
	  cur_t_end = (*X).categories[m].trials[p][n].end_time*(*X).sites[n].time_scale;
	  if(cur_t_end<t_end)
	    t_end = cur_t_end;
	}
  
  return t_end;
}

int staReadComp(char *stamfile, struct input *X)
{
  FILE *fid;
  char *line;
  char firstchar;
  char *temp,*temp2;
  char *firstword;
  const char eq[] = "=";
  const char sc[] = ";";
  const char sp[] = " ";
  const char spnl[] = " \n";
  int i,j,m,n,p,q;
  int P_total;
  char **nm,**vl;
  int cur_n,cur_m=0;
  char stadfile[MAXPATH];
  int *m_vec,*p_vec,*n_vec,*q_vec;
  double *start_time_vec,*end_time_vec;
  double *cur_list;
  int linecnt;
  unsigned int read_length = LEN;

  /* First, read in metadata */
#ifdef DEBUG
  printf("stamfile=\"%s\"\n",stamfile);
#endif

  fid = fopen(stamfile,"r");
  if(fid==NULL)
    {
      printf("Cannot find .stam file: %s. Please check the path.\n",stamfile);
      free(X);
      return EXIT_FAILURE;
    }

  nm = (char **)malloc(MAX(MAX(TRACE_ATTR,SITE_ATTR),CAT_ATTR)*sizeof(char *));
  vl = (char **)malloc(MAX(MAX(TRACE_ATTR,SITE_ATTR),CAT_ATTR)*sizeof(char *));

  line = (char *)malloc(read_length*sizeof(char)); 

  /*************************************************************/
  /*** Pass 1: Determine the number of sites and categories. ***/
  /*************************************************************/

  (*X).M=0;
  (*X).N=0;

  while(fgets(line,read_length,fid) != NULL)
    {
      sscanf(line,"%c",&firstchar);

      /* If it's a #, we have a comment */
      if(firstchar!='#')
	{
	  /* Copy the line into a working copy */
	  temp = strdup(line);
	  
	  /* Read in the text leading up to the first "=" */
	  firstword = strtok(temp,eq);  
	  if(strcmp(firstword,"datafile")==0)
	    strcpy(stadfile,strtok(NULL,sc));	  
	  else if(strcmp(firstword,"site")==0)
	    (*X).N++;
	  else if(strcmp(firstword,"category")==0)
	    (*X).M++;
	}
    }

  fclose(fid);

#ifdef DEBUG
  printf("stadfile=\"%s\"\n",stadfile);
  printf("(*X).N=%d (*X).M=%d\n",(*X).N,(*X).M);
#endif

  /* Allocate memory for sites and categories */
  (*X).sites = (struct site *)malloc((*X).N*sizeof(struct site));
  (*X).categories = (struct category *)malloc((*X).M*sizeof(struct category));
  for(n=0;n<(*X).N;n++) /* initialize optional fields */
    {
      strcpy((*X).sites[n].si_unit,"none");
      (*X).sites[n].si_prefix = 1.0;
    }
  
  /****************************************************************/
  /*** Pass 2: Read in metadata about sites and categories.     ***/
  /***         Determine the number of trials in each category. ***/
  /****************************************************************/

  for(m=0;m<(*X).M;m++)
    (*X).categories[m].P=0;

  fid = fopen(stamfile,"r");

  linecnt=1;
  while(fgets(line,read_length,fid) != NULL)
    {
      sscanf(line,"%c",&firstchar);

      /* If it's a #, we have a comment */
      if(firstchar!='#')
	{
	  /* Copy the line into a working copy */
	  temp = strdup(line);
	  
	  /* Read in the text leading up to the first "=" */
	  firstword = strtok(temp,eq);  

	  /*******************************/
	  /* If the first word is site */
	  /*******************************/
	  if(strcmp(firstword,"site")==0)
	    {
	      cur_n = atoi(strtok(NULL,sc))-1; /* Get the site index */
	      for(i=0;i<SITE_ATTR;i++)
		{
		  nm[i] = strtok(NULL,eq);
		  vl[i] = strtok(NULL,sc);
		  if((i<SITE_ATTR_REQ) && ((nm[i]==NULL) || (vl[i]==NULL)))
		    {
		      printf("Malformed site in line %d in %s.\n",linecnt,stamfile);
                      free(nm);
                      free(vl);
                      free(line);
                      free((*X).sites);
                      free((*X).categories);
                      free(X);
		      return EXIT_FAILURE;
		    }
		}

	      /* Pull off leading whitespace of the name if it is there */
	      for(i=0;i<SITE_ATTR;i++)
                {
		  nm[i] = strtok(nm[i],spnl);
#ifdef DEBUG
		  printf("nm[%d]='%s'    vl[%d]='%s'\n",i,nm[i],i,vl[i]);
#endif
                }

	      /* Find out which name/value pairs are what */
	      for(i=0;i<SITE_ATTR;i++)
		if(nm[i])
		{
		  if(strcmp(nm[i],"label")==0)
		    strcpy((*X).sites[cur_n].label,vl[i]);
		  else if(strcmp(nm[i],"recording_tag")==0)
		    strcpy((*X).sites[cur_n].recording_tag,vl[i]);
		  else if(strcmp(nm[i],"time_scale")==0)
		    (*X).sites[cur_n].time_scale = atof(vl[i]);
		  else if(strcmp(nm[i],"time_resolution")==0)
		    (*X).sites[cur_n].time_resolution = atof(vl[i]);
		  else if(strcmp(nm[i],"si_unit")==0)
		    strcpy((*X).sites[cur_n].si_unit,vl[i]);
		  else if(strcmp(nm[i],"si_prefix")==0)
		    (*X).sites[cur_n].si_prefix = atof(vl[i]);
		  else
		    {
		      printf("Malformed site in line %d in %s.\n",linecnt,stamfile);
                      free(nm);
                      free(vl);
                      free(line);
                      free((*X).sites);
                      free((*X).categories);
                      free(X);
		      return EXIT_FAILURE;
		    }
		}
	    }

	  /***********************************/
	  /* If the first word is category */
	  /***********************************/
	  else if(strcmp(firstword,"category")==0)
	    {
	      cur_m = atoi(strtok(NULL,sc))-1; /* Get the cat index */
	      for(i=0;i<CAT_ATTR;i++)
		{
		  nm[i] = strtok(NULL,eq);
		  vl[i] = strtok(NULL,sc);
		  if((nm[i]==NULL) | (vl[i]==NULL))
		    {
		      printf("Malformed category in line %d in %s.\n",linecnt,stamfile);
                      free(nm);
                      free(vl);
                      free(line);
                      free((*X).sites);
                      free((*X).categories);
                      free(X);
		      return EXIT_FAILURE;
		    }
		}

	      /* Pull off leading whitespace of the name if it is there */
	      for(i=0;i<CAT_ATTR;i++)
		nm[i] = strtok(nm[i],sp);

	      /* Find out which name/value pairs are what */
	      for(i=0;i<CAT_ATTR;i++)
		{
		  if(strcmp(nm[i],"label")==0)
		    strcpy((*X).categories[cur_m].label,vl[i]);
		  else
		    {
		      printf("Malformed category in line %d in %s.\n",linecnt,stamfile);
                      free(nm);
                      free(vl);
                      free(line);
                      free((*X).sites);
                      free((*X).categories);
                      free(X);
		      return EXIT_FAILURE;
		    }
		}
	    }

	  /******************************/
	  /* If the first word is trace */
	  /******************************/
	  else if(strcmp(firstword,"trace")==0)
	    {
	      /* Now parse the line */
	      temp2 = strtok(NULL,sc); /* Get the trace index */
	      for(i=0;i<TRACE_ATTR;i++)
		{
		  nm[i] = strtok(NULL,eq);
		  vl[i] = strtok(NULL,sc);
		  if((nm[i]==NULL) | (vl[i]==NULL))
		    {
		      printf("Malformed trace in line %d in %s.\n",linecnt,stamfile);
                      free(nm);
                      free(vl);
                      free(line);
                      free((*X).sites);
                      free((*X).categories);
                      free(X);
		      return EXIT_FAILURE;
		    }
		}

	      /* Pull off leading whitespace of the name if it is there */
	      for(i=0;i<TRACE_ATTR;i++)
		nm[i] = strtok(nm[i],sp);
	      
	      /* Find out which name/value pairs are what */
	      for(i=0;i<TRACE_ATTR;i++)
		if(strcmp(nm[i],"catid")==0)
		  cur_m = atoi(vl[i])-1;
	      
	      /* Because we only want to count multi-site trials once... */
	      for(i=0;i<TRACE_ATTR;i++)
		if(strcmp(nm[i],"siteid")==0)
		  if(atoi(vl[i])==1)
		    (*X).categories[cur_m].P++;
	    }
	}
      linecnt++;
    }

  fclose(fid);
  
#ifdef DEBUG  
  for(n=0;n<(*X).N;n++)
    printf("(*X).sites[%d].label=\"%s\" (*X).sites[%d].recording_tag=\"%s\"\n",n,(*X).sites[n].label,n,(*X).sites[n].recording_tag);

  for(m=0;m<(*X).M;m++)
    printf("(*X).categories[%d].label=\"%s\" (*X).categories[%d].P=%d\n",m,(*X).categories[m].label,m,(*X).categories[m].P);
#endif

  /* Now allocate memory for trials */
  for(m=0;m<(*X).M;m++)
    {
      (*X).categories[m].trials = (struct trial **)malloc((*X).categories[m].P*sizeof(struct trial *));
      for(p=0;p<(*X).categories[m].P;p++)
	(*X).categories[m].trials[p] = (struct trial *)malloc((*X).N*sizeof(struct trial));
    }

  /* Count the total number of traces */
  P_total=0;
  for(m=0;m<(*X).M;m++)
    for(p=0;p<(*X).categories[m].P;p++)
      for(n=0;n<(*X).N;n++)
	P_total++;

  /**********************************************/
  /*** Pass 3: Read in metadata about trials. ***/
  /**********************************************/

  fid = fopen(stamfile,"r");

  /* Allocate memory for vectors */
  p_vec = (int *)malloc(P_total*sizeof(int));
  m_vec = (int *)malloc(P_total*sizeof(int));
  n_vec = (int *)malloc(P_total*sizeof(int));
  start_time_vec = (double *)malloc(P_total*sizeof(double));
  end_time_vec = (double *)malloc(P_total*sizeof(double));

  linecnt=1;
  while(fgets(line,read_length,fid) != NULL)
    {
      sscanf(line,"%c",&firstchar);

      /* If it's a #, we have a comment */
      if(firstchar!='#')
	{
	  /* Copy the line into a working copy */
	  temp = strdup(line);
	  
	  /* Read in the text leading up to the first "=" */
	  firstword = strtok(temp,eq);  
	  if(strcmp(firstword,"trace")==0)
	    {
	      /* Now parse the line */
	      j = atoi(strtok(NULL,sc))-1; /* Get the trace index */
	      for(i=0;i<TRACE_ATTR;i++)
		{
		  nm[i] = strtok(NULL,eq);
		  vl[i] = strtok(NULL,sc);
		}

	      /* Pull off leading whitespace of the name if it is there */
	      for(i=0;i<TRACE_ATTR;i++)
		nm[i] = strtok(nm[i],sp);

	      /* Find out which name/value pairs are what */
	      for(i=0;i<TRACE_ATTR;i++)
		{
		  if(strcmp(nm[i],"catid")==0)
		    m_vec[j] = atoi(vl[i])-1;
		  else if(strcmp(nm[i],"trialid")==0)
		    p_vec[j] = atoi(vl[i])-1;
		  else if(strcmp(nm[i],"siteid")==0)
		    n_vec[j] = atoi(vl[i])-1;
		  else if(strcmp(nm[i],"start_time")==0)
		    start_time_vec[j] = atof(vl[i]);
		  else if(strcmp(nm[i],"end_time")==0)
		    end_time_vec[j] = atof(vl[i]);
		  else
		    {
		      printf("Malformed trace in line %d.\n",linecnt);
                      free(nm);
                      free(vl);
                      free(line);
                      free((*X).sites);
                      for(m=0;m<(*X).M;m++)
                        {
                          for(p=0;p<(*X).categories[m].P;p++)
                            free((*X).categories[m].trials[p]);
                          free((*X).categories[m].trials);
                        }
                      free((*X).categories);
                      free(X);
                      free(p_vec);
                      free(m_vec);
                      free(n_vec);
                      free(start_time_vec);
                      free(end_time_vec);
		      return EXIT_FAILURE;
		    }	
		}
	    }
	}
      linecnt++;
    }

  fclose(fid);
  free(nm);
  free(vl);

#ifdef DEBUG
  for(i=0;i<P_total;i++)
    printf("m_vec[%d]=%d p_vec[%d]=%d n_vec[%d]=%d start_time_vec[%d]=%f end_time_vec[%d]=%f\n",i,m_vec[i],i,p_vec[i],i,n_vec[i],i,start_time_vec[i],i,end_time_vec[i]);
#endif
  
  /*********************************/
  /***** Now read in data file *****/
  /*********************************/

  /***********************************************/
  /*** Pass 1: Count the elements in each list ***/
  /***********************************************/

  fid = fopen(stadfile,"r");
  if(fid==NULL)
    {
      printf("Cannot find .stad file: %s. Please check the path.\n",stadfile);
      free(line);
      free((*X).sites);
      for(m=0;m<(*X).M;m++)
        {
          for(p=0;p<(*X).categories[m].P;p++)
            free((*X).categories[m].trials[p]);
          free((*X).categories[m].trials);
        }
      free((*X).categories);
      free(X);
      free(p_vec);
      free(m_vec);
      free(n_vec);
      free(start_time_vec);
      free(end_time_vec);
      return EXIT_FAILURE;
    }

  q_vec = (int *)calloc(P_total,sizeof(int));

  i = 0;
  while(fgets(line,read_length,fid) != NULL)
    {

      /* Check to see if we exceeded the maximum line limit, reallocating as necessary */
      /* If there is no \n in the entire string, then it didn't finish reading */
      if(strchr(line,'\n')==NULL)
	{
          fseek(fid,-read_length+1,SEEK_CUR);
          read_length = (unsigned int)(1.618*read_length);
	  line = (char *)realloc(line,read_length*sizeof(char)); 
	  continue;
	}

      /* Get the first number */
      temp = strtok(line,spnl);
      if(temp != NULL) /* If the spike train is not empty */
	{	
	  q_vec[i]++; /* count the first one */
	  while((temp = strtok(NULL,spnl))!=NULL)
	    q_vec[i]++;
	}
      i++;
    }
  fclose(fid);

  /* Give an error if there is a mismatch between the
     number of traces in the metadata file and the number of
     traces in the data file! */
  if(i!=P_total)
    {
      printf("Mismatch between trace metadata and trace data in %s.\n",stadfile);
      free(line);
      free((*X).sites);
      for(m=0;m<(*X).M;m++)
        {
          for(p=0;p<(*X).categories[m].P;p++)
            free((*X).categories[m].trials[p]);
          free((*X).categories[m].trials);
        }
      free((*X).categories);
      free(X);
      free(p_vec);
      free(m_vec);
      free(n_vec);
      free(start_time_vec);
      free(end_time_vec);
      free(q_vec);
      return EXIT_FAILURE;
    }

#ifdef DEBUG
  printf("i=%d P_total=%d\n",i,P_total);
  for(i=0;i<P_total;i++)
    printf("q_vec[%d]=%d ",i,q_vec[i]);
  printf("\n");
#endif

  /****************************/
  /*** Pass 2: Do the rest. ***/
  /****************************/

  /* Loop through all of the traces to read in the metadata */
  for(i=0;i<P_total;i++)
    {
      (*X).categories[m_vec[i]].trials[p_vec[i]][n_vec[i]].start_time = start_time_vec[i];
      (*X).categories[m_vec[i]].trials[p_vec[i]][n_vec[i]].end_time = end_time_vec[i];
      (*X).categories[m_vec[i]].trials[p_vec[i]][n_vec[i]].Q = q_vec[i];
      
      /* Allocate memory for the lists */
      (*X).categories[m_vec[i]].trials[p_vec[i]][n_vec[i]].list = (double *)malloc(q_vec[i]*sizeof(double)); 
    }

  /* Open the datafile and get the lists. */
  fid = fopen(stadfile,"r");
  i=0;
  while(fgets(line,read_length,fid) != NULL)
    {
      cur_list = (*X).categories[m_vec[i]].trials[p_vec[i]][n_vec[i]].list;

      for(q=0;q<q_vec[i];q++)
	{
	  if(q==0)
	    temp = strtok(line,spnl);
	  else
	    temp = strtok(NULL,spnl);	

	  if(temp==NULL)
	    {
	      printf("Malformed trace data in line %d in %s\n",i+1,stadfile);
              free(line);
              FreeInput(X);
              free(p_vec);
              free(m_vec);
              free(n_vec);
              free(start_time_vec);
              free(end_time_vec);
              free(q_vec);
	      return EXIT_FAILURE;
	    }
	  cur_list[q]=atof(temp);
	  if((strcmp((*X).sites[n_vec[i]].recording_tag,"episodic")==0) && ((cur_list[q]<start_time_vec[i]) || (cur_list[q]>end_time_vec[i])))
	    {
	      printf("Time out of range in line %d in %s\n",i+1,stadfile);
              free(line);
              FreeInput(X);
              free(p_vec);
              free(m_vec);
              free(n_vec);
              free(start_time_vec);
              free(end_time_vec);
              free(q_vec);
	      return EXIT_FAILURE;
	    }
	}
      if((strcmp((*X).sites[n_vec[i]].recording_tag,"episodic")==0) && (IsSortedDouble(q_vec[i],cur_list)==0))
	{
	  printf("Spike times are not sorted in line %d in %s\n",i+1,stadfile);
          free(line);
          FreeInput(X);
          free(p_vec);
          free(m_vec);
          free(n_vec);
          free(start_time_vec);
          free(end_time_vec);
          free(q_vec);
	  return EXIT_FAILURE;
	}
      i++;
    }
  fclose(fid);

#ifdef DEBUG
  for(m=0;m<(*X).M;m++)
    for(p=0;p<(*X).categories[m].P;p++)
      for(n=0;n<(*X).N;n++)
	{
	  printf("(*X).categories[%d].trials[%d][%d]: start_time=%f end_time=%f Q=%d\n",m,p,n,(*X).categories[m].trials[p][n].start_time,(*X).categories[m].trials[p][n].end_time,(*X).categories[m].trials[p][n].Q);
	  for(q=0;q<(*X).categories[m].trials[p][n].Q;q++)
	    printf("%f ",(*X).categories[m].trials[p][n].list[q]);
	  printf("\n");
	}
#endif

  free(line);
  free(p_vec);
  free(m_vec);
  free(n_vec);
  free(start_time_vec);
  free(end_time_vec);
  free(q_vec);

  return EXIT_SUCCESS;
}

struct input *MultiSiteSubsetComp(struct input *X,int *vec,int N)
{
  int m,n,p;
  struct input *Y;

  Y = (struct input *)malloc(sizeof(struct input));

  Y[0].N = N;
  Y[0].M = X[0].M;
  Y[0].sites = (struct site *)malloc(N*sizeof(struct site));
  Y[0].categories = (struct category *)malloc(Y[0].M*sizeof(struct category));

  for(n=0;n<N;n++)
  {
#ifdef DEBUG
    printf("n=%d vec[%d]=%d\n",n,n,vec[n]);
#endif
    
    /* sites */
    memcpy(Y[0].sites[n].label,
	   X[0].sites[vec[n]].label,
	   MAXCHARS*sizeof(char));
    memcpy(Y[0].sites[n].recording_tag,
	   X[0].sites[vec[n]].recording_tag,
	   MAXCHARS*sizeof(char));
    Y[0].sites[n].time_scale = X[0].sites[vec[n]].time_scale;
    Y[0].sites[n].time_resolution = X[0].sites[vec[n]].time_resolution;
    memcpy(Y[0].sites[n].si_unit,
	   X[0].sites[vec[n]].si_unit,
	   MAXCHARS*sizeof(char));
    Y[0].sites[n].si_prefix = X[0].sites[vec[n]].si_prefix;
  }
    
  /* categories */
  for(m=0;m<X[0].M;m++)
    {
#ifdef DEBUG
      printf("m=%d\n",m);
#endif
      memcpy(Y[0].categories[m].label,X[0].categories[m].label,MAXCHARS*sizeof(char));
      Y[0].categories[m].P = X[0].categories[m].P;
      Y[0].categories[m].trials =
	(struct trial **)malloc(Y[0].categories[m].P*sizeof(struct trial *));

	/* trials */
	for(p=0;p<Y[0].categories[m].P;p++)
	  {
	    Y[0].categories[m].trials[p] =
	      (struct trial *)malloc(N*sizeof(struct trial));
	    for(n=0;n<N;n++)
	      {
#ifdef DEBUG
		printf("p=%d n=%d vec[%d]=%d\n",p,n,n,vec[n]);
#endif
		Y[0].categories[m].trials[p][n].start_time =
		  X[0].categories[m].trials[p][vec[n]].start_time;
		Y[0].categories[m].trials[p][n].end_time =
		  X[0].categories[m].trials[p][vec[n]].end_time;
		Y[0].categories[m].trials[p][n].Q =
		  X[0].categories[m].trials[p][vec[n]].Q;
#ifdef DEBUG
		printf("start_time=%f end_time=%f Q=%d\n",
		       Y[0].categories[m].trials[p][n].start_time,
		       Y[0].categories[m].trials[p][n].end_time,
		       Y[0].categories[m].trials[p][n].Q);
#endif
	    Y[0].categories[m].trials[p][n].list = 
	      (double *)malloc(Y[0].categories[m].trials[p][n].Q*sizeof(double));
	    memcpy(Y[0].categories[m].trials[p][n].list,
		   X[0].categories[m].trials[p][vec[n]].list,
		   Y[0].categories[m].trials[p][n].Q*sizeof(double));
	      }
	  }
    }
  
  return Y;
}

struct input *MultiSiteArrayComp(struct input *X,int *vec,int N)
{
  int m,n,p;
  struct input *Y;

  Y = (struct input *)malloc(N*sizeof(struct input));

  /* sites */
  for(n=0;n<N;n++)
    {
#ifdef DEBUG
      printf("n=%d vec[%d]=%d\n",n,n,vec[n]);
#endif
      Y[n].N = 1;
      Y[n].sites = (struct site *)malloc(sizeof(struct site));
      memcpy(Y[n].sites[0].label,
	     X[0].sites[vec[n]].label,
	     MAXCHARS*sizeof(char));
      memcpy(Y[n].sites[0].recording_tag,
	     X[0].sites[vec[n]].recording_tag,
	     MAXCHARS*sizeof(char));
      Y[n].sites[0].time_scale = X[0].sites[vec[n]].time_scale;
      Y[n].sites[0].time_resolution = X[0].sites[vec[n]].time_resolution;
      memcpy(Y[n].sites[0].si_unit,
	     X[0].sites[vec[n]].si_unit,
	     MAXCHARS*sizeof(char));
      Y[n].sites[0].si_prefix = X[0].sites[vec[n]].si_prefix;
      
      /* categories */
      Y[n].M = X[0].M;
      Y[n].categories = (struct category *)malloc(X[0].M*sizeof(struct category));
      for(m=0;m<X[0].M;m++)
	{
#ifdef DEBUG
	  printf("m=%d\n",m);
#endif
	  memcpy(Y[n].categories[m].label,X[0].categories[m].label,MAXCHARS*sizeof(char));

	  /* trials */
	  Y[n].categories[m].P = X[0].categories[m].P;
	  Y[n].categories[m].trials =
	    (struct trial **)malloc(Y[n].categories[m].P*sizeof(struct trial *));
	  for(p=0;p<Y[n].categories[m].P;p++)
	    {
#ifdef DEBUG
	      printf("p=%d\n",p);
#endif
	      Y[n].categories[m].trials[p] =
		(struct trial *)malloc(sizeof(struct trial));
	      Y[n].categories[m].trials[p][0].start_time =
		X[0].categories[m].trials[p][vec[n]].start_time;
	      Y[n].categories[m].trials[p][0].end_time =
		X[0].categories[m].trials[p][vec[n]].end_time;
	      Y[n].categories[m].trials[p][0].Q =
		X[0].categories[m].trials[p][vec[n]].Q;
#ifdef DEBUG
	      printf("start_time=%f end_time=%f Q=%d\n",
		     Y[n].categories[m].trials[p][0].start_time,
		     Y[n].categories[m].trials[p][0].end_time,
		     Y[n].categories[m].trials[p][0].Q);
#endif
	      Y[n].categories[m].trials[p][0].list = 
		(double *)malloc(Y[n].categories[m].trials[p][0].Q*sizeof(double));
	      memcpy(Y[n].categories[m].trials[p][0].list,
		     X[0].categories[m].trials[p][vec[n]].list,
		     Y[n].categories[m].trials[p][0].Q*sizeof(double));
	    }
	}
    }
  return Y;
}

void FreeInput(struct input *X)
{
  int m,n,p;

  free((*X).sites);
  
  for(m=0;m<(*X).M;m++)
    {
      for(p=0;p<(*X).categories[m].P;p++)
	for(n=0;n<(*X).N;n++)
	  free((*X).categories[m].trials[p][n].list);
      free((*X).categories[m].trials);
    }
  
  free((*X).categories);
  
  free(X);
}
