/*

Simple wrapper program to allow people to suid to their own user id.
Version 3.0a

Directions:

1) Compile this C program (use cc if you don't have gcc):

     gcc -o wrap_mgr.o wrap_mgr.c

2) Set permissions on the wrapper so it runs under your id:

     chmod 555 wrap_mgr.o
     chmod a+s wrap_mgr.o   (some servers this works OK)
     chmod 4555 wrap_mgr.o  (some servers this works also/instead)

3) Manager.cgi 3.1+ will detect the wrapper and use it automatically if it
   is properly placed in the same directory.

*/

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "stdio.h"
main()
{
FILE *fp;
char the_file[25] = "./manager.cgi";
struct stat mybuf;

if ( -1 ==  stat(the_file,&mybuf))
{
 printf("Content-type: text/html\n\n");
 printf(" Error with stat of %s\n", the_file);
 exit(0);
}

if(!(geteuid() == mybuf.st_uid))
{
 printf("Content-type: text/html\n\n");
 printf("Owners do not match!\n");
 exit(0);
}

if((fp=fopen(the_file,"r"))==NULL)
{
printf("Content-type: text/html\n\nCannot open the file %s\n",the_file);
exit();
}
fclose(fp);

/* Set the real id to the value of the effective id, may help GPG */

if (setreuid(geteuid(),-1) == -1)
{
 printf("Content-type: text/html\n\nCannot set real UID to %d\n",
        (int)geteuid());
 exit();
}

 execl(the_file,the_file,"nowrap",NULL); /* */

}

