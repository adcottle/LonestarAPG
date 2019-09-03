#!/usr/bin/perl -T
##
## agora.cgi relay program 1.1
# This program 'relays' data posted to it to the agora.cgi program, and
# gets the result, posting it back to the calling browser.  It is an
# alternative to using the wrapper on sites where the Offline gateway 
# is in use but the https:// servr runs under a different id.  If the
# servers on different hosts, this program will relay fine but the data
# can potentially be intercepted.  You must evaluate whether the machines
# in question are, in fact, secure enough to allow for the relay to be
# used.
#
# Place this program in the same directory as agora.cgi and set the
# Offline URL to point to it.  Set the permissions to 755

$versions{'ragora.cgi'} = "1.1";
$versions{'perl'} = "$]";
$versions{'OSNAME'} = "$^O";
$versions{'server'} = $ENV{'SERVER_SOFTWARE'} if $ENV{'SERVER_SOFTWARE'};

##
## This is the 'relay agora.cgi' support program that enhances agora.cgi,
## agora.cgi information is below:
##
## Version history is available at... 
## http://www.agoracart.com/
##
## Agora.cgi is based on Selena Sol's freeware 'Web Store' 
## available at http://www.extropia.com with many modifications 
## made independently by Carey Internet Services before splitting 
## off and becoming this package known as agora.cgi.  The package
## distributed here is Copyright 1999-2000 by Steven P. Kneizys of
## Agoracgi.com and is distributed free of charge consistent with 
## the GNU General Public License Version 2 dated June 1991. 
##
## This program is free software; you can redistribute it and/or 
## modify it under the terms of the GNU General Public License 
## Version 2 as published by the Free Software Foundation.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
##
## There are several add-on modest-cost modules planned, see the 
## http://www.agoracart.com web site for more details.  Licensing
## for these add-on modules will be different than for this program.
##

$| = 1;
$ENV{"PATH"} = "/bin:/usr/bin";

$time = time;
$relay_program_running = "yes";
print "Content-type: text/html\n\n";

&require_supporting_libraries (__FILE__, __LINE__,
		"./admin_files/agora_user_lib.pl",
		"./library/cgi-lib.pl",
		"./library/shipping_lib.pl");

&ReadParse(*form_data);

$site = $sc_domain_name_for_cookie;
$path = $sc_path_for_cookie . "/agora.cgi";

$work_string = "relay=1";
$linker = "&";

foreach $key (keys %form_data) {
  $work_string .= $linker . "$key=" . &str_encode($form_data{$key});
 }

$work_string=&un_taint($work_string);

$do_work_string = 'http://' . $site . $path . '?' . $work_string;


# can change here to lwp or http-lib if need to override 'shipping' settings
#$sc_use_socket = "http-lib"; 

$site=&un_taint($site);
$path=&un_taint($path);
if ($sc_use_socket =~ /lwp/i) { # use LWP library POST
  $test_result = eval("use LWP::Simple; 1;");
 # By calling this way, no error generated if library is missing
 # when the library is first loaded up or at runtime of this routine
  $answer = eval("use LWP::UserAgent;  LWP_post\(\"$do_work_string\"\);");
 }
if ($sc_use_socket =~ /http-lib/i) { # use http-lib.pl library POST
  &request_supporting_libraries($wtd, __FILE__, __LINE__, 
		"./library/http-lib.pl");
  $answer = &HTTPPost($path,$site,80,$work_string);
 }

print $answer;
&call_exit;

#######################################################################
# For running codehooks at various places
#######################################################################
sub codehook{
  local($hookname)=@_;
  local($codehook,$err_code,@hooklist);
  if ($codehooks{$hookname} ne "") {
    @hooklist = split(/\|/,$codehooks{$hookname});
    foreach $codehook (@hooklist) {
      eval("&$codehook;");
      $err_code = $@;
      if ($err_code ne "") { #script died, error of some kind
        &update_error_log("code-hook $hookname $codehook $err_code","","");
       }
     }
   }
 }
#######################################################################
# For adding codehooks to the list for later execution
#######################################################################
sub add_codehook{
  local($hookname,$sub_name)=@_;
  local($codehook,$err_code,@hooklist);
  if ($sub_name eq "") { return;}
  if ($codehooks{$hookname} eq "") {
    $codehooks{$hookname} = $sub_name;
   } else {
    $codehooks{$hookname} .= "|" . $sub_name;
   }
 }
#######################################################################
# For cleanup purposes such as closing files, removing locks, etc.
#######################################################################
sub call_exit {
  codehook("cleanup_before_exit");
  exit;
 }
sub require_supporting_libraries
{
		# The libraries are required by us,so exit if loading error
local ($file, $line, @require_files) = @_;
local ($require_file);
&request_supporting_libraries("warn exit",$file, $line, @require_files);
}# end sub require_supporting_libraries

sub request_supporting_libraries
{

		# The incoming file and line arguments are split into
		# the local variables $file and $line while the file list
		# is assigned to the local list array @require_files.
		#
		# $require_file which will just be a temporary holder
		# variable for our foreach processing is also defined as a
		# local variable.

local ($what_to_do_on_error, $file, $line, @require_files) = @_;
local ($require_file);

		# Next, the script checks to see if every file in the
		# @require_files list array exists (-e) and is readable by
		# it (-r). If so, the script goes ahead and requires it.

foreach $require_file (@require_files)
{
if (-e "$require_file" && -r "$require_file")
{ # file is there, now try to require it
$result = eval('require "$require_file"'); # require it in a not-fatal way
if ($@ ne "") {
 if($what_to_do_on_error =~ /warn/i) {
  if ($error_header_done ne "yes") {
     $error_header_done = "yes";
     print "Content-type: text/html\n\n";
    }
   print "<div><table width=500><tr><td>\n";
   print "Error loading library $require_file:<br><br>\n  $@\n";
   print "<br><br>Please fix the error and try again.<br>\n";
   print "</td></tr></table></div>\n";
  }
 if($what_to_do_on_error =~ /exit/i) {
   &call_exit;
  }
 }
}

		# If not, the scripts sends back an error message that
		# will help the admin isolate the problem with the script.

else
{

 if($what_to_do_on_error =~ /warn/i) {
  if ($error_header_done ne "yes") {
     $error_header_done = "yes";
     print "Content-type: text/html\n\n";
    }
print "I am sorry but I was unable to require $require_file at line
$line in $file.  <br>\nWould you please make sure that you have the
path correct and that the permissions are set so that I have
read access?  Thank you.";
  }


 if($what_to_do_on_error =~ /exit/i) {
   &call_exit;
  }
}

} # End of foreach $require_file (@require_files)
} # End of sub request_supporting_libraries
#######################################################################
sub un_taint{
 local($str) = @_;
 $str =~ /([^\xFF]*)/;
 return $1;
}
########################################################################
sub str_encode { # encode a string for cgi or other purposes
  local($str)=@_;
  local($mypat)='[\x00-\x1F"\x27#%/+;<>?\x7F-\xFF]';
  $str =~ s/($mypat)/sprintf("%%%02x",unpack('c',$1))/ge;
  $str =~ tr/ /+/;
  return $str;
 }
########################################################################
sub file_open_error
{
local ($bad_file, $script_section, $this_file, $line_number) = @_;
print "FILE OPEN ERROR-$bad_file", $this_file, $line_number, "<br>\n";
#&update_error_log("FILE OPEN ERROR-$bad_file", $this_file, $line_number);
#open(ERROR, $error_page);
#while (<ERROR>)
#{  
#print $_;
#}
#close (ERROR);
}
