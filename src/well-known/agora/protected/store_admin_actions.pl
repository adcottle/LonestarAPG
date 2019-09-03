###############################################################################
# This file contains the action logic for the store admin program
#
###############################################################################
#
$versions{'store_admin_actions.pl'} = "20040121";
#
###############################################################################
sub upcase {
 local($string) = @_;
 $string =~ tr/a-z/A-Z/;
 return $string;
}
###############################################################################
sub downcase {
 local($string) = @_;
 $string =~ tr/A-Z/a-z/;
 return $string;
}
###############################################################################
sub register_extension {
  local ($name, $description, $version) = @_;
  local ($continue) = "";
  &codehook("register-manager-extension");
  if ($continue eq "no") { return;}
  $manager_ext_desc{$name} = $description;
  $manager_ext_version{$name} = $version;
 }
###############################################################################
sub register_menu {
# link the incoming POST info to a subroutine to process it
  local ($name, $action_subroutine, $module, $description) = @_;
  local ($continue) = "";
  &codehook("register-manager-menu-item");
  if ($continue eq "no") { return;}
  if ($description eq "") {
    $description = $action_subroutine;
    $description =~ s/\_/\ /g;
   }
  $menu_items{$name} = $action_subroutine;
  $menu_items_module{$name} = $module;
  $menu_items_desc{$name} = $description;
 }
###############################################################################
sub action_process_login {
 local ($continue) = "";
 &codehook("action-process-login-top");
 if ($continue eq "no") { return;}
 &$manager_process_login;
 &codehook("action-process-login-bot");
}
###############################################################################
sub std_action_process_login
{
local ($msg);
if($in{'username'} eq "$username" && $in{'password'} eq "$password")
{
 &update_ip_ok;
 if (($mc_use_cookie_login =~ /yes/) && ($mc_have_cookie =~ /no/)) {
   $msg = "Looks like cookies are not working for the manager,";
   $msg .= " logins from muliple IP addresses ";
   $msg .= " simultaneously are not enabled.";
   $msg .= "&nbsp; Often this happens when the main store settings ";
   $msg .= "(URL path info) are not properly set, check them now!";
   $other_welcome_message .= "<BR><BR><FONT COLOR=RED>$msg</FONT>";
  }
}
else
{
&display_login;
&call_exit;
}

}
###############################################################################
sub make_random_chars {
# name says it all
 local ($part1,$part2,$valid_chars,$chars,$inx);
 $part1 = "abcdefghijklmnopqrstuvwxyz";
 $part2 = $part1;
 $part2 =~ tr/a-z/A-Z/;
 $valid_chars= $part1 . $part2 . "0123456789";
 $chars="";
 for ($inx=0;($inx < 8); $inx++) {
   $chars .= substr($valid_chars,rand(length($valid_chars)),1);
  }
 return $chars;
}
###############################################################################
sub update_ip_ok {
  local(@lines);
  open(FILE, "<$ip_file");
  @lines = (<FILE>);
  close(FILE);
  $lines[0] = "\$ok_ip=\"$ENV{'REMOTE_ADDR'}\"; 1;\n"; # always first line
  open(FILE, ">$ip_file") || &my_die("Can't Open ip_file, check "
         . "permissions for the \"files\" directory");
  foreach $inx (@lines) {  
    print(FILE $inx);
   }
  close(FILE);
}
###############################################################################
sub my_escape { #escape out chars used in qq stuff

 local ($logic) = @_;

 $logic =~ s/\\/\\\\/g;
 $logic =~ s/\$/\\\$/g;
 $logic =~ s/\@/\\\@/g;
 $logic =~ s/\"/\\\"/g;
$logic =~ s/\#/\\\#/g;  # Blocks response from PayPal
$logic =~ s/\+/\\\+/g;  # Used as the space character
$logic =~ s/\&/\\\&/g;  # Used as the new variable delimiter
$logic =~ s/\%/\\\%/g;  # Used as the hex character delimiter
$logic =~ s/\?/\\\?/g;  # Used as the begin variable delimiter

#delete control-M (^M)
 $logic =~ s/\r//g;

 return $logic;
}
#######################################################################################
sub my_die {
 local ($msg) = @_;
 print "The manager program cannot continue for the following reason:" .
       "<br>\n$msg\n";
 print "<br><br>\nPermissions are the most common cause of errors. &nbsp;";
 print "The following directories and files contained within need to be " .
       " made read/write:<br>\n";
 $msg = "&nbsp;&nbsp;&nbsp;&nbsp;";
 print"$msg admin_files <br>\n";
 print"$msg data_files <br>\n";
 print"$msg log_files <br>\n";
 print"$msg pgpfiles \(only when updating public keys)<br>\n";
 print"$msg protected/files <br>\n";
 print"$msg shopping_carts <br>\n";
 $ENV{'PATH'} = "/bin:/usr/bin";
 $result = `id `; # find out the unix id we are running under
 print "<br>CGI programs run under the following id: &nbsp;$result<br>";
 print "If your user id is not listed above, then you must chmod 777 ",
       "those directories and files.<br>";
 print "If your user id is listed above, then you may chmod 755 ",
       "everything and try to chmod 700 the order log file.<br>";
 &call_exit;
}
################################################################################
sub action_commando{ # simulate "telnet" command line executions
 local($result)="";

 if ($in{'command'} ne "") { #perform the command
  # Totally bogus.  Untaint everything.  Wow.  Well, they should know
  # what they are doing, right?  I mean they have to type it in and they
  # have to have the directory password so ...
   $in{'command'} =~ /([^\n]+)/;
   $zcommand = $1;
   $result = `$zcommand`;
  }
# this is a combo edit/results screen  

print &$manager_page_header("COMMANDO!","","","","");

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=500 BORDER=0 CELLPADDING=2>

<TR>
<TD COLSPAN=2>
<HR WIDTH=550>
This is the most dangerous part of the manager. &nbsp;Unless you have
a specific reason to be here then don't be! &nbsp;It allows Unix 
commands to be entered and their results to be posted below. &nbsp;If
a command returns with no results, it is possible there was an error.
&nbsp;To display errors, you can redirect STDERR to STDOUT by
placing  "2>&1" after the command.
<br><BR>BE VERY CAREFUL HERE!<BR><BR>
<FORM ACTION="manager.cgi" METHOD="POST">
Command: <INPUT TYPE="TEXT" NAME="command" size=60 maxsize=120>
<INPUT TYPE="hidden" NAME="commando" VALUE="yes">
<INPUT TYPE="submit" NAME="submitcommando" VALUE="Execute Command">
</FORM>
<HR WIDTH=550>
</TD>
</TR>
<TR>
<TD COLSPAN=2>
 <table width=500 border=0 BGCOLOR="F0F0F0"><tr><td>
   <pre>$zcommand <br><br>$result</pre>
  </td></tr></table>
</TD>
</TR>
</TABLE>
ENDOFTEXT
print &$manager_page_footer;
 
 }
################################################################################

sub init_convert_menu_item
{
local($str, @lines, @my_items);
local($kount,$inx,$action,$display,$procname,$junk);

$manager_banner_main = 
 "AgoraCart " .
 '<FONT COLOR=RED>D</FONT>' .
 '<FONT COLOR=GREEN>E</FONT>' .
 '<FONT COLOR=BLUE>L</FONT>' .
 '<FONT COLOR=GOLD>U</FONT>' .
 '<FONT COLOR=MAGENTA>X</FONT>' .
 '<FONT COLOR=SILVER>E</FONT>' .
 " Store Manager ver. $versions{'manager'}";

$manager_banner = 
'<A HREF="http://www.adwarebanners.com/ads/ads.pl?banner=NonSSI;page=agoracart;zone=agoracart" target="_new"><IMG SRC="http://www.adwarebanners.com/ads/ads.pl?page=agoracart;zone=agoracart" WIDTH=468 HEIGHT=60 BORDER=0></A>' .
 '<FONT FACE=ARIAL><STRONG><h2>AgoraCart ' .
 '<FONT COLOR=RED>D</FONT>' .
 '<FONT COLOR=GREEN>E</FONT>' .
 '<FONT COLOR=BLUE>L</FONT>' .
 '<FONT COLOR=GOLD>U</FONT>' .
 '<FONT COLOR=MAGENTA>X</FONT>' .
 '<FONT COLOR=SILVER>E</FONT>' .
 " Store Manager ver. $versions{'manager'}</h2></STRONG></FONT>";

 if (-e "$mgrdir/.htaccess" ) {
  $ht_menu = "";
 } else {
  $ht_menu = "<FONT FACE=ARIAL SIZE=2><A HREF=manager.cgi?" .
             "htaccess_screen=yes>" .
             "htaccess protect the /$mgrdirname directory " .
             'where this program is running ' .
             "</A>&nbsp;&nbsp;</FONT><br>";
 }

$str = "<CENTER><TABLE WIDTH=550 BORDER=0>\n";
$str = "<TR WIDTH=550 BORDER=0><TD WIDTH=550 BORDER=0><CENTER>\n";
$str .= $ht_menu;
$kount = 0;
foreach $inx (sort(keys %top_menu)) {
  $action = $top_menu{$inx};
  $display = $top_menu_name{$inx};
  ($procname,$junk) = split(/\=/,$action,2);
  if ($menu_items_disabled{$procname} eq '') {
    $str .= "<FONT FACE=ARIAL SIZE=2><A HREF=manager.cgi?$action>";
    $str .= "$display</A>&nbsp;&nbsp;</FONT>\n";
    $kount++;
    if ($kount == $mc_max_top_menu_items) {
      $kount = 0;
      $str .= "<br>\n";
     }
   }
 }

 $str .= "</CENTER>\n</TD></TR></TABLE></CENTER>\n";

$manager_menu = $str;

}
#######################################################################################

sub encryptit {
  local ($mytime, $salt, $my_ans);
  local ($pass) = @_;

  $mytime =  time();
  $mytime =  "$mytime";

# not secure enough for an OS, but fine for
# something run once in a while

  $salt = substr($mytime,length($mytime)-2,2);
  $my_ans = crypt($mytime,$salt); 
# now get the new salt for encryption ...
  $salt = substr($my_ans,length($my_ans)-2,2);
  $my_ans = crypt($pass,$salt);
  return ($my_ans);
}
#######################################################################################
sub eval_store_settings {
  local($error_list,$item,$err_count);
  $error_list='';
  $err_count = 0;
  &load_store_settings;
  foreach $zitem (sort(keys %store_settings)) {
    $item = $store_settings{$zitem};     
    $item =~ /([^\xFF]*)/;
    $item = $1;
    eval($item);
    if ($@ ne "") {
      $error_list .= "Error loading \"$zitem\" settings:<br>$@<br><br>\n";
      $err_count++;
     } else {
      $error_list .= "Loaded settings \"$zitem\" OK<br>\n";
     }
   }
  if ($err_count==0) {
    return "";
   } else {
    return $error_list;
   }
 }
#######################################################################################
sub load_store_settings {
local($junk,$name,$stuff);
local($user_settings) = "./admin_files/agora_user_lib.pl";
{
open(SETTINGS,"$user_settings") || &my_die("Can't Open $user_settings");
local $/=undef;
$everything=<SETTINGS>;
close(SETTINGS);
}
undef(%store_settings);
if ($everything =~ /#:#: end/i) { # new style file
  while ($everything =~ /#:#: end/i) {
    ($junk,$everything) = split(/#:#:#: start /i,$everything,2);
#    ($name,$everything) = split(/( settings)([^\n]+)(\n)/i,$everything,2);
    ($name,$everything) = split(/ settings/i,$everything,2);
    ($junk,$everything) = split(/\n/i,$everything,2);
    ($stuff,$everything) = split(/#:#:#: end/i,$everything,2);
    $name =~ tr/a-z/A-Z/;
    $store_settings{$name} = $stuff;
   }
 # and by default we need to set the MAIN vars
  $store_settings{'MAIN'} =~ /([^\xFF]*)/;
  $temp = $1;
  eval($temp);
  $mc_path_for_cookie = $sc_path_for_cookie . "/$mgrdirname";
 } else { #old style, everything is for the main program
  &update_store_settings('MAIN',$everything);
 # also need to load in the other files that belong here now
 # old pgp user lib
  $user_settings = "./admin_files/pgp_user_lib.pl";
{
  open(SETTINGS,"$user_settings");
  local $/=undef;
  $myset=<SETTINGS>;
  close(SETTINGS);
}
  &update_store_settings('pgp',$myset);
  open(SETTINGS,">$user_settings") || &my_die("Can't Open $user_settings");
  print(SETTINGS "#These settings have been moved to the agora user lib\n");
  print(SETTINGS "#here for compatability w older versions\n1\;\n");
  close(SETTINGS);
 # old cart user lib
  $user_settings = "./admin_files/cart_user_lib.pl";
{
  open(SETTINGS,"$user_settings");
  local $/=undef;
  $myset=<SETTINGS>;
  close(SETTINGS);
}
  $myset = "sub init_cart_settings {\n" . $myset . "}\n";
  $myset .= 'if ($main_program_running =~ /yes/i) {' . "\n";
  $myset .= '&add_codehook("open_for_business","init_cart_settings");' . "\n";
  $myset .= '} else { ' . "\n";
  $myset .= '&init_cart_settings;' . "\n";
  $myset .= '}' . "\n";
  &update_store_settings('cart',$myset);
  open(SETTINGS,">$user_settings") || &my_die("Can't Open $user_settings");
  print(SETTINGS "#These settings have been moved to the agora user lib\n");
  print(SETTINGS "#here for compatability w older versions\n1\;\n");
  close(SETTINGS);
 }
}
#######################################################################################
sub save_store_settings {
  local($user_settings) = "./admin_files/agora_user_lib.pl";
  local($myset,$item,$zitem);

  &get_file_lock("$user_settings.lockfile");
  open(SETTINGS,">$user_settings") || &my_die("Can't Open $user_settings");
  $myset  = "## This file contains the user specific variables\n";
  $myset .= "## necessary for AgoraCart to operate\n\n";
  print (SETTINGS $myset);
  foreach $zitem (sort(keys %store_settings)) {
    $item = $zitem;
    $item =~ tr/a-z/A-Z/;
    print (SETTINGS "#:#:#: start $item settings\n");
    print (SETTINGS $store_settings{$zitem});
    print (SETTINGS "#:#:#: end $item settings\n");
   }
  print (SETTINGS "#\n1\;\n");
  close(SETTINGS);
  &release_file_lock("$user_settings.lockfile");
 }
#######################################################################################
sub update_store_settings {
  local($item,$stuff) = @_;
  $item =~ tr/a-z/A-Z/;
  $store_settings{$item} = $stuff;
  &save_store_settings;# need save them all!
 }
#######################################################################################
sub action_htaccess_settings
{
local ($my_message, $my_ans, $my_str, $junk, $pwd, $old_path);

&ReadParse;

$old_path = $ENV{"PATH"};
$ENV{"PATH"}="/bin:/usr/bin";
$pwd = `pwd`;
if (length($pwd) < 4) { #sanity check ... use our name to get path
  ($pwd,$junk) = (/\/$mgrdirname/,$ENV{'SCRIPT_FILENAME'},2);
 }
chomp($pwd);
$my_file = $pwd . "/$mgrdirname/manager.access";
#$ENV{"PATH"} = $old_path;

$my_str = qq!#
#Options All

AuthType "Basic"
AuthName "Protected Access"

AuthUserFile $my_file

<Limit GET>
require valid-user
</Limit>     
!;

$my_saveumask = umask $original_umask;
open (PSETTINGS, "> $mgrdir/.htaccess");
print (PSETTINGS $my_str);
close (PSETTINGS);

$username = $in{'username'};
$password = $in{'password'};

$stuff = $username . ":" . &encryptit($password) . "   \n";

open (PSETTINGS, "> $mgrdir/manager.access");
print (PSETTINGS $stuff);
close (PSETTINGS);
umask $my_saveumask;

&init_convert_menu_item;
&welcome_screen;

}

#######################################################################################
sub clear_order_log
{
local ($logfile,$count);

# set umask and file name
require "./admin_files/agora_user_lib.pl";

$logfile = "$sc_logs_dir/$sc_order_log_name";
$count = $in{'bytes'};

if ($count > 0 ) {
  &get_file_lock("$logfile.lockfile");
  open (LOGFILE, "$logfile") || print "";
  read(LOGFILE,$stuff,999999);
  close(LOGFILE);
  $stuff = substr($stuff,$count,9999999);
  unlink($logfile);
  open (LOGFILE, ">$logfile") || print "";
  print (LOGFILE $stuff);
  close(LOGFILE);
  &release_file_lock("$logfile.lockfile");
 }

&init_convert_menu_item;
&display_order_log;

}

#######################################################################################
sub clear_error_log
{
local ($logfile);

$logfile = "./log_files/error.log";

unlink($logfile);
open (LOGFILE, ">$logfile") || print "";
close(LOGFILE);

&init_convert_menu_item;
&display_error_log;

}

#############################################################################
1;
