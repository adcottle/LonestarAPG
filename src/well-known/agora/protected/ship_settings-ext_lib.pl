# file ./store/protected/shipping_settings-ext_lib.pl

$versions{'shipping_settings'} = "20030102";

{
 local ($modname) = 'shipping_settings';
 &register_extension($modname,"Shipping Library Settings",$versions{$modname});
 &add_settings_choice("shipping settings"," Shipping Settings ",
	"shipping_settings_screen");
 &register_menu('shipping_settings_screen',"show_ship_settings_screen",
	$modname,"Display Shipping Library Settings");
 &register_menu('ChangeShipSettings',"action_input_ship_settings",
	$modname,"Write Shipping Library Settings");
}
#######################################################################################
sub action_input_ship_settings
{

local($admin_email, $order_email, $cookieDomain, $cookiePath);
local($other_program_settings)="";
local($myset)="";

&ReadParse;

$myset = "";

$myset .= "\$sc_calculate_shipping_loop = " . 
                 "\"$in{'sc_calculate_shipping_loop'}\";\n";
$myset .= "\$sc_handling_charge = \"$in{'sc_handling_charge'}\";\n";
$myset .= "\$sc_add_handling_cost_if_shipping_is_zero = \"$in{'sc_add_handling_cost_if_shipping_is_zero'}\";\n";
$myset .= "\$sc_use_custom_shipping_logic = \"$in{'sc_use_custom_shipping_logic'}\";\n";
$myset .= "\$sc_use_SBW2 = \"$in{'sc_use_SBW2'}\";\n";
$sc_custom_shipping_logic = &my_escape($in{'sc_custom_shipping_logic'});
$myset .= "\$sc_custom_shipping_logic = qq`$sc_custom_shipping_logic`;\n";
$myset .= "#\n";
$myset .= "\$sc_use_SBW = \"$in{'sc_use_SBW'}\";\n";
$myset .= "\$sc_use_FEDEX = \"$in{'sc_use_FEDEX'}\";\n";
$myset .= "\$sc_use_UPS = \"$in{'sc_use_UPS'}\";\n";
$myset .= "\$sc_use_USPS = \"$in{'sc_use_USPS'}\";\n";
$myset .= "\$sc_use_socket = \"$in{'sc_use_socket'}\";\n";
$myset .= "\$sc_FEDEX_max_wt = \"$in{'sc_FEDEX_max_wt'}\";\n";
$myset .= "\$sc_FEDEX_Origin_ZIP = \"$in{'sc_FEDEX_Origin_ZIP'}\";\n";
$myset .= "\$sc_UPS_max_wt = \"$in{'sc_UPS_max_wt'}\";\n";
$myset .= "\$sc_UPS_Origin_ZIP = \"$in{'sc_UPS_Origin_ZIP'}\";\n";
$myset .= "\$sc_UPS_RateChart = \"$in{'sc_UPS_RateChart'}\";\n";
$myset .= "\$sc_USPS_max_wt = \"$in{'sc_USPS_max_wt'}\";\n";
$myset .= "\$sc_USPS_Origin_ZIP = \"$in{'sc_USPS_Origin_ZIP'}\";\n";
$myset .= "\$sc_USPS_use_API = \"$in{'sc_USPS_use_API'}\";\n";
$myset .= "\$sc_USPS_userid = \"$in{'sc_USPS_userid'}\";\n";
$myset .= "\$sc_USPS_password = \"$in{'sc_USPS_password'}\";\n";
$myset .= "\$sc_USPS_host_URL = \"$in{'sc_USPS_host_URL'}\";\n";

&update_store_settings('shipping',$myset); # main settings
$myset = "";
&show_ship_settings_screen;
}
#############################################################################################
sub show_ship_settings_screen
{
print &$manager_page_header("Shipping Settings","","","","");

if ($sc_debug_mode eq ""){
  $sc_debug_mode = "no";
 }

   $test_result = eval("use LWP::Simple; 1;");
   if ($@ eq "") {
#     use LWP::Simple;
    } else {
     $Lib_message="<FONT COLOR=RED><b>WARNING:</b> LWP library was " .
                  "not found!  Choose one of the other options.</FONT><BR>";
    }
#   $test_result = eval('require "./library/http-lib.pl"');
   if (!($http_lib_ok =~ /yes/i)) {
     $Lib_message .= "<FONT COLOR=RED>Couldn't load http-lib. " .   
                  "Choose one of the other options.</FONT><BR>";
    } 
   $test_result = eval('&get_lynx_path("0")');
   if ($test_result eq "") {
     $Lib_message .= "<FONT COLOR=RED>Lynx was not found. " .     
                  "Choose one of the other options.</FONT><BR>";
    } 

if ($sc_path_of_images_directory ne "") {
 $URL_of_images_directory = $sc_path_of_images_directory;
}

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=580>
</CENTER>

<CENTER>
<TABLE WIDTH=580>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Welcome to the <b>AgoraCart</b> System Manager
Shipping Library settings.</TD>
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
<FONT FACE=ARIAL SIZE=2 COLOR=RED>System settings have been 
successfully updated. </FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

&make_lists_of_various_options;

if ($sc_UPS_RateChart eq "") {
  $sc_UPS_RateChart = "Regular Daily Pickup";
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
<TD><b>In what loop of calculate_final_values do you wish to calculate
the shipping?</b>&nbsp; If zero is selected, shipping will never be
calculated.&nbsp; If 3 is selected, then the tax is based on the
pre-shipping subtotal.&nbsp; Currently, if either 1 or 2 is selected, then
the tax is based on the subtotal of merchandise + shipping.
</TD>

<TD>
<SELECT NAME="sc_calculate_shipping_loop">
<OPTION>$sc_calculate_shipping_loop</OPTION>
<OPTION>0</OPTION>
<OPTION>1</OPTION>
<OPTION>2</OPTION>
<OPTION>3</OPTION>
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<td>Handling Charge to be added to all orders.<br><small>No \$ Needed. Enter 0 if no handling charge is to be added to orders.</small></td>
<TD>
<INPUT NAME="sc_handling_charge" TYPE="TEXT" SIZE=5 MAXLENGTH="5"
VALUE="$sc_handling_charge">
</TD>
</td>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<td>Add handling Charge if shipping total is Zero?</td>
<TD>
<SELECT NAME=sc_add_handling_cost_if_shipping_is_zero>
<OPTION>$sc_add_handling_cost_if_shipping_is_zero</OPTION>
<OPTION>yes</OPTION> 
<OPTION>no</OPTION> 
</SELECT>
</TD>
</td>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
<b>Custom Shipping Logic:</b>
</TD>
</TR>

<TR>
<td>Use the custom shipping logic?  If yes, you may still use the
SBW module (perhaps some items are not appropriate for that 
module and you
desire to handle these differently.)&nbsp;  If Custom logic and SBW are 
both set to "no" then the "shipping" field in the database
is the shipping price of the item.</td>

<TD>
<SELECT NAME=sc_use_custom_shipping_logic>
<OPTION>$sc_use_custom_shipping_logic</OPTION>
<OPTION>yes</OPTION> 
<OPTION>no</OPTION> 
</SELECT>
</TD>
</TR>

<TR>
<td>If using Custom Logic, is shipping measured by weight?  In other words, do you define total shipping price by total order weight within the custom shipping logic? If so, select yes</td>

<TD>
<SELECT NAME=sc_use_SBW2>
<OPTION>$sc_use_SBW2</OPTION>
<OPTION>yes</OPTION> 
<OPTION>no</OPTION> 
</SELECT>
</TD>
</TR>

<TR>
<TD COLSPAN="2">
<TEXTAREA NAME="sc_custom_shipping_logic" 
cols="68" rows=12 wrap=off>$sc_custom_shipping_logic</TEXTAREA> 
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<b>Please enter the SBW (Ship By Weight) Shipping Module
Information:</b><BR>
</TD>
</TR>

<TR>
<td>Use the SBW (Ship By Weight for FedEx/UPS/USPS) module?  If yes, then
the "shipping" field in the database is a shipping weight (instead of 
shipping price.)</td>
<TD>
<SELECT NAME=sc_use_SBW>
<OPTION>$sc_use_SBW</OPTION>
<OPTION>yes</OPTION> 
<OPTION>no</OPTION> 
</SELECT>
</TD>
</TR>
<TR>
<td colspan=2>Allow Shipments via which services:
&nbsp;&nbsp;
FedEx:<SELECT NAME=sc_use_FEDEX>
<OPTION>$sc_use_FEDEX</OPTION>
<OPTION>yes</OPTION> 
<OPTION>no</OPTION> 
</SELECT>
&nbsp;&nbsp;&nbsp;&nbsp;
UPS:<SELECT NAME=sc_use_UPS>
<OPTION>$sc_use_UPS</OPTION>
<OPTION>yes</OPTION> 
<OPTION>no</OPTION> 
</SELECT>
&nbsp;&nbsp;&nbsp;&nbsp;
USPS:<SELECT NAME=sc_use_USPS>
<OPTION>$sc_use_USPS</OPTION>
<OPTION>yes</OPTION> 
<OPTION>no</OPTION> 
</SELECT><br>
NOTE: Using the UPS interface requires that you be REGISTERED and 
accept the LICENSE AGREEMENT.</TD>
</TR>

<TR>
<td colspan=2>
USPS API URL: <INPUT NAME="sc_USPS_host_URL" TYPE="TEXT" SIZE=60
MAXLENGTH="75" VALUE="$sc_USPS_host_URL"><br>
USPS API Userid: <INPUT NAME="sc_USPS_userid" TYPE="TEXT" SIZE=14
MAXLENGTH="25" VALUE="$sc_USPS_userid">
&nbsp;&nbsp;&nbsp;&nbsp;
USPS API Password: <INPUT NAME="sc_USPS_password" TYPE="TEXT" SIZE=14
MAXLENGTH="25" VALUE="$sc_USPS_password">
</TD>
</TR>

<TR> <td> $Lib_message How do you wish to connect to FedEx/UPS/USPS?  If
perl is installed in a fairly modern way, then the LWP library should be
present. If not, then the http-lib has been included here as a backup.  If
for some reason perl sockets have not been setup properly, then you should
complain to your web hosting company to get with the program!</td>
<TD> 
 <SELECT NAME=sc_use_socket>
 <OPTION>$sc_use_socket</OPTION> 
 <OPTION>LWP</OPTION>
 <OPTION>http-lib</OPTION> 
 <OPTION>lynx</OPTION> 
 </SELECT></TD> 
</TR>

<TR>
<td colspan=2>Max weight per box (lbs.)  If zero is entered, each item 
is shipped it its own box.<br>
FedEx: <INPUT NAME="sc_FEDEX_max_wt" TYPE="TEXT" SIZE=3 MAXLENGTH="3"
VALUE="$sc_FEDEX_max_wt">
&nbsp;&nbsp;&nbsp;&nbsp;
UPS: <INPUT NAME="sc_UPS_max_wt" TYPE="TEXT" SIZE=3 MAXLENGTH="3"
VALUE="$sc_UPS_max_wt">
&nbsp;&nbsp;&nbsp;&nbsp;
USPS: <INPUT NAME="sc_USPS_max_wt" TYPE="TEXT" SIZE=3 MAXLENGTH="3"
VALUE="$sc_USPS_max_wt">
</TD>
</TR>

<TR>
<td colspan=2>Origination of shipments:<br>
FedEx ZIP: <INPUT NAME="sc_FEDEX_Origin_ZIP" TYPE="TEXT" SIZE=5
MAXLENGTH="5" VALUE="$sc_FEDEX_Origin_ZIP">
<br>
UPS ZIP: <INPUT NAME="sc_UPS_Origin_ZIP" TYPE="TEXT" SIZE=5 MAXLENGTH="5"
VALUE="$sc_UPS_Origin_ZIP">&nbsp;&nbsp;&nbsp;&nbsp;
UPS Pickup: <SELECT NAME="sc_UPS_RateChart">
   <OPTION VALUE="$sc_UPS_RateChart">$sc_UPS_RateChart</OPTION>
   <OPTION VALUE="Regular Daily Pickup">Regular Daily Pickup
   <OPTION VALUE="On Call Air">On Call Air
   <OPTION VALUE="One Time Pickup">One Time Pickup
   <OPTION VALUE="Letter Center">Letter Center
   <OPTION VALUE="Customer Counter">Customer Counter
</SELECT>
<br>
USPS ZIP: <INPUT NAME="sc_USPS_Origin_ZIP" TYPE="TEXT" SIZE=5
MAXLENGTH="5" VALUE="$sc_USPS_Origin_ZIP">
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT NAME="ChangeShipSettings" TYPE="SUBMIT" VALUE="Submit">
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
1; #Library
