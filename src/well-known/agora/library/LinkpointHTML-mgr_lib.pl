#
# For the CC and Check Processing Gateway Linkpoint HTML, included
# in the base package of agora.cgi, a GPL-ed program.
#
# Copyright 2000,2001 Steve Kneizys. 

$versions{'LinkpointHTML-mgr_lib.pl'} = "20010630";
&add_codehook("gateway_admin_screen","LinkpointHTML_mgr_check");
&add_codehook("gateway_admin_settings","LinkpointHTML_settings");
$mc_gateways .= "|LinkpointHTML";
##############################################################################
sub LinkpointHTML_settings {
local($custom_logic);
if ($sc_gateway_name eq "LinkpointHTML") {

 open (GATEWAY, "> $gateway_settings") || 
	&my_die("Can't Open $gateway_settings");
 print (GATEWAY  "\$sc_gateway_username = \'$in{'sc_gateway_username'}\';\n");
 print (GATEWAY  "\$sc_order_script_url = \"$in{'order_url'}\";\n");
 print (GATEWAY  "#\n1\;# We are a Library\n");
 close(GATEWAY);
 }
}
##############################################################################
sub LinkpointHTML_mgr_check {
if ($sc_gateway_name eq "LinkpointHTML") {
  &print_LinkpointHTML_mgr_form;
  &call_exit;
 }
}
##############################################################################
sub print_LinkpointHTML_mgr_form {
	
#
# Linkpoint HTML Gateway
#

print &$manager_page_header("Linkpoint Gateway","","","","");

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=580 CELLPADDING=0 CELLSPACING=0 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>
Linkpoint HTML Settings
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
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Gateway settings have been successfully
updated</FONT>
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
<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD WIDTH="55%">
ID as registered with Linkpoint.
</TD>
<TD WIDTH="45%">
<INPUT NAME="sc_gateway_username" TYPE="TEXT" SIZE=30
VALUE='$sc_gateway_username'><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
URL to the Linkpoint HTML server
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="order_url" TYPE="TEXT" SIZE=70
VALUE="$sc_order_script_url"><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT TYPE="HIDDEN" NAME="gateway" VALUE="LinkpointHTML">
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
