#!/usr/local/bin/perl
#
# Public Domain software :) to test flock() mechanism
# Steve Kneizys 09/27/00
#
# Put this file in the data_files directory if a copy is not there already,
# chmod it 755, and run from a web browser, as in: 
#  http://www.mydomain.com/cgi-bin/store/data_files/testlock.cgi
#

print "Content-type: text/html\n\n";

$| = 1;

print "This tests the flock() mechanism on this system.             <br>\n";

open(MYFILE,">./myfile.tst") || &mydie("HELP!!! Cannot open ./myfile.tst");
print MYFILE "Testing locks is as easy as 1 ";
close(MYFILE);

$val = fork();

if ($val eq 0) { # we are the new process
  &get_a_lock("./locktest");
  sleep(2);
  open(MYFILE,">>./myfile.tst");
  print MYFILE "2 ";
  close(MYFILE);
  &release_a_lock;
 } else {# original process
  sleep(1);
  &get_a_lock("./locktest");
  open(MYFILE,">>./myfile.tst");
  print MYFILE "3 ";
  close(MYFILE);
  &release_a_lock;
  sleep(2);
  open(MYFILE,"./myfile.tst");
  read(MYFILE,$str,9999);
  close(MYFILE);
  unlink("./myfile.tst");
  print "$str                  <br>";
  print "\nIf it says '1 2 3' and not '1 3 2' then flock() locks are OK!\n";
 }

sub get_a_lock {
  local ($lck) = @_;
  local ($err)="There was a problem obtaining the lock $lck";
  open(TESTLOCK,'>'.$lck)||&mydie($err);
  flock(TESTLOCK,2);
 }
sub release_a_lock {
  flock(TESTLOCK,8);
  close(TESTLOCK);
 }
sub mydie{
  local($str)=@_;
  print "An error has occurred, perhaps it is a permissions problem?<br>\n";
  print $str,"            <br>\n";
  exit;
}
