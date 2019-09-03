March 14, 2000
Updated April 29, 2000
Rewrite June 15, 2000
Updated September 2, 2001
Updated December 31, 2002

These are the wrapper programs, and some pre-compiled versions.  If your
OS is in the list below, try to follow those directions as step one.

If you are not sure what ID your hosting account runs under, you may
download the test_id.cgi script at http://www.AgoraCart.com/download.htm

If you you do not have TELNET or SSH type access, cannot get it, and
your SUID bit does not run under your ID, then you will need to ask your
server administrator to install the wrappers for you.  If they are unwilling to
perform this for you we recommend that that you check out the authorized
hosting companies listed at AgoraCart.com

     DIRECTIONS FOR SPECIFIC OS's
     ============================

for directions for your OS, if available.

To use the makefile, just type 

    make wrapper

and it will use the 'cc' compiler to compile and set permissions.
Make sure

The wrapper programs are designed to help keep AgoraCart
running more safely.  Hopefully your web hosting company has things setup
on your Unix host such that scripts run under your user id instead of a
generic account.  If not, and you want to run scripts under your id, you
will need a wrapper program.  It may also prove useful in "Offline" mode
to solve file permissions problems when using a different user id for
https:// calls (often happens if you are running under a "borrowed" server
certificate).

If you are installing the wrapper because your scripts do not run under
your own id normally and the SUID bit cannot be set for scripts on your
OS, you will need to install for both agora and the manager.  If you are
just solving https:// problems, you may not need the manager wrapper if
you won't run the manager from the https:// address. 

The provided wrappers were tested under Linux.  Some OS's allow scripts to
have their SUID bit set (Solaris for example) and do not need a wrapper. 
Some other OS's are "broken" and perl complains loudly, hence the need for
this wrapper program. 

Optimally, you will be running on a system that runs scripts under your id
and will have no need for a wrapper.  Many people do run web store type
programs under generic user id's without incident, but since file
permissions need to be "loosened" to allow this, it is inherently less
secure.  Many other cart programs use these unsecure settings but don't
let you know they are doing it!

The latest version wrapper programs available are 3.0a.  There was a
vulnerability with 2.0a and earlier wrappers in that a symbolic link could
be used to gain access to your web site.  By using the 2.0b (download
at AgoraCart.com) or the new 3.0a wrapper this vulnerability is eliminated.

============================================================================

DIRECTIONS FOR SPECIFIC OS's
============================

LINUX:
------
    Linux does not allow the SUID bit to be set for scripts on older
  kernels.  At AgoraCart.com (security page), you will find pre-complied wrappers
  in the tar file linux_wrap.tar.  After un-tarring, move the files to the
  appropriate directories and follow the steps starting with step 2
  listed in the comment header for wrap_mgr.c and wrap_agc.c respectively. 
  (the compilation step is done already)  You will need TELNET or SSH access to 
  complete these steps.  The command to un-tar the files compiled
  under slackware 3.4 (2.0 series kernels and 2.2 kernals) is:  

    tar -xvf linux_20_wrap.tar
               or
    tar -xvf linux_22_wrap.tar

------- Part 1 ------

you may also try the manual compiling method outlined below on newer Linux systems:

Directions for wrap_agc.c:

1a) upload wrap_agc.c (ascii mode) to same location as  the agora.cgi file.
      In newer versions it is already there.

1b) Compile this C program (use cc if you don't have gcc):

     gcc -o wrap_agc.o wrap_agc.c

2) Set permissions on the wrapper so it runs under your id:

     chmod 555 wrap_agc.o
         or chmod 4555 wrap_agc.o  (some servers this works also/instead)
     chmod a+s wrap_agc.o   (some servers this works OK)

3) Agora.cgi 3.1+ will detect the wrapper and use it automatically if it
   is properly placed in the same directory.

------- Part 2 ------

Directions for wrap_mgr.c:

1a) upload wrap_mgr.c (ascii mode) to same location as the manager.cgi file ...
     in the store's /protected directory.  In newer versions it is already there.

1b) Compile this C program (use cc if you don't have gcc):

     gcc -o wrap_mgr.o wrap_mgr.c

2) Set permissions on the wrapper so it runs under your id:

     chmod 555 wrap_mgr.o
         or chmod 4555 wrap_mgr.o  (some servers this works also/instead)
     chmod a+s wrap_mgr.o   (some servers this works OK)

3) Manager.cgi 3.1+ will detect the wrapper and use it automatically if it
   is properly placed in the same directory.



SOLARIS:
--------
    You probably do not need a wrapper program, as modern Solaris kernels
  have the code to allow for SUID bit to be properly set on your scripts
  in case your web server does not automatically do that for you.  From
  your TELNET or SSH session, use the commands: 

    chmod a+s agora.cgi   (from the main directory)
    chmod a+s manager.cgi (from the ./protected directory)

  That should enable scripts to run under the acct owner's id, provided
  that those files are "properly owned" by the account owner.  Also, this
  assumes your http server allows SUID programs to be executed.  If your
  web server does not allow the execution of SUID programs, you can then 
  compile and install the wrappers.


FreeBSD and Other Unix or Unix-like OS:
---------------------------

  Try to use the SUID bit on the script, or ask your system administrator
if the SUID bit works with scripts.  If it does not or you prefer to use
the wrapper program, just follow the directions in the comments at the
top of each wrapper program.  If that doesn't work consult your system
administrator or tech support dept. at your hosting company.

Step 1: Manual Wrapper compile Directions for wrap_agc.c:

1a) upload wrap_agc.c (ascii mode) to same location as  the agora.cgi file.
      In newer versions it is already there.

1b) Compile this C program (use cc if you don't have gcc):

     gcc -o wrap_agc.o wrap_agc.c

2) Set permissions on the wrapper so it runs under your id:

     chmod 555 wrap_agc.o
     chmod a+s wrap_agc.o   (some servers this works OK)
     chmod 4555 wrap_agc.o  (some servers this works also/instead)

3) Agora.cgi 3.1+ will detect the wrapper and use it automatically if it
   is properly placed in the same directory.


Step 2: Directions for wrap_mgr.c:

1a) upload wrap_mgr.c (ascii mode) to same location as the manager.cgi file ...
     in the store's /protected directory.  In newer versions it is already there.

1b) Compile this C program (use cc if you don't have gcc):

     gcc -o wrap_mgr.o wrap_mgr.c

2) Set permissions on the wrapper so it runs under your id:

     chmod 555 wrap_mgr.o
     chmod a+s wrap_mgr.o   (some servers this works OK)
     chmod 4555 wrap_mgr.o  (some servers this works also/instead)

3) Manager.cgi 3.1+ will detect the wrapper and use it automatically if it
   is properly placed in the same directory.
