#
# For the Credit Card Processing Gateway 2checkout
#
# Copyright 2001 Steve Kneizys.  All Rights Reserved.
# June 30, 2001

$versions{'2checkout-mgr_lib.pl'} = "20010630";
&add_codehook("gateway_admin_screen","checkout_mgr_check");
&add_codehook("gateway_admin_settings","checkout_settings");
$mc_gateways .= "|2checkout";
##############################################################################
sub checkout_settings {
if ($sc_gateway_name eq "2checkout") {

  $x_Description = &my_escape($in{'x_Description'});
  $x_Header_Html_Payment_Form = &my_escape($in{'x_Header_Html_Payment_Form'});
  $x_Footer_Html_Payment_Form = &my_escape($in{'x_Footer_Html_Payment_Form'});
  $x_Header_Html_Receipt = &my_escape($in{'x_Header_Html_Receipt'});
  $x_Footer_Html_Receipt = &my_escape($in{'x_Footer_Html_Receipt'});
  $x_Header_Email_Receipt = &my_escape($in{'x_Header_Email_Receipt'});
  $x_Footer_Email_Receipt = &my_escape($in{'x_Footer_Email_Receipt'});

  open (GW, "> $gateway_settings") || &my_die("Can't Open $gateway_settings");
  print (GW "\$sc_gateway_username = '$in{'sc_gateway_username'}';\n");
  print (GW "\$sc_order_script_url = \"$in{'order_url'}\";\n");
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
sub checkout_mgr_check {
if ($sc_gateway_name eq "2checkout") {
  &print_2checkout_mgr_form;
  &call_exit;
 }
}
##############################################################################
sub print_2checkout_mgr_form {
	
##
## AUTHORIZE.NET
##

print &$manager_page_header("2checkout Gateway","","","","");

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
<TD COLSPAN=2><HR></TD>
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
Gateway Username</td>
<TD width="20%">
<INPUT NAME="sc_gateway_username" TYPE="TEXT" SIZE=30 
VALUE='$sc_gateway_username'><br>
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
What description do you want to use for the order?
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
