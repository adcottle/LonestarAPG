Custom Code Directory for manager.cgi
-------------------------------------
April 21, 2000
Revised June 15, 2000
Revised September 15, 2000

This directory is for installation of custom libraries.  The only thing
that will be delivered in this directory are ".txt" files that might be
useful to setting up custom perl libraries. 

The manager.cgi will automatically load the custom libraries if they are
found in this directory.  You may place whatever code you like in such a
library, including custom libraries for inventory, custom tracking, or
support routines for use with databases and code to load other libraries.
Only files ending in .pl are loaded, in fact all such files are loaded, so
do not make anything other than a legitimate perl library have the .pl
ending!

You should chmod files in this dir 644.
