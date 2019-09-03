Readme for Custom Code Directory for AgoraCart
-----------------------------------
April 21, 2000
Revised June 15, 2000
Revised August 22, 2000
Revised September 15, 2000
Revised May 7, 2003

This directory is for installation of custom libraries.  The only thing
that will be delivered in this directory are ".txt" files that might be
useful to setting up custom perl libraries. 

AgoraCart will automatically load the custom libraries if they are found
in this directory.  You may place whatever code you like in such a
library, including custom shipping logic or support routines for use with
agorascript and code to load other libraries.  Only files ending in .pl
are loaded, in fact all such files are loaded, so do not make anything
other than a legitimate perl library have the .pl ending! 

You should chmod .pl files in this dir 644.

If you are using "secondary" (aka multiple) payment gateways, place them in this
directory so they will be available at checkout time!   For example, zOffline will be
your primary gateway set in main settings.  Then you wanted to use Authorize.Net and
Offline as two gateways that you wish to offer.  Place copies of the the
Offline-order_lib.pl as well as the AuthorizeNet-order_lib.pl files in this directory.  This will
load those order libraries so that they are avialable for your order processing.


