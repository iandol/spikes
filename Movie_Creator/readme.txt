*---------------------------------------------------------*
|            Temporal Movie Creator v0.3                  |
|            (Rowland Sillito April 2002)                 |
|---------------------------------------------------------|
| Written as an accessory to Ian's Spike Analysis program |
| [ian]     added a movie frame summary (Mar 2001)        |
| [rowland] timeslice choice (in spikes) & code tidyup    |
|           & max-value display & AVI export (Apr 2002)   |
*---------------------------------------------------------*


===Changes========(Rowland - April 2002)===================
1. Have now got rid of the old AVI export routine - as it's 
   now built into Matlab (as of v6).
2. CreateMovie now acts on a timeslice as chosen in spikes
   by measuring from a psth / typing in the min/max boxes.
3. After a movie has first been created (eg. auto scaled)
   a message box now displays the max/min values for the
   movie frames, so it can be recreated with a meaningful
   scale. 
===========================================================


===========================================================
Make sure this directory and its children are in the matlab
path definition.

This program works in conjunction with and is executed from
Ian's spikes.m program.

called as follows:

	createmovie;
===========================================================