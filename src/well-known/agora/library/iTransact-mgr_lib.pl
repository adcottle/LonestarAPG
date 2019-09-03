#
# For the Credit Card Processing Gateway iTransact
#
# Copyright 2001 Steve Kneizys.  All Rights Reserved.
# June 30, 2001

$versions{'iTransact-mgr_lib.pl'} = "20010630";
&add_codehook("gateway_admin_screen","iTransact_mgr_check");
&add_codehook("gateway_admin_settings","iTransact_settings");
$mc_gateways .= "|iTransact";
##############################################################################
sub iTransact_settings {
 local ($email_text);
 $email_text = &my_escape($in{'email_text'});
 if ($sc_gateway_name eq "iTransact") {
   open (GW,"> $gateway_settings") || &my_die("Can't Open $gateway_settings");
   print (GW "\$sc_gateway_username = \"$in{'sc_gateway_username'}\";\n");
   print (GW "\$sc_order_script_url = \"$in{'order_url'}\";\n");
   print (GW "\$mername = \"$in{'mername'}\";\n");
   print (GW "\$acceptcards = \"$in{'acceptcards'}\";\n");
   print (GW "\$acceptchecks = \"$in{'acceptchecks'}\";\n");
   print (GW "\$accepteft = \"$in{'accepteft'}\";\n");
   print (GW "\$altaddr = \"$in{'altaddr'}\";\n");
   print (GW "\$email_text = \"$email_text\";\n");
   print (GW "\$merchant_live_mode = \"$in{'live_mode'}\";\n");
   print (GW "1\;\n");
   close(GW);
  }
 }
##############################################################################
sub iTransact_mgr_check {
if ($sc_gateway_name eq "iTransact") {
  &print_iTransact_mgr_form;
  &call_exit;
 }
}
##############################################################################
sub print_iTransact_mgr_form {
	
##
## ITRANSACT
##

print &$manager_page_header("iTransact Gateway","","","","");

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=580>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
<FONT FACE=ARIAL>
iTransact Settings<br>$msg<br>
Don't forget that iTransact uses PGP signatures to validate
every transaction.  To take full advantage of this, you should
install PGP or RSA-enabled GPG on your server and set it up properly 
on the PGP/GPG page.  You will need to import the
iTransact public key as well, see the instructions at:<br><br>
&nbsp;&nbsp;&nbsp;&nbsp;
<a href="http://www.itransact.com/support/pgp.html">
http://www.itransact.com/support/pgp.html</a><br>
</FONT>

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
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Gateway settings 
have been successfully updated</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<FORM METHOD="POST" ACTION="manager.cgi">
<CENTER>
<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>Are you ready to go live?  (Answer "no" to run in test mode.)</TD>
<TD>
<SELECT NAME="live_mode">
<OPTION>$merchant_live_mode</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>

</TABLE><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD WIDTH="200">
Gateway Username
</TD>
<TD WIDTH="350">
<INPUT NAME="sc_gateway_username" TYPE="TEXT" SIZE=30 
VALUE='$sc_gateway_username'><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Secure URL to your Gateway's server
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="order_url" TYPE="TEXT" SIZE=60
VALUE="$sc_order_script_url"><br>
</TD>
</TR>

</TABLE><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Enter the name of your business here.
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="mername" TYPE="TEXT" SIZE=60 VALUE="$mername"><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>
Are setup to accept credit cards through iTransact? 
Select '0' for no, '1' for yes.
</TD>
<TD>
<SELECT NAME="acceptcards">
<OPTION>$acceptcards</OPTION>
<OPTION VALUE="0">0</OPTION>
<OPTION VALUE="1">1</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>
Are you setup to accept checks through iTransact?
Select '0' for no, '1' for yes.
</TD>
<TD>
<SELECT NAME="acceptchecks">
<OPTION>$acceptchecks</OPTION>
<OPTION VALUE="0">0</OPTION>
<OPTION VALUE="1">1</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>
Are you setup to accept EFT through iTransact?
Select '0' for no, '1' for yes.
</TD>
<TD>
<SELECT NAME="accepteft">
<OPTION>$accepteft</OPTION>
<OPTION VALUE="0">0</OPTION>
<OPTION VALUE="1">1</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>
Do you want to allow customers to 
enter an alternate shipping address?
Select '0' for no, '1' for yes.
</TD>
<TD>
<SELECT NAME="altaddr">
<OPTION>$altaddr</OPTION>
<OPTION VALUE="0">0</OPTION>
<OPTION VALUE="1">1</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

</TABLE><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>


<TR>
<TD COLSPAN="2">
Enter the text that you'd like to appear
in the body of the confirmation e-mail
sent to the customer.
</TD>
</TR>
<TR>
<TD COLSPAN="2">
<TEXTAREA NAME="email_text" ROWS=6 COLS=60 
wrap=soft>$email_text</TEXTAREA>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT TYPE="HIDDEN" NAME="gateway" VALUE="iTransact">
<INPUT NAME="GatewaySettings" TYPE="SUBMIT" VALUE="Submit">
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
##############################################################################
1; #Library
