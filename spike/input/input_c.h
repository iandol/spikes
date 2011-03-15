/*
 *  Copyright 2010, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
/* Input data structure */

struct site{
  char label[MAXCHARS];
  char recording_tag[MAXCHARS];
  double time_scale;
  double time_resolution;
  char si_unit[MAXCHARS];
  double si_prefix;
};

struct category{
  char label[MAXCHARS];
  int P;
  struct trial **trials;
};

struct trial{
  double start_time;
  double end_time;
  int Q;
  double *list;
};

struct input{
  int M;
  int N;
  struct site *sites;
  struct category *categories;
};

/* Input data structure */
extern int GetNumTrials(struct input *X);
extern int GetMaxSpikes(struct input *X);
extern double GetStartTime(struct input *X);
extern double GetEndTime(struct input *X);
extern int staReadComp(char *stamfile,struct input *X);
extern struct input *MultiSiteSubsetComp(struct input *X,int *vec,int N);
extern struct input *MultiSiteArrayComp(struct input *X,int *vec,int N);
extern void FreeInput(struct input *X);


