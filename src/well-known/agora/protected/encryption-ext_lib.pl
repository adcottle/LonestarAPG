# file ./store/protected/encryption-ext_lib.pl

$versions{'encryption'} = "20021020";

{
 local ($modname) = 'encryption';
 &register_extension($modname,"Custom Store Logic",$versions{$modname});
 &add_item_to_manager_menu("GnuPG/PGP","change_PGP_screen=yes","");
 &register_menu('change_PGP_screen',"show_encryption_screen",
	$modname,"Display Encryption Settings");
 &register_menu('ConfigPGP',"write_pgp_settings",
	$modname,"Write Encryption Settings");
}
###############################################################################
sub write_pgp_settings
{
local ($my_message, $my_ans, $my_str, $my_command);
local ($myset) = "";
local ($pgp_settings) = "./admin_files/agora_user_lib.pl";
local($order_email);

&ReadParse;

$order_email = $in{'email_address_for_orders'}; 
$order_email =~ s/\@/\\@/;

$myset .= "\$sc_use_pgp = \"$in{'pgp_orders_yes_no'}\";\n";
$myset .= "\$sc_pgp_change_newline = \"$in{'sc_pgp_change_newline'}\";\n";
$myset .= "\$sc_pgp_or_gpg = \"$in{'pgp_or_gpg'}\";\n";
$myset .= "\$sc_pgp_or_gpg_path = \"$in{'pgp_or_gpg_path'}\";\n";
$myset .= "\$sc_pgp_order_email = \"$order_email\";\n";

&update_store_settings('pgp',$myset);

require $pgp_settings; 

if($in{'system_edit_success'} ne "")
{
  $my_message = "";
  if (-e $sc_pgp_or_gpg_path) {
    $my_message .= ""
   } else {
    $my_message .= "<br>Warning: Program not detected at $sc_pgp_or_gpg_path";
   }
if ($in{'public_key_to_import'} ne "") {
  $datafile = "./admin_files/import_pgp_temp.txt";
  open (DATABASE, ">$datafile");
  $my_key = $in{'public_key_to_import'};
  print DATABASE $my_key;
  close(DATABASE);
  $my_str = $sc_pgp_or_gpg_path;
  $my_str =~ /(.*)/;
  $my_str = $1;
  $old_path = $ENV{"PATH"};
  $ENV{"PATH"}="";
  if ($sc_pgp_or_gpg eq "GPG") {
    if (length($my_key) > 15) {
      $my_command =  "--home ./pgpfiles";
      $my_command .= " --allow-non-selfsigned-uid --import";
      $my_ans =`$my_str $my_command $datafile 2>&1`;
     }
    $my_ans .="\nLIST OF KEYS ON GPG KEYRING:\n";
    $my_ans .=`$my_str --home ./pgpfiles --list-keys 2>&1`;
    $my_ans =~ s/\</\&\#60;/g;
    $my_ans =~ s/\>/\&\#62;/g;
   } else { # using pgp
    $ENV{"PGPPATH"}="./pgpfiles";
    chop($my_str);
    $my_str .="k"; #use same path but the pgpk instead of pgpe
    if (length($my_key) > 15) {
      $my_ans = `/bin/echo "\n\n\n\n\n"|$my_str -a $datafile 2>&1`;
     }
    $my_ans .="\nLIST OF KEYS ON PGP KEYRING:\n";
    $my_ans .=`$my_str -l 2>&1`;
    $my_ans =~ s/\</\&\#60;/g;
    $my_ans =~ s/\>/\&\#62;/g;
   }
  $my_message .= "<PRE>$my_ans</PRE>";
  unlink $datafile;
  $pgp_update_message = $my_message;
  $ENV{"PATH"} = $old_path; 
 } else {
 } 
}

&show_encryption_screen;

}
#############################################################################################

sub show_encryption_screen
{

print &$manager_page_header("Encryption","","","","");

$nl_stuff = $sc_pgp_change_newline;
$nl_stuff = "Leave Alone" if $nl_stuff eq "";

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=580>
</CENTER>

<CENTER>
<FORM ACTION="manager.cgi" METHOD="POST">
<TABLE WIDTH=580>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Welcome to the PGP section of the <b>AgoraCart</b>
System Manager. 
Each value is defined and described, so you should have no problem 
getting through this part.  Versions of PGP vary a bit, hopefully
the command flags in pgp-lib.pl won't need to be 
adjusted.
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
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Encryption settings have been
successfully updated.</FONT>
<FONT FACE=COURIER SIZE=2 COLOR=RED>$pgp_update_message</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<CENTER>
<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD><b>Do you wish to have orders encrypted in the log file and email?</b>
It is important
to protect the privacy of your customer's credit card information,
especially if it is going to be emailed to you for offline processing.
</TD>
<TD>
<SELECT NAME="pgp_orders_yes_no">
<OPTION>$sc_use_pgp</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>
<B>Please choose how to encrypt and/or verify 
orders on your host server:</B><br>
<a href="http://www.pgp.com" target="_blank">PGP (Pretty Good Privacy) 
software</a> is available for 
both servers and the workstation to encrypt and decrypt email.
It costs money.<br>
<a href="http://www.gnupg.org" target="_blank">GPG, or GNU Privacy
Guard</a>, is 
a free replacement for PGP.  You may use PGP ver 5 and higher
keys with the standard version of GPG.
<br></td>
<TD>
<SELECT NAME=pgp_or_gpg>
<OPTION>$sc_pgp_or_gpg</OPTION>
<OPTION>PGP</OPTION> 
<OPTION>GPG</OPTION> 
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Please enter the path to the software on the server:<br>
For example: <b>/usr/local/bin/pgpe</b> or <b>/usr/local/bin/gpg</b><br>
</TD>
</TR>

</TABLE><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2>
<INPUT NAME="pgp_or_gpg_path" TYPE="TEXT" SIZE=60 
 VALUE="$sc_pgp_or_gpg_path">
</TD>
</TR>

<TR>
<TD COLSPAN=2>
Note for PGP users only: The path to the key program pgpk is assumed to 
be obtained by changing the last letter of the path above to
the letter 'k'.  If this is not correct, then you will have to 
use the command line to import public keys into PGP. 
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
Enter the e-mail address to use to lookup an encryption key
on the keyring.  This will be the Public Key used to encrypt
the orders.  If you have not already added a copy of this public key
to the keyring, you may do so in the item below.<br>
For example: <b>sales\@yourdomain.com</b><br>
</TD>
</TR>

<TR>
<TD COLSPAN="2">
<INPUT NAME="email_address_for_orders" TYPE="TEXT" 
VALUE="$sc_pgp_order_email" SIZE="55">
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD colspan=2>
<B>Convert Newlines to anything?</B>&nbsp;
<SELECT NAME=sc_pgp_change_newline>
<OPTION value="$sc_pgp_change_newline">$nl_stuff</OPTION>
<OPTION value="">Leave Alone</OPTION> 
<OPTION>\\r\\n</OPTION> 
<OPTION>\\n\\r</OPTION> 
<OPTION>\\r</OPTION> 
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

</TABLE><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN="2">
You may paste an "ascii-armored" public key to add to the keyring here.
PGP software exports these with a <b>.asc</b> extension.<br>
Note: PGP and GPG use different keyrings.  If you switch from using 
one to the other, you will need to repeat this public key import step.
(Also, just by putting a blank space or two here, the list of keys
already loaded will be listed.)
</TD>
</TR>

<TR>
<TD COLSPAN="2">
<TEXTAREA NAME="public_key_to_import" 
cols="68" rows=4 wrap=off>
</TEXTAREA> 
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT NAME="ConfigPGP" TYPE="SUBMIT" VALUE="Submit">
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

################################################################################
1; # Library
