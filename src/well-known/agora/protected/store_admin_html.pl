######################################################################################
# This file contains the HTML for the store admin screens
######################################################################################

$versions{'store_admin_html.pl'} = "20040121";

if ($mc_max_top_menu_items eq '') { # set the default
  $mc_max_top_menu_items = 6;
 }
&add_item_to_manager_menu("View Orders","order_log=yes","");
&add_item_to_manager_menu("Error Log","error_log=yes","");
&add_item_to_manager_menu("Tracking","tracking_screen=yes","");
&add_item_to_manager_menu("Log Out","log_out=yes","");
if ($commando_ok =~ /yes/i) {
  &add_item_to_manager_menu("Commando","commando=yes","");
 }
###############################################################################
sub add_item_to_manager_menu 
{
  local ($display_name,$action,$sort_name) = @_;
  local ($continue) = "";
  if ($sort_name eq '') {$sort_name = $display_name;}
  &codehook("add-item-to-manager-menu");
  if ($continue eq "no") { return;}
  $sort_name =~ tr/a-z/A-Z/;
  $top_menu{$sort_name} = $action;
  $top_menu_name{$sort_name} = $display_name;
}
#########################################################################
sub make_lists_of_various_options{
local (@glist,@dblibs,@zlist,$item,$item_lc);

opendir (USER_LIBS, "./library");
@dblibs = sort(grep(/_db_lib\.pl\b/i,readdir(USER_LIBS)));
closedir (USER_LIBS);
$mylist_of_database_libs="";
foreach $item (@dblibs) {
  if ($item eq $sc_database_lib) {
    $mylist_of_database_libs .= "<OPTION SELECTED>$item</OPTION>\n";
   } else {
    $mylist_of_database_libs .= "<OPTION>$item</OPTION>\n";
   }
 }

$mylist_of_gateway_options = "";
@glist = split(/\|/,$mc_gateways);
foreach $item (@glist) {
  if ($item ne "") {
    $item_lc = $item;
    $item_lc =~ tr/A-Z/a-z/;
    if ($item ne $sc_gateway_name) {
      $zlist{$item_lc} = "<OPTION>$item</OPTION>\n";
     } else {
      $zlist{$item_lc} = "<OPTION SELECTED>$item</OPTION>\n";
     } 
   } 
 }
foreach $item (sort(keys %zlist)) {
  $mylist_of_gateway_options .= $zlist{$item};
 }
}
#########################################################################
sub parse_image_string{

 local ($str) = @_;
 local ($image,$junk);

 ($junk,$image) = split(/\<IMG SRC=\"/i,$str,2);# keep part up to the "
 ($image,$junk) = split(/\"/,$image,2);# discard " and anything after

 $image =~ s/.*%%URLofImages%%\///g;
 $image =~ s/.*Html\/Images\///g;
 $image =~ s/.*html\/Images\///g;
 $image =~ s/.*html\/images\///g;
 $image =~ s/.png.*/.png/g;
 $image =~ s/.gif.*/.gif/g;
 $image =~ s/.jpg.*/.jpg/g;

 return $image;

}

#########################################################################
sub create_image_string{

 local ($str) = @_;
 local ($image,$junk);

 $image = $sc_image_string_template;
 $image =~ s/%%image%%/$str/ig;

 return $image;

}
#########################################################################
sub PageHeader {
print <<ENDOFTEXT;

<HTML>
<BODY BGCOLOR=WHITE>
<CENTER>
<TABLE WIDTH=500>
<TR WIDTH=500>
<TD WIDTH=125>
<B>Ref. #</B>
</TD>
<TD WIDTH=125>
<B>Category</B>
</TD>
<TD WIDTH=125>
<B>Description</B>
</TD>
<TD WIDTH=125>
<B>Price</B>
</TD>
</TR>

ENDOFTEXT
}

#######################################################################################
sub PageFooter
{

print <<ENDOFTEXT;

</TABLE>
</CENTER>
ENDOFTEXT
print &$manager_page_footer;

}
#######################################################################################
sub display_login
{

  opendir (USER_LOGINS, "$ip_file_dir"); 
  @myfiles = grep(/\.login/,readdir(USER_LOGINS)); 
  closedir (USER_LOGINS);
  foreach $zfile (@myfiles){
    $my_path = "$ip_file_dir/$zfile";
    if (-M "$my_path" > 0.1) {
      $my_path =~ /([^\xFF]*)/;
      $my_path = $1;
      unlink("$my_path");
     }
   }

print <<ENDOFTEXT;

<HTML>
<HEAD>
<TITLE>Build an online store with AgoraCart</TITLE>

<META NAME="description" CONTENT="FREE shopping cart software - AgoraCart"> 
<META NAME="keywords" CONTENT="free, shopping cart, e-commerce, software, perl, 
database, easy, secure, store, dynamic, web based, c, c++, javascript, html">

</HEAD>
<BODY BGCOLOR="WHITE">

<CENTER>

$manager_banner

</CENTER>

<FORM METHOD=POST ACTION=manager.cgi>
<CENTER>
<TABLE WIDTH=500 BORDER=0 CELLPADDING=2>

<TR>
<TD COLSPAN=2>
<HR WIDTH=550>
</TD>
</TR>

ENDOFTEXT

if (! -e "$mgrdir/.htaccess")
{
print <<ENDOFTEXT;

<TR>
<TD COLSPAN=2>
<FONT FACE=ARIAL>
<STRONG>
<blink><FONT COLOR="#FF0000">WARNING</FONT></blink> No .htaccess file found
in the /$mgrdirname directory. &nbsp;
YOU STILL NEED TO PASSWORD PROTECT THAT DIRECTORY<BR>
</STRONG>
</FONT>
</TD>
</TR>

ENDOFTEXT
}

print <<ENDOFTEXT;

<TR>
<TD COLSPAN=2><P>&nbsp;</P></TD>
</TR>

<TR>
<TD COLSPAN=2>Username:&nbsp;<INPUT TYPE=text NAME=username></TD>
</TR>
<TR>
<TD COLSPAN=2>Password:&nbsp;<INPUT TYPE=password NAME=password></TD>
</TR>

<TR>
<TD><br>Note:  you must have atleast two periods (.) in the URL you are using to access this manager area.  For example, if you are using: www.yourname.com/store/protected/manager.cgi, then you are okay.  If using something like: yourname.com/store/protected/manager.cgi (notice no preceeding www.), you will have login problems.<br><br></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE=HIDDEN NAME="login" VALUE="yes">
<INPUT TYPE=HIDDEN NAME="welcome_screen" VALUE="yes">
<INPUT TYPE=submit VALUE=submit>&nbsp;<INPUT TYPE=reset VALUE=reset>
</CENTER>
</TD>
</TR>

</TABLE>
</CENTER>
</FORM>

<HR WIDTH=550>

<P>&nbsp;</P>

<CENTER>
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 WIDTH="550">
<TR>
<TD>
<IMG SRC="manager.cgi?picserve=front_footer.gif" BORDER=0>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
print &$manager_page_footer;

}
################################################################################
sub std_manager_footer_code {
local ($text);
$text = <<ENDOFTEXT;
<center>
<small>Copyright 1999-2004 K-Factor Technologies Inc. at <a href="http://www.agoracart.com">AgoraCart.com</a><br>
Distributed under the GPL.</small>
</center>
ENDOFTEXT
&codehook("manager_footer_code");
$text .= "\n</BODY>\n</HTML>\n";
return $text;
}
################################################################################
sub std_manager_header_code {
  local ($ztitle,$header_code,$body_tag,$messages,$err_msgs) = @_;
  local ($my_header);
  local ($errs) = &html_eval_settings;

  $title = "Agora Manager";
  if ($ztitle ne "") {
    $title .= " - " . $ztitle;
   }
  if ($body_tag eq "") {
    $body_tag = $mc_standard_body_tag;
   }

  $my_header =  <<ENDOFTEXT;
<HTML>
<HEAD>
<TITLE>$title</TITLE>
<META NAME="description" CONTENT="FREE shopping cart software - AgoraCart"> 
<META NAME="keywords" CONTENT="free, shopping cart, e-commerce, software, perl, 
database, easy, secure, store, dynamic, javascript, html">
$header_code
</HEAD>

<BODY $body_tag>
<CENTER>
$manager_banner
</CENTER>
$manager_menu
$errs
$messages
ENDOFTEXT

  return $my_header;
 }
#######################################################################################
sub welcome_screen {
 &$manager_welcome_screen;
 }
#######################################################################################
sub std_welcome_screen {

print &$manager_page_header("Welcome!","","","","");

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=500 BORDER=0 CELLPADDING=2>

<TR>
<TD COLSPAN=2>
<HR WIDTH=550>
</TD>
</TR>
ENDOFTEXT

if($error_message ne "")

{

print <<ENDOFTEXT;

<TR>
<TD COLSPAN=2>
<CENTER>
<TABLE>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=2 COLOR=RED>$error_message</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
</TD>
</TR>

ENDOFTEXT

}

print <<ENDOFTEXT;

<TR>
<TD COLSPAN=2><P><strong>Welcome $username!&nbsp; Choose from 
the options above...</strong></P>
The home site of AgoraCart (aka Agora.cgi) is 
<a href="http://www.agoracart.com/">www.AgoraCart.com</a>.\&nbsp;\&nbsp;
<br>
<br>
<font size=+1><b>Resources:</b></font><br><br>
<center><a href="http://www.agoracart.com/download.htm" target="_new">Online Manual</a>  | 
<a href="http://www.agoracart.com/help/wherestuff.html" target="_new">AgoraCart File Structure, File Locations \& Permissions</a><br>
<a href="http://www.agoracart.com/help/3rdparty.html" target="_new">Misc Reference \& Tutorials</a>  | 
<a href="http://www.agoracart.com/paymentgateways.htm" target="_new">Payment Processing Gateways Supported</a><br>


<a href="http://members.agoracartpro.com/" target="_new">Pro Members</a>  | 
<a href="http://www.agoraguide.com/faq/" target="_new">Free User Forum \& FAQ</a>  | 
<a href="http://groups.yahoo.com/group/agora2/" target="_new">Free User Forum \@ Yahoo Groups</a><br>
<a href="http://www.agoracart.com/pages/Shopping/">Free ad - Agora users only</a>  | 
<a href="http://www.imegamall.com/info/listing.htm">Free Listing in iMegaMall</a>  | 
<a href="http://www.SnooperClick.com/">SnooperClick Search Engine</a><br><br>

<FORM action=http://www.SnooperClick.com/smartsearch.cgi method=post>
<B>Try SnooperClick: Enter Keyword or Phrase:</B><BR>
<INPUT name=keywords size=30>
<INPUT type=submit value=Search></FORM>
</center>
<br><br>
Join the <a href="http://www.agoracartpro.com/"><b>Pro Members Group</b></a> for \$29.95 per year or \$59.95 for a lifetime
membership.  Benefits include more professional support in pro user forums, extra add-ons such as PayPal, Verisign and eWay gateway libraries, FedEx shipping libraries, other payment gateways, additional hacks and add-ons for pro members only, discounts on custom services, and more.
<br><br>

Also, visit <a href="http://www.agoracartpro.com/proshop/">AgoraCart.com</a> for add-ons (free and fee based) including: a net profit tracker to keep track of net profits amounts per order for use with such things as affiliate program variables,  the popular Multi Login script for the store manager that allows you to change, add, delete manager passwords and assign rights to each manager to allow or disallow specific manager functions, and <a href="http://www.agoracart.com/dbwizz/">DBwizz database manager</a> that allows you to manage your stores database offline and then upload any changes you make to your product database.<br><br>

$other_welcome_message
</TD>
</TR>

</TABLE>
</CENTER>

<HR WIDTH=550>
<CENTER>
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 WIDTH="550">
<TR>
<TD><IMG SRC="manager.cgi?picserve=front_footer.gif" BORDER=0>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
print &$manager_page_footer;

}
################################################################################
sub display_order_log

{
local ($stuff);
local ($errs)='';
local ($lines)=0;

local ($logfile)= "$sc_logs_dir/$sc_order_log_name";

print &$manager_page_header("Display Order Log","","","");

&get_file_lock("$logfile.lockfile");

{
open(LOGFILE, "$logfile") || print "";
local $/=undef;
$junk=<LOGFILE>;
close(LOGFILE);
}
$junk=length($junk);

print "<center>\n";
print "<table width='90%' border=0 cellpadding=10>",
      "<tr width=600><td><font face=courier>\n",
      "<b>ORDER LOG: $logfile<br></b></td>\n",
      "<td>&nbsp;</td>\n",
      '<td align=right><a href="manager.cgi?clear_order_log=yes', 
	"&bytes=$junk\">",
      "<b>CLEAR ORDER LOG</b></a></td>\n",
      "</tr></table>\n";

&display_a_file($logfile,"","Empty Order Log");

print "</center>\n";
print &$manager_page_footer;

&release_file_lock("$logfile.lockfile");

}

#######################################################################################
sub display_error_log

{
local ($stuff);
local ($lines)=0;
local ($logfile)= "./log_files/error.log";

print &$manager_page_header("Error Log","","","","");

#print "<html><title>Error Log</title><body bgcolor=#ffffff>\n";
print "<center>\n";
print "<table width='90%' border=0 cellpadding=10>",
      "<tr width=600><td><font face=courier>\n",
      "<b>ERROR LOG: $logfile<br></b></td>\n",
      "<td>&nbsp;</td>\n",
      '<td align=right><a href="manager.cgi?clear_error_log=yes">',
      "<b>CLEAR ERROR LOG</b></a></td>\n",
      "</tr></table>\n";

&display_a_file($logfile,"yes","Empty Error Log");

print "</center>\n";
print &$manager_page_footer;

}

#######################################################################################
sub display_a_file

{
local ($logfile,$need_rules,$empty_msg)=@_;
local ($stuff);
local ($lines)=0;

print "<table width='90%' border=1 cellpadding=10>",
      "<tr width=600><td width=600><font face=courier>\n";

open(LOGFILE, "$logfile") || print "";

while(<LOGFILE>){

 if (($lines > 0) && ($need_rules)) {
   print "<hr>\n";
  }

 $stuff = $_;
 $stuff =~ s/\</\&lt;/g;
 $stuff =~ s/\>/\&gt;/g;
 $stuff =~ s/\|/\<br\>/g;
# $stuff =~ s/ /\&nbsp;/g;

 print "$stuff<br>\n";
 $lines++;

 }# End of while LOGFILE

close(LOGFILE);

 if ($lines == 0) {
   print "$empty_msg\n";
  }

print "</font></td></tr></table>\n";

}

#############################################################################################
sub display_main_settings_choices {

local ($maxcols) = 3;
local ($colwidth) = int(550/$maxcols);
local (%my_list, @my_keys, $inx, $items, $link);

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0 CELLPADDING=0 CELLSPACING=0>
ENDOFTEXT

if ($mc_change_main_settings_ok =~ /yes/i) {
print <<ENDOFTEXT;
	<TR WIDTH=550>
	<TD colspan=$maxcols>
        <center><FORM METHOD=POST ACTION=manager.cgi>
	<INPUT TYPE=SUBMIT NAME="main_settings_screen" 
          VALUE="  Main AgoraCart Store Settings  ">
	</FORM></center>
	</TD>
	</TR>
ENDOFTEXT
}

$items = 0;
foreach $inx (sort(keys(%store_settings_name))){
  $link = $store_settings_link{$inx}; 
  if ($menu_items_disabled{$link} eq '') {
    $items++;
    if ($items == 1) {
      print "<TR WIDTH=550>\n";
     }
    print <<ENDOFTEXT; 
	<TD colspan=1 WIDTH=$colwidth>
	<CENTER>
	<FORM METHOD=POST ACTION=manager.cgi>
	<INPUT TYPE=SUBMIT NAME=$store_settings_link{$inx} 
         VALUE="$store_settings_name{$inx}">
	</FORM>
	</CENTER>
	</TD>
ENDOFTEXT

    if ($items == $maxcols) {
      $items = 0;
      print "</TR>\n";
     }
   }
 }

 if ($items > 0) {
   while ($items < $maxcols) {
     $items++;
     print "<TD colspan=1 WIDTH=$colwidth>&nbsp;</TD>\n";
    }
   $items = 0;
   print "</TR>\n";
  }


print <<ENDOFTEXT;

</TABLE>
</CENTER>

ENDOFTEXT

}

#############################################################################################
sub html_eval_settings
{
local($errs)='';
$errs = &eval_store_settings;

if ($errs ne '') {
  $errs = "<center><table width='85%'><tr><td>" . 
	  "<font color=red>$errs</font></td></tr></table></center>\n";
 }

return $errs;
}
#############################################################################################

sub setup_htaccess_screen
{
local ($the_id,$temp,$whoami);

print &$manager_page_header("htaccess","","","","");

$temp = $ENV{'PATH'};
$ENV{'PATH'} = "/bin:/usr/bin";
$the_id = `id`;
$whoami = `whoami`;
$ENV{'PATH'} = $temp;

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=580>
</CENTER>

<CENTER>
<FORM ACTION="manager.cgi" METHOD="POST">
<TABLE WIDTH=580>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Welcome to the htaccess section of the
<b>AgoraCart</b> System Manager.
This code is here to assist you in the event that you are
running Apache or compatable server and have no way to setup 
your .htaccess file to protect the /$mgrdirname directory.
If your ISP or web hosting company has allowed for you to
password protect this directory in another fashion, then 
go ahead and use that.  If not, this procedure will attempt
to place a generic .htaccess file as well as a manager.access 
password file in this directory.  <br><br>
Scripts are running under id: $the_id<br>
Unix 'whoami' responds with: $whoami<br><br>
Note: If your scripts run only under the permissions
of a generic id (such as "nobody") 
and not your user id, and you get locked out after setting this option,
you will have to delete the .htaccess file (use COMMANDO 
if necessary).  You might be able to 
install the wrapper programs to solve this problem.
</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT

if($in{'system_edit_success'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Settings have been
successfully updated.</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<CENTER>
<TABLE BORDER=0 CELLPADDING=2 CELLSPACING=0 WIDTH=580>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<tr><td colspan=2><center>
<TABLE BORDER=2 CELLPADDING=2 CELLSPACING=0 WIDTH=560>

<TR>
<TD>
username:<INPUT NAME="username" TYPE="TEXT" SIZE=8 maxlength=8 
 VALUE="manager">
</TD>
<TD>
password:<INPUT NAME="password" TYPE="TEXT" SIZE=8 maxlength=8 
 VALUE="">(plain text, will be visible!)</TD>
</TR>

</table></center>
</td></tr>
<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT NAME="htaccessSettings" TYPE="SUBMIT" VALUE="Submit">
&nbsp;&nbsp;
<INPUT TYPE="RESET" VALUE="Reset">
</CENTER>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<HR>
</TD>
</TR>

</TABLE>

</CENTER>
</FORM>
ENDOFTEXT
print &$manager_page_footer;
}
#############################################################################################
sub change_settings_screen
{
local ($the_id,$temp,$whoami);

print &$manager_page_header("Change Settings","","","","");

$temp = $ENV{'PATH'};
$ENV{'PATH'} = "/bin:/usr/bin";
$the_id = `id`;
$whoami = `whoami`;
$ENV{'PATH'} = $temp;

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=580>
</CENTER>

<CENTER>
<TABLE WIDTH=580>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Welcome to the System Settings section of the
<b>AgoraCart</b> System Manager.
</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT

if($in{'system_edit_success'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Settings have been
successfully updated.</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

&display_main_settings_choices;

print <<ENDOFTEXT;

<CENTER>
<HR WIDTH=580>
</CENTER>
ENDOFTEXT
print &$manager_page_footer;
}
#############################################################################################

sub tracking_screen
{

print &$manager_page_header("Tracking","","","","");

$| = 1;

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
Welcome to the <b>AgoraCart</b> Tracking Manager. Here you will learn some
important information about your visitors and your store.
</FONT>
</TD>
</TR>
</TABLE>
<CENTER>

<CENTER>
<TABLE WIDTH=500>
<TR>
<TD>

<HR WIDTH=500>
<FONT FACE=ARIAL SIZE=2>
<h4>These are the pages that are linking to your store</h4><br>

ENDOFTEXT

$datafile = "./log_files/access.log";

open(DATABASE, "$datafile") || die "Can't Open $datafile";

while(<DATABASE>)

	{

($url, $shortdate, $requested_page, $visit_number, $ip_address, $browser_type, 
 $referring_page, $unix_date) = split(/\|/, $_);

$referring_page = substr($referring_page, 0, 110);
$requested_page = substr($requested_page, 0, 110);

foreach ($referring_page) {

	if ($requested_page ne "")
	{
	$referring_page_count{$referring_page}++;
	}
}

#####
foreach ($requested_page) {

	if ($referring_page eq "possible bookmarks"){

	if ($requested_page ne "")
	{
	$count_bookmarked_pages{$requested_page}++;
	}

}	
#####
foreach ($requested_page) {

	if ($requested_page ne ""){

	$count_first_hit_pages{$requested_page}++;
	}

}
#####
foreach ($ip_address) {

	if ($ip_address ne ""){

	$count_ip{$ip_address}++;
	}

}
#####
foreach ($visit_number) {

	if ($visit_number ne ""){

	$count_visit{$visit_number}++;
	}

}
#####
foreach ($browser_type) {

	if ($browser_type ne ""){

	$count_browser{$browser_type}++;
	}

}
#####

}
	}

close DATABASE;

###########################################

foreach $referring_page (sort { $referring_page_count{$b} <=> $referring_page_count{$a} } keys %referring_page_count) {

if ($referring_page_count{$referring_page} > 1)

{
print <<ENDOFTEXT;

$referring_page_count{$referring_page} visits from <a href=$referring_page>$referring_page</a><br>

ENDOFTEXT
}

}


###########################################

print <<ENDOFTEXT;

<BR>
<CENTER>
<HR WIDTH=500>
</CENTER>
<BR>

<h4>These pages appear to be accessed directly, <br>possibly through a bookmark.</h4><br>
ENDOFTEXT

foreach $requested_page (sort { $count_bookmarked_pages{$b} <=> $count_bookmarked_pages{$a} } keys %count_bookmarked_pages) {

if ($count_bookmarked_pages{$requested_page} > 1)

{
print <<ENDOFTEXT;

$count_bookmarked_pages{$requested_page} visits to <a href=$requested_page>$requested_page</a><br>

ENDOFTEXT
}

}

##########################################

print <<ENDOFTEXT;

<BR>
<CENTER>
<HR WIDTH=500>
</CENTER>
<BR>

<h4>These pages were accessed first during visits to your store</h4><br>
ENDOFTEXT

foreach $requested_page (sort { $count_first_hit_pages{$b} <=> $count_first_hit_pages{$a} } keys %count_first_hit_pages) {

if ($count_first_hit_pages{$requested_page} > 1)

{
print <<ENDOFTEXT;

$count_first_hit_pages{$requested_page} first visits to <a href=$requested_page>$requested_page</a><br>

ENDOFTEXT
}

}

##########################################

print <<ENDOFTEXT;

<BR>
<CENTER>
<HR WIDTH=500>
</CENTER>
<BR>

<h4>I.P. Addresses of the visitors to your store.</h4><br>
ENDOFTEXT

foreach $ip_address (sort { $count_ip{$b} <=> $count_ip{$a} } keys %count_ip) {

if ($count_ip{$ip_address} > 1)

{
print <<ENDOFTEXT;

$count_ip{$ip_address} visitors from I.P. address <a href=http://$ip_address>$ip_address</a>.<br>

ENDOFTEXT
}

}

##########################################

print <<ENDOFTEXT;

<BR>
<CENTER>
<HR WIDTH=500>
</CENTER>
<BR>

<h4>Web browsers your visitors are using.</h4><br>
ENDOFTEXT

foreach $browser_type (sort { $count_browser{$b} <=> $count_browser{$a} } keys %count_browser) {

if ($count_browser{$browser_type} > 1)

{
print <<ENDOFTEXT;

$count_browser{$browser_type} visitors use $browser_type as a web browser.<br>

ENDOFTEXT
}

}

#########################################

print <<ENDOFTEXT;

<BR>
<CENTER>
<HR WIDTH=500>
</CENTER>
<BR>

</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
</BODY>

ENDOFTEXT

}

########################################################################### 
sub make_file_option_list {

 local($my_path,$add_path_to_option_value) = @_;
 local($answer) = "";

 opendir (USER_FILES, "$my_path");
 @files = sort(grep(/\w/,readdir(USER_FILES)));
 
 foreach $filename (@files) {
  if (-f "$my_path/$filename") {
    if ($add_path_to_option_value =~ /yes/i) {
      $answer .= "<option value=\"$my_path/$filename\">$filename</option>\n";
    } else {
      $answer .= "<option>$filename</option>\n";
    }
 #  print "$my_path/$filename\n";
  } else {
 #  print "$my_path/$filename is not a file\n";
  }
 }
 closedir (USER_FILES);
 return $answer;
}
#############################################################################################
# Writen by Steve Kneizys to serve images 04-FEB-2000
#

sub serve_picture
{

 local ($qstr, $sc_path_of_images_directory) = @_;
 local ($test, $test2, $my_path_to_image);

 $qstr =~ /([\w\-\=\+\/\.\:]+)/;
 $qstr = "$1";

 $my_path_to_image = $sc_path_of_images_directory . $qstr ;

 $test = substr($my_path_to_image,0,6);
 $test2 = substr($my_path_to_image,(length($my_path_to_image)-3),3);

 if ($test2 =~ /jpg/i || $test2 =~ /png/i || $test2 =~ /gif/i) {
  if ($test2 =~ /jpg/i) {
    $test2 = "jpeg";
   } 
  if ($test=~ /http:\//i || $test =~ /https:/i) { 
   # need to GET the info
#    use LWP::Simple;
#    print "Content-type: image/$test2\n\n";
#    print get($my_path_to_image);
   } else { 
    print "Content-type: image/$test2\n\n";
    open(MYPIC,$my_path_to_image);
    $size = 250000;
    while ($size > 0) {
      $size = read(MYPIC,$the_picture,$size); 
      print "$the_picture";
     }
    close(MYPIC);
   }
 }
}
#######################################################################
sub log_out
{

if (-e "$ip_file")
 {
  unlink ("$ip_file"); }
    &display_login;
    &call_exit;
}
#######################################################################
1;
