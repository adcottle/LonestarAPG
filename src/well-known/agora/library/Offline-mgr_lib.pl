#
# For the 'Offline' CC and Check Processing Gateway
# Requires atleast 4.0K non-SSI versions and above.
#
# Copyright 2000,2001 Steve Kneizys.
# Copyright 2002, 2003 K-Factor Technologies, Inc.  All Rights Reserved.
$versions{'Offline-mgr_lib.pl'} = "20030306";
&add_codehook("gateway_admin_screen","Offline_mgr_check");
&add_codehook("gateway_admin_settings","Offline_settings");
$mc_gateways .= "|Offline";
##############################################################################
sub Offline_settings {
local($custom_logic);
if ($sc_gateway_name eq "Offline") {
  open (GATEWAY, "> $gateway_settings") || 
    &my_die("Can't Open $gateway_settings");
  print (GATEWAY  "\$sc_order_script_url = \"$in{'order_url'}\";\n");
  print (GATEWAY  "\$sc_Offline_CC_validation = \"$in{'CC_validation'}\";\n");
  print (GATEWAY  "\$sc_allow_pay_by_check = \"$in{'pay_by_check'}\";\n");
  print (GATEWAY  "\$sc_allow_pay_by_PO = \"$in{'pay_by_PO'}\";\n");
  print (GATEWAY  "\$sc_allow_pay_by_CC = \"$in{'pay_by_CC'}\";\n");
  print (GATEWAY  "\$sc_take_discover = \"$in{'sc_take_discover'}\";\n");
  print (GATEWAY  "\$sc_take_amex = \"$in{'sc_take_amex'}\";\n");
  print (GATEWAY  "\$sc_Offline_show_table = \"$in{'show_table'}\";\n");
  print (GATEWAY  "\$sc_upsgroundres = \"$in{'sc_upsgroundres'}\";\n");
  print (GATEWAY  "\$sc_upsgroundcomm = \"$in{'sc_upsgroundcomm'}\";\n");
  print (GATEWAY  "\$sc_ups2da = \"$in{'sc_ups2da'}\";\n");
  print (GATEWAY  "\$sc_ups1da = \"$in{'sc_ups1da'}\";\n");
  print (GATEWAY  "\$sc_fedexprioiryovernight = \"$in{'sc_fedexprioiryovernight'}\";\n");
  print (GATEWAY  "\$sc_fedexexpress = \"$in{'sc_fedexexpress'}\";\n");
  print (GATEWAY  "\$sc_fedexground = \"$in{'sc_fedexground'}\";\n");
  print (GATEWAY  "\$sc_fedexhome = \"$in{'sc_fedexhome'}\";\n");
  print (GATEWAY  "\$sc_uspsparcelpost = \"$in{'sc_uspsparcelpost'}\";\n");
  print (GATEWAY  "\$sc_uspsprioritymail = \"$in{'sc_uspsprioritymail'}\";\n");
  print (GATEWAY  "\$sc_uspsexpressmail = \"$in{'sc_uspsexpressmail'}\";\n");
$sc_offline_top_message_temp = &my_escape($in{'sc_offline_top_message'});
  print (GATEWAY  "\$sc_offline_top_message = qq'$sc_offline_top_message_temp';\n");
$sc_offline_shipping_message_temp = &my_escape($in{'sc_offline_shipping_message'});
  print (GATEWAY  "\$sc_offline_shipping_message = qq'$sc_offline_shipping_message_temp';\n");
$sc_offline_special_message_temp = &my_escape($in{'sc_offline_special_message'});
  print (GATEWAY  "\$sc_offline_special_message = qq'$sc_offline_special_message_temp';\n");
  &codehook("manager_write_gateway_settings");
  &codehook("Offline_mgr_write_settings");
  print (GATEWAY  "1\;\n");
  close(GATEWAY);
 }
}
##############################################################################
sub Offline_mgr_check {
if ($sc_gateway_name eq "Offline") {
  &print_Offline_mgr_form;
  &call_exit;
 }
}
##############################################################################
sub print_Offline_mgr_form {

##
## OFFLINE PROCESSING
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
Offline Processing
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
if ($sc_Offline_show_table eq '') { # default it in
  $sc_Offline_show_table = 'no';
 }
if ($sc_Offline_CC_validation eq '') { # default it in
  $sc_Offline_CC_validation = $sc_CC_validation;
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
<OPTION>$sc_Offline_show_table</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
$mc_Offline_show_table_special_option
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
<OPTION>$sc_Offline_CC_validation</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>Visa and Master Cards are accepted by default.  Please indicate if you accept Discover and American Express</TD>
<TD><b>Discover:</b> 
<SELECT NAME="sc_take_discover">
<OPTION>$sc_take_discover</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT><br><br>

<b>American Express:</b> 
<SELECT NAME="sc_take_amex">
<OPTION>$sc_take_amex</OPTION>
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
<TD>Do you offer UPS Ground Residential</TD>
<TD>
<SELECT NAME="sc_upsgroundres">
<OPTION>$sc_upsgroundres</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer UPS Ground Commercial</TD>
<TD>
<SELECT NAME="sc_upsgroundcomm">
<OPTION>$sc_upsgroundcomm</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer UPS 2nd Day</TD>
<TD>
<SELECT NAME="sc_ups2da">
<OPTION>$sc_ups2da</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer UPS Next Day</TD>
<TD>
<SELECT NAME="sc_ups1da">
<OPTION>$sc_ups1da</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer FedEx Priority Overnight</TD>
<TD>
<SELECT NAME="sc_fedexprioiryovernight">
<OPTION>$sc_fedexprioiryovernight</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer FedEx Express Saver</TD>
<TD>
<SELECT NAME="sc_fedexexpress">
<OPTION>$sc_fedexexpress</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer FedEx Ground</TD>
<TD>
<SELECT NAME="sc_fedexground">
<OPTION>$sc_fedexground</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer FedEx Home Delivery</TD>
<TD>
<SELECT NAME="sc_fedexhome">
<OPTION>$sc_fedexhome</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer USPS Parcel Post</TD>
<TD>
<SELECT NAME="sc_uspsparcelpost">
<OPTION>$sc_uspsparcelpost</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer USPS Priority Mail</TD>
<TD>
<SELECT NAME="sc_uspsprioritymail">
<OPTION>$sc_uspsprioritymail</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer USPS Express Mail</TD>
<TD>
<SELECT NAME="sc_uspsexpressmail">
<OPTION>$sc_uspsexpressmail</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR><TD COLSPAN=2>
Top message for Offline form.  Allows you to place a message above the Payment Information area and just below the cart total boxes.  HTML formatting (for text color, font, spacing, etc) is accepted.  Leave blank if not needed:<br>
<TEXTAREA NAME="sc_offline_top_message" 
cols="68" rows=8 
wrap=off>$sc_offline_top_message</TEXTAREA> <br><br>

Shipping message for Offline form.  Allows you to place a message in the Shipping Information area of the Offline form.  HTML formatting (for text color, font, spacing, etc) is accepted.  Leave blank if not needed:<br>
<TEXTAREA NAME="sc_offline_shipping_message" 
cols="68" rows=8 
wrap=off>$sc_offline_shipping_message</TEXTAREA> <br><br>

Message for Special Message area for Offline form.  Allows you to place a message just above the Special Message area of the Offline form.  HTML formatting (for text color, font, spacing, etc) is accepted.  Leave blank if not needed:<br>
<TEXTAREA NAME="sc_offline_special_message" 
cols="68" rows=8 
wrap=off>$sc_offline_special_message</TEXTAREA> <br><br>
</TD></TR>

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
<INPUT TYPE="HIDDEN" NAME="gateway" VALUE="Offline">
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
