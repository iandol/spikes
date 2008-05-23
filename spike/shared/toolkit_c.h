/*
 *  Copyright 2006, Weill Medical College of Cornell University
 *  All rights reserved.
 *
 *  This software is distributed WITHOUT ANY WARRANTY
 *  under license "license.txt" included with distribution and
 *  at http://neurodatabase.org/src/license.
 */
/* Some useful constants */
#define MAXCHARS 256
#define MAXPATH 260
#define BITS_IN_A_BYTE 8

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <limits.h>
#include "../input/input_c.h"
#include "../entropy/entropy_c.h"
#include "hist_c.h"
#include "gen_c.h"
#include "sort_c.h"

#ifdef TOOLKIT
#include "mex.h"
#endif

/* Some useful macros */
#define NAT2BIT(x) x/log(2)
#define LOGZ(x) (x <= 0 ? 0 : log(x))
#define LOG2Z(x) NAT2BIT(LOGZ(x))
#define XLOGX(x) (-x*LOGZ(x))
#define XLOG2X(x) (-x*LOG2Z(x))
#define MAX(a,b) (a > b ? a : b) 
#define MIN(a,b) (a < b ? a : b) 
#define MIN3(a,b,c) MIN(MIN(a,b),c)

