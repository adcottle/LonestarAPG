# file ./store/protected/main_settings-ext_lib.pl

$versions{'main_settings'} = "20021020";

{
 local ($modname) = 'main_settings';
 if ($mc_change_main_settings_ok eq "") {
   $mc_change_main_settings_ok = "yes";
  }
 if ($mc_change_main_settings_ok =~ /yes/i) {
   &register_extension($modname,"Main Store Settings",$versions{$modname});
   &register_menu('main_settings_screen',"show_main_settings_screen",
	$modname,"Display Main Store Settings");
   &register_menu('ChangeMainSettings',"action_input_main_settings",
	$modname,"Write Main Store Settings");
   &add_settings_choice("Payment Gateway"," Payment Gateway ",
	"gateway_screen");
   &register_menu('gateway_screen',"show_gateway_settings_screen",
	$modname,"Display Gateway Settings");
   &register_menu('GatewaySettings',"write_gateway_settings",
	$modname,"Write Gateway Settings");
   &add_item_to_manager_menu("Program Settings","change_settings_screen=yes",
	"");
   &add_item_to_manager_menu("Payment Gateway","gateway_screen=yes","");
  }
}
#######################################################################################
sub write_gateway_settings {

local($admin_email, $order_email);

&ReadParse;

if ($in{'gateway'} ne "") {
  $sc_gateway_name = $in{'gateway'};
  $sc_gateway_name =~ /([^\n]+)/; 
  $sc_gateway_name = $1;
 } else { 
  require "./admin_files/agora_user_lib.pl";
 }

$gateway_settings = "./admin_files/$sc_gateway_name-user_lib.pl";

$order_email = $in{'email_address_for_orders'}; 
$order_email =~ s/\@/\\@/g;

$admin_email = $in{'admin_email'};
$admin_email =~ s/\@/\\@/g;

&codehook("gateway_admin_settings");

&show_gateway_settings_screen;

}
################################################################################
sub show_gateway_settings_screen {

local ($msg);

local($errs)=&html_eval_settings;

if ($in{'gateway'} ne "") {
  $sc_gateway_name = $in{'gateway'};
  $sc_gateway_name =~ /([^\n]+)/; 
  $sc_gateway_name = $1;
 }

eval("require './admin_files/$sc_gateway_name-user_lib.pl'");
if ($@ ne "") {
  $msg= "<br><FONT COLOR=RED>GATEWAY USER LIB NOT FOUND!</FONT><br>\n";
  $msg.= "You might consider copying the " .
         "$sc_gateway_name example order form and " .
        "$sc_gateway_name-user_lib.pl files from the " .
        "html/main/examples and admin_files/examples directories " .
        "to make things easier.<br>\n";
 }
 
&codehook("gateway_admin_screen");

}
#############################################################################################
sub action_input_main_settings{

local($admin_email, $order_email, $cookieDomain, $cookiePath);
local($other_program_settings)="";
local($myset)="";

&ReadParse;

$cookieDomain = $in{'sc_store_url'};
$cookiePath = $in{'sc_store_url'};

$cookieDomain =~ s/http.*:\/\///g;
$cookieDomain =~ s/\/.*//g;
$cookieDomain =~ s/\/agora.cgi//g;

$cookiePath =~ s/http.*:\/\/$cookieDomain//g;
$cookiePath =~ s/agora.cgi//g;
chop $cookiePath; # no trailing slash

$order_email3 = $in{'email_address_for_orders'}; 
$order_email3 =~ s/\@/\\@/g;

$admin_email = $in{'admin_email'};
$admin_email =~ s/\@/\\@/g;
$sc_temp_money_symbol = '$';
$order_email5 = $in{'second_email_address_for_orders'};
$order_email5 =~ s/\@/\\@/g;
$order_email = $order_email3;
if ($in{'second_email_orders_yes_no'} =~ /yes/i) {
$order_email6 = "," . $order_email5;
$order_email = $order_email3 . $order_email6;
}

$myset = "";

if ($in{'sc_set_0077_umask'} =~ /yes/i) {
  $myset .= "\$sc_set_0077_umask = 'yes';\n";
  $myset .= "\$original_umask = umask 0077;\n";
 } else {
  $myset .= "\$sc_set_0077_umask = 'no';\n";
  $myset .= "\$original_umask = umask;\n";
 }
$myset .= "\$sc_allow_ofn_choice = \"$in{'sc_allow_ofn_choice'}\";\n";
$myset .= "\$sc_gateway_name = \"$in{'gateway_name'}\";\n";
$myset .= "\$sc_database_lib = \"$in{'database_lib'}\";\n";
$myset .= "\$sc_prod_db_pad_length = \"$in{'sc_prod_db_pad_length'}\";\n";
$sc_money_symbol = $in{'sc_money_symbol'};
if ($sc_money_symbol =~ /\$/i) {
$myset .= "\$sc_money_symbol = \'$sc_temp_money_symbol\';\n";
 } else {
  $myset .= "\$sc_money_symbol = \'$in{'sc_money_symbol'}\';\n";
 }
$myset .= "\$sc_money_symbol_placement = \"$in{'sc_money_symbol_placement'}\";\n";
$myset .= "\$sc_http_affilliate_call = \'$in{'sc_http_affilliate_call'}\';\n";
if ($in{'sc_affiliate_image_call'} ne '') {
$temp_affiliate_image_call = "<IMG SRC=\"$sc_http_affilliate_call://" . $in{'sc_affiliate_image_call'} . "\" border=0>";
$myset .= "\$sc_affiliate_image_call = \'$temp_affiliate_image_call\';\n";
} else {
$myset .= "\$sc_affiliate_image_call = \'$in{'sc_affiliate_image_call'}\';\n";
}
$myset .= "\$sc_send_order_to_email = \"$in{'email_orders_yes_no'}\";\n";
$myset .= "\$sc_second_send_order_to_email = \"$in{'second_email_orders_yes_no'}\";\n";
$myset .= "\$sc_order_log_name = \"$in{'name_of_the_log_file'}\";\n";
$myset .= "\$sc_send_order_to_log = \"$in{'log_orders_yes_no'}\";\n";
$myset .= "\$sc_order_email = \"$order_email\";\n";
$myset .= "\$sc_first_order_email = \"$order_email3\";\n";
$myset .= "\$sc_second_order_email = \"$order_email5\";\n";
$myset .= "\$sc_store_url = \"$in{'sc_store_url'}\";\n";
$myset .= "\$sc_ssl_location_url2 = \"$in{'sc_ssl_location_url2'}\";\n";
$myset .= "\$sc_stepone_order_script_url = \"$in{'sc_ssl_location_url2'}\";\n";
$myset .= "\$sc_admin_email = \"$admin_email\";\n";
$myset .= "\$sc_domain_name_for_cookie = \"$cookieDomain\";\n";
$myset .= "\$sc_path_for_cookie = \"$cookiePath\";\n";
$myset .= "\$sc_self_serve_images = \"$in{'sc_self_serve_images'}\";\n";
if ($in{'sc_self_serve_images'} =~ /yes/i) {
#  $myset .= "\$URL_of_images_directory = \"agora.cgi?picserve=\";\n";
  $myset .= "\$URL_of_images_directory = \"picserve.cgi?picserve=\";\n";
 } else {
  $myset .= "\$URL_of_images_directory = " . 
                   "\"$in{'URL_of_images_directory'}\";\n";
}
$myset .= "\$sc_path_of_images_directory = " . 
                   " \"$in{'URL_of_images_directory'}\";\n";
$myset .= "\$sc_db_max_rows_returned = \"$in{'sc_db_max_rows_returned'}\";\n";
$myset .= "\$sc_order_check_db = \"$in{'sc_order_check_db'}\";\n";
$myset .= "\$sc_use_html_product_pages = \"$in{'sc_use_html_product_pages'}\";\n";
$myset .= "\$sc_should_i_display_cart_after_purchase = \"$in{'sc_should_i_display_cart_after_purchase'}\";\n";
$myset .= "\$sc_scramble_cc_info = \"$in{'scramble_cc_info'}\";\n";
&codehook("other_program_settings");
if ($other_program_settings ne "") {
  $myset .= "$other_program_settings\n";
 }
&update_store_settings('MAIN',$myset); # main settings
&show_main_settings_screen;
}
#######################################################################################
sub show_main_settings_screen {

print &$manager_page_header("Main Store Settings","","","","");

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=580>
</CENTER>

<CENTER>
<TABLE WIDTH=580>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Welcome to the <b>AgoraCart</b> System Manager. Here you
will set the data variables specific to your store.</TD>
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
<FONT FACE=ARIAL SIZE=2 COLOR=RED>System settings have been successfully updated. Check your Gateway Settings <a href=manager.cgi?gateway_screen=yes>here</a></FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

&make_lists_of_various_options;

#set some defaults
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

#if ($sc_path_of_images_directory ne "") {
# $URL_of_images_directory = $sc_path_of_images_directory;
#}

if ($sc_path_of_images_directory eq "") {
 $sc_path_of_images_directory =  $URL_of_images_directory;
}
if ($sc_UPS_RateChart eq "") {
  $sc_UPS_RateChart = "Regular Daily Pickup";
 }
if ($sc_allow_ofn_choice eq ""){
  $sc_allow_ofn_choice = "no";
 }
if ($sc_allow_ofn_choice =~ /yes/i){
  $sc_allow_ofn_choice = "yes";
  $sc_other_ofn = "no";
 } else {
  $sc_allow_ofn_choice = "no";
  $sc_other_ofn = "yes";
 }
if ($sc_debug_mode eq ""){
  $sc_debug_mode = "no";
 }
if ($sc_set_0077_umask eq ""){
  $sc_set_0077_umask = "no";
 }
if ($sc_set_0077_umask =~ /yes/i){
  $sc_set_0077_umask = "yes";
  $sc_other_0077 = "no";
 } else {
  $sc_set_0077_umask = "no";
  $sc_other_0077 = "yes";
 }
if ($sc_scramble_cc_info eq ""){
  $sc_scramble_cc_info = "no";
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
<TD colspan=1>
Please select your Primary Payment Gateway:
<br>
<TD colspan=1>
<SELECT NAME=gateway_name>
$mylist_of_gateway_options
</SELECT>
</TD>
</TR>

<TR>
<td>Allow Multiple Gateways?  For security reasons it is a good idea
to delete any order forms from the html/main directory for
gateways you are not using. </td>
<TD><SELECT NAME=sc_allow_ofn_choice>
<OPTION SELECTED>$sc_allow_ofn_choice</OPTION>
<OPTION>$sc_other_ofn</OPTION> 
</SELECT></TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD colspan=2>
Select your Database library and set the product database key pad length:
<br>
Library: <SELECT NAME=database_lib>
$mylist_of_database_libs
</SELECT>
&nbsp;&nbsp;&nbsp;&nbsp;
Key Pad Length: <INPUT NAME="sc_prod_db_pad_length" TYPE="TEXT" SIZE=1 
MAXLENGTH="1" VALUE="$sc_prod_db_pad_length">
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD colspan=2>
Enter your Monetary Symbol and Select the position of the Symbol:
<br>
Money Symbol: <INPUT NAME="sc_money_symbol" TYPE="TEXT" SIZE=1 
MAXLENGTH="1" VALUE="$sc_money_symbol">
&nbsp;&nbsp;&nbsp;&nbsp;
Position of Symbol: <SELECT NAME=sc_money_symbol_placement>
<option>$sc_money_symbol_placement</option>
<option>front</option>
<option>back</option>
</SELECT>
</TD>
</TR>
<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD colspan=2>
If using an affiliate program, Enter your image call info:
<br><small>in the form of: locationURLtoImage?ordertotal=AMOUNTHERE&unique=UNIQUEIDHERE&otherneededinfo .  edit as needed.  do not enter: &lt;IMG SRC="https:// or the "
BORDER=0&gt; portions of the image call as those are added automatically. For the total, insert this into the AMOUNTHERE: \$sc_affiliate_order_total.  If using the net profit add-on, use this instead: \$x_aff_profit.  For the UniqueID portion, you may use this inserted into the UNIQUEIDHERE portion: \$sc_affiliate_order_unique.  add whatever else is needed by your affiliate program for the image call.</small><br>
<SELECT NAME=sc_http_affilliate_call>
<option>$sc_http_affilliate_call</option>
<option>http</option>
<option>https</option>
</SELECT>&nbsp;&nbsp;&nbsp;

tag info: <INPUT NAME="sc_affiliate_image_call" TYPE="TEXT" SIZE=45 
MAXLENGTH="110" VALUE="$sc_affiliate_image_call">

</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Please enter the full URL of your /images directory. For example:<br>
<b>http://$ENV{'SERVER_NAME'}/cgi-bin/store/html/images</b><br>
DO NOT include the trailing slash!!! <b>/</b>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="URL_of_images_directory" TYPE="TEXT" SIZE=60 
VALUE="$sc_path_of_images_directory"><br>
<b>URL of the /images directory</b>
<br>
Hint: if you desire to use the \%\%URLofImages\%\% token in both
secure https and insecure http pages, then setup things so that
both use the same tree to access the images.  In this case, instead
of using the full URL just use the directory/file part, such as:<br>
<b>/cgi-bin/store/html/images</b> or <b>html/images</b><br><br>
If you cannot do that but the disk paths (disk locations) are
the same, then put the absolute disk path (or relative to agora.cgi 
path) for your server's images
directory above (without the trailing slash) 
and set the next option to "yes" for self-serve of the images.<br>
Do you want to self-serve the images? <SELECT NAME=sc_self_serve_images>
<OPTION>$sc_self_serve_images</OPTION>
<OPTION>No</OPTION> 
<OPTION>Yes</OPTION> 
</SELECT>&nbsp; Say NO unless you have entered the server
disk path above instead of the http:// path or have some
other good reason to use this images serving feature.&nbsp; One reason
would be that your server will not serve images from your cgi-bin 
directory and for some reason you do not desire to move them. 
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Please enter the full URL of your store here. &nbsp;Note: according to 
browser cookie implementation rules, you must have at least two dots in 
the name of the host for cookies to work properly for domains such as 
.com, .org, .net, etc.<BR>
(ex: <b>http://$ENV{'SERVER_NAME'}/cgi-bin/store/agora.cgi</b>)
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="sc_store_url" TYPE="TEXT" SIZE=66 
MAXLENGTH="128" VALUE="$sc_store_url"><br><b>Store URL</b>
</TD>
</TR>

<TR>
<TD COLSPAN=2><br>
<INPUT NAME="sc_ssl_location_url2" TYPE="TEXT" SIZE=66 
MAXLENGTH="128" VALUE="$sc_ssl_location_url2"><br><b>SSL URL</b><br><small>Leave blank if not using SSL<br>. Shared SSL hosting, enter the SSL URL in form of: https://www.SSLserverURLhere.com/pathtoStoreHere/agora.cgi.   If SSL runs under your domain name, then enter the SSL URL inthe form of:  https://www.yourDomanNameHere.com/cgi-bin/store/agora.cgi</small>
</TD>
</TR>

<TR>
<TD COLSPAN=2><br><HR></TD>
</TR>

<TR>
<TD>Do you wish to have orders e-mailed to you?</TD>
<TD><SELECT NAME="email_orders_yes_no">
<OPTION>$sc_send_order_to_email</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT></TD></TR>
<tr><td colspan=2>Email Address to use: <INPUT 
NAME="email_address_for_orders" TYPE="TEXT" 
VALUE="$sc_first_order_email" SIZE="48">
</TD>
</TR>
<TR>
<TD>Do you wish to have orders e-mailed to a second email address?<br><small>NOTE: some hosting services may requie both email addresses to be to the same domain for security and anti-spamming purposes.  If this is the case, setup a forwarding address on the same domain name to forward orders to the email address you need to use.</small></TD>
<TD><SELECT NAME="second_email_orders_yes_no">
<OPTION>$sc_second_send_order_to_email</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT></TD></TR>
<tr><td colspan=2>Email Address to use: <INPUT 
NAME="second_email_address_for_orders" TYPE="TEXT" 
VALUE="$sc_second_order_email" SIZE="48">
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<table width="100%"><tr>
<td>Do you wish to have the orders written to a log file?</td>
<td><SELECT NAME="log_orders_yes_no">
<OPTION>$sc_send_order_to_log</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT></td></tr>
<tr><td>Choose a unique name for your log file.<br> (ex: "mylog3218.log")</TD>
<TD>
<INPUT NAME="name_of_the_log_file" TYPE="TEXT" VALUE="$sc_order_log_name">
</TD>
</tr></table></td>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
Enter the e-mail address of your webmaster or administrator here
</TD>

<TR>
<TD COLSPAN="2">
<INPUT NAME="admin_email" TYPE="TEXT" VALUE="$sc_admin_email" SIZE="55">
</TD>

</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>How many products do you wish to display on each product page?<br>
(May override this by setting the URL/Form variable maxp=nn)</td>
<TD>
<INPUT NAME="sc_db_max_rows_returned" TYPE=TEXT SIZE=4 
  VALUE="$sc_db_max_rows_returned">
</TD>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>Do you wish to verify orders with the database info?  Say "no" 
if running an HTML-based store without a database or adding to the cart from non-agora.cgi parsed pages. NOTE: links to cart and database still need to come from the same domain name as AgoraCart runs from</TD>
<TD><SELECT NAME="sc_order_check_db">
<OPTION>$sc_order_check_db</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT></TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD>How do you want to generate database based html product pages?  <small>Default is "maybe" which allows you to generate database product pages unless a specific ppinc page is specified.  "No" will allow you to only generate pages from the products in the database.  Say "yes" if running an HTML-based store and you are not using a database. NOTE: links to cart and database still need to come from the same domain name as AgoraCart runs from.</small></TD>
<TD><SELECT NAME="sc_use_html_product_pages">
<OPTION>$sc_use_html_product_pages</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
<OPTION>maybe</OPTION>
</SELECT></TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>
<TR>
<TD>How do you want to the customer to view the cart contents after adding an item to the cart?  Default is "no" which takes the customer back to the database generated product page they were originally at with a thank you message generated towards the top of the page.  Say "yes" if running an HTML-based store and you DO NOT want to the customer to go to a database generated product page.</TD>
<TD><SELECT NAME="sc_should_i_display_cart_after_purchase">
<OPTION>$sc_should_i_display_cart_after_purchase</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT></TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<td>Use 0077 umask?  For security reasons it is a good idea
to say yes here if the cgi scripts on your Unix host 
run under your own id.</td>
<TD><SELECT NAME=sc_set_0077_umask>
<OPTION SELECTED>$sc_set_0077_umask</OPTION>
<OPTION>$sc_other_0077</OPTION> 
</SELECT></TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<td>Scramble CC Info?&nbsp; This option scrambles the CC info that
is stored on disk temporarily in the VERIFY files in Offline and other
gateways that take CC info on your server.  Set to yes unless you have
trouble with blank CC numbers in confirmation emails and you are
sure that the VERIFY files are safe from prying eyes.</td>
<TD><SELECT NAME=scramble_cc_info>
<OPTION>$sc_scramble_cc_info</OPTION>
<OPTION>yes</OPTION> 
<OPTION>no</OPTION> 
</SELECT></TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT NAME="ChangeMainSettings" TYPE="SUBMIT" VALUE="Submit">
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
#######################################################################################
1; # Library
