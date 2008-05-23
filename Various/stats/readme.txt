circStat - circular statistics toolbox
======================================

these toolbox contains some functions to compute circular statistics. these must be used in the case of circular data, where normal statistical tests and measures fail. for references on the topic see

Statistical analysis of circular data, N.I. Fisher
Topics in circular statistics, S.R. Jammalamadaka et al. 

contents:
circMean 	  - circular mean direction
circVar 	  - circular variance, measure of dispersion
circResLength - resulting vector length, measure of concentration
circTestR 	  - rayleigh's test for nonuniformity
circCorr 	  - correlation coefficient between circular data
rad2ang		  - converts radians to angles
ang2rad		  - converts angles to radians

all funtions take arguments in radians (all but ang2rad, that is)

copyright (c) 2006 philipp berens
berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens
distributed under GPL with no liability
http://www.gnu.org/copyleft/gpl.html
