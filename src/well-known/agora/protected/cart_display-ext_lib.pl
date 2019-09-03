# file ./store/protected/cart_display-ext_lib.pl

$versions{'cart_display'} = "20021020";

{
 local ($modname) = 'cart_display';
 &register_extension($modname,"Cart Display Settings",$versions{$modname});
 &add_settings_choice("Cart Display"," Cart Display ",
	"change_cart_screen");
 &register_menu('ConfigCART',"write_cart_display_settings",
	$modname,"Write Cart Display Settings");
 &register_menu('change_cart_screen',"display_cart_settings_screen",
	$modname,"Display Cart Display Settings");
 &add_item_to_manager_menu("Cart Display","change_cart_screen=yes","");
}
#######################################################################################
sub write_cart_display_settings
{
local ($my_message, $my_ans);
local ($other_cart_settings) = "";
local ($my_cols) = "";
local ($my_str) = "";
local ($myset) = "";
local ($cart_settings) = "./admin_files/agora_user_lib.pl";

&ReadParse;

$myset .=  "\@sc_cart_index_for_display = ( \n";
$my_str = "$in{'col_0_heading'}|";
$my_cols = "$in{'col_0_name'}|";
$my_fact = "$in{'col_0_factor'}|";
$my_form = "$in{'col_0_format'}|";
$myset .= "    \$cart\{\"$in{'col_0_name'}\"\} \n";
if ($in{'col_1_name'} ne "") {
  $my_str .= "$in{'col_1_heading'}|";
  $my_cols .= "$in{'col_1_name'}|";
  $my_fact .= "$in{'col_1_factor'}|";
  $my_form .= "$in{'col_1_format'}|";
  $myset .= "    ,\$cart\{\"$in{'col_1_name'}\"\} \n";
 }
if ($in{'col_2_name'} ne "") {
  $my_str .= "$in{'col_2_heading'}|";
  $my_cols .= "$in{'col_2_name'}|";
  $my_fact .= "$in{'col_2_factor'}|";
  $my_form .= "$in{'col_2_format'}|";
  $myset .= "    ,\$cart\{\"$in{'col_2_name'}\"\} \n";
 }
if ($in{'col_3_name'} ne "") {
  $my_str .= "$in{'col_3_heading'}|";
  $my_cols .= "$in{'col_3_name'}|";
  $my_fact .= "$in{'col_3_factor'}|";
  $my_form .= "$in{'col_3_format'}|";
  $myset .= "    ,\$cart\{\"$in{'col_3_name'}\"\} \n";
 }
if ($in{'col_4_name'} ne "") {
  $my_str .= "$in{'col_4_heading'}|";
  $my_cols .= "$in{'col_4_name'}|";
  $my_fact .= "$in{'col_4_factor'}|";
  $my_form .= "$in{'col_4_format'}|";
  $myset .= "    ,\$cart\{\"$in{'col_4_name'}\"\} \n";
 }
if ($in{'col_5_name'} ne "") {
  $my_str .= "$in{'col_5_heading'}|";
  $my_cols .= "$in{'col_5_name'}|";
  $my_fact .= "$in{'col_5_factor'}|";
  $my_form .= "$in{'col_5_format'}|";
  $myset .= "    ,\$cart\{\"$in{'col_5_name'}\"\} \n";
 }
if ($in{'col_6_name'} ne "") {
  $my_str .= "$in{'col_6_heading'}|";
  $my_cols .= "$in{'col_6_name'}|";
  $my_fact .= "$in{'col_6_factor'}|";
  $my_form .= "$in{'col_6_format'}|";
  $myset .= "    ,\$cart\{\"$in{'col_6_name'}\"\} \n";
 }
if ($in{'col_7_name'} ne "") {
  $my_str .= "$in{'col_7_heading'}|";
  $my_cols .= "$in{'col_7_name'}|";
  $my_fact .= "$in{'col_7_factor'}|";
  $my_form .= "$in{'col_7_format'}|";
  $myset .= "    ,\$cart\{\"$in{'col_7_name'}\"\} \n";
 }
if ($in{'col_8_name'} ne "") {
  $my_str .= "$in{'col_8_heading'}|";
  $my_cols .= "$in{'col_8_name'}|";
  $my_fact .= "$in{'col_8_factor'}|";
  $my_form .= "$in{'col_8_format'}|";
  $myset .= "    ,\$cart\{\"$in{'col_8_name'}\"\} \n";
 }
if ($in{'col_9_name'} ne "") {
  $my_str .= "$in{'col_9_heading'}|";
  $my_cols .= "$in{'col_9_name'}|";
  $my_fact .= "$in{'col_9_factor'}|";
  $my_form .= "$in{'col_9_format'}|";
  $myset .= "    ,\$cart\{\"$in{'col_9_name'}\"\} \n";
 }
  $myset .= "    );\n";
chop($my_str);
chop($my_cols);
chop($my_fact);
chop($my_form);
$myset .= "\$sc_cart_display_str = \'$my_str\';\n";
$myset .= '@sc_cart_display_fields = split(/\|/,' .
          "\$sc_cart_display_str\);\n";
$myset .= "\$sc_cart_display_col = \'$my_cols\';\n";
$myset .= '@sc_col_name = split(/\|/,' .
          "\$sc_cart_display_col\);\n";
$myset .= "\$sc_cart_display_fact = \'$my_fact\';\n";
$myset .= '@sc_cart_display_factor = split(/\|/,' .
          "\$sc_cart_display_fact\);\n";
$myset .= "\$sc_cart_display_form = \'$my_fact\';\n";
$myset .= '@sc_cart_display_format = split(/\|/,' .
          "\$sc_cart_display_form\);\n";

$my_str = "$in{'textcol_0_heading'}|";
$my_cols = "$in{'textcol_0_name'}|";
$my_fact = "$in{'textcol_0_factor'}|";
$my_form = "$in{'textcol_0_format'}|";
$myset .= "\@sc_textcart_index_for_display = ( \n";
$myset .= "    \$cart\{\"$in{'textcol_0_name'}\"\} \n";
if ($in{'textcol_1_name'} ne "") {
  $my_str .= "$in{'textcol_1_heading'}|";
  $my_cols .= "$in{'textcol_1_name'}|";
  $my_fact .= "$in{'textcol_1_factor'}|";
  $my_form .= "$in{'textcol_1_format'}|";
  $myset .= "    ,\$cart\{\"$in{'textcol_1_name'}\"\} \n";
 }
if ($in{'textcol_2_name'} ne "") {
  $my_str .= "$in{'textcol_2_heading'}|";
  $my_cols .= "$in{'textcol_2_name'}|";
  $my_fact .= "$in{'textcol_2_factor'}|";
  $my_form .= "$in{'textcol_2_format'}|";
  $myset .= "    ,\$cart\{\"$in{'textcol_2_name'}\"\} \n";
 }
if ($in{'textcol_3_name'} ne "") {
  $my_str .= "$in{'textcol_3_heading'}|";
  $my_cols .= "$in{'textcol_3_name'}|";
  $my_fact .= "$in{'textcol_3_factor'}|";
  $my_form .= "$in{'textcol_3_format'}|";
  $myset .= "    ,\$cart\{\"$in{'textcol_3_name'}\"\} \n";
 }
if ($in{'textcol_4_name'} ne "") {
  $my_str .= "$in{'textcol_4_heading'}|";
  $my_cols .= "$in{'textcol_4_name'}|";
  $my_fact .= "$in{'textcol_4_factor'}|";
  $my_form .= "$in{'textcol_4_format'}|";
  $myset .= "    ,\$cart\{\"$in{'textcol_4_name'}\"\} \n";
 }
if ($in{'textcol_5_name'} ne "") {
  $my_str .= "$in{'textcol_5_heading'}|";
  $my_cols .= "$in{'textcol_5_name'}|";
  $my_fact .= "$in{'textcol_5_factor'}|";
  $my_form .= "$in{'textcol_5_format'}|";
  $myset .= "    ,\$cart\{\"$in{'textcol_5_name'}\"\} \n";
 }
if ($in{'textcol_6_name'} ne "") {
  $my_str .= "$in{'textcol_6_heading'}|";
  $my_cols .= "$in{'textcol_6_name'}|";
  $my_fact .= "$in{'textcol_6_factor'}|";
  $my_form .= "$in{'textcol_6_format'}|";
  $myset .= "    ,\$cart\{\"$in{'textcol_6_name'}\"\} \n";
 }
if ($in{'textcol_7_name'} ne "") {
  $my_str .= "$in{'textcol_7_heading'}|";
  $my_cols .= "$in{'textcol_7_name'}|";
  $my_fact .= "$in{'textcol_7_factor'}|";
  $my_form .= "$in{'textcol_7_format'}|";
  $myset .= "    ,\$cart\{\"$in{'textcol_7_name'}\"\} \n";
 }
  $myset .= "    );\n";
chop($my_str);
chop($my_cols);
chop($my_fact);
chop($my_form);
$myset .= "\$sc_textcart_display_str = \'$my_str\';\n";
$myset .= '@sc_textcart_display_fields = split(/\|/,' .
          "\$sc_textcart_display_str\);\n";
$myset .= "\$sc_textcart_display_col = \'$my_cols\';\n";
$myset .= '@sc_textcol_name = split(/\|/,' .
          "\$sc_textcart_display_col\);\n";
$myset .= "\$sc_textcart_display_fact = \'$my_fact\';\n";
$myset .= '@sc_textcart_display_factor = split(/\|/,' .
                    "\$sc_textcart_display_fact\);\n";
$myset .= "\$sc_textcart_display_form = \'$my_form\';\n";
$myset .= '@sc_textcart_display_format = split(/\|/,' .
          "\$sc_textcart_display_form\);\n";

&codehook("other_cart_settings");

if ($other_cart_settings ne "") {
  $myset .= "$other_cart_settings\n";
 }

$myset = "sub init_cart_settings {\n" . $myset . "}\n";
$myset .= 'if ($main_program_running =~ /yes/i) {' . "\n";
$myset .= '&add_codehook("after_loading_setup_db","init_cart_settings");' 
		. "\n";
$myset .= '} else { ' . "\n";
$myset .= '&init_cart_settings;' . "\n";
$myset .= '}' . "\n";

&update_store_settings('cart',$myset); 
&display_cart_settings_screen;

}
#############################################################################################
sub display_cart_settings_screen
{

print &$manager_page_header("Cart Display","","","","");

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=580>
</CENTER>

<CENTER>
<FORM ACTION="manager.cgi" METHOD="POST">
<TABLE WIDTH=580>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Welcome to the CART DISPLAY section of the
<b>AgoraCart</b> System Manager. 
This determines how AgoraCart displays a customer's cart,
both on the screen and log file/confirming emails. 
Choose the columns to be displayed and define the heading for each.
<br>Note: some of the labels are a bit misleading, "product" is 
actually product category.</TD>
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
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Cart Display settings have been
successfully updated.</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

$format_options = 
'<OPTION>none</OPTION>' . "\n" .
'<OPTION>2-D Price</OPTION>' . "\n" .
'<OPTION>2-Decimal</OPTION>' . "\n" .
"";

$my_options = "";
foreach $inx (sort(keys %cart)){
  $my_options .= "<OPTION>$inx</OPTION>\n";
 }

for ($inx=0; $inx <= 8; $inx++) {
  if (($sc_col_name[$inx] ne "") &&
      ($sc_cart_display_factor[$inx] eq "")) {
     $sc_cart_display_factor[$inx] = "no";
    }
 }
for ($inx=0; $inx <= 6; $inx++) {
  if (($sc_textcol_name[$inx] ne "") &&
      ($sc_textcart_display_factor[$inx] eq "")) {
     $sc_textcart_display_factor[$inx] = "no";
    }
  if (($sc_textcol_name[$inx] ne "") &&
      ($sc_textcart_display_format[$inx] eq "")) {
     $sc_textcart_display_format[$inx] = "none";
    }
 }

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<CENTER>
<TABLE BORDER=0 CELLPADDING=2 CELLSPACING=0 WIDTH=580>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<tr><td colspan=2>
Define the Screen Displays of Cart Contents:<br>
<center>
<TABLE BORDER=2 CELLPADDING=2 CELLSPACING=0 width=560>

<TR>
<TD>What to Display</TD>
<TD>Multiply<br>by QTY?</TD>
<TD>Column Heading</TD>
</TR>

<TR>
<TD>
<SELECT NAME="col_0_name">
<OPTION>$sc_col_name[0]</OPTION>
$my_options
</SELECT>
</TD>
<TD>
<SELECT NAME="col_0_factor">
<OPTION>$sc_cart_display_factor[0]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<INPUT NAME="col_0_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_cart_display_fields[0]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="col_1_name">
<OPTION>$sc_col_name[1]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="col_1_factor">
<OPTION>$sc_cart_display_factor[1]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<INPUT NAME="col_1_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_cart_display_fields[1]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="col_2_name">
<OPTION>$sc_col_name[2]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="col_2_factor">
<OPTION>$sc_cart_display_factor[2]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<INPUT NAME="col_2_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_cart_display_fields[2]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="col_3_name">
<OPTION>$sc_col_name[3]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="col_3_factor">
<OPTION>$sc_cart_display_factor[3]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<INPUT NAME="col_3_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_cart_display_fields[3]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="col_4_name">
<OPTION>$sc_col_name[4]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="col_4_factor">
<OPTION>$sc_cart_display_factor[4]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<INPUT NAME="col_4_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_cart_display_fields[4]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="col_5_name">
<OPTION>$sc_col_name[5]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="col_5_factor">
<OPTION>$sc_cart_display_factor[5]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<INPUT NAME="col_5_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_cart_display_fields[5]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="col_6_name">
<OPTION>$sc_col_name[6]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="col_6_factor">
<OPTION>$sc_cart_display_factor[6]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<INPUT NAME="col_6_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_cart_display_fields[6]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="col_7_name">
<OPTION>$sc_col_name[7]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="col_7_factor">
<OPTION>$sc_cart_display_factor[7]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<INPUT NAME="col_7_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_cart_display_fields[7]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="col_8_name">
<OPTION>$sc_col_name[8]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="col_8_factor">
<OPTION>$sc_cart_display_factor[8]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<INPUT NAME="col_8_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_cart_display_fields[8]">
</TD>
</TR>

</table></center>
</td></tr>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<tr><td colspan=2>
Define the extra fields printed in the "text" version of the cart 
(order log and confirming emails):<br>
<center><TABLE BORDER=2 CELLPADDING=2 CELLSPACING=0 WIDTH=560>
<TR>
<TD>What to Print</TD>
<TD>Multiply<br>by QTY?</TD>
<TD>Special<br>Formating</TD>
<TD>Label to give it (only 13 chars printed!)</TD>
</TR>

<TR>
<TD>
<SELECT NAME="textcol_0_name">
<OPTION>$sc_textcol_name[0]</OPTION>
$my_options
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_0_factor">
<OPTION>$sc_textcart_display_factor[0]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_0_format">
<OPTION>$sc_textcart_display_format[0]</OPTION>
$format_options
</SELECT>
</TD>
<TD>
<INPUT NAME="textcol_0_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_textcart_display_fields[0]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="textcol_1_name">
<OPTION>$sc_textcol_name[1]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_1_factor">
<OPTION>$sc_textcart_display_factor[1]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_1_format">
<OPTION>$sc_textcart_display_format[1]</OPTION>
$format_options
</SELECT>
</TD>
<TD>
<INPUT NAME="textcol_1_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_textcart_display_fields[1]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="textcol_2_name">
<OPTION>$sc_textcol_name[2]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_2_factor">
<OPTION>$sc_textcart_display_factor[2]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_2_format">
<OPTION>$sc_textcart_display_format[2]</OPTION>
$format_options
</SELECT>
</TD>
<TD>
<INPUT NAME="textcol_2_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_textcart_display_fields[2]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="textcol_3_name">
<OPTION>$sc_textcol_name[3]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_3_factor">
<OPTION>$sc_textcart_display_factor[3]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_3_format">
<OPTION>$sc_textcart_display_format[3]</OPTION>
$format_options
</SELECT>
</TD>
<TD>
<INPUT NAME="textcol_3_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_textcart_display_fields[3]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="textcol_4_name">
<OPTION>$sc_textcol_name[4]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_4_factor">
<OPTION>$sc_textcart_display_factor[4]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_4_format">
<OPTION>$sc_textcart_display_format[4]</OPTION>
$format_options
</SELECT>
</TD>
<TD>
<INPUT NAME="textcol_4_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_textcart_display_fields[4]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="textcol_5_name">
<OPTION>$sc_textcol_name[5]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_5_factor">
<OPTION>$sc_textcart_display_factor[5]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_5_format">
<OPTION>$sc_textcart_display_format[5]</OPTION>
$format_options
</SELECT>
</TD>
<TD>
<INPUT NAME="textcol_5_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_textcart_display_fields[5]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="textcol_6_name">
<OPTION>$sc_textcol_name[6]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_6_factor">
<OPTION>$sc_textcart_display_factor[6]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_6_format">
<OPTION>$sc_textcart_display_format[6]</OPTION>
$format_options
</SELECT>
</TD>
<TD>
<INPUT NAME="textcol_6_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_textcart_display_fields[6]">
</TD>
</TR>

<TR>
<TD>
<SELECT NAME="textcol_7_name">
<OPTION>$sc_textcol_name[7]</OPTION>
$my_options
<OPTION value="">BLANK</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_7_factor">
<OPTION>$sc_textcart_display_factor[7]</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT>
</TD>
<TD>
<SELECT NAME="textcol_7_format">
<OPTION>$sc_textcart_display_format[7]</OPTION>
$format_options
</SELECT>
</TD>
<TD>
<INPUT NAME="textcol_7_heading" TYPE="TEXT" SIZE=25 
 VALUE="$sc_textcart_display_fields[7]">
</TD>
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
<INPUT NAME="ConfigCART" TYPE="SUBMIT" VALUE="Submit">
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
