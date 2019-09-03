#
# For the Credit Card Processing Gateway AuthorizeNet
# SIM version
#
# Copyright 2001 Steve Kneizys.
# Copyright 2002, 2003 K-Factor Technologies, Inc.  All Rights Reserved.
# March 6, 2003 SIM integration version

$versions{'AuthorizeNet-mgr_lib.pl'} = "20030306";
&add_codehook("gateway_admin_screen","AuthorizeNet_mgr_check");
&add_codehook("gateway_admin_settings","AuthorizeNet_settings");
$mc_gateways .= "|AuthorizeNet";
$tstamptemp = time;
##############################################################################
sub AuthorizeNet_settings {
if ($sc_gateway_name eq "AuthorizeNet") {

  $x_Description = &my_escape($in{'x_Description'});
  $x_Header_Html_Payment_Form = &my_escape($in{'x_Header_Html_Payment_Form'});
  $x_Footer_Html_Payment_Form = &my_escape($in{'x_Footer_Html_Payment_Form'});
  $x_Header_Html_Receipt = &my_escape($in{'x_Header_Html_Receipt'});
  $x_Footer_Html_Receipt = &my_escape($in{'x_Footer_Html_Receipt'});
  $x_Header_Email_Receipt = &my_escape($in{'x_Header_Email_Receipt'});
  $x_Footer_Email_Receipt = &my_escape($in{'x_Footer_Email_Receipt'});

  open (GW, "> $gateway_settings") || &my_die("Can't Open $gateway_settings");
$sc_auth_top_message_temp = &my_escape($in{'sc_auth_top_message'});
  print (GW "\$sc_auth_top_message = qq'$sc_auth_top_message_temp';\n");
  print (GW "\$sc_gateway_username = '$in{'sc_gateway_username'}';\n");
  print (GW "\$txnkey = \"$in{'txnkey'}\";\n");
  print (GW "\$sc_tstamp2 = \"$in{'sc_tstamp2'}\";\n");
  print (GW "\$sc_tstamp3 = \"$in{'sc_tstamp3'}\";\n");
  print (GW "\$sc_order_script_url = \"$in{'order_url'}\";\n");
  print (GW "\$sc_auth_upsgroundres = \"$in{'sc_auth_upsgroundres'}\";\n");
  print (GW "\$sc_auth_upsgroundcomm = \"$in{'sc_auth_upsgroundcomm'}\";\n");
  print (GW "\$sc_auth_ups2da = \"$in{'sc_auth_ups2da'}\";\n");
  print (GW "\$sc_auth_ups1da = \"$in{'sc_auth_ups1da'}\";\n");
  print (GW "\$sc_auth_fedexprioiryovernight = \"$in{'sc_auth_fedexprioiryovernight'}\";\n");
  print (GW "\$sc_auth_fedexexpress = \"$in{'sc_auth_fedexexpress'}\";\n");
  print (GW "\$sc_auth_fedexground = \"$in{'sc_auth_fedexground'}\";\n");
  print (GW "\$sc_auth_fedexhome = \"$in{'sc_auth_fedexhome'}\";\n");
  print (GW "\$sc_auth_uspsparcelpost = \"$in{'sc_auth_uspsparcelpost'}\";\n");
  print (GW "\$sc_auth_uspsprioritymail = \"$in{'sc_auth_uspsprioritymail'}\";\n");
  print (GW "\$sc_auth_uspsexpressmail = \"$in{'sc_auth_uspsexpressmail'}\";\n");
  print (GW "\$x_Logo_URL = \"$in{'x_Logo_URL'}\";\n");
  print (GW "\$x_Color_Background = \"$in{'x_Color_Background'}\";\n");
  print (GW "\$x_Color_Link = \"$in{'x_Color_Link'}\";\n");
  print (GW "\$x_Color_Text = \"$in{'x_Color_Text'}\";\n");
  print (GW "\$x_Description = \"$x_Description\";\n");
  print (GW "\$x_Header_Html_Payment_Form = \"$x_Header_Html_Payment_Form\";\n");
  print (GW "\$x_Footer_Html_Payment_Form = \"$x_Footer_Html_Payment_Form\";\n");
  print (GW "\$x_Header_Html_Receipt = \"$x_Header_Html_Receipt\";\n");
  print (GW "\$x_Footer_Html_Receipt = \"$x_Footer_Html_Receipt\";\n");
  print (GW "\$x_Header_Email_Receipt = \"$x_Header_Email_Receipt\";\n");
  print (GW "\$x_Footer_Email_Receipt = \"$x_Footer_Email_Receipt\";\n");
  print (GW "\$merchant_live_mode = \"$in{'live_mode'}\";\n");
  print (GW  "1\;\n");
  close(GW);

 }
}
##############################################################################
sub AuthorizeNet_mgr_check {
if ($sc_gateway_name eq "AuthorizeNet") {
  &print_AuthorizeNet_mgr_form;
  &call_exit;
 }
}
##############################################################################
sub print_AuthorizeNet_mgr_form {
	
##
## AUTHORIZE.NET
##

print &$manager_page_header("AuthorizeNet Gateway","","","","");

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=580>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>
$sc_gateway_name Settings
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

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<FORM METHOD="POST" ACTION="manager.cgi">
<CENTER>
<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2>Note: if you are wishing to use this gateway with zOffline (as part of multiple gateways), you will need to download the version or the add-on available only to pro members.  See AgoraCart.com for more information about becoming a Pro member for only \$29.95 per year or \$59.95 for Life.<br><br><HR></TD>
</TR>

<TR>
<TD width=80%>
Are you ready to go live?  (Answer "no" to run in 
test mode.)</TD>
<TD>
<SELECT NAME="live_mode">
<OPTION>$merchant_live_mode</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

</table><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD width="80%">
<b>Gateway Username</b></td>
<TD width="20%">
<INPUT NAME="sc_gateway_username" TYPE="TEXT" SIZE=30 
VALUE='$sc_gateway_username'><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD width="80%">
<b>Transaction Key</b><br>
To get the actual 'Transaction Key' value for above go into your control panel at Authorize.net<br><br>
1) Click on settings<br>
2) Click on 'Obtain Transaction Key' under the security section.<br>
3) Enter your 'Secret Answer' and click Submit. Your secret answer should be what you used when you first set up your account.<br><br>

NOTE: Someone reported that after you generate/change the Transaction Key it may take about a half hour for this to become active.... if you experience problems at first you may want to wait a while to make sure that this is not the problem.<br><br>

</td>
<TD width="20%">
<INPUT NAME="txnkey" TYPE="TEXT" SIZE=30 
VALUE='$txnkey'><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD width="80%">
<b>Time Stamp</b><br>
if you get error 97 you may have to change your timestamp to match Authorize.net's clock, to do that Go to http://www.sluggis.com/fptest.htm , use the time to the left, it will tell you how many seconds you are off by.<br><br>Do this immediately or reload this page for an acurrate number.<br><br> If you are within say 5-10 minutes either way, don't worry about adjusting the time stamp..
</td>
<TD width="20%">
Actual <INPUT NAME="tstamptemp" TYPE="TEXT" SIZE=20 
VALUE='$tstamptemp'><br><br>
Adjust up or down
<SELECT NAME="sc_tstamp3">
<OPTION>$sc_tstamp3</OPTION>
<OPTION>add</OPTION>
<OPTION>subtract</OPTION>
</SELECT><br><br>
How many seconds:<br>
<INPUT NAME="sc_tstamp2" TYPE="TEXT" SIZE=20 
VALUE='$sc_tstamp2'><br>
</TD>
</TR>
<TR>
<TD COLSPAN=2><HR></TD>
</TR>
<TR>
<TD>Do you offer UPS Ground Residential</TD>
<TD>
<SELECT NAME="sc_auth_upsgroundres">
<OPTION>$sc_auth_upsgroundres</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer UPS Ground Commercial</TD>
<TD>
<SELECT NAME="sc_auth_upsgroundcomm">
<OPTION>$sc_auth_upsgroundcomm</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer UPS 2nd Day</TD>
<TD>
<SELECT NAME="sc_auth_ups2da">
<OPTION>$sc_auth_ups2da</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer UPS Next Day</TD>
<TD>
<SELECT NAME="sc_auth_ups1da">
<OPTION>$sc_auth_ups1da</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer FedEx Priority Overnight</TD>
<TD>
<SELECT NAME="sc_auth_fedexprioiryovernight">
<OPTION>$sc_auth_fedexprioiryovernight</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer FedEx Express Saver</TD>
<TD>
<SELECT NAME="sc_auth_fedexexpress">
<OPTION>$sc_auth_fedexexpress</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer FedEx Ground</TD>
<TD>
<SELECT NAME="sc_auth_fedexground">
<OPTION>$sc_auth_fedexground</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer FedEx Home Delivery</TD>
<TD>
<SELECT NAME="sc_auth_fedexhome">
<OPTION>$sc_auth_fedexhome</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer USPS Parcel Post</TD>
<TD>
<SELECT NAME="sc_auth_uspsparcelpost">
<OPTION>$sc_auth_uspsparcelpost</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer USPS Priority Mail</TD>
<TD>
<SELECT NAME="sc_auth_uspsprioritymail">
<OPTION>$sc_auth_uspsprioritymail</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>
<TR>
<TD>Do you offer USPS Express Mail</TD>
<TD>
<SELECT NAME="sc_auth_uspsexpressmail">
<OPTION>$sc_auth_uspsexpressmail</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR><TD COLSPAN=2>
Top message for Order form.  Allows you to place a message above the Payment Information area and just below the cart total boxes.  HTML formatting (for text color, font, spacing, etc) is accepted.  Leave blank if not needed:<br>
<TEXTAREA NAME="sc_auth_top_message" 
cols="68" rows=8 
wrap=off>$sc_auth_top_message</TEXTAREA> <br><br>
</TD>
</TR>
</table><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

</table><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

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

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Complete URL to the logo you'd like to display on your orderform.
This <b>MUST</b> be a secure https URL. You can also leave this 
blank if you prefer.
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="x_Logo_URL" TYPE="TEXT" SIZE=60 VALUE="$x_Logo_URL"><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

</table><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD width="80%">
Background color of your orderform.
</TD>
<TD width="20%">
<SELECT NAME="x_Color_Background">
<OPTION>$x_Color_Background</OPTION>
<OPTION VALUE="#00FFFF">AQUA</OPTION>
<OPTION VALUE="#000000">BLACK</OPTION>
<OPTION VALUE="#0000FF">BLUE</OPTION>
<OPTION VALUE="#FF00FF">FUCHSIA</OPTION>
<OPTION VALUE="#808080">GRAY</OPTION>
<OPTION VALUE="#008000">GREEN</OPTION>
<OPTION VALUE="#00FF00">LIME</OPTION>
<OPTION VALUE="#800000">MAROON</OPTION>
<OPTION VALUE="#000080">NAVY</OPTION>
<OPTION VALUE="#808000">OLIVE</OPTION>
<OPTION VALUE="#800080">PURPLE</OPTION>
<OPTION VALUE="#FF0000">RED</OPTION>
<OPTION VALUE="#C0C0C0">SILVER</OPTION>
<OPTION VALUE="#008080">TEAL</OPTION>
<OPTION VALUE="#FFFFFF">WHITE</OPTION>
<OPTION VALUE="#FFFF00">YELLOW</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>
Text Color
</TD>
<TD>
<SELECT NAME="x_Color_Text">
<OPTION>$x_Color_Text</OPTION>
<OPTION VALUE="#00FFFF">AQUA</OPTION>
<OPTION VALUE="#000000">BLACK</OPTION>
<OPTION VALUE="#0000FF">BLUE</OPTION>
<OPTION VALUE="#FF00FF">FUCHSIA</OPTION>
<OPTION VALUE="#808080">GRAY</OPTION>
<OPTION VALUE="#008000">GREEN</OPTION>
<OPTION VALUE="#00FF00">LIME</OPTION>
<OPTION VALUE="#800000">MAROON</OPTION>
<OPTION VALUE="#000080">NAVY</OPTION>
<OPTION VALUE="#808000">OLIVE</OPTION>
<OPTION VALUE="#800080">PURPLE</OPTION>
<OPTION VALUE="#FF0000">RED</OPTION>
<OPTION VALUE="#C0C0C0">SILVER</OPTION>
<OPTION VALUE="#008080">TEAL</OPTION>
<OPTION VALUE="#FFFFFF">WHITE</OPTION>
<OPTION VALUE="#FFFF00">YELLOW</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>
Link Color
</TD>
<TD>
<SELECT NAME="x_Color_Link">
<OPTION>$x_Color_Link</OPTION>
<OPTION VALUE="#00FFFF">AQUA</OPTION>
<OPTION VALUE="#000000">BLACK</OPTION>
<OPTION VALUE="#0000FF">BLUE</OPTION>
<OPTION VALUE="#FF00FF">FUCHSIA</OPTION>
<OPTION VALUE="#808080">GRAY</OPTION>
<OPTION VALUE="#008000">GREEN</OPTION>
<OPTION VALUE="#00FF00">LIME</OPTION>
<OPTION VALUE="#800000">MAROON</OPTION>
<OPTION VALUE="#000080">NAVY</OPTION>
<OPTION VALUE="#808000">OLIVE</OPTION>
<OPTION VALUE="#800080">PURPLE</OPTION>
<OPTION VALUE="#FF0000">RED</OPTION>
<OPTION VALUE="#C0C0C0">SILVER</OPTION>
<OPTION VALUE="#008080">TEAL</OPTION>
<OPTION VALUE="#FFFFFF">WHITE</OPTION>
<OPTION VALUE="#FFFF00">YELLOW</OPTION>
</SELECT>
</TD>
</TR>

</table><TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
Enter the text that you'd like displayed at the <b>top
of your orderform</b>.
</TD>
</TR>
<TR>
<TD COLSPAN="2">
<TEXTAREA NAME="x_Header_Html_Payment_Form" ROWS=6 COLS=60 
wrap=soft>$x_Header_Html_Payment_Form</TEXTAREA>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
Enter the text that you'd like displayed at the <b>bottom
of your orderform</b>.
</TD>
</TR>
<TR>
<TD COLSPAN="2">
<TEXTAREA NAME="x_Footer_Html_Payment_Form" ROWS=6 COLS=60 
wrap=soft>$x_Footer_Html_Payment_Form</TEXTAREA>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
Enter the text that you'd like displayed at the <b>top
of your receipt page</b>.
</TD>
</TR>
<TR>
<TD COLSPAN="2">
<TEXTAREA NAME="x_Header_Html_Receipt" ROWS=6 COLS=60 
wrap=soft>$x_Header_Html_Receipt</TEXTAREA>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
Enter the text that you'd like displayed at the <b>bottom
of your receipt page</b>.
</TD>
</TR>
<TR>
<TD COLSPAN="2">
<TEXTAREA NAME="x_Footer_Html_Receipt" ROWS=6 COLS=60 
wrap=soft>$x_Footer_Html_Receipt</TEXTAREA>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
Enter the text that you'd like displayed at the <b>top
of your customer's e-mail receipt</b>.
</TD>
</TR>
<TR>
<TD COLSPAN="2">
<TEXTAREA NAME="x_Header_Email_Receipt" ROWS=6 COLS=60 
wrap=soft>$x_Header_Email_Receipt</TEXTAREA>
</TD>
</TR>

<TR>
<TD COLSPAN="2">
Enter the text that you'd like displayed at the <b>bottom
of your customer's e-mail receipt</b>.
</TD>
</TR>
<TR>
<TD COLSPAN="2">
<TEXTAREA NAME="x_Footer_Email_Receipt" ROWS=6 COLS=60 
wrap=soft>$x_Footer_Email_Receipt</TEXTAREA>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
What description do you want to use for the order? (no longer used in SIM)
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="x_Description" TYPE="TEXT" SIZE=60 
VALUE="$x_Description"><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT TYPE="HIDDEN" NAME="gateway" VALUE="$sc_gateway_name">
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
