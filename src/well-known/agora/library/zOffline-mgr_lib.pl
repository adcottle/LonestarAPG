#
# For the 'zOffline' Multiple Choice Processing Gateway
#  Configured for PayPal and Offline Processing Options
#
# Copyright 2001-2002 K-Factor Technologies, Inc at http://www.AgoraCart.com .  All Rights Reserved.

$versions{'zOffline-mgr_lib.pl'} = "20011123";
&add_codehook("gateway_admin_screen","zOffline_mgr_check");
&add_codehook("gateway_admin_settings","zOffline_settings");
$mc_gateways .= "|zOffline";
##############################################################################
sub zOffline_settings {
local($custom_logic);
if ($sc_gateway_name eq "zOffline") {
  open (GATEWAY, "> $gateway_settings") || 
    &my_die("Can't Open $gateway_settings");
  print (GATEWAY  "\$sc_order_script_url = \"$in{'order_url'}\";\n");
  print (GATEWAY  "\$sc_zOffline_CC_validation = \"$in{'CC_validation'}\";\n");
  print (GATEWAY  "\$sc_allow_pay_by_check = \"$in{'pay_by_check'}\";\n");
  print (GATEWAY  "\$sc_allow_pay_by_PO = \"$in{'pay_by_PO'}\";\n");
  print (GATEWAY  "\$sc_allow_pay_by_CC = \"$in{'pay_by_CC'}\";\n");
  print (GATEWAY  "\$sc_zOffline_show_table = \"$in{'show_table'}\";\n");
  &codehook("manager_write_gateway_settings");
  &codehook("zOffline_mgr_write_settings");
  print (GATEWAY  "1\;\n");
  close(GATEWAY);
 }
}
##############################################################################
sub zOffline_mgr_check {
if ($sc_gateway_name eq "zOffline") {
  &print_zOffline_mgr_form;
  &call_exit;
 }
}
##############################################################################
sub print_zOffline_mgr_form {

##
## zOffline PROCESSING
##

print &$manager_page_header("$sc_gateway_name Gateway","","","","");

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=580>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>
zOffline Processing
$msg</FONT>
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
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Gateway settings have been successfully updated</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

if ($sc_allow_pay_by_check eq '') { # default it in
  $sc_allow_pay_by_check = 'yes';
 }
if ($sc_allow_pay_by_PO eq '') { # default it in
  $sc_allow_pay_by_PO = 'no';
 }
#if ($sc_allow_pay_by_CC eq '') { # default it in
#  $sc_allow_pay_by_CC = 'yes';
# }
if ($sc_zOffline_show_table eq '') { # default it in
  $sc_zOffline_show_table = 'no';
 }
if ($sc_zOffline_CC_validation eq '') { # default it in
  $sc_zOffline_CC_validation = $sc_CC_validation;
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
<TD COLSPAN=2><TABLE WIDTH="100%"><TR>
<TD>Create a browser receipt after order completion?:</TD>
<TD>
<SELECT NAME="show_table">
<OPTION>$sc_zOffline_show_table</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
$mc_zOffline_show_table_special_option
</SELECT>
</TD>
</TR></TABLE></TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2><TABLE WIDTH="100%"><TR>
<TD>Allowed Payment Methods (in addtion to Credit Cards):</TD>
<TD>
Check:<br>
<SELECT NAME="pay_by_check">
<OPTION>$sc_allow_pay_by_check</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
$mc_pay_by_check_special_option
</SELECT>
</TD>
<TD>Purchase Order:<BR>
<SELECT NAME="pay_by_PO">
<OPTION>$sc_allow_pay_by_PO</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
$mc_pay_by_PO_special_option
</SELECT>
</TD>
</TR></TABLE></TD>
</TR>


<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>Perform a rough validation of CC info?
Attempts to determine if the Credit Card number is a mathematically valid
number and has not expired. 
(Experimental)</TD>
<TD>
<SELECT NAME="CC_validation">
<OPTION>$sc_zOffline_CC_validation</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Please enter the Secure URL to your agora.cgi store.
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="order_url" TYPE="TEXT" SIZE=60
VALUE="$sc_order_script_url"><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<TABLE WIDTH='100%' CELLPADDING=0 CELLSPACING=0>
<TR>
<TD ALIGN='LEFT' WIDTH='20%'>&nbsp;</TD>
<TD WIDTH='60%'>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT TYPE="HIDDEN" NAME="gateway" VALUE="zOffline">
<INPUT NAME="GatewaySettings" TYPE="SUBMIT" VALUE="Submit">
&nbsp;&nbsp;
<INPUT TYPE="RESET" VALUE="Reset">
</CENTER>
</TD>
<TD ALIGN='LEFT' WIDTH='20%'>&nbsp;</TD>
</TR></TABLE>
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
