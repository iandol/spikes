/*
*  Copyright (C) 1997--2002  Charles Kooperberg
*
*  This program is free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 2 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  The text of the GNU General Public License, version 2, is available
*  as http://www.gnu.org/copyleft or by writing to the Free Software
*  Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include "mex.h"

#define Salloc(n,t) (t *) mxCalloc((long)(n),(int)sizeof(t))

#define MAXKNOTS 60

struct datastruct { 
int ndata; 
double *data;
   int *idata;
   short *same;
};

/* ndata;
   ndat - # number of cases
   dat  - data
   idat - the ips are the integration points: idat indicates
          what the integration point immediately to the left of a datapoint is
   same - is the observation the same as the previous in the same category? 
   kdata - relates the total order to the data, if kdata[37]=(0,18), the
           37th datapoint is #18 in dat0: a first index of 2 refers to dat2
           3 to dat3, 4 to the first column of dat4 and 5 to the second column
           of dat4 */

struct space {
   int ndim,nk,nip,*iknots,ilow,iupp;
   double *knots,aic,**info,*score,*ips,low,upp,cth;
   struct basisfunct *basis;
};

/* ndim    - dimension
   nk      - number of knots (=ndim+1)
   nip     - number of integration points
   iknots  - datapoint at or just left of knot
   ilow    - is the lower bound -infinity? (1=yes)
   iupp    - is the upper bound +infinity? (1=yes)
   knots   - the knots
   aic     - present value of aic
   info    - the hessian
   score   - score function
   ips     - integration points
   low     - lower integration boundary
   upp     - upper integration boundary 
   cth     - ctheta */

struct basisfunct {
   double beta,*c1,**c2,sumunc;
   int c3[2],iks[5];
};

/* beta   - coefficient
   c1     - to translate the basis function in the truncated power basis
   c2     - to translate the basisfunction at an integration point in a
            polynomial
   c3     - first and last integration point for which this function is nonzero
   iks    - which knots are involved with this basisfunction - integrationpt 
   sumunc - sum_i B(x_i) over the uncensored data */


static int *isvector();
static short *issvector();
static double *dsvector(),**dsmatrix();
static int nlsd();
static struct space *definespace();
static void getsame();
static void five();
static void five01();
static void five00();
static void lubksb();
static int ludcmp();
static int adddim();
static int findyl();
static int findyr();
static int findl();
static int findr();
static int findm();
static int dlocation();
static void betaadd();
static int iter();
static int iterx();
static double pompall();
static void savecode1();
static int savecoden();
static void initk();
static double rao();
static double praox();
static int getnewc2();
static double save22coden();
static void remdim();
static void betarem();
static void redo1();
static void redo2();
static void solver();
static void getc2();
static void getc1();
static void getonec1();
static void setupspace();
static int startspace();
static void startnow();
static int rearrange();
static void getip();
static void getp0();
static void getq0();
static void getp2();
static void getq2();
static void getp1();
static void getq1();
static double z1int();
static double z2int();
static double z3int();
static double pqexpi();
static double getf();
static double mylog();
static double myexp();
static void m1int();
static void l1int();
static void l2int();
static double fctf1();
static double fctf2();
static double pol3();
static double inp3();
static double mat3();
static void swapspace();
static void quadalloc();
/* allocation */

static int lusolve2();
static void luinverse();
/* matrix inversion, solve a system */

static double ctheta,*betaaddsorted;
static double **kints,*cuu;
/* see piter - partial integrals and so on, which we want to keep */
static struct basisfunct *bbx;
/* storage */
static double ww6[7],yy6[7],ww7[33],yy7[33],*pompalcy,**pompalcyy;
static int *rearix,*getiips,*luwi;
static double *fiveee,*fiveh1,*fiverr,*betaaddv1,*betaremr1,*raoss,*luw,*luw2,**luww;
static double *itertmp1,*itertmp2,*rearsorted,**solc1,**solc2,**solc3;
static double **itertmp3,**pompcoef,**betaaddt1,**raoii,**raoc2,**betaremm2;
/******************************************************************************/
void nlogcensorx(intpars)
int *intpars;
{
      intpars[0]=MAXKNOTS+5;
      return;
}

void nlogcensor(intpars,data0,dpars,logs,ad,kts)
int *intpars,*ad;
double *data0,*logs,*kts,*dpars;

/* data0  - uncensored data; coefs on exit
   intpars- integer parameters
   dpars  - double parameters
   ad     - is a model added during addition (1), deletion (2) or not at all
   kts    - knots */
{
   struct datastruct *data;
   struct space *spc;
   int i,j,strt,mind,ndmax,silent;
   double x,y,alpha;

/* data  - datastructure for all the data
   spc   - datastructure for a model
   definespace - allocation for a model 
   i,j   - counters
   k     - one line for kdata
   nlsd- does the work
   strt  - where starting knots provided
   mind  - minimum distance between knots
   ndmax - maximum dimension, the sign indicates whether it should be attained
   silent- print diagnostic output? (1=yes)
   alpha - penalty parameter
   x,y   - utility */

/* we only want parameters and leave... */
   if(intpars[0]<-10){
      intpars[0]=MAXKNOTS+5;
      return;
   }

/* define the data */
   data=(struct datastruct *)Salloc(1,struct datastruct);
   (*data).ndata=intpars[0];

   (*data).data=data0;
   (*data).same=issvector(intpars[0]+1);
/* get the "same" vectors */
   getsame(data0,intpars[0],(*data).same);
   (*data).idata=isvector(intpars[0]);
/* allocate the space */
   spc=definespace((*data).ndata);

   getiips=isvector((*spc).nip+10);
   luwi=isvector(2*MAXKNOTS+20);
   rearix=isvector((*data).ndata);
   fiverr=dsvector((*data).ndata+2*MAXKNOTS);
   fiveee=dsvector((*data).ndata+MAXKNOTS+5);
   fiveh1=dsvector((*data).ndata+MAXKNOTS+5);
   betaaddv1=dsvector((*data).ndata+MAXKNOTS+5);
   betaremr1=dsvector((*data).ndata+MAXKNOTS+5);
   raoss=dsvector((*data).ndata+MAXKNOTS+5);
   itertmp1=dsvector((*data).ndata+MAXKNOTS+5);
   itertmp2=dsvector((*data).ndata+MAXKNOTS+5);
   rearsorted=dsvector((*data).ndata+MAXKNOTS+5);
   luw=dsvector(2*MAXKNOTS+20);
   luw2=dsvector(2*MAXKNOTS+20);
   itertmp3=dsmatrix(MAXKNOTS+5,MAXKNOTS+5);
   solc1=dsmatrix(MAXKNOTS+5,MAXKNOTS+5);
   solc2=dsmatrix(MAXKNOTS+5,MAXKNOTS+5);
   solc3=dsmatrix(MAXKNOTS+5,MAXKNOTS+5);
   luww=dsmatrix(2*MAXKNOTS+20,2*MAXKNOTS+20);
   pompcoef=dsmatrix((*spc).nip+2,4);
   betaaddt1=dsmatrix(MAXKNOTS+5,MAXKNOTS+5);
   betaremm2=dsmatrix(MAXKNOTS+5,MAXKNOTS+5);
   raoii=dsmatrix(MAXKNOTS+5,MAXKNOTS+5);
   raoc2=dsmatrix((*spc).nip+10,(*spc).nip+10);

   pompalcy=dsvector(2*MAXKNOTS+10);
   betaaddsorted=dsvector((*data).ndata);
   pompalcyy=dsmatrix(MAXKNOTS+5,MAXKNOTS+5);

   bbx=(struct basisfunct *)Salloc(MAXKNOTS,struct basisfunct);
/* get the integer and double parameters */
   (*bbx).beta=0;
   (*bbx).sumunc=0;
   (*bbx).c3[0]=0;
   (*bbx).c3[1]=0;
   (*bbx).iks[0]=0;
   (*bbx).iks[1]=0;
   (*bbx).iks[2]=0;
   (*bbx).iks[3]=0;
   (*bbx).iks[4]=0;
   ndmax=intpars[1];
   mind=intpars[6];
   if(mind<1){
   mind=2.5*pow((double)(*data).ndata,(double)0.2)+0.5;
   if((*data).ndata/mind<10)mind=(*data).ndata/10;
   if(mind<3)mind=3;
   }
   intpars[6]=mind;
   strt=intpars[2];
   silent=intpars[3];
   alpha=dpars[0];
   if(strt==547) {
       strt= floor(2.5*pow((double)intpars[0],(double)0.2));
       if(strt>25)strt=25;
       if(strt>intpars[0]/4)strt=intpars[0]/4;
   }
   if(alpha<0) alpha= mylog((double)intpars[0]);
   (*spc).ilow=intpars[4];
   (*spc).iupp=intpars[5];
   (*spc).low=dpars[1];
   (*spc).upp=dpars[2];

   i=0;
/* starting knots */
   if(ndmax==0)
      ndmax = - floor(4.*pow((double)intpars[0],(double)0.2)+1);
   if(ndmax>MAXKNOTS)ndmax=MAXKNOTS;
   if(strt<=0){
      if(intpars[2]<0)intpars[2]= -intpars[2];
      else intpars[2]=floor(2.5*pow((double)intpars[0],(double)0.2)+1);
      if(intpars[2]<0)intpars[2]= -intpars[2];
      if(intpars[2]<3)intpars[2]=3;
      five(data0,kts,intpars,(*data).same);
      strt= intpars[2];
   }
/* they were user provided */
   if(strt>0){
      (*spc).nk=strt;
      (*spc).ndim=strt-1;
      for(i=0;i<strt;i++)(*spc).knots[i]=kts[i];
      strt=1;
/* find the iknots */
      j=0;
      y= -pow((double)10.,(double)100.);
      for(i=0;i<(*data).ndata;i++){
         x=(*data).data[i];
         if(y<=(*spc).knots[j]&&x>(*spc).knots[j]){
            (*spc).iknots[j]=i;
            j++;
            i--;
            if(j==(*spc).nk)i=(*data).ndata+10;
         }
         else y=x;
      }
      if(j==((*spc).nk)-1)
         (*spc).iknots[(*spc).nk-1]=(*data).ndata-1;
/* two knots outside the range of the data is not allowed */
      if(j<((*spc).nk)-1){
         intpars[0]=17;
         return;
      }
      if((*spc).iknots[1]==0){
         intpars[0]=18;
         return;
      }
   }
/* allocations */
   cuu = dsvector(MAXKNOTS+5);
   kints = dsmatrix((*spc).nip+10,7);
   quadalloc();

/* do the work */
   intpars[0]=nlsd(spc,data,alpha,ndmax,mind,strt,silent,logs,ad);
   dpars[0]= alpha;
/* output */
   if(intpars[0]>0 && intpars[0]<100)return;
   intpars[1]=(*spc).nk;
   intpars[2]=(*spc).ndim;
   for(i=0;i<((*spc).nk)+2;i++){
      data0[i] = 0.;
      for(j=0;j<(*spc).nk-1;j++)
         data0[i]+=(*spc).basis[j].beta*(*spc).basis[j].c1[i];
   }
   data0[0]+=mylog((*spc).cth);
   for(i=0;i<((*spc).nk);i++)kts[i]=(*spc).knots[i];
   return;
}
/******************************************************************************/
/* the work */
static int nlsd(best,data,alpha,ndmax,mind,strt,silent,logs,ad)
struct space *best;
struct datastruct *data;
double alpha,*logs;
int ndmax,mind,strt,silent,*ad;

/* best  - best space up to now
   data  - the data
   alpha - penalty parameter
   ndmax - maximum dimension size: negative: does not have to be attained
   mind  - minimum distance between knots
   strt  - were starting knots provided (1=yes)
   silent- should diagnostic info be printed? (1=yes)
   logs  - log-likelihood of models 
   ad    - fit during addition (1), deletion (2), not at all (0) */
{
   struct space *current,*trynew;
   int add=1,i,oops=0,ndm2,oops2=0,oops3=0,j,coco=0;
   double xxa=0;

/* current - present space
   trynew  - needed during addition and deletion
   definespace- allocates a space
   add     - adding=1, deleting=something else
   i       - counter
   oops    - error status
   ndm2    - sign of ndmax
   iter  - fits a model
   swapspace - copies a model
   adddim- adds a dimension
   remdim- removes a dimension
   startspace- the starting model */

/* allocates storage for spaces */
   trynew=definespace((*data).ndata);
   current=definespace((*data).ndata);

/* starting */
   swapspace(current,best);
   i=startspace(current,data,strt,silent);
   if(i==0)return 39;

/* initialization */
   ndm2=ndmax;
   if(ndmax<0)ndmax= -ndmax;
   (*best).aic=pow((double)10.,(double)150.);
   for(i=0;i<MAXKNOTS;i++)logs[i]= -pow((double)10.,(double)150.);

/* we start in adding mode */
   do{

/* fits the model */
      if(oops3==0)oops=iter(current,data,silent,&xxa);
      if((oops>0 || oops3>0)&& ndmax > (*current).ndim ){
/* problems. Jonge vriend, verzin een list! */
         do{
            for(i= -1;i> -4; i--){
/* begin opnieuw */
               xxa=0.;
               coco=coco+1;
               j=startspace(current,data,i,silent);
               if(j==0)return 39;
               if(coco==10)return 39;
               oops=iter(current,data,silent,&xxa);
               oops2++;
               if(oops==0)i= -10;
            }
         }while(oops!=0 && ndmax > (*current).ndim);
      }
      if(oops2>2)oops2--;
      if(oops!=0){ 
         if((*best).aic< -1.0e149)return 40;
         else swapspace(current,best);
         add=0;
      }
      
      if(oops==0){
/* compute aic */
         logs[(*current).ndim-1]=(*current).aic;
         ad[(*current).ndim-1]=1;
         (*current).aic=(*current).ndim*alpha-2*(*current).aic;
         if((*current).ndim==ndmax)add=0;
/* did we improve */
         if((*current).aic<(*best).aic) swapspace(best,current);
      }

/* continue */
      if(add==1 && ndm2<0){
/* was there any recent improvement? */
         for(i=2;i<(*current).ndim-2;i++){
            if(logs[(*current).ndim-1]-logs[i-1]<((*current).ndim-i)/2.-0.5){
               add=0;
               ndmax=(*current).ndim;
            }
         }
      }
/* adds dimensions, computes new starting values */
      if(add==1){
         add=adddim(current,trynew,data,mind,silent);
         if(add!=1 && oops2<2) ndmax=(*current).ndim;
         if(add!=1 && oops2>=2){
            oops3=1;
            add=1;
         }
      }

/* keep on adding? */
   }while(add==1);

/* start deleting */
   if((*current).ndim>2)do{

/* removes dimensions, computes new starting values */
      if(ndmax>2)remdim(current,data,trynew,silent);

/* fits the model */
      oops=iter(current,data,silent,&xxa);
      if(oops!=0){
         oops=oops+100;
         (*best).ndim=ndmax-1;
         return oops;
      }
      
/* compute aic */
      if((*current).aic>logs[(*current).ndim-1]){
         logs[(*current).ndim-1]=(*current).aic;
         ad[(*current).ndim-1]=2;
      }
      (*current).aic=(*current).ndim*alpha-2*(*current).aic;

/* did we improve */
      if((*current).aic<(*best).aic) swapspace(best,current);
/* does further deleting make sense */
   }while((*current).aic-(*best).aic<alpha*((*current).ndim-2));

   (*best).ndim=ndmax-1;
   if(oops2>0)return 100;
   return 0;
}
/******************************************************************************/
/* allocates storage for a space, and initializes elements */
static struct space *definespace(nd)
int nd;
{
   int i,j,k;
   struct space *spc;
   spc=(struct space *)Salloc(1,struct space);
   (*spc).aic=pow(10.,100.);
   (*spc).ndim=0;
   (*spc).nk=0;
   (*spc).nip=0;
   (*spc).ilow=0;
   (*spc).iupp=0;
   (*spc).low=0.;
   (*spc).upp=0.;
   (*spc).cth=0.;
   (*spc).iknots=isvector(MAXKNOTS+5);
   (*spc).knots=dsvector(MAXKNOTS+5);
   (*spc).score=dsvector(MAXKNOTS+5);
   (*spc).info=dsmatrix(MAXKNOTS+5,MAXKNOTS+5);
   k=MAXKNOTS+10+nd/100+300;
   (*spc).ips=dsvector(k);
   (*spc).basis=(struct basisfunct *)Salloc(MAXKNOTS,struct basisfunct);
   for(i=0;i<MAXKNOTS;i++){
      (*spc).basis[i].beta=0.;
      (*spc).basis[i].sumunc=0.;
      for(j=0;j<2;j++)(*spc).basis[i].c3[j]=0;
      (*spc).basis[i].c1=dsvector(MAXKNOTS+5);
      (*spc).basis[i].c2=dsmatrix(k,4);
      for(j=0;j<5;j++)(*spc).basis[i].iks[j]=0;
   }
   (*spc).nip=k;
   return spc;
}
/******************************************************************************/
/* figure out which datapoints are the same.... */
static void getsame(x,n,s)
double *x;
int n;
short *s;
{
   int i;
   double r;
   s[0]=0;
   for(i=1;i<n;i++){
/* exactly the same */
      if(x[i]==x[i-1])s[i]=1;
      else {
         if(x[i]!=0){
/* almost exactly the same */
            r=fabs(x[i-1]/x[i]-1.);
            if(r<0.0000000000001)s[i]=1;
            else s[i]=0;
         }
         else s[i]=0;
      }
   }
}
/******************************************************************************/
static void five(data,kts,intpars,same)
double *data,*kts;
int *intpars;
short *same;
{
   int n1,k,l,i,j,g1,g2;
   double *rr,*ee,*h1,h2,h3;
   n1 = intpars[0];
   k=intpars[2];
   rr=fiverr;
   if(intpars[4]+intpars[5]==2)five00(rr,k,n1);
   if(intpars[4]+intpars[5]==1)five01(rr,k,n1,intpars[5]);
   if(intpars[4]+intpars[5]==0)for(i=0;i<k;i++)rr[i]=(double)i/(double)(k-1);
   ee=fiveee;
   h1=fiveh1;
   ee[0]=1.;
   h1[0]=0.;
   h1[1]=1.;
   l=0;
   for(i=1;i<n1;i++){
      if(same[i]==1){
         h1[l+1]++;
      }
      else{
         l++;
         ee[l]=data[i];
         h1[l+1]=h1[l]+1;
     }
   }
   for(i=0;i<l;i++) h1[i]=0.5*(h1[i]+h1[i+1]);   
   h2=h1[0];
   h3=0.;
   for(i=0;i<l;i++) {
      h1[i]-=h2;
      if(h1[i]>h3)h3=h1[i];
   }
   for(i=0;i<l;i++) h1[i]/=h3;
   kts[0]=data[0];
   kts[k-1]=data[n1-1];
   for(i=1;i<k-1;i++){
      g1=0;
      g2=l;
      for(j=0;j<l;j++){
         if(h1[j]<=rr[i] && j>g1)g1=j;
         if(h1[j]>rr[i] && j<g2)g2=j;
      }
      h2=h1[g1];
      h3=h1[g2];
      h3=(rr[i]-h2)/(h3-h2);
      kts[i]=h3*ee[g2] + (1 - h3) * ee[g1];
   }
}     
static void five01(rr,k,n,il)
int k,n,il;
double *rr;
{
   int i;
   five00(rr,2*k-1,2*n);
   for(i=0;i<k;i++)rr[i]=2*rr[i];
   if(il==0) for(i=0;i<k;i++)rr[i]=1-rr[2*k-2-i];
} 
static void five00(rr,k,n)
int k,n;
double *rr;
{
   double fi=4.,eps1,eps2,eps,s,w,v;
   int i,i1,j,j2;
   j=floor((double)((k-1.)/2.+0.99));
   j2=floor((double)((k-1.)/2.));
   eps1=fi - pow((double)((n-1.)/fi),(double)(1./(j-1.)));
   if(eps1>0) eps1 = 0;
   eps2=fi-1;
   for(i=0;i<k;i++)rr[i]=0;
   rr[0]=1.;
   rr[k]=n;
   for(i1=0;i1<100;i1++)if(i1==0||eps2-eps1>0.0001){
      eps = (eps1+eps2)/2.;
      s=1;
      w=fi;
      for(i=1;i<=j2;i++){
         v=i;
         s+=w;
         rr[i]=s;
         rr[k-i-1]=n+1.-s;
         v=fi-v*eps;
         if(v<1)v=1;
         w*=v;
      }
      if(2*j==k)s+=w/2.;
      else rr[j]=(n+1)/2.;
      if(2.*s>=n+1)eps1=eps;
      else eps2=eps;
   }
   else i1=100;
   for(i=0;i<k;i++)rr[i]=(rr[i]-1)/(n-1.);
} 
/******************************************************************************/
static void luinverse(a,n)
double **a;
int n;
{
   int k,j,*i;
   double *d,**c,r;
   c=luww;
   d=luw2;
   i=luwi;
   for(j=1;j<=n;j++) for(k=1;k<=n;k++) c[j][k]=a[j-1][k-1];
   if(ludcmp(c,n,i,&r)==0)(void)mexPrintf("singular matrix in routine LUDCMP\n");
   for(j=1;j<=n;j++){
      for(k=1;k<=n;k++) d[k]=0.;
      d[j]=1.;
      lubksb(c,n,i,d);
      for(k=1;k<=n;k++) a[k-1][j-1]=d[k];
   }
}
/******************************************************************************/
static int lusolve2(a,n,b)
double **a,*b;
int n;
{
   int *i,j,k;
   double **c,r;
   c=luww;
   i=luwi;
   for(j=0;j<(n+1);j++)i[j]=0;
   for(j=0;j<n;j++) for(k=0;k<n;k++) c[j+1][k+1]=a[j][k];
   if(ludcmp(c,n,i,&r)==0)return 0;
   lubksb(c,n,i,b-1);
   return 1;
}
/******************************************************************************/
static void lubksb(a,n,indx,b)
double **a,b[];
int n,*indx;
{
   int i,ii=0,ip,j;
   double sum;
   for (i=1;i<=n;i++) {
      ip=indx[i];
      sum=b[ip];
      b[ip]=b[i];
      if (ii) for (j=ii;j<=i-1;j++) sum -= a[i][j]*b[j];
      else if (sum) ii=i;
      b[i]=sum;
   }
   for (i=n;i>=1;i--) {
      sum=b[i];
      for (j=i+1;j<=n;j++) sum -= a[i][j]*b[j];
      b[i]=sum/a[i][i];
   }
}
/******************************************************************************/
#define TINY 1.0e-20;
static int ludcmp(a,n,indx,d)
int n,*indx;
double **a,*d;
{
   int i,imax,j,k;
   double big,dum,sum,temp,*vv;
   vv=luw;
   for(i=0;i<=n+1;i++)vv[i]=0.;
   *d=1.0;
   for (i=1;i<=n;i++) {
      big=0.0;
      for (j=1;j<=n;j++) if ((temp=fabs(a[i][j])) > big) big=temp;
      if (big == 0.0) return 0;
      vv[i]=1.0/big;
   }
   for (j=1;j<=n;j++) {
      for (i=1;i<j;i++) {
         sum=a[i][j];
         for (k=1;k<i;k++) sum -= a[i][k]*a[k][j];
         a[i][j]=sum;
      }
      big=0.0;
      for (i=j;i<=n;i++) {
         sum=a[i][j];
         for (k=1;k<j;k++) sum -= a[i][k]*a[k][j];
         a[i][j]=sum;
         if ( (dum=vv[i]*fabs(sum)) >= big) {
            big=dum;
            imax=i;
         }
      }
      if (j != imax) {
         for (k=1;k<=n;k++) {
            dum=a[imax][k];
            a[imax][k]=a[j][k];
            a[j][k]=dum;
         }
         *d = -(*d);
         vv[imax]=vv[j];
      }
      indx[j]=imax;
      if (a[j][j] == 0.0) a[j][j]=TINY;
      if (j != n) {
         dum=1.0/(a[j][j]);
         for (i=j+1;i<=n;i++) a[i][j] *= dum;
      }
   }
   return 1;
}
#undef TINY
/******************************************************************************/
static int adddim(spc,spc2,data,mind,silent)
struct space *spc,*spc2;
struct datastruct *data;
int mind,silent;
{
   int i,nx,uu,ll,nowloc1,loloc,uploc,bestloc= -1;
   int besti= -1,nowloc2;
   double *sorted,nowrao1,bestrao= -1.,nowrao2;
   sorted=betaaddsorted;
   swapspace(spc2,spc);
   for(i=0;i<(*data).ndata;i++)
      sorted[i]=(*data).data[i];
   nx=(*data).ndata;
/* find the interval */
   for(i=0;i<=(*spc).nk;i++){
/* before first knot */
      if(i==0) nowloc1=findl(&ll,&uu,mind,sorted,nx,(*spc).knots[0]);
/* after last knot */
      if(i==(*spc).nk) 
         nowloc1=findr(&ll,&uu,mind,sorted,nx,(*spc).knots[(*spc).nk-1]);
/* in between knots */
      if(i>0 && i<(*spc).nk)nowloc1=
         findm(&ll,&uu,mind,sorted,nx,(*spc).knots[i-1],(*spc).knots[i]);
/* possible location */
      if(nowloc1>=0){
         nowrao1=rao(spc,data,sorted[nowloc1]);
         if(nowrao1>bestrao){
            loloc=ll;
            uploc=uu;
            bestloc=nowloc1;
            bestrao=nowrao1;
            besti=i;
         }
      }
   }
   if(bestloc<0)return -1;
/* as long as the locations are different, do interval halving */
   do{
      if(sorted[uploc]>sorted[loloc]){
         nowloc2=findyr(uploc,bestloc,sorted);
/* two search points, the upper one */
         if(nowloc2>=0) nowrao2=rao(spc,data,sorted[nowloc2]);
         else nowrao2=bestrao;
/* two search points, the lower one */
         nowloc1=findyl(bestloc,loloc,sorted);
         if(nowloc1>=0) nowrao1=rao(spc,data,sorted[nowloc1]);
         else nowrao1=bestrao;
/* the middle one is the best, we call it quits */
         if(bestrao>=nowrao2 && bestrao>=nowrao1) loloc=uploc;
         else{
/* the lower search point is the best */
            if(nowrao1>bestrao){
               uploc=bestloc;
               bestloc=nowloc1;
               bestrao=nowrao1;
            }
/* the upper search point is the best */
            else{
               loloc=bestloc;
               bestloc=nowloc2;
               bestrao=nowrao2;
            }
         }
      }
   }while(sorted[uploc]>sorted[loloc]);
/* failure */
   if(bestloc<0)return bestloc;
/* done record the new knot in its correct position */
   if(besti==(*spc).nk){
       (*spc).knots[(*spc).nk]=sorted[bestloc];
       (*spc).iknots[(*spc).nk]=bestloc;
   }
   else{
      for(i=(*spc).nk;i>besti;i=i-1){
         (*spc).knots[i]=(*spc).knots[i-1];
         (*spc).iknots[i]=(*spc).iknots[i-1];
      }
      (*spc).knots[besti]=sorted[bestloc];
      (*spc).iknots[besti]=bestloc;
   }
   ((*spc).nk)++;
   ((*spc).ndim)++;
   if(silent==1) (void)mexPrintf("add(%.2f), rao=%.2f ",sorted[bestloc],bestrao);
/* get (*spc).ips (*spc).nip (*data).idatx */
/* get (*spc).basis.c1 (*spc).basis.c2 (*spc).basis.c3 (*spc).basis.sumunc */
   setupspace(spc,data);
/* get (*spc).basis.beta */
   betaadd(spc,spc2,besti);
   return 1;
}
/******************************************************************************/
/* finds location in an interval (l,b) - l might not have been tested yet */
static int findyl(u,l,x)
int l,u;
double *x;
{
   int i;
   if(x[l]==x[u])return -1;
   i=(u+l-1)/2;
   if(x[i]!=x[u])return i;
   i=(i+l)/2;
   if(x[i]!=x[u])return i;
   return l;
}
/******************************************************************************/
/* finds location in an interval (b,u) - u might not have been tested yet */
static int findyr(u,l,x)
int l,u;
double *x;
{
   int i;
   if(x[l]==x[u])return -1;
   i=(u+l+1)/2;
   if(x[i]!=x[l])return i;
   i=(i+u)/2;
   if(x[i]!=x[l])return i;
   return u;
}
/******************************************************************************/
/* Finds a possible location for a knot on the interval (0,knot1)
   ll - lowest number we can search on in the future
   uu - highest number we can search on in the future
   mind minimum distance between knots
   x  - data
   nx - length of data
   knt- knot */
static int findl(ll,uu,mind,x,nx,knt)
double *x,knt;
int nx,*ll,*uu,mind;
{
/* dlocation - finds uu */
   int i;
   (*uu)=dlocation(0,x,nx,knt);
   if((*uu)<mind)return -1;
   i=((*uu)-1)/2;
   if((*uu)-i<mind+1)i=(*uu)-mind-1;
   *ll=0;
   *uu=(*uu)-mind-1;
   return i;
}
/******************************************************************************/
/* Finds a possible location for a knot on the interval (knot-last,nx-1)
   ll - lowest number we can search on in the future
   uu - highest number we can search on in the future
   mind minimum distance between knots
   x  - data
   nx - length of data
   knt- knot */
static int findr(ll,uu,mind,x,nx,knt)
double *x,knt;
int nx,*ll,*uu,mind;
{
/* dlocation - finds ll */
   int i;
   (*ll)=dlocation(1,x,nx,knt);
   if(nx-1-(*ll)<mind)return -1;
   i=(nx+(*ll))/2;
   if(i-(*ll)<mind+1)i=(*ll)+mind+1;
   *uu=nx-1;
   *ll=(*ll)+mind+1;
   return i;
}
/******************************************************************************/
/* Finds a possible location for a knot on the interval (k0,k1)
   ll - lowest number we can search on in the future
   uu - highest number we can search on in the future
   mind minimum distance between knots
   x  - data
   nx - length of data
   k0 - knot
   k1 - knot */
static int findm(ll,uu,mind,x,nx,k0,k1)
double *x,k0,k1;
int nx,*ll,*uu,mind;
{
/* dlocation - finds ll */
   (*ll)=dlocation(1,x,nx,k0);
   (*uu)=dlocation(0,x,nx,k1);
   if((*uu)-(*ll)<2*mind+1)return -1;
   *uu=(*uu)-mind-1;
   *ll=(*ll)+mind+1;
   return ((*uu)+(*ll))/2;
}
/******************************************************************************/
/* finds the lowest (if what = 0) or the highest (if what = 1) index of x for
   which x==k */
/* what - see above
   x    - data
   nx   - length data
   k    - see above */
static int dlocation(what,x,nx,k)
int nx,what;
double k,*x;
{
   int i;
   if(what==1){
      if(x[0]>k)return 0;
      if(x[nx-1]<=k)return nx-1;
      for(i=0;i<nx-1;i++) if(x[i+1]>k && x[i]<=k) return i;
   }
   if(x[nx-1]<k)return nx-1;
   if(x[0]>=k)return 0;
   for(i=1;i<nx;i++) if(x[i]>=k && x[i-1]<k)return i;
   return nx;
}
/******************************************************************************/
/* gets the new starting values, solve one coef matrix w.r.t. the other */
static void betaadd(spc,spc2,besti)
struct space *spc,*spc2;
int besti;
{
   int i,j,k;
   double **t1,*v1;
   k=(*spc).ndim+3;
   t1=betaaddt1;
   v1=betaaddv1;
   for(i=0;i<((*spc2).nk)+2;i++){
      v1[i] = 0.;
      for(j=0;j<(*spc2).ndim;j++)
         v1[i]+=(*spc2).basis[j].beta*(*spc2).basis[j].c1[i];
   }
   for(i=(*spc2).nk;i>besti;i=i-1) v1[i+2]=v1[i+1];
   v1[besti+2]=0.;
   for(i=0;i<k;i++)for(j=0;j<k;j++)t1[i][j]=0.;
   for(j=0;j<k;j++)for(i=0;i<k-3;i++)t1[i][j]=(*spc).basis[i].c1[j];
   for(i=k-2;i<k;i++)t1[i][i]=1.;
   t1[k-3][0]=1.;
   luinverse(t1,k);
   for(i=0;i<k-3;i++){
      (*spc).basis[i].beta=0.;
      for(j=0;j<k;j++)(*spc).basis[i].beta+=t1[j][i]*v1[j];
   }
   return;
}
/******************************************************************************/
/* top iteration - governs bounds */
static int iter(spc,data,silent,xxa)
int silent;
double *xxa;
struct space *spc;
struct datastruct *data;
{
   double xpp=(*spc).upp,lpp=(*spc).upp,lll=(*spc).low,xll=(*spc).low;
   int n=0,oops,mll=(*spc).ilow,muu=(*spc).iupp;
/* bounded intervals */
   if((*spc).ilow==0 && (*spc).iupp==0) return iterx(spc,data,silent,xxa);
   do{
/* try unbounded intervals */
      n++;
      if(((*spc).basis[1].beta<0||muu==0)&&((*spc).basis[0].beta<0||mll==0)){
         (*spc).low=xll;
         (*spc).ilow=mll;
         (*spc).upp=xpp;
         (*spc).iupp=muu;
         oops=iterx(spc,data,silent,xxa);
         if(oops==0 || n==6)return oops;
      }
      (*spc).iupp=0;
      (*spc).ilow=0;
/* widen bounded intervals */
      if(muu==1)(*spc).upp=4*lpp-3*(*spc).low;
      if(mll==1)(*spc).low=4*lll-3*(*spc).upp;
      lpp=(*spc).upp;
      lll=(*spc).low;
      oops=iterx(spc,data,silent,xxa);
      (*spc).iupp=muu;
      (*spc).upp=xpp;
      (*spc).ilow=mll;
      (*spc).low=xll;
      if(oops!=0)return oops;
   }while(n<6);
   return 9999;
}
/******************************************************************************/
/* the works */
static int iterx(spc,data,silent,xxa)
int silent;
double *xxa;
struct space *spc;
struct datastruct *data;

/* spc   - model
   data  - data
   silent- print info? (1=yes) */

{
   double zerror=0.000001,factor,logl,lnew;
   double *tmp1,*tmp2,**tmp3;
   int iter,maxiter=100,j,i,i1,i2,kk;

/* error - convergence criterion
   j     - counter
   logl  - log-likelihood
   lnew  - new loglikelihood
   iter  - iteration counter
   factor- stepsize for the NR algorithm
   evmin/evmax - minimum and maximum eigenvalue
   pompall   - compute logl/score/hessian
   maxiter     - maximum number of iterations */

   for(iter=0;iter<maxiter;iter++){
      tmp1=itertmp1;
      tmp2=itertmp2;
      tmp3=itertmp3;
/* compute logl/score/hessian */
      logl=pompall(spc,data,2,&i1);
      if(iter==0 && fabs((*xxa))>0.01 && (*xxa)-logl > 100){
/* try alternate starting values */
         lnew=logl;
         for(j=0;j<(*spc).ndim;j++){
            tmp1[j]=(*spc).score[j];
            tmp2[j]=(*spc).basis[j].beta;
            (*spc).basis[j].beta=0.;;
            for(i=0;i<(*spc).ndim;i++)tmp3[i][j]=(*spc).info[i][j];
         }
         startnow(spc,data);
         logl=pompall(spc,data,2,&i2);
         if(lnew>logl ){
            logl=lnew;
            for(j=0;j<(*spc).ndim;j++){
               (*spc).score[j]=tmp1[j];
               (*spc).basis[j].beta=tmp2[j];
               for(i=0;i<(*spc).ndim;i++)(*spc).info[i][j]=tmp3[i][j];
            }
         }
         else i1=i2;
      }
/* serious ctheta problems */
      if(i1==1)return 7;
/* solve the system */
      j=lusolve2((*spc).info,(*spc).ndim,(*spc).score);
/*    return 2 - something wrong with system */
      if(j==0) return 2;
/* adjust the tail shifts */
      if((*spc).ilow==1){
         (*spc).score[0]= -(*spc).score[0]/(*spc).basis[0].beta;
         if((*spc).score[0]<-100)(*spc).score[0]=-100;
      }
      if((*spc).iupp==1){
         (*spc).score[1]= -(*spc).score[1]/(*spc).basis[1].beta;
         if((*spc).score[1]<-100)(*spc).score[1]=-100;
      }
/* find the right step size */
      factor= -1.;
/* tail check */
      if((*spc).ilow==1 && (*spc).iupp==1 &&
         (*spc).basis[0].beta==0 && (*spc).basis[1].beta==0)return 6;
      if((*spc).ilow==1 && (*spc).basis[0].beta>=0)return 4;
      if((*spc).iupp==1 && (*spc).basis[1].beta>=0)return 3;
/* adjust beta */
      if((*spc).ilow==0)(*spc).basis[0].beta-=factor*(*spc).score[0];
      else (*spc).basis[0].beta= 
                 -myexp(factor*(*spc).score[0]+mylog(-(*spc).basis[0].beta));
      if((*spc).iupp==0)(*spc).basis[1].beta-=factor*(*spc).score[1];
      else (*spc).basis[1].beta= 
                 -myexp(factor*(*spc).score[1]+mylog(-(*spc).basis[1].beta));
      for(j=2;j<(*spc).ndim;j++)(*spc).basis[j].beta-=factor*(*spc).score[j];
      do{
/* new logl */
         if((*spc).ilow==1 && (*spc).iupp==1 &&
            (*spc).basis[0].beta==0 && (*spc).basis[1].beta==0)return 6;
         if((*spc).ilow==1 && (*spc).basis[0].beta>=0)return 4;
         if((*spc).iupp==1 && (*spc).basis[1].beta>=0)return 3;
         lnew=pompall(spc,data,0,&i);
/* did we win? */
         kk=0;
         if((lnew-logl)< -zerror)kk=1;
         if((lnew-logl)< -zerror * 100 && (*spc).ilow==1 &&
               (*spc).basis[0].beta> -1.e8 )kk=1;
         if((lnew-logl)< -zerror * 100 && (*spc).iupp==1 &&
            (*spc).basis[1].beta> -1.e8 )kk=1;
         if(kk==1 || (i==1 && fabs(factor)>0.1)){
/* adjust the stepsize */
            i=0;
            factor=factor/2.;
            if((*spc).ilow==0)(*spc).basis[0].beta+=factor*(*spc).score[0];
            else (*spc).basis[0].beta= 
                   -myexp(-factor*(*spc).score[0]+mylog(-(*spc).basis[0].beta));
            if((*spc).iupp==0)(*spc).basis[1].beta+=factor*(*spc).score[1];
            else (*spc).basis[1].beta= 
                   -myexp(-factor*(*spc).score[1]+mylog(-(*spc).basis[1].beta));
            for(j=2;j<(*spc).ndim;j++)
               (*spc).basis[j].beta+=factor*(*spc).score[j];
            if(fabs(factor)< 0.00001 && 
              (((*spc).iupp==1 && (*spc).basis[1].beta> -1.e8) ||
               ((*spc).ilow==1 && (*spc).basis[0].beta> -1.e8))) return 5;
            if(fabs(factor)< 0.00001) return 8;
/*             return 5/8 - too much step-halving */
         }
         if(i==1)return 7;
      } while(kk==1);
/* convergence */
      if(fabs(lnew-logl)<zerror && fabs(factor) > 0.96 )iter=maxiter+1000;
      if(fabs(lnew-logl)<zerror * 100 && (*spc).ilow==1 &&
            (*spc).basis[0].beta> -1.e8 )iter=maxiter+1000;
      if(fabs(lnew-logl)<zerror * 100 && (*spc).iupp==1 &&
            (*spc).basis[1].beta> -1.e8 )iter=maxiter+1000;
   }
   if(iter<maxiter+500) return 1;
/* return 1 - no convergence */
   logl=pompall(spc,data,1,&i);
   (*xxa)=logl;
   (*spc).aic=logl;
   if(silent==1){
      (void)mexPrintf("|| logl= %.2f (nd=%d)\n",logl,(*spc).ndim);
      (void)fflush(stdout);
   }
   (*spc).cth=ctheta;
   return 0;
}
/******************************************************************************/
static double pompall(spc,data,what,xp)
int what,*xp;
struct space *spc;
struct datastruct *data;
{
   double *ips,f,logl;
   double *cy,**cyy,**coef;
   int i,j,k,nip=(*spc).nip,ndim=(*spc).ndim;
   cy=pompalcy;
   cyy=pompalcyy;
   coef=pompcoef;
   ips=(*spc).ips;
/* numerical integration */
   for(i=0;i<nip-1;i++) for(j=0;j<4;j++){
      coef[i][j]=0.;
      for(k=0;k<ndim;k++)
         coef[i][j]+=(*spc).basis[k].beta*(*spc).basis[k].c2[i][j];
   }
   if((*spc).ilow==1) l1int(kints[0],ips[1],coef[0],1,what);
   else l2int(kints[0],(*spc).low,ips[1],coef[0],what);
   for(i=1;i<nip-2;i++)
      m1int(kints[i],ips[i],ips[i+1],what,coef[i],0);
   if((*spc).iupp==1) l1int(kints[nip-2],ips[nip-2],coef[nip-2],-1,what);
   else l2int(kints[nip-2],ips[nip-2],(*spc).upp,coef[nip-2],what);
/* ctheta */
   ctheta=0.;
   for(i=0;i<nip-1;i++) ctheta+=kints[i][0];
   if(ctheta>0)(*xp)=0;
   else{
      (*xp)=1.;
      return 0.;
   }
   ctheta=mylog(ctheta);
/* logl - uncensored */
   logl=0.;
   for(i=0;i<(*data).ndata;i++){
      if((*data).same[i]==0) 
         f=pol3(coef[(*data).idata[i]],(*data).data[i])-ctheta;
      logl+=f;
   }
   ctheta=myexp(-ctheta);
   if(what==0){
      return logl;
   }
/* get ctheta-j and ctheta-jk */
   initk(0,ndim,(*spc).score,(*spc).info,cy,cyy);
   (void)savecoden(spc,0,nip-1,(*spc).score,(*spc).info);

/* score and hessian - basic */
   for(i=0;i<ndim;i++){
      for(j=0;j<ndim;j++){
         (*spc).info[i][j]= (*data).ndata*(*spc).info[i][j]*ctheta;
      }
      (*spc).score[i]= -(*data).ndata*(*spc).score[i]*ctheta;
   }
   for(i=0;i<ndim;i++) for(j=0;j<ndim;j++)
      (*spc).info[i][j]-= (*spc).score[i]*(*spc).score[j]/(*data).ndata;
   if(what==1)for(i=0;i<ndim;i++)cuu[i]=(*spc).score[i];
/* uncensored - score */
   for(i=0;i<ndim;i++)(*spc).score[i]+=(*spc).basis[i].sumunc;
/* symmatrize */
   for(i=0;i<ndim;i++) for(j=i+1;j<ndim;j++)(*spc).info[i][j]=(*spc).info[j][i];
   return logl;
}
/******************************************************************************/
static void savecode1(spc,j,cz,czz,what)
int j;
struct space *spc;
double *cz,**czz,*what;
{
   int k,j2;
   for(k=0;k<(*spc).ndim;k++){
      if(j>=(*spc).basis[k].c3[0]&&j<=(*spc).basis[k].c3[1]){
         cz[k]+=inp3(what,(*spc).basis[k].c2[j]);
         for(j2=0;j2<=k;j2++){
            if(j>=(*spc).basis[j2].c3[0]&&j<=(*spc).basis[j2].c3[1])
               czz[k][j2]+=
                  mat3(what,(*spc).basis[k].c2[j],(*spc).basis[j2].c2[j]);
         }
      }
   }
   return;
}
/******************************************************************************/
static int savecoden(spc,i0,i1,cz,czz)
int i0,i1;
struct space *spc;
double *cz,**czz;
{
   int j;
   for(j=i0;j<i1;j++) savecode1(spc,j,cz,czz,kints[j]);
   return i1;
}
/******************************************************************************/
static void initk(i,ndim,v,mm,v2,mm2)
int ndim,i;
double *v,*v2,**mm,**mm2;
{
   int j,k;
   if(i==0){
      for(j=0;j<ndim;j++){
         for(k=0;k<ndim;k++)mm[j][k]=0.;
         v[j]=0.;
      }
   }
   else{
      for(j=0;j<ndim;j++){
         for(k=0;k<ndim;k++)mm[j][k]=mm2[j][k];
         v[j]=v2[j];
      }
   }
   return;
}
/******************************************************************************/
/* gets the rao statistic */
static double rao(spc,data,loc)
struct space *spc;
struct datastruct *data;
double loc;
{
   double **ii,*ss,r,iext[7],c2ext[4];
   int i,j,j0ext,ndim=(*spc).ndim;
   ii=raoii;
   ss=raoss;
   for(i=0;i<ndim;i++){
      for(j=0;j<ndim;j++)ii[i][j]=(*spc).info[i][j];
      ss[i]=0.;
   }
   (*bbx).c2=raoc2;
   j0ext=getnewc2(spc,data,loc,bbx,iext,c2ext);
   ss[ndim]=praox(spc,data,bbx,ii[ndim],iext,c2ext,j0ext);
   for(i=0;i<ndim;i++)ii[i][ndim]=ii[ndim][i];
   r=ss[ndim];
   i=lusolve2(ii,ndim+1,ss);
   if(i<0)r=0.;
   return ss[ndim]*r;
}
/******************************************************************************/
/* computes the new parts of score and hessian */
static double praox(spc,data,bb,iext,intext,c2ext,j0ext)
struct space *spc;
struct datastruct *data;
struct basisfunct *bb;
double *iext,intext[7],c2ext[4];
int j0ext;
{
   double sext;
   int i,j,ndim=(*spc).ndim;
   double int2ext[7];
   if(j0ext>=0)for(i=0;i<7;i++)int2ext[i]=kints[j0ext][i]-intext[i];
/* get ctheta-j and ctheta-jk */
   for(j=0;j<=ndim;j++) iext[j]=0.;
   sext=save22coden(spc,iext,bb,int2ext,j0ext,c2ext);
   for(j=0;j<=ndim;j++) iext[j]= (*data).ndata*iext[j]*ctheta;
   sext= -(*data).ndata*sext*ctheta;
   for(j=0;j<ndim;j++) iext[j]-= sext*cuu[j]/(*data).ndata;
   iext[ndim]-= sext*sext/(*data).ndata;
   sext+=(*bb).sumunc;
   return sext;
}
/******************************************************************************/
/* coefficients for a test-basis function */
static int getnewc2(spc,data,loc,bb,intext,c2ext)
struct space *spc;
struct datastruct *data;
struct basisfunct *bb;
double loc,intext[7],c2ext[4];
{
   int i,j,k,j0,j1,ii[3],j0ext;
   double coef[10],rrr[10],t[3],cc[3];
/* get (*spc).basis.c3 */
   t[1]=(*spc).knots[(*spc).nk-2];
   t[2]=(*spc).knots[(*spc).nk-1];
   t[0]=loc;
   for(j=0;j<3;j++){
      ii[j]=(*spc).nip-1;
      for(i=1;i<(*spc).nip;i++) if((*spc).ips[i]>=t[j]){
         ii[j]=i;
         i=(*spc).nip;
      }
   }
   (*bb).c3[0]=ii[0]-1;
   if(ii[1]<ii[0]-1)(*bb).c3[0]=ii[1];
   (*bb).c3[1]=(*spc).nip+1;
   if((*bb).c3[0]<0)(*bb).c3[0]=0;
   cc[0]=1.;
   cc[1]=(t[0]-t[2])/(t[2]-t[1]);
   cc[2]=(t[1]-t[0])/(t[2]-t[1]);
/* get (*spc).basis.c2 */
   for(j=0;j<(*spc).nip;j++) for(j0=0;j0<4;j0++)(*bb).c2[j][j0]=0.;
   for(j=(*bb).c3[0];j<=(*bb).c3[1];j++) for(j1=0;j1<3;j1++) if(j>=ii[j1]){
      (*bb).c2[j][3]+=cc[j1];
      (*bb).c2[j][2]-=3.*cc[j1]*t[j1];
      (*bb).c2[j][1]+=3.*cc[j1]*t[j1]*t[j1];
      (*bb).c2[j][0]-=cc[j1]*t[j1]*t[j1]*t[j1];
   }
/* get j0ext */
   j0ext=(*spc).nip+100;
   if(t[0]<(*spc).ips[1])j0ext=0;
   else for(i=1;i<(*spc).nip-2;i++){
      if(t[0]==(*spc).ips[i])j0ext= -1;
      else if(t[0]<(*spc).ips[i+1])j0ext=i;
      if(j0ext<(*spc).nip+50)i=(*spc).nip;
   }
   if(j0ext>(*spc).nip+50)j0ext=(*spc).nip-2;
/* get c2ext */
   for(i=0;i<4;i++)c2ext[i]=0.;
   for(j1=0;j1<3;j1++) if(t[j1]<=t[0]){
      c2ext[3]+=cc[j1];
      c2ext[2]-=3.*cc[j1]*t[j1];
      c2ext[1]+=3.*cc[j1]*t[j1]*t[j1];
      c2ext[0]-=cc[j1]*t[j1]*t[j1]*t[j1];
   }
/* get intext */
   if(j0ext>=0){
      for(j=0;j<4;j++){
         coef[j]=0.;
         for(k=0;k<(*spc).ndim;k++)
            coef[j]+=(*spc).basis[k].beta*(*spc).basis[k].c2[j0ext][j];
      }
      if(j0ext==0){
         if((*spc).ilow==1) l1int(rrr,t[0],coef,1,1);
         else l2int(rrr,(*spc).low,t[0],coef,1);
      }
      if(j0ext==((*spc).nip)-2) l2int(rrr,(*spc).ips[j0ext],t[0],coef,1);
      if(j0ext>0&&j0ext<((*spc).nip)-2)
         m1int(rrr,(*spc).ips[j0ext],t[0],1,coef,0);
     for(i=0;i<7;i++)intext[i]=rrr[i];
   }
/* get (*spc).basis.sumunrc */
   (*bb).sumunc=0.;
   for(j1=0;j1<(*data).ndata;j1++){
      j0=(*data).idata[j1];
      if(j0>=(*bb).c3[0]&&j0<=(*bb).c3[1]){
        if(j0!=j0ext || t[0]>(*data).data[j1])
           (*bb).sumunc+=pol3((*bb).c2[j0],(*data).data[j1]);
        else (*bb).sumunc+=pol3(c2ext,(*data).data[j1]);
      }
   }
   return j0ext;
}
/******************************************************************************/
/* integrates all steps for score and hessian */
static double save22coden(spc,czz,bb,int2ext,j0ext,c2ext)
int j0ext;
struct basisfunct *bb;
struct space *spc;
double *czz,int2ext[7],c2ext[4];
{
   int j,k,i1=((*spc).nip)-1;
   double cz=0;
/* correct the new one */
   if(j0ext>=0 && j0ext<i1)for(k=0;k<7;k++)kints[j0ext][k]-=int2ext[k];
/* regular stuff */
   for(j=0;j<i1;j++){
      if(j>=(*bb).c3[0]&&j<=(*bb).c3[1]){
         for(k=0;k<(*spc).ndim;k++)
            if(j>=(*spc).basis[k].c3[0]&&j<=(*spc).basis[k].c3[1])
               czz[k]+=mat3(kints[j],(*spc).basis[k].c2[j],(*bb).c2[j]);
         cz+=inp3(kints[j],(*bb).c2[j]);
         czz[(*spc).ndim]+=mat3(kints[j],(*bb).c2[j],(*bb).c2[j]);
      }
   }
/* correct the new one  part II */
   if(j0ext>=0 && j0ext<i1){
      for(k=0;k<(*spc).ndim;k++)
         if(j0ext>=(*spc).basis[k].c3[0]&&j0ext<=(*spc).basis[k].c3[1])
            if(j0ext>=(*bb).c3[0]&&j0ext<=(*bb).c3[1])
            czz[k]+=mat3(int2ext,(*spc).basis[k].c2[j0ext],c2ext);
      cz+=inp3(int2ext,c2ext);
      czz[(*spc).ndim]+=mat3(int2ext,c2ext,c2ext);
      for(k=0;k<7;k++)kints[j0ext][k]+=int2ext[k];
   }
   return cz;
}
/******************************************************************************/
static void remdim(spc,data,spc2,silent)
struct space *spc,*spc2;
struct datastruct *data;
int silent;

/* spc   - model to be worked on
   spc2  - temporary copy of the space
   data  - data
   silent- should info be printed? (1=yes) */

{
   double ratmax=0.,se,phi;
   int i,j,k,irmax=1,ndim=(*spc).ndim;

/* ratmax - largest phi/se ratio
   phi    - coefficient in power basis
   se     - standard errors
   i,j,k  - counters
   irmax  - for which coefficient is ratmax attained
   getip  - gets the
   setupspace - sets up a new space
   swapspace  - copies a space
   betarem    - new starting values */

/* invert the Hessian */
   luinverse((*spc).info,ndim);
/* copy for later use */
   swapspace(spc2,spc);

   for(i=0;i<(*spc).nk;i++){
/* compute the coefficient */
      phi = 0.;
      for(j=0;j<ndim;j++) phi+=(*spc).basis[j].beta*(*spc).basis[j].c1[i+2];
      phi=fabs(phi);
/* the standard error */
      se = 0.;
      for(j=0;j<ndim;j++)for(k=0;k<ndim;k++)
         se-=(*spc).basis[j].c1[i+2]*(*spc).basis[k].c1[i+2]*(*spc).info[j][k];
      se = sqrt(fabs(se));
/* Select for which knot se/phi takes it maximal value */
      if(se > phi * ratmax){
         ratmax = se / phi;
         irmax = i;
      }
   }
   if(silent==1) (void)mexPrintf("rem(%.2f), wald=%.2f ",
                       (*spc).knots[irmax],1./(ratmax*ratmax));

/* get (*spc).nk and (spc).ndim */
   (*spc).nk -= 1;
   (*spc).ndim -= 1;
/* remove the knot */
   for(i=irmax;i<(*spc).nk;i++){
       (*spc).iknots[i]=(*spc).iknots[i+1];
       (*spc).knots[i]=(*spc).knots[i+1];
   }
/* get (*spc).ips (*spc).nip (*data).idatx and (*spc).basis.iks */
/* get (*spc).basis.c1  (*spc).basis.c2 (*spc).basis.c3 (*spc).basis.sumunc */
   setupspace(spc,data);
/* get (*spc).basis.beta */
   betarem(spc2,spc,irmax);
}
/******************************************************************************/
static void betarem(spc2,spc,irmax)
struct space *spc,*spc2;
int irmax;
{
   int i,j,k;
   double **mm2,*r1,x,y;
   k=(*spc2).ndim;
   mm2=betaremm2;
   r1=betaremr1;

/* find A, the restriction */
   for(i=0;i<k;i++)mm2[0][i]=(*spc2).basis[i].c1[irmax+2];
/* solve the quadratic problem */
   solver(mm2,k,1,r1,spc2);
/* problems, a coefficient needing to be <0 is >=0 */
   if(((*spc).ilow==1 && r1[0]>=0) ||( (*spc).iupp==1 && r1[1]>=0)){ 
/* only restrictions on the lower tail */
      if((*spc).ilow==1 && (*spc).iupp==0){ 
         if(irmax<=2){ 
            for(i=0;i<((*spc2).nk)+2;i++){
               r1[i] = 0.;
               for(j=0;j<(*spc2).ndim;j++)
                  r1[i]+=(*spc2).basis[j].beta*(*spc2).basis[j].c1[i];
            }
            redo1(spc2,irmax,k);
            for(i=0;i<k+3;i++)for(j=0;j<k+3;j++)mm2[i][j]=0.;
            for(j=0;j<k+3;j++)for(i=0;i<k;i++)mm2[i][j]=(*spc2).basis[i].c1[j];
            for(i=k+1;i<k+3;i++)mm2[i][i]=1.;
            mm2[k][0]=1.;
            luinverse(mm2,k+3);
            for(i=0;i<k;i++){
               (*spc2).basis[i].beta=0.;
               for(j=0;j<k+3;j++)(*spc2).basis[i].beta+=mm2[j][i]*r1[j];
            }
         }
         for(i=0;i<k;i++)mm2[0][i]=(*spc2).basis[i].c1[irmax+2];
         for(i=0;i<k;i++)mm2[1][i]=0.;
         mm2[1][0]=1.;
         x=(*spc2).basis[0].beta;
         (*spc2).basis[0].beta=0.;
         solver(mm2,k,2,r1,spc2);
         r1[0]+=x;
      } 
/* only restrictions on the upper tail */
      if((*spc).ilow==0 && (*spc).iupp==1){  
         if(irmax>=k-2){
            for(i=0;i<((*spc2).nk)+2;i++){
               r1[i] = 0.;
               for(j=0;j<(*spc2).ndim;j++)
                  r1[i]+=(*spc2).basis[j].beta*(*spc2).basis[j].c1[i];
            }
            redo2(spc2,irmax,(*spc2).nk); 
            for(i=0;i<k+3;i++)for(j=0;j<k+3;j++)mm2[i][j]=0.;
            for(j=0;j<k+3;j++)for(i=0;i<k;i++)mm2[i][j]=(*spc2).basis[i].c1[j];
            for(i=k+1;i<k+3;i++)mm2[i][i]=1.;
            mm2[k][0]=1.;
            luinverse(mm2,k+3);
            for(i=0;i<k;i++){
               (*spc2).basis[i].beta=0.;
               for(j=0;j<k+3;j++)(*spc2).basis[i].beta+=mm2[j][i]*r1[j];
            }
            for(i=0;i<((*spc2).nk)+2;i++){
               r1[i] = 0.;
               for(j=0;j<(*spc2).ndim;j++)
                  r1[i]+=(*spc2).basis[j].beta*(*spc2).basis[j].c1[i];
            }
         }
         for(i=0;i<k;i++)mm2[0][i]=(*spc2).basis[i].c1[irmax+2];
         for(i=0;i<k;i++)mm2[1][i]=0.;
         mm2[1][1]=1.;
         x=(*spc2).basis[1].beta;
         (*spc2).basis[1].beta=0.;
         solver(mm2,k,2,r1,spc2);
         r1[1]+=x;
      } 
/* restrictions on both tails */
      if((*spc).ilow==1 && (*spc).iupp==1){ 
         if(irmax>k-3 || irmax<=2){
            for(i=0;i<((*spc2).nk)+2;i++){
               r1[i] = 0.;
               for(j=0;j<(*spc2).ndim;j++)
                  r1[i]+=(*spc2).basis[j].beta*(*spc2).basis[j].c1[i];
            }
            if(irmax<=2)redo1(spc2,irmax,k);
            if(irmax>k-3) redo2(spc2,irmax,(*spc2).nk);
            for(i=0;i<k+3;i++)for(j=0;j<k+3;j++)mm2[i][j]=0.;
            for(j=0;j<k+3;j++)for(i=0;i<k;i++)mm2[i][j]=(*spc2).basis[i].c1[j];
            for(i=k+1;i<k+3;i++)mm2[i][i]=1.;
            mm2[k][0]=1.;
            luinverse(mm2,k+3);
            for(i=0;i<k;i++){
               (*spc2).basis[i].beta=0.;
               for(j=0;j<k+3;j++)(*spc2).basis[i].beta+=mm2[j][i]*r1[j];
            }
         }
         for(i=0;i<k;i++)mm2[0][i]=(*spc2).basis[i].c1[irmax+2];
         for(i=0;i<k;i++)mm2[1][i]=0.;
         mm2[1][0]=1.;
         for(i=0;i<k;i++)mm2[2][i]=0.;
         mm2[2][1]=1.;
         x=(*spc2).basis[0].beta;
         (*spc2).basis[0].beta=0.;
         y=(*spc2).basis[1].beta;
         (*spc2).basis[1].beta=0.;
         solver(mm2,k,3,r1,spc2);
         r1[0]+=x;
         r1[1]+=y;
      }  
   } 
/* record beta */
   for(i=0;i<(*spc2).ndim;i++)(*spc2).basis[i].beta=r1[i];
/* get it to be a power basis */
   for(i=0;i<((*spc2).nk)+2;i++){
      r1[i] = 0.;
      for(j=0;j<(*spc2).ndim;j++)
         r1[i]+=(*spc2).basis[j].beta*(*spc2).basis[j].c1[i];
   } 
   for(i=irmax;i<(*spc2).nk;i++) r1[i+2]=r1[i+3];
   k=k-1;
   for(i=0;i<k+3;i++)for(j=0;j<k+3;j++)mm2[i][j]=0.;
   for(j=0;j<k+3;j++)for(i=0;i<k;i++)mm2[i][j]=(*spc).basis[i].c1[j];
   for(i=k+1;i<k+3;i++)mm2[i][i]=1.;
   mm2[k][0]=1.;
   luinverse(mm2,k+3);
   for(i=0;i<k;i++){
      (*spc).basis[i].beta=0.;
      for(j=0;j<k+3;j++)(*spc).basis[i].beta+=mm2[j][i]*r1[j];
   }
   return;
}
/******************************************************************************/
static void redo1(spc,irmax,k)
int k,irmax;
struct space *spc;
{
   int i,i0=0,i1=2,i2=3;
   double a,b,*t,*c;
   c=(*spc).basis[0].c1;
   t=(*spc).knots;
   if(irmax==2)i1=1;
   if(irmax==0)i0=1;
   for(i=0;i<=k+1;i++)c[i]=0.;
   a=t[i2]-t[i0];
   b=t[i2]-t[i1];
   c[i0+2]=1.;
   c[i1+2]= -a/b;
   c[i2+2]= -1.-c[i1+2];
   c[1]= -3.*(t[i0]*t[i0]+c[i1+2]*t[i1]*t[i1]+c[i2+2]*t[i2]*t[i2]);
   c[0]= -t[i2]*c[1]-c[i0+2]*a*a*a-c[i1+2]*b*b*b;
}
/******************************************************************************/
static void redo2(spc,irmax,k)
int k,irmax;
struct space *spc;
{
   int i,i0=k-4,i1=k-3,i2=k-1;
   double *t,*c;
   c=(*spc).basis[1].c1;
   t=(*spc).knots;
   if(irmax==k-3)i1=k-2;
   if(irmax==k-1)i2=k-2;
   for(i=0;i<=k+1;i++)c[i]=0.;
   c[i0+2]=1.;
   c[i1+2]=(t[i0]-t[i2])/(t[i2]-t[i1]);
   c[i2+2]= -1.-c[i1+2];
}
/******************************************************************************/
/* This routine computes  Inv(H)%*%t(A)%*%Inv(A%*%Inv(H)%*%t(A))%*%A          
   mm2 = A jxi, mm1 = Inv (H) ixi */
static void solver (mm2,i,j,r1,spc)
double **mm2,*r1;
int i,j;
struct space *spc;
/* r1   - new beta
   i    - (*spc).ndim
   j    - number of restrictions */
{
   int k0,k1,k2;
   double **c1,**c2,**c3,**mm1;
   c1=solc1;
   c2=solc2;
   c3=solc3;
/* k0,k1,k2 - counters
   c1,c2,c3 - half-products, as indicated below
   mm1      - hessian */
   if(i==j)for(k0=0;k0<i;k0++)r1[k0]=0.;
   mm1=(*spc).info;
/* c1=Inv(H)%*%t(A) ixi * ixj = ixj */
   for(k0=0;k0<i;k0++)for(k1=0;k1<j;k1++){
      c1[k0][k1]=0.;
      for(k2=0;k2<i;k2++)c1[k0][k1]+=mm1[k0][k2]*mm2[k1][k2];
   }
/* c2=A%*%c1 jxi * ixj = jxj */
   for(k0=0;k0<j;k0++)for(k1=0;k1<j;k1++){
      c2[k0][k1]=0.;
      for(k2=0;k2<i;k2++)c2[k0][k1]+=mm2[k0][k2]*c1[k2][k1];
   }
/* c2=Inv(c2)=Inv(A%*%Inv(H)%*%t(A)) */
   luinverse(c2,j);
/* c3=c1%*%c2=Inv(H)%*%t(A)%*%Inv(A%*%Inv(H)%*%t(A)) ixj * jxj = ixj */
   for(k0=0;k0<i;k0++)for(k1=0;k1<j;k1++){
      c3[k0][k1]=0.;
      for(k2=0;k2<j;k2++)c3[k0][k1]+=c1[k0][k2]*c2[k2][k1];
   }
/* c1=c3%*%A=Inv(H)%*%t(A)%*%Inv(A%*%Inv(H)%*%t(A))%*%A ixj * jxi = ixi */
   for(k0=0;k0<i;k0++)for(k1=0;k1<i;k1++){
      c1[k0][k1]=0.;
      for(k2=0;k2<j;k2++)c1[k0][k1]+=c3[k0][k2]*mm2[k2][k1];
   }
/* shift beta */
   for(k0=0;k0<i;k0++){
      r1[k0]=(*spc).basis[k0].beta;
      for(k1=0;k1<i;k1++)r1[k0]-=c1[k0][k1]*(*spc).basis[k1].beta;
   }
   return;
}
/******************************************************************************/
/* get the c2, c3 and sumunc elements of a bsis function */
static void getc2(spc,data)
struct space *spc;
struct datastruct *data;

/* spc  - model
   data - data */
{
   int i,j,k,l,m,n;
   double a,b;
   struct basisfunct *bn;
/* no deep meanings */
/* get (*spc).basis.c3 */
   for(i=0;i<(*spc).ndim;i++){
      bn=&((*spc).basis[i]);
      (*bn).c3[0]=(*bn).iks[0]-1;
      (*bn).c3[1]=(*bn).iks[2]+1;
      if(i==0) (*bn).c3[0]=0;
      if(i==1 || i==2) (*bn).c3[1]=(*spc).nip;
      if(i>2) (*bn).c3[1]=(*bn).iks[4]+1;
/* get (*spc).basis.c2 */
      for(j=0;j<(*spc).nip;j++) for(k=0;k<4;k++)(*bn).c2[j][k]=0.;
      for(j=(*bn).c3[0];j<=(*bn).c3[1];j++){
         l=5;
         if(i==0||i==1)l=3;
         if(i==2)l=4;
         if(i==0){
            (*bn).c2[j][0]+=(*bn).c1[0];
            (*bn).c2[j][1]+=(*bn).c1[1];
         }
         for(n=0;n<l;n++){
            if(i==0)m=n;
            if(i==1)m=(*spc).nk-3+n;
            if(i==2)m=(*spc).nk-4+n;
            if(i>2)m=i+n-3;
            a=(*spc).knots[m];
            b=(*bn).c1[2+m];
            if(j>=(*bn).iks[n]){
               (*bn).c2[j][3]+=b;
               b=a*b;
               (*bn).c2[j][2]-=3.*b;
               b=a*b;
               (*bn).c2[j][1]+=3.*b;
               b=a*b;
               (*bn).c2[j][0]-=b;
            }
         }
      }
/* get (*spc).basis.sumunc */
      (*bn).sumunc=0.;
      for(m=0;m<(*data).ndata;m++){
         l=(*data).idata[m];
         if(l>=(*bn).c3[0]&&l<=(*bn).c3[1])
           (*bn).sumunc+=pol3((*bn).c2[l],(*data).data[m]);
      } 
   }
   return;
}
/******************************************************************************/
/* get c1 - the power basis representation - for a basisfunction */
static void getc1(t,c,i,k)
double *c,*t;
int i,k;
{
/* get (*spc).basis.c1 */
   double a,b,d[10],r;
   int j;
   for(j=0;j<=k+1;j++)c[j]=0.;
   if(i==0){
      a=t[2]-t[0];
      b=t[2]-t[1];
      c[2]= 1.;
      c[3]= -a/b;
      c[4]= -c[2]-c[3];
      c[1]= -3.*(t[0]*t[0]+c[3]*t[1]*t[1]+c[4]*t[2]*t[2]);
      c[0]= -t[2]*c[1]-c[2]*a*a*a-c[3]*b*b*b;
   }
   if(i==1){
      c[k-1]=1.;
      c[k]=(t[k-3]-t[k-1])/(t[k-1]-t[k-2]);
      c[k+1]= -c[k]-c[k-1];
   }
   if(i==2) getonec1(c,k-2,t,k-4);
   if(i>2){
      getonec1(c,i-1,t,i-3);
      getonec1(d,0,t,i-2);
      a=0.;
      b=0.;
      for(j=0;j<4;j++){
         r=(t[k-1]-t[i+j-2]);
         a+=d[j]*r*r*r;
         r=(t[k-1]-t[i+j-3]);
         b+=c[i+j-1]*r*r*r;
      }
      for(j=0;j<4;j++)c[i+j]-=d[j]*b/a;
   } 
}
/******************************************************************************/
static void getonec1(c,i,t,j)
double *c,*t;
int i,j;
{
   c[i]=1.;
   c[i+3]=(t[j+2]-t[j])*(t[j]-t[j+1])/((t[j+2]-t[j+3])*(t[j+1]-t[j+3]));
   c[i+2]=(c[i+3]*(t[j+1]-t[j+3])+t[j+1]-t[j])/(t[j+2]-t[j+1]);
   c[i+1]=-1.-c[i+3]-c[i+2];
   return;
}
   
/******************************************************************************/
static void setupspace(spc,data)
struct space *spc;
struct datastruct *data;
{
   int i;
/* get (*spc).ips (*spc).nip (*data).idatx and (*spc).basis.iks */
   getip(spc,data);
/* get (*spc).basis.c1 */
   for(i=0;i<(*spc).ndim;i++)getc1((*spc).knots,(*spc).basis[i].c1,i,(*spc).nk);
/* get (*spc).basis.c2 (*spc).basis.c3 and (*spc).basis.sumunc */
   getc2(spc,data);
   return;
}
/******************************************************************************/
static int startspace(spc,data,strt,silent)
int silent,strt;
struct space *spc;
struct datastruct *data;
{
   int i,k,l,ok;
   double r,s;
/* place the knots */
   k=(*data).ndata;
   ok=1;
   if(strt==0){
      (*spc).iknots[0]=0;
      (*spc).iknots[1]=(int)(k/2);
      (*spc).iknots[2]=k-1;
      for(i=0;i<3;i++)
         (*spc).knots[i]=(*data).data[(*spc).iknots[i]];
      (*spc).nk=3;
      if(silent==1)(void)mexPrintf("Starting knots at %.2f, %.2f and %.2f ",
               (*spc).knots[0],(*spc).knots[1],(*spc).knots[2]);
      (*spc).ndim=2;
      if(silent==1)(void)fflush(stdout);
   }
   if(strt<0){
      if(strt== -1){
         l=((*spc).nk);
         r=l+2.;
         if(l>3){
         s=(double)l/((double)l-3.);
         for(i=1;i<l-1;i++)  (*spc).iknots[i]=(((i-1)*s+1.)/r)*k;
         }
         else (*spc).iknots[1]=(k-1)/2.;
         (*spc).iknots[0]=0;
         (*spc).iknots[l-1]=k-1;
      }
      if(strt== -2){
         l=((*spc).nk);
         r=l+4.;
         if(l>3){
         s=(double)(l+2)/((double)l-3.); 
         for(i=1;i<l-1;i++)  (*spc).iknots[i]=(((i-1)*s+1.)/r)*k;
         }
         else (*spc).iknots[1]=(k-1)/2.;
         (*spc).iknots[0]=1;
         (*spc).iknots[l-1]=k-2;
      }
      if(strt == -3){
         l=(*spc).nk-2;
         r=l+2.;
         s=0;
         if(l>3) s=(double)(l)/((double)l-3.);
         for(i=1;i<l-1;i++)  (*spc).iknots[i+1]=(((i-1)*s+1.)/r)*(k-8.)+4;
         (*spc).iknots[1]=4;
         (*spc).iknots[l]=k-5;
         (*spc).iknots[0]=0;
         (*spc).iknots[l+1]=k-1;
         l=l+2;
      }
      for(i=0;i<l;i++){
         (*spc).knots[i]=(*data).data[(*spc).iknots[i]];
         if(i>0)if((*spc).knots[i]<=(*spc).knots[i-1])ok=0;
      }
      (*spc).nk=l;
      if(ok==0)ok=rearrange(spc,data);
      if(ok==0)return ok;
      (*spc).ndim=l-1;
      if(silent==1){
         (void)mexPrintf("\nRestart: knots at ");
         for(i=0;i<l;i++)(void)mexPrintf("%.2f ",(*spc).knots[i]);
         (void)fflush(stdout);
      }
   }
   if((*spc).ilow==1) (*spc).low=(*data).data[0];
   if((*spc).iupp==1) (*spc).upp=(*data).data[k-1];
/* compute c1, c2, c3 and so on */
   setupspace(spc,data);
/* starting values */
   startnow(spc,data);
   return ok;
}
/******************************************************************************/
static void startnow(spc,data)
struct space *spc;
struct datastruct *data;
{
   int i,j0,j1;
   double r0,r1,s0,s1;
   for(i=0;i<(*spc).ndim;i++)(*spc).basis[i].beta=0.;
   r0=((*spc).knots[0]+(*spc).knots[1])/2.;
   r1=((*spc).knots[(*spc).nk-2]+(*spc).knots[(*spc).nk-1])/2.;
   j0=0;
   j1=0;
   s0=0.;
   s1=0.;
   for(i=0;i<(*data).ndata;i++){
      if((*data).data[i]<r0){
         s0+= r0-(*data).data[i];
         j0+=2;
      }
      if((*data).data[i]>r1){
         s1+= (*data).data[i]-r1;
         j1+=2;
      }
   }
   s0=2.*s0/(double)j0;
   s1=2.*s1/(double)j1;
   if((*spc).ilow==1) (*spc).basis[0].beta= -1./fabs(s0*(*spc).basis[0].c1[1]);
   if((*spc).iupp==1)(*spc).basis[1].beta=
      -1./fabs(s1*(*spc).basis[1].c2[(*spc).nip][1]);
   return;
}
/******************************************************************************/
static int rearrange(spc,data)
struct space *spc;
struct datastruct *data;
{
   int i,k,*ix,jx[500],nk=(*spc).nk,is,j,l;
   double *sorted;
   sorted=rearsorted;
   ix=rearix;
   for(i=0;i<(*data).ndata;i++){
      sorted[i]=(*data).data[i];
      ix[i]=i;
   }
   k=1;
   for(i=1;i<(*data).ndata;i++){
      if(sorted[i]>sorted[k-1]){
         sorted[k]=sorted[i];
         ix[k]=ix[i];
         k++;
      }
   }
   is=0;
   for(i=0;i<nk;i++){
      for(j=is;j<k;j++){
         if((*spc).knots[i]<=sorted[j]){
            jx[i]=j;
            is=j;
            j=k;
         }
      }
   }
   for(is=0;is<10;is++){
      for(j=1;j<nk-1;j++) if(jx[j]==jx[j-1]) if(jx[j+1]>jx[j])jx[j]++;
      for(j=nk-2;j>0;j--) if(jx[j]==jx[j+1]) if(jx[j-1]<jx[j])jx[j]--;
   }
   l=1;
   for(j=1;j<nk;j++)if(jx[j]==jx[j-1])l=0;
   if(l==0)return 0;
   for(i=0;i<nk;i++){
      (*spc).iknots[i]=ix[jx[i]];
      (*spc).knots[i]=sorted[jx[i]];
   }
   return 1;
}
/******************************************************************************/
/* selects integration points */
static void getip(spc,data)
struct space *spc;
struct datastruct *data;

/* spc - model
   data- data */
{
   int i,nip=1,*iips,j,k,*kips;
   double *ips;

/* i,j,k - counters
   kips  - integration points for knots
   iips  - index of integration points
   ips   - integration points
   nip   - number of integration points */

/* allocation */
   iips=getiips;
   ips=(*spc).ips;

/* the first two points */
   iips[0]= -4;
   iips[1]=(*spc).iknots[0];
   ips[0]=(*spc).low;
   ips[1]=(*spc).knots[0];
/* get (*spc).ips - the actual integration points */
   for(i=1;i<(*spc).nk;i++){
      j=(*spc).iknots[i]-(*spc).iknots[i-1];
      j=floor((double)(j/100.))+1;
/* integration points in between knots */
      for(k=1;k<j;k++){
         nip++;
         iips[nip]=(*spc).iknots[i-1]+k*((*spc).iknots[i]-(*spc).iknots[i-1])/j;
         ips[nip]=(*data).data[iips[nip]];
      }
/* every knot is an integration point */
      nip++;
      ips[nip]=(*spc).knots[i];
      iips[nip]=(*spc).iknots[i];
   }
/* the last integration point */
   nip++;
   ips[nip]=(*spc).upp;
   iips[nip]=(*data).ndata+4;
/* get (*spc).nip */
   nip++;
   (*spc).nip=nip;
/* get (*data).idatx */
   for(i=0;i<nip-1;i++) for(j=iips[i];j<=iips[i+1]-1;j++){
      if(j>=0 && j<(*data).ndata) (*data).idata[j]=i;
   }
/* get (*spc).basis.iks */
   kips=iips;
   for(i=0;i<(*spc).nk;i++){
      j=(*spc).iknots[i];
      kips[i]=(*data).idata[j];
   }
   for(i=0;i<3;i++)(*spc).basis[0].iks[i]=kips[i];
   for(i=0;i<3;i++)(*spc).basis[1].iks[i]=kips[i-3+(*spc).nk];
   if((*spc).ndim>2)for(i=0;i<4;i++)(*spc).basis[2].iks[i]=kips[i-4+(*spc).nk];
   for(j=3;j<(*spc).ndim;j++)for(i=0;i<5;i++)(*spc).basis[j].iks[i]=kips[j+i-3];
   return;
}
void rpqlsd(coef,knots,bnd,ipq,pq,lk,lp)
double *coef,*knots,*pq,*bnd;
int *ipq,*lk,*lp;
{
   double *kpl,**cpl,*ppl,*pqx,r;
   double *zz,cor;
   int i,j,nk,fst,lst;
   /* Gaussian quadrature coefficients */
   ww6[1 ]= 0.467913934572691; yy6[1 ]= 0.238619186083197;
   ww6[2 ]= 0.360761573048139; yy6[2 ]= 0.661209386466265;
   ww6[3 ]= 0.171324429379170; yy6[3 ]= 0.932469514203152;
   ww7[1 ]=  0.00178328072169643; yy7[1 ]=  0.99930504173577217;
   ww7[2 ]=  0.00414703326056247; yy7[2 ]=  0.99634011677195533;
   ww7[3 ]=  0.00650445796897836; yy7[3 ]=  0.99101337147674429;
   ww7[4 ]=  0.00884675982636395; yy7[4 ]=  0.98333625388462598;
   ww7[5 ]=  0.01116813946013113; yy7[5 ]=  0.97332682778991098;
   ww7[6 ]=  0.01346304789671864; yy7[6 ]=  0.96100879965205377;
   ww7[7 ]=  0.01572603047602472; yy7[7 ]=  0.94641137485840277;
   ww7[8 ]=  0.01795171577569734; yy7[8 ]=  0.92956917213193957;
   ww7[9 ]=  0.02013482315353021; yy7[9 ]=  0.91052213707850282;
   ww7[10]=  0.02227017380838325; yy7[10]=  0.88931544599511414;
   ww7[11]=  0.02435270256871087; yy7[11]=  0.86599939815409277;
   ww7[12]=  0.02637746971505466; yy7[12]=  0.84062929625258032;
   ww7[13]=  0.02833967261425948; yy7[13]=  0.81326531512279754;
   ww7[14]=  0.03023465707240248; yy7[14]=  0.78397235894334139;
   ww7[15]=  0.03205792835485155; yy7[15]=  0.75281990726053194;
   ww7[16]=  0.03380516183714161; yy7[16]=  0.71988185017161088;
   ww7[17]=  0.03547221325688239; yy7[17]=  0.68523631305423327;
   ww7[18]=  0.03705512854024005; yy7[18]=  0.64896547125465731;
   ww7[19]=  0.03855015317861563; yy7[19]=  0.61115535517239328;
   ww7[20]=  0.03995374113272034; yy7[20]=  0.57189564620263400;
   ww7[21]=  0.04126256324262353; yy7[21]=  0.53127946401989457;
   ww7[22]=  0.04247351512365359; yy7[22]=  0.48940314570705296;
   ww7[23]=  0.04358372452932345; yy7[23]=  0.44636601725346409;
   ww7[24]=  0.04459055816375657; yy7[24]=  0.40227015796399163;
   ww7[25]=  0.04549162792741814; yy7[25]=  0.35722015833766813;
   ww7[26]=  0.04628479658131442; yy7[26]=  0.31132287199021097;
   ww7[27]=  0.04696818281621002; yy7[27]=  0.26468716220876742;
   ww7[28]=  0.04754016571483031; yy7[28]=  0.21742364374000708;
   ww7[29]=  0.04799938859645831; yy7[29]=  0.16964442042399283;
   ww7[30]=  0.04834476223480295; yy7[30]=  0.12146281929612056;
   ww7[31]=  0.04857546744150343; yy7[31]=  0.07299312178779904;
   ww7[32]=  0.04869095700913972; yy7[32]=  0.02435029266342443;

/* allocation */
   kpl=dsvector((*lk)*4);
   ppl=dsvector((*lk)*4);
   cpl=dsmatrix((*lk)*4,4);
   pqx=dsvector((*lp));
/* get the integration points: the knots */
   nk=(*lk)+1;
   for(i=0;i<=nk;i++){
      if(i<nk && i>0)kpl[i]=knots[i-1];
      if(i==0){
         kpl[0]=knots[0]-1;
         if(bnd[0]>0.5)kpl[0]=bnd[1];
         else if(pq[0]<kpl[0])kpl[0]=pq[0]-1.;
      }
      if(i==nk){
         kpl[nk]=knots[nk-2]+1;
         if(bnd[2]>0.5)kpl[nk]=bnd[3];
         else if(pq[(*lp)-1]+1.>kpl[nk])kpl[nk]=pq[(*lp)-1]+1.;
      }
/* get the coeffiecients */
      cpl[i][0]=coef[0];
      cpl[i][1]=coef[1];
      cpl[i][2]=0.;
      cpl[i][3]=0.;
      for(j=0;i>j && j<(*lk);j++){
         cpl[i][3]+=coef[j+2];
         cpl[i][2]-=3.*coef[j+2]*knots[j];
         cpl[i][1]+=3.*coef[j+2]*knots[j]*knots[j];
         cpl[i][0]-=coef[j+2]*knots[j]*knots[j]*knots[j];
      }
      if(i>=nk-1){
         cpl[i][3]=0.;
         cpl[i][2]=0.;
      }
   }
/* compute the density */
   ppl[0]=0.;
   if(bnd[0]>0.5)ppl[1]=z2int(kpl[0],kpl[1],cpl[0]);
   else ppl[1]=z1int(kpl[1],cpl[0],1);
   for(i=1;i<nk-1;i++)ppl[i+1]=z3int(kpl[i],kpl[i+1],cpl[i],0)+ppl[i];
   if(bnd[2]>0.5) ppl[nk]=z2int(kpl[nk-1],kpl[nk],cpl[nk-1])+ppl[nk-1];
   else ppl[nk]=z1int(kpl[nk-1],cpl[nk-1],-1)+ppl[nk-1];
/* higher precision needed */
   if(ppl[nk]<0.99999 || ppl[nk]>1.00001){
/* integration points: knots times four */
      nk=4*(*lk)-2;
      for(i=0;i<=nk;i++){
         if(i<nk && i>0){
            j=floor((double)(i-1)/4.);
            r=(double)i/4.-j-0.25;
            kpl[i]=(1.-r)*knots[j]+r*knots[j+1];
         }
         if(i==0){
            kpl[0]=knots[0]-1;
            if(bnd[0]>0.5)kpl[0]=bnd[1];
            else if(pq[0]<kpl[0])kpl[0]=pq[0]-1.;
         }
         if(i==nk){
            kpl[nk]=knots[(*lk)-1]+1;
            if(bnd[2]>0.5)kpl[nk]=bnd[3];
            else if(pq[(*lp)-1]+1>kpl[nk])kpl[nk]=pq[(*lp)-1]+1.;
         }
/* get the coeffiecients */
         cpl[i][0]=coef[0];
         cpl[i][1]=coef[1];
         cpl[i][2]=0.;
         cpl[i][3]=0.;
         for(j=0;i>j*4 && j<(*lk);j++){
            cpl[i][3]+=coef[j+2];
            cpl[i][2]-=3.*coef[j+2]*knots[j];
            cpl[i][1]+=3.*coef[j+2]*knots[j]*knots[j];
            cpl[i][0]-=coef[j+2]*knots[j]*knots[j]*knots[j];
         }
         if(i>=nk-1){
            cpl[i][3]=0.;
            cpl[i][2]=0.;
         }
      }
/* compute the density */
      if(bnd[0]>0.5)ppl[1]=z2int(kpl[0],kpl[1],cpl[0]);
      else ppl[1]=z1int(kpl[1],cpl[0],1);
      for(i=1;i<nk-1;i++) ppl[i+1]=z3int(kpl[i],kpl[i+1],cpl[i],0)+ppl[i];
      if(bnd[2]>0.5) ppl[nk]=z2int(kpl[nk-1],kpl[nk],cpl[nk-1])+ppl[nk-1];
      else ppl[nk]=z1int(kpl[nk-1],cpl[nk-1],-1)+ppl[nk-1];
   }
/* correction factor */
   cor=ppl[nk];
/* correct the density */
   for(i=0;i<=nk;i++)ppl[i]=ppl[i]/ppl[nk];
   j=0;
/* initialize */
   if((*ipq)==0)zz=ppl;  
   else zz=kpl;
/* before the first point */
   for(j=0;j<(*lp) && pq[j]<=zz[0];j++){
      if((*ipq)==0){
         if(bnd[0]>0.5)pqx[j]=kpl[0];
         else pqx[j]= -1.0e100;
      }
      else pqx[j]=0.;
   }
/* before the first knot */
   fst=j;
   lst=j-1;
   for(j=j;j<(*lp) && pq[j]<=zz[1];j++) lst=j;
   if(lst>=fst){
      if((*ipq)==0) getq0(pq,pqx,fst,lst,cpl[0],kpl[0],bnd[0],cor);
      else getp0(pq,pqx,fst,lst,cpl[0],kpl[0],bnd[0],cor);
   }
/* per interval between integration points */
   for(i=1;i<nk-1;i++){
      fst=j;
      lst=j-1;
      for(j=j;j<(*lp) && pq[j]<=zz[i+1];j++) lst=j;
      if(lst>=fst){
         if((*ipq)==0)
            getq1(pq,pqx,fst,lst,cpl[i],kpl[i],kpl[i+1],ppl[i],ppl[i+1]);
         else getp1(pq,pqx,fst,lst,cpl[i],kpl[i],kpl[i+1],ppl[i],ppl[i+1]);
      }
   }
/* beyond the larst knot */
   fst=j;
   lst=j-1;
   for(j=j;j<(*lp) && pq[j]<zz[nk];j++) lst=j;
   if(lst>=fst){
      if((*ipq)==0) getq2(pq,pqx,fst,lst,cpl[nk-1],kpl[nk],bnd[2],cor);
      else getp2(pq,pqx,fst,lst,cpl[nk-1],kpl[nk],bnd[2],cor);
   }
/* outside the range */
   for(j=j;j<(*lp);j++){
      if((*ipq)==0){
         if(bnd[2]>0.5)pqx[j]=kpl[nk];
         else pqx[j]= 1.0e100;
      }
      else pqx[j]=1.;
   }
  for(j=0;j<(*lp);j++)pq[j]=pqx[j];
}
/******************************************************************************/
static void getp0(q,p,f,l,cf,k,b,cr)
double *q,*p,*cf,k,b,cr;
int f,l;
{
   int i; 
   if(b>0.5) for(i=f;i<=l;i++) p[i]=z2int(k,q[i],cf)/cr;
   else for(i=f;i<=l;i++) p[i]=z1int(q[i],cf,1)/cr;
}
/******************************************************************************/
static void getq0(p,q,f,l,cf,k,b,cr)
double *q,*p,*cf,k,b,cr;
int f,l;
{
   int i; 
   if(b>0.5)for(i=f;i<=l;i++) q[i]=pqexpi(2,k,p[i]/cr,cf);
   else for(i=f;i<=l;i++) q[i]=pqexpi(1,k,p[i]/cr,cf);
}
/******************************************************************************/
static void getp2(q,p,f,l,cf,k,b,cr)
double *q,*p,*cf,k,b,cr;
int f,l;
{
   int i; 
   if(b>0.5) for(i=f;i<=l;i++) p[i]=1.-z2int(q[i],k,cf)/cr;
   else for(i=f;i<=l;i++) p[i]=1.-z1int(q[i],cf,-1)/cr;
}
/******************************************************************************/
static void getq2(p,q,f,l,cf,k,b,cr)
double *q,*p,*cf,k,b,cr;
int f,l;
{
   int i; 
   if(b>0.5)for(i=f;i<=l;i++) q[i]=pqexpi(4,k,1.-p[i]/cr,cf);
   else for(i=f;i<=l;i++) q[i]=pqexpi(3,k,1.-p[i]/cr,cf);
}
/******************************************************************************/
static void getp1(q,p,f,l,cf,k0,k1,p0,p1)
double *p,*q,*cf,k0,k1,p0,p1;
int f,l;
{
   int i,j=0;
   double r;
   if(l-f>5)j=1;
   p[f]=z3int(k0,q[f],cf,j);
   r=p[f]+z3int(q[l],k1,cf,j);
   for(i=f+1;i<=l;i++) p[i]=z3int(q[i-1],q[i],cf,j)+p[i-1];
   r=p[l]+z3int(q[l],k1,cf,j);
   r=(p1-p0)/r;
   for(i=f;i<=l;i++)p[i]=p0+p[i]*r;
}
/******************************************************************************/
static void getq1(p,q,f,l,cf,k0,k1,p0,p1)
double *p,*q,*cf,k0,k1,p0,p1;
int f,l;
{
   int i,j;
   double y[51],f1[101],r,s;
   r=(k1-k0)/100.;
   for(i=0;i<101;i++) f1[i]=getf(cf,(double)(k0+r*i));
   y[0]=0.;
   for(i=1;i<=50;i++)y[i]=y[i-1]+r*(f1[2*(i-1)]+4*f1[2*i-1]+f1[2*i])/3.;
   s=(p1-p0)/y[50];
   for(i=0;i<=50;i++)y[i]=p0+y[i]*s;
   i=0;
   s=2.*r;
   for(j=f;j<=l;j++){
      q[j]=k0-1.;
      do{
         if(p[j]>=y[i] && p[j]<=y[i+1]) q[j]=k0+s*i+s*(p[j]-y[i])/(y[i+1]-y[i]);
         else i++;
      }
      while (q[j]<k0);
   }
}
/******************************************************************************/
/* computes integrals from -inf to t1 (j=1) or from t1 to inf (j1= -1)
   of exp(polynomial(c0)) */

static double z1int(t1,c0,j)
double t1,*c0;
int j;
{
   double f1;
   if(c0[1]<0) j = -j;
   f1 = mylog(fabs(1./c0[1])) + c0[1]*t1+c0[0];
   if(f1>600.) f1=600.;
   return (double)(j*myexp(f1));
}
/******************************************************************************/
/* computes integrals from t1 to t2 of exp(polynomial(c0)) */

static double z2int(t1,t2,c0)
double t1,t2,*c0;
{
   int i1=1;
   double f1,f2;
   if(t2==t1)return 0.;
   if(c0[1]!=0){
      if(c0[1]<0) i1 = -1;
      f1 = mylog(fabs(1./c0[1])) + c0[1]*t1+c0[0];
      f2 = f1 + c0[1]*(t2-t1);
      if(f1>600.) f1=600.;
      if(f2>600.) f2=600.;
      return (double)(i1*myexp(f2)-i1*myexp(f1));
   }
   else return (t2-t1)*myexp(c0[0]);
}
/******************************************************************************/
/* computes integrals from t1 to t2 of exp(polynomial(coef)) */

static double z3int(k1,k2,coef,accuracy)
double k1,k2,*coef;
int accuracy;
{
   double r1,r2,x,y,v,vv=0.;
   int i1;
   if(k2==k1)return 0.;
   r1 = ((k2 - k1) / 2);
   r2 = ((k2 + k1) / 2);
   if(accuracy==1){
      for(i1=1;i1<4;i1++){
         y=yy6[i1]*r1;
         v=r1*ww6[i1];
         x=r2-y;
         vv+=v*myexp(coef[0]+x*(coef[1]+x*(coef[2]+x*coef[3])));
         x=r2+y;
         vv+=v*myexp(coef[0]+x*(coef[1]+x*(coef[2]+x*coef[3])));
      }
   }
   else{
      for(i1=1;i1<33;i1++){
         y=yy7[i1]*r1;
         v=r1*ww7[i1];
         x=r2-y;
         vv+=v*myexp(coef[0]+x*(coef[1]+x*(coef[2]+x*coef[3])));
         x=r2+y;
         vv+=v*myexp(coef[0]+x*(coef[1]+x*(coef[2]+x*coef[3])));
      }
   }
   return vv;
}
/******************************************************************************/
/* 1: -inf -> x / 2: t -> x / 3: x -> inf / 4: x -> t  */
static double pqexpi(version,t,p,cf)
int version;
double t,p,*cf;
{
   if(cf[1]!=0. || version == 1 || version == 3){
      p=p*cf[1];
      if(version == 1 && p < 0)return myexp((double)600.);
      if(version == 3 && p > 0)return -myexp((double)600.);
      if(version==2 || version ==4)t=myexp(t*cf[1]+cf[0]);
      if(version == 2 && t+p < 0)return myexp((double)600.);
      if(version == 4 && t-p < 0)return -myexp((double)600.);
      if(version==1)return (mylog(p)-cf[0])/cf[1];
      if(version==2)return (mylog(t+p)-cf[0])/cf[1];
      if(version==3)return (mylog(-p)-cf[0])/cf[1];
      return (mylog(t-p)-cf[0])/cf[1];
   }
   if(version==2)return t+p/myexp(cf[0]);
   return t-p/myexp(cf[0]);
}
/******************************************************************************/
static double *dsvector(l)
int l;
/* allocate a double vector with subscript range v[0...l] */
{
   double *v;
   int i;
   v=(double *)Salloc(l+1,double); 
   for(i=0;i<=l;i++)v[i]=0.;
   return v;
}
/******************************************************************************/
static double getf(c,x)
double *c,x;
{
   return exp(c[0]+x*(c[1]+x*(c[2]+x*c[3])));
}
/******************************************************************************/
static double mylog(x)
double x;
{
if(x < 10.e-250)return (double)(-575.64627);
else return log(x);
}
/******************************************************************************/
static double myexp(x)
double x;
{
if(x > 576.)return exp((double)576.);
else return exp(x);
}
/******************************************************************************/
/* allocate an short vector with subscript range v[0...l] */
static short *issvector(l)
int l;
{
   int i;
   short *v;
   v=(short *)Salloc(l+1,short); 
   for(i=0;i<=l;i++)v[i]=0;
   return v;
}
/******************************************************************************/
/* allocate an int vector with subscript range v[0...l] */
static int *isvector(l)
int l;
{
   int *v,i;
   v=(int *)Salloc(l+1,int); 
   for(i=0;i<=l;i++)v[i]=0;
   return v;
}
/******************************************************************************/
/* computes integrals from t1 to t2  (numerically)
   of x^i (i<1, what=0; i<7 o.w.) times exp(polynomial(coef)) */
static void m1int(vv,k1,k2,what,coef,accuracy)

/* accuracy  - accuracy
   r1 and r2 - from (k1,k2) to (-1,1)         */

double k1,k2,*vv,*coef;
int accuracy,what;
{
   double r1,r2,x,y,z,v;
   int i1,i2,j;
   r1 = ((k2 - k1) / 2);
   r2 = ((k2 + k1) / 2);
   for(i1=0;i1<7;i1++)vv[i1]=0.;
   if(k2==k1)return;
   j=7;
   if(what==0)j=1;
   if(accuracy==1){
      for(i1=1;i1<4;i1++){
         y=yy6[i1]*r1;
         v=r1*ww6[i1];
         x=r2-y;
         z=v*myexp(coef[0]+x*(coef[1]+x*(coef[2]+x*coef[3])));
         vv[0]+=z;
         for(i2=1;i2<j;i2++){
            z=z*x;
            vv[i2]+=z;
         }
         x=r2+y;
         z=v*myexp(coef[0]+x*(coef[1]+x*(coef[2]+x*coef[3])));
         vv[0]+=z;
         for(i2=1;i2<j;i2++){
            z=z*x;
            vv[i2]+=z;
         }
      }
   }
   else{
      for(i1=1;i1<33;i1++){
         y=yy7[i1]*r1;
         v=r1*ww7[i1];
         x=r2-y;
         z=v*myexp(coef[0]+x*(coef[1]+x*(coef[2]+x*coef[3])));
         vv[0]+=z;
         for(i2=1;i2<j;i2++){
            z=z*x;
            vv[i2]+=z;
         }
         x=r2+y;
         z=v*myexp(coef[0]+x*(coef[1]+x*(coef[2]+x*coef[3])));
         vv[0]+=z;
         for(i2=1;i2<j;i2++){
            z=z*x;
            vv[i2]+=z;
         }
      }
   }
}
/******************************************************************************/
/* computes integrals from -inf to t1 (j=1) or from t1 to inf (j1= -1)
   of x^i (i<1, what=0; i<7 o.w.) times exp(polynomial(coef)) */

static void l1int(results,t1,coef,j,what)
int j,what;
double t1,*coef,*results;

{
   double u6,u5,u4,u3,u2,u1,u0,f1,b1=coef[1],b0=coef[0],b3[7];
   b3[0]=(double)1./b1;

   f1 = b3[0];
   results[0]=fctf1(b0,b1,t1,f1,j);
   if(what==0)return;
   b3[1]=b3[0]*b3[0];
   b3[2]=b3[1]*b3[0];
   b3[3]=b3[2]*b3[0];
   b3[4]=b3[3]*b3[0];
   b3[5]=b3[4]*b3[0];
   b3[6]=b3[5]*b3[0];

   u1 = b3[0];
   u0 = -b3[1];
   f1 = u1*t1+u0;
   results[1]=fctf1(b0,b1,t1,f1,j);

   u2 = b3[0];
   u1 = -2*b3[1];
   u0 = 2*b3[2];
   f1 = (u2*t1+u1)*t1+u0;
   results[2]=fctf1(b0,b1,t1,f1,j);

   u3 = b3[0];
   u2 = -3*b3[1];
   u1 = 6*b3[2];
   u0 = -6*b3[3];
   f1 = ((u3*t1+u2)*t1+u1)*t1+u0;
   results[3]=fctf1(b0,b1,t1,f1,j);

   u4 = b3[0];
   u3 = -4*b3[1];
   u2 = 12*b3[2];
   u1 = -24*b3[3];
   u0 = 24*b3[4];
   f1 = (((u4*t1+u3)*t1+u2)*t1+u1)*t1+u0;
   results[4]=fctf1(b0,b1,t1,f1,j);

   u5 = b3[0];
   u4 = -5*b3[1];
   u3 = 20*b3[2];
   u2 = -60*b3[3];
   u1 = 120*b3[4];
   u0 = -120*b3[5];
   f1 = ((((u5*t1+u4)*t1+u3)*t1+u2)*t1+u1)*t1+u0;
   results[5]=fctf1(b0,b1,t1,f1,j);

   u6 = b3[0];
   u5 = -6*b3[1];
   u4 = 30*b3[2];
   u3 = -120*b3[3];
   u2 = 360*b3[4];
   u1 = -720*b3[5];
   u0 = 720*b3[6];
   f1 = (((((u6*t1+u5)*t1+u4)*t1+u3)*t1+u2)*t1+u1)*t1+u0;
   results[6]=fctf1(b0,b1,t1,f1,j);

   return;
}
/******************************************************************************/
/* computes integrals from t1 to t2  (exactly)
   of x^i (i<1, what=0; i<7 o.w.) times exp(polynomial(coef)) */
static void l2int(results,t1,t2,coef,what)
int what;
double t1,t2,*coef,*results;

{
   double u6,u5,u4,u3,u2,u1,u0,f1,b1=coef[1],b0=coef[0],b3[7],f2;
   int i;
   if(b1!=0.){
      b3[0]=(double)1./b1;
 
      f1 = b3[0];
      f2 = b3[0];
      results[0]=fctf2(b0,b1,t1,t2,f1,f2);
      if(what==0)return;
      b3[1]=b3[0]*b3[0];
      b3[2]=b3[1]*b3[0];
      b3[3]=b3[2]*b3[0];
      b3[4]=b3[3]*b3[0];
      b3[5]=b3[4]*b3[0];
      b3[6]=b3[5]*b3[0];

      u1 = b3[0];
      u0 = -b3[1];
      f1 = u1*t1+u0;
      f2 = u1*t2+u0;
      results[1]=fctf2(b0,b1,t1,t2,f1,f2);

      u2 = b3[0];
      u1 = -2*b3[1];
      u0 = 2*b3[2];
      f1 = (u2*t1+u1)*t1+u0;
      f2 = (u2*t2+u1)*t2+u0;
      results[2]=fctf2(b0,b1,t1,t2,f1,f2);

      u3 = b3[0];
      u2 = -3*b3[1];
      u1 = 6*b3[2];
      u0 = -6*b3[3];
      f1 = ((u3*t1+u2)*t1+u1)*t1+u0;
      f2 = ((u3*t2+u2)*t2+u1)*t2+u0;
      results[3]=fctf2(b0,b1,t1,t2,f1,f2);

      u4 = b3[0];
      u3 = -4*b3[1];
      u2 = 12*b3[2];
      u1 = -24*b3[3];
      u0 = 24*b3[4];
      f1 = (((u4*t1+u3)*t1+u2)*t1+u1)*t1+u0;
      f2 = (((u4*t2+u3)*t2+u2)*t2+u1)*t2+u0;
      results[4]=fctf2(b0,b1,t1,t2,f1,f2);

      u5 = b3[0];
      u4 = -5*b3[1];
      u3 = 20*b3[2];
      u2 = -60*b3[3];
      u1 = 120*b3[4];
      u0 = -120*b3[5];
      f1 = ((((u5*t1+u4)*t1+u3)*t1+u2)*t1+u1)*t1+u0;
      f2 = ((((u5*t2+u4)*t2+u3)*t2+u2)*t2+u1)*t2+u0;
      results[5]=fctf2(b0,b1,t1,t2,f1,f2);

      u6 = b3[0];
      u5 = -6*b3[1];
      u4 = 30*b3[2];
      u3 = -120*b3[3];
      u2 = 360*b3[4];
      u1 = -720*b3[5];
      u0 = 720*b3[6];
      f1 = (((((u6*t1+u5)*t1+u4)*t1+u3)*t1+u2)*t1+u1)*t1+u0;
      f2 = (((((u6*t2+u5)*t2+u4)*t2+u3)*t2+u2)*t2+u1)*t2+u0;
      results[6]=fctf2(b0,b1,t1,t2,f1,f2);
      return;
   }
   b0=myexp(b0);
   results[0]=(t2-t1)*b0;
   if(what==0)return;
   f2=t2;
   f1=t1;
   for(i=1;i<7;i++){
     f2=f2*t2;
     f1=f1*t1;
     results[i]=b0*(f2-f1)/(double)(i+1);
   }
   return;
}
/******************************************************************************/
static double fctf1(b0,b1,t1,f1,j)
double b0,b1,t1,f1;
int j;
{
   if(f1<0) j = -j;
   f1 = mylog(fabs(f1)) + b1*t1+b0;
   if(f1>600.) f1=600.;
   return (double)(j*myexp(f1));
}
/******************************************************************************/
static double fctf2(b0,b1,t1,t2,f1,f2)
double b0,b1,t1,t2,f1,f2;
{
   int i1=1,i2=1;
   if(f1<0) i1 = -1;
   f1 = mylog(fabs(f1)) + b1*t1+b0;
   if(f1>600.) f1=600.;
   if(f2<0) i2 = -1;
   f2 = mylog(fabs(f2)) + b1*t2+b0;
   if(f2>600.) f2=600.;
   return (double)(i2*myexp(f2)-i1*myexp(f1));
}
/******************************************************************************/
static double pol3(coef,x)
double *coef,x;
{
   return coef[0]+x*(coef[1]+x*(coef[2]+x*coef[3]));
}
/******************************************************************************/
static double inp3(c1,c2)
double *c1,*c2;
{
   return c1[0]*c2[0]+c1[1]*c2[1]+c1[2]*c2[2]+c1[3]*c2[3];
}
/******************************************************************************/
static double mat3(c1,c2,c3)
double *c1,*c2,*c3;
{
   double x=0.;
   int i,j;
   for(i=0;i<4;i++)for(j=0;j<4;j++)x+=c1[i+j]*c2[i]*c3[j];
   return x;
}
/******************************************************************************/
/* copies one space into another space */
static void swapspace(s1,s2)
struct space *s1,*s2;
{
   int i,j,k;
   (*s1).ndim=(*s2).ndim;
   (*s1).nk=(*s2).nk;
   (*s1).cth=(*s2).cth;
   (*s1).nip=(*s2).nip;
   (*s1).aic=(*s2).aic;
   (*s1).low=(*s2).low;
   (*s1).upp=(*s2).upp;
   (*s1).ilow=(*s2).ilow;
   (*s1).iupp=(*s2).iupp;
   for(i=0;i<(*s1).nip;i++) (*s1).ips[i]=(*s2).ips[i];
   for(i=0;i<(*s1).nk;i++){
      (*s1).knots[i]=(*s2).knots[i];
      (*s1).iknots[i]=(*s2).iknots[i];
   }
   for(i=0;i<(*s1).ndim;i++){
      for(j=0;j<5;j++)(*s1).basis[i].iks[j]=(*s2).basis[i].iks[j];
      (*s1).score[i]=(*s2).score[i];
      for(j=0;j<(*s1).ndim;j++) (*s1).info[i][j]=(*s2).info[i][j];
      (*s1).basis[i].beta=(*s2).basis[i].beta;
      for(j=0;j<2;j++)(*s1).basis[i].c3[j]=(*s2).basis[i].c3[j];
      (*s1).basis[i].sumunc=(*s2).basis[i].sumunc;
      for(j=0;j<(*s1).nk+2;j++)(*s1).basis[i].c1[j]=(*s2).basis[i].c1[j];
      for(j=0;j<4;j++)for(k=0;k<(*s1).nip;k++)
         (*s1).basis[i].c2[k][j]=(*s2).basis[i].c2[k][j];
   }
   return;
}
/******************************************************************************/
static void quadalloc()
{
/* Gaussian quadrature coefficients */
   ww6[1 ]= 0.467913934572691; yy6[1 ]= 0.238619186083197;
   ww6[2 ]= 0.360761573048139; yy6[2 ]= 0.661209386466265;
   ww6[3 ]= 0.171324429379170; yy6[3 ]= 0.932469514203152;
   ww7[1 ]=  0.00178328072169643; yy7[1 ]=  0.99930504173577217;
   ww7[2 ]=  0.00414703326056247; yy7[2 ]=  0.99634011677195533;
   ww7[3 ]=  0.00650445796897836; yy7[3 ]=  0.99101337147674429;
   ww7[4 ]=  0.00884675982636395; yy7[4 ]=  0.98333625388462598;
   ww7[5 ]=  0.01116813946013113; yy7[5 ]=  0.97332682778991098;
   ww7[6 ]=  0.01346304789671864; yy7[6 ]=  0.96100879965205377;
   ww7[7 ]=  0.01572603047602472; yy7[7 ]=  0.94641137485840277;
   ww7[8 ]=  0.01795171577569734; yy7[8 ]=  0.92956917213193957;
   ww7[9 ]=  0.02013482315353021; yy7[9 ]=  0.91052213707850282;
   ww7[10]=  0.02227017380838325; yy7[10]=  0.88931544599511414;
   ww7[11]=  0.02435270256871087; yy7[11]=  0.86599939815409277;
   ww7[12]=  0.02637746971505466; yy7[12]=  0.84062929625258032;
   ww7[13]=  0.02833967261425948; yy7[13]=  0.81326531512279754;
   ww7[14]=  0.03023465707240248; yy7[14]=  0.78397235894334139;
   ww7[15]=  0.03205792835485155; yy7[15]=  0.75281990726053194;
   ww7[16]=  0.03380516183714161; yy7[16]=  0.71988185017161088;
   ww7[17]=  0.03547221325688239; yy7[17]=  0.68523631305423327;
   ww7[18]=  0.03705512854024005; yy7[18]=  0.64896547125465731;
   ww7[19]=  0.03855015317861563; yy7[19]=  0.61115535517239328;
   ww7[20]=  0.03995374113272034; yy7[20]=  0.57189564620263400;
   ww7[21]=  0.04126256324262353; yy7[21]=  0.53127946401989457;
   ww7[22]=  0.04247351512365359; yy7[22]=  0.48940314570705296;
   ww7[23]=  0.04358372452932345; yy7[23]=  0.44636601725346409;
   ww7[24]=  0.04459055816375657; yy7[24]=  0.40227015796399163;
   ww7[25]=  0.04549162792741814; yy7[25]=  0.35722015833766813;
   ww7[26]=  0.04628479658131442; yy7[26]=  0.31132287199021097;
   ww7[27]=  0.04696818281621002; yy7[27]=  0.26468716220876742;
   ww7[28]=  0.04754016571483031; yy7[28]=  0.21742364374000708;
   ww7[29]=  0.04799938859645831; yy7[29]=  0.16964442042399283;
   ww7[30]=  0.04834476223480295; yy7[30]=  0.12146281929612056;
   ww7[31]=  0.04857546744150343; yy7[31]=  0.07299312178779904;
   ww7[32]=  0.04869095700913972; yy7[32]=  0.02435029266342443;
}
/******************************************************************************/
static double **dsmatrix(r,c)
int r,c;
/* allocate a double matrix with subscript range m[0..r][0..c] */
{
   int i;
   double **m;
   m=(double **) Salloc(r+1,double*); 
   for(i=0;i<=r;i++) m[i]=dsvector(c);
   return m;
}

int compare (const void * a, const void * b)
{
  double temp = *(double*)a - *(double*)b;
  
  if (temp > 0)
    return 1;
  else if (temp < 0)
    return -1;
  else
    return 0;
}

double *tssdvec(nh)
int nh;
{
   return (double *)mxCalloc((long) (nh),sizeof(double));
}

double *tssdvec0(nh)
int nh;
{
  double *u;
  int i;
  u = tssdvec(nh);
  for(i=0;i<nh;i++){
    u[i] = 0.0;
  }
  return u;
}

int *tssivec(nh)
int nh;
{
   return (int *)mxCalloc((long) (nh),sizeof(int));
}

int *tssivec0(nh)
int nh;
{
  int *u;
  int i;
  u = tssivec(nh);
  for(i=0;i<nh;i++){
    u[i] = 0;
  }
  return u;
}

double get_sum(int n, double *y){
  double dout = 0.0;
  while(n--){
    dout += *y++;
  }
  return dout;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{  
    int i,j,n,nn,*ls_ip,*ls_ad,m,ww;
    double *ls_coef,*ls_dp,*ls_logl,*ls_kts,w,*ls_y;
    double *my_kts,xi_sub,x_min,x_max;
    double *x,*y,*st_knots, binwidth;    
    
    x = mxGetPr(prhs[0]);
    y = mxGetPr(prhs[1]);
    n = mxGetNumberOfElements(prhs[0]);
    binwidth = (x[n-1] - x[0])/(n-1);
/*
      mexPrintf("n: %i\n",n);
  mexPrintf("x:\n");
  for (i = 0; i < n; i++)
  {
      if (i % 19 == 0)
          mexPrintf(" %i: ",i+1);
      mexPrintf(" %lf",x[i]);
      if (i % 19 == 18)
          mexPrintf("\n");
  }
  mexPrintf("\n");  
  mexEvalString("drawnow");
  mexPrintf("y:\n");
  for (i = 0; i < n; i++)
  {
      if (i % 19 == 0)
          mexPrintf(" %i: ",i+1);
      mexPrintf(" %lf",y[i]);
      if (i % 19 == 18)
          mexPrintf("\n");
  }
  mexPrintf("\n");  
  mexPrintf("binwidth: %lf\n",binwidth);
    */
    nn = (int) get_sum(n,y);

    ls_y = tssdvec0(n);
    ls_ip = tssivec0(7);
    ls_ad = tssivec0(1000);
    ls_coef = tssdvec0(nn);
    ls_dp = tssdvec0(3);
    ls_logl = tssdvec0(1000);
    ls_kts = tssdvec0(1000);
    
    my_kts = tssdvec0(3);
    ls_ip[0] = nn;
    ls_ip[1] = 0;
    ls_ip[2] = 3;
    ls_ip[3] = 0;
    ls_ip[4] = 1;
    ls_ip[5] = 1;
    ls_ip[6] = -1;
    m = 0;
    
    x_min = 100.0;
    x_max = -100.0;

    for(i=0;i<n;i++)
    {
        ww = (int)(y[i] + 0.5);
        if ((x[i] > x_max) && (y[i] > 0.5)) x_max = x[i];
        if ((x[i] < x_min) && (y[i] > 0.5)) x_min = x[i];
        for(j=0;j<ww;j++)
        {
            ls_coef[m] = ((double)j/(double)(ww - 1)) - 0.5;
            ls_coef[m] *= binwidth;
            ls_coef[m] += x[i];
        if ((ls_coef[m] > DBL_EPSILON) && (1.0 - ls_coef[m] > DBL_EPSILON))
            m++;
        }
    }
  
    /*  printf("xmin = %le, xmax = %le\n",x_min,x_max); */

    /*  memcpy(xxxx,ls_coef,sizeof(double)*m); */
  

    ls_dp[0] = -1.0;
    ls_dp[1] = 0.0;
    ls_dp[2] = 0.0;
    ls_kts[0] = ls_coef[0];
    ls_kts[2] = ls_coef[(m-1)];
    ls_kts[1] = 0.5 * (ls_kts[0] + ls_kts[2]);
    for(i=0;i<3;i++)
    {
        my_kts[i] = ls_kts[i];
    }
    ls_ip[0] = m;
    ls_ip[2] = 0;

/*    mexPrintf("ls_ip:\n");
  for (i = 0; i < 7; i++)
  {
      mexPrintf(" %i",ls_ip[i]);
  }
  mexPrintf("\n");
  mexPrintf("ls_coef (%i):\n",nn);
  for (i = 0; i < nn; i++)
  {
      if (i % 19 == 0)
          mexPrintf(" %i: ",i+1);
      mexPrintf(" %lf",ls_coef[i]);
      if (i % 19 == 18)
          mexPrintf("\n");
  }
  mexPrintf("\n");
  mexPrintf("ls_dp:\n");
  for (i = 0; i < 3; i++)
  {
      mexPrintf(" %lf",ls_dp[i]);
  }
  mexPrintf("\n");
  mexPrintf("ls_logl:\n");
  for (i = 0; i < 1000; i++)
  {
      if (i % 19 == 0)
          mexPrintf(" %i: ",i+1);
      mexPrintf(" %lf",ls_logl[i]);
      if (i % 19 == 18)
          mexPrintf("\n");
  }
  mexPrintf("\n");
  mexPrintf("ad:\n");
  for (i = 0; i < 1000; i++)
  {
      if (i % 19 == 0)
          mexPrintf(" %i: ",i+1);
      mexPrintf(" %i",ls_ad[i]);
      if (i % 19 == 18)
          mexPrintf("\n");
  }
  mexPrintf("\n");
  mexPrintf("kts:\n");
  for (i = 0; i < 1000; i++)
  {
      if (i % 19 == 0)
          mexPrintf(" %i: ",i+1);
      mexPrintf(" %lf",ls_kts[i]);
      if (i % 19 == 18)
          mexPrintf("\n");
  }
  mexPrintf("\n");*/
  nlogcensor(ls_ip,ls_coef,ls_dp,ls_logl,ls_ad,ls_kts);

  if ((ls_ip[0] > 0) && (ls_ip[0] < 100))
  {
    j = 1;
  } 
  else 
  {
    x_min += DBL_EPSILON;
    x_max -= DBL_EPSILON;
    j = 0;
    for(i=0;i<ls_ip[1];i++)
    {
      if ((ls_kts[i] > x_min) && (ls_kts[i] < x_max))
      {
        j++;
      }
    }
    if (j == 0)
    {
      j = 1;
    }
  }
  
  plhs[0] = mxCreateDoubleMatrix(j,1,mxREAL);
  st_knots = mxGetPr(plhs[0]);
  
  if ((ls_ip[0] > 0) && (ls_ip[0] < 100))
  {
    st_knots[0] = my_kts[1];
  } 
  else 
  {
    x_min += DBL_EPSILON;
    x_max -= DBL_EPSILON;
    j = 0;
    for(i=0;i<ls_ip[1];i++)
    {
      if ((ls_kts[i] > x_min) && (ls_kts[i] < x_max))
      {
        st_knots[j++] = ls_kts[i];
      }
    }
    if (j == 0)
    {
      st_knots[0] = my_kts[1];
    }
  }
  
  mxFree(ls_y);
  mxFree(ls_ip);
  mxFree(ls_ad);
  mxFree(ls_coef);
  mxFree(ls_dp);
  mxFree(ls_logl);
  mxFree(ls_kts);
  mxFree(my_kts);                  
}
