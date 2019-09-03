# file ./store/protected/store_layout_display-ext_lib.pl
#########################################################################
#
# Copyright (c) 2002 K-Factor Technologies, Inc.
# http://www.k-factor.net/  and  http://www.AgoraCart.com/
# All Rights Reserved.
#
# This software is the confidential and proprietary information of
# K-Factor Technologies, Inc.  You shall
# not disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with K-Factor Technologies, Inc.
#
# K-Factor Technologies, Inc. MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT
# THE SUITABILITY OF THE SOFTWARE, EITHER EXPRESSED OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
# OR NON-INFRINGEMENT.
#
# K-Factor Technologies, Inc. SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY
# LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS
# SOFTWARE OR ITS DERIVATIVES.
#
# You may not give this script away or distribute it an any way without
# written permission.
#
##########################################################################
$versions{'layout manager'} = "20021020";

{
 local ($modname) = 'store_layout_display';
 &register_extension($modname,"Store Layout Settings",$versions{$modname});
 &add_settings_choice("Store Layout"," Store Layout ",
	"change_store_layout_screen");
 &register_menu('LayoutSettings',"write_store_layout_settings",
	$modname,"Write Store Layout Settings");
 &register_menu('change_store_layout_screen',"display_store_layout_screen",
	$modname,"Display Store Layout Settings");
 &add_item_to_manager_menu("Store Layout","change_store_layout_screen=yes","");
}
#######################################################################################
sub write_store_layout_settings {
local($info);
local($myset)="";
local(@temp,$junk);

  &ReadParse;

$myset .= "\$layout_store_page_font_color = \"$in{'layout_store_page_font_color'}\";\n";
$myset .= "\$layout_store_page_linkfont_color = \"$in{'layout_store_page_linkfont_color'}\";\n";
$myset .= "\$layout_store_page_vlinkfont_color = \"$in{'layout_store_page_vlinkfont_color'}\";\n";
$myset .= "\$layout_store_page_bgcolor = \"$in{'layout_store_page_bgcolor'}\";\n";
$myset .= "\$layout_store_page_bgimage = \"$in{'layout_store_page_bgimage'}\";\n";
if ($in{'layout_store_page_bgimage'} ne '') {
$temp_page_body_layout = "text=$in{'layout_store_page_font_color'} Link=$in{'layout_store_page_linkfont_color'} vlink=$in{'layout_store_page_vlinkfont_color'} BGCOLOR=\"$in{'layout_store_page_bgcolor'}\" Background=\"$in{'layout_store_page_bgimage'}\"";
} else {
$temp_page_body_layout = "text=$in{'layout_store_page_font_color'} Link=$in{'layout_store_page_linkfont_color'} vlink=$in{'layout_store_page_vlinkfont_color'} BGCOLOR=\"$in{'layout_store_page_bgcolor'}\"";
}
$myset .= "\$sc_standard_body_info = \'$temp_page_body_layout\';\n";
$myset .= "\$layout_store_productpage_width = \"$in{'layout_store_productpage_width'}\";\n";
$temp_page_width_layout = "qq!<CENTER><TABLE BORDER=0 WIDTH=$in{'layout_store_productpage_width'}>!";
$myset .= "\$sc_product_display_header = $temp_page_width_layout;\n";
$myset .= "\$layout_store_productpage_thanks_size = \"$in{'layout_store_productpage_thanks_size'}\";\n";
$myset .= "\$layout_store_productpage_thanks_color = \"$in{'layout_store_productpage_thanks_color'}\";\n";
$myset .= "\$layout_store_productpage_thanks_font = \"$in{'layout_store_productpage_thanks_font'}\";\n";
$myset .= "\$layout_store_productpage_thanks_mess = \"$in{'layout_store_productpage_thanks_mess'}\";\n";
$temp_page_thanks_layout2 = "<TR><TD COLSPAN=3><CENTER><FONT FACE=\"$in{'layout_store_font_style'}\" SIZE=$in{'layout_store_productpage_thanks_size'} COLOR=$in{'layout_store_productpage_thanks_color'}>$in{'layout_store_productpage_thanks_mess'}</FONT></CENTER></TD></TR>";
$myset .= "\$sc_item_ordered_message = \'$temp_page_thanks_layout2\';\n";
$myset .= "\$layout_store_cart_table_border = \"$in{'layout_store_cart_table_border'}\";\n";
$myset .= "\$layout_store_cart_table_cellpadding = \"$in{'layout_store_cart_table_cellpadding'}\";\n";
$myset .= "\$layout_store_cart_table_cellspacing = \"$in{'layout_store_cart_table_cellspacing'}\";\n";
$myset .= "\$layout_store_cart_table_bgcolor = \"$in{'layout_store_cart_table_bgcolor'}\";\n";
$temp_cart_table_layout = "BORDER=$in{'layout_store_cart_table_border'} CELLPADDING=$in{'layout_store_cart_table_cellpadding'} CELLSPACING=$in{'layout_store_cart_table_cellspacing'} BGCOLOR=\"$in{'layout_store_cart_table_bgcolor'}\"";
$myset .= "\$cart_table_def = \'$temp_cart_table_layout\';\n";
$myset .= "\$layout_store_cart_table_header_bgcolor = \"$in{'layout_store_cart_table_header_bgcolor'}\";\n";
$temp_cart_table_header_layout = "BGCOLOR=\"$in{'layout_store_cart_table_header_bgcolor'}\"";
$myset .= "\$cart_heading_def = \'$temp_cart_table_header_layout\';\n";
$myset .= "\$layout_store_order_table_border = \"$in{'layout_store_order_table_border'}\";\n";
$myset .= "\$layout_store_order_table_cellpadding = \"$in{'layout_store_order_table_cellpadding'}\";\n";
$myset .= "\$layout_store_order_table_cellspacing = \"$in{'layout_store_order_table_cellspacing'}\";\n";
$myset .= "\$layout_store_order_table_bgcolor = \"$in{'layout_store_order_table_bgcolor'}\";\n";
$temp_order_table_layout = "BORDER=$in{'layout_store_order_table_border'} CELLPADDING=$in{'layout_store_order_table_cellpadding'} CELLSPACING=$in{'layout_store_order_table_cellspacing'} BGCOLOR=\"$in{'layout_store_order_table_bgcolor'}\"";
$myset .= "\$order_table_def = \'$temp_order_table_layout\';\n";
$myset .= "\$layout_store_order_table_header_bgcolor = \"$in{'layout_store_order_table_header_bgcolor'}\";\n";
$temp_order_table_header_layout = "align=center colspan=2 BGCOLOR=\"$in{'layout_store_order_table_header_bgcolor'}\"";
$myset .= "\$order_heading_def = \'$temp_order_table_header_layout\';\n";
$myset .= "\$sc_totals_table_ship_label = \"$in{'sc_totals_table_ship_label'}\";\n";
$myset .= "\$sc_totals_table_disc_label = \"$in{'sc_totals_table_disc_label'}\";\n";
$myset .= "\$sc_totals_table_stax_label = \"$in{'sc_totals_table_stax_label'}\";\n";
$myset .= "\$sc_totals_table_gtot_label = \"$in{'sc_totals_table_gtot_label'}\";\n";
$myset .= "\$sc_totals_table_itot_label = \"$in{'sc_totals_table_itot_label'}\";\n";
$myset .= "\$sc_totals_table_thdr_label = \"$in{'sc_totals_table_thdr_label'}\";\n";
$myset .= "\$layout_store_font_style = \"$in{'layout_store_font_style'}\";\n";
$myset .= "\$layout_store_font_size = \"$in{'layout_store_font_size'}\";\n";
$myset .= "\$layout_store_font_color = \"$in{'layout_store_font_color'}\";\n";
$temp_cart_font_style1 = "<FONT FACE=\"$in{'layout_store_font_style'}\" SIZE=$in{'layout_store_font_size'} color=\"$in{'layout_store_font_color'}\">";
$myset .= "\$cart_font_style = \'$temp_cart_font_style1\';\n";
$myset .= "\$layout_store_font_style2 = \"$in{'layout_store_font_style2'}\";\n";
$myset .= "\$layout_store_font_size2 = \"$in{'layout_store_font_size2'}\";\n";
$myset .= "\$layout_store_font_color2 = \"$in{'layout_store_font_color2'}\";\n";
$temp_cart_font_style2 = "<FONT FACE=\"$in{'layout_store_font_style2'}\" SIZE=$in{'layout_store_font_size2'} color=\"$in{'layout_store_font_color2'}\">";
$myset .= "\$cartnum_font_style = \'$temp_cart_font_style2\';\n";

  &update_store_settings('layout',$myset); # layout settings
  &display_store_layout_screen;
 }
################################################################################
sub display_store_layout_screen
{
print &$manager_page_header("Store Layout","","","","");

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=580>
</CENTER>

<FORM ACTION="manager.cgi" METHOD="POST">
<CENTER>
<TABLE WIDTH=580>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Welcome to the <b>AgoraCart</b> Store Layout Manager.  The Store Layout manager controls such things as body tag, page header, and table cell attributes as well as general font variables.</TD>
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


print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2><br>
<CENTER>
<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>
<TR>
<TD COLSPAN=2 BGCOLOR="#E0E5FF"><center><h3><font face="Arial, Helvetica, sans-serif">Main Body Tag Attibutes</font></h3></center></TD>
</TR>

<TR>
<TD colspan=2><br><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter Page Body Attributes:</b><br>this is the attributes of each dynamically generated page such as the background color, background image, and font color for the text and links on the pages.  Colors can be a spelled out color like: red or yellow or in standard RGB notation with the pound sign included, like: \#0000FF.  The background image must be in the same directory as the main Agora.cgi and is case sensitive (must be entered in for of: backimage.gif) ... if not using one, leave the field blank.<br><br>
Page Font Color: <INPUT NAME="layout_store_page_font_color" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_page_font_color">
&nbsp;&nbsp;&nbsp;&nbsp;
Link Font Color: <INPUT NAME="layout_store_page_linkfont_color" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_page_linkfont_color">
&nbsp;&nbsp;&nbsp;&nbsp;
Visited Link Font Color: <INPUT NAME="layout_store_page_vlinkfont_color" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_page_vlinkfont_color">
<br>
Page Background Color: <INPUT NAME="layout_store_page_bgcolor" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_page_bgcolor">&nbsp;&nbsp;&nbsp;&nbsp;
Page Background Image: <INPUT NAME="layout_store_page_bgimage" TYPE="TEXT" SIZE=20 
MAXLENGTH="30" VALUE="$layout_store_page_bgimage">
</font>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR><br><br></TD>
</TR>

<TR>
<TD COLSPAN=2 BGCOLOR="#E0E5FF"><center><h3><font face="Arial, Helvetica, sans-serif">Product Page Info & Table Width</font></h3></center></TD>
</TR>
<TR>
<TD colspan=2><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter the width of the table for dynamicly generated product pages:</b><br>this is the master width setting for the product pages (productPage.inc files).<br><br>
Table Width: <INPUT NAME="layout_store_productpage_width" TYPE="TEXT" SIZE=3 
MAXLENGTH="3" VALUE="$layout_store_productpage_width">
</font>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD colspan=2><br><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter thank you message font attributes:</b><br>the message for dynamicly generated product pages:</b><br>this is basically the thank you message or message of choice that is show after a visitor adds an item to the cart (for the product pages productPage.inc type files).  Font Face can be multiple fonts separatated by commas: Verdana,Arial,Helvetica,sans-serif.  Sizes can be standard notation: -2,-1,1,2,3,+1,+2,etc.  Colors can be a spelled out color like: red or yellow or in standard RGB notation with the pound sign included, like: \#0000FF.<br><br>
Thank You Font Color: <INPUT NAME="layout_store_productpage_thanks_color" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_productpage_thanks_color">
&nbsp;&nbsp;&nbsp;&nbsp;
Thank You Font Size: <INPUT NAME="layout_store_productpage_thanks_size" TYPE="TEXT" SIZE=2 
MAXLENGTH="2" VALUE="$layout_store_productpage_thanks_size">
</font>
</TD>
</TR>
<TR>
<TD COLSPAN=2><HR></TD>
</TR>
<TR>
<TD colspan=2><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter the message for dynamicly generated product pages:</b><br>this is basically the thank you message or message of choice that is show after a visitor adds an item to the cart (for the product pages productPage.inc type files).  Special characters such as \$ and \" marks may need to be escaped using a preceeding backslash mark, like so: \\\" or \\\$<br><br>
<TEXTAREA NAME="layout_store_productpage_thanks_mess" cols="68" 
rows="2" wrap=off>$layout_store_productpage_thanks_mess</TEXTAREA>
</font>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR><br><br></TD>
</TR>

<TR>
<TD COLSPAN=2 BGCOLOR="#E0E5FF"><center><h3><font face="Arial, Helvetica, sans-serif">Cart Contents Display Table Layout</font></h3></center></TD>
</TR>

<TR>
<TD colspan=2><br><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter Table attributes for the Cart Contents Display Table:</b><br>this is the table that lists each item added to the cart. The cart contents can be seen during "view cart" and the rest of the check out process.  Color can be a spelled out color like: red or yellow or in standard RGB notation with the pound sign included, like: \#0000FF<br><br>
Border Width: <INPUT NAME="layout_store_cart_table_border" TYPE="TEXT" SIZE=2 
MAXLENGTH="2" VALUE="$layout_store_cart_table_border">
&nbsp;&nbsp;&nbsp;&nbsp;
Cell Padding: <INPUT NAME="layout_store_cart_table_cellpadding" TYPE="TEXT" SIZE=2 
MAXLENGTH="2" VALUE="$layout_store_cart_table_cellpadding">
&nbsp;&nbsp;&nbsp;&nbsp;
Cell Spacing: <INPUT NAME="layout_store_cart_table_cellspacing" TYPE="TEXT" SIZE=2 
MAXLENGTH="2" VALUE="$layout_store_cart_table_cellspacing">
Background Color: <INPUT NAME="layout_store_cart_table_bgcolor" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_cart_table_bgcolor">
</font>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD colspan=2><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter header background color for the Cart Contents Display Table:</b><br>this is the header for the table that lists each item added to the cart. The cart contents can be seen during "view cart" and the rest of the check out process.  Color can be a spelled out color like: red or yellow or in standard RGB notation with the pound sign included, like: \#0000FF<br><br>
Background Color: <INPUT NAME="layout_store_cart_table_header_bgcolor" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_cart_table_header_bgcolor">
</font>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD colspan=2><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter Font Face and Font Size used for cart contents table headers and and other cart contents table text:</b><br>Font can be multiple fonts separatated by commas: Verdana,Arial,Helvetica,sans-serif.  Sizes can be standard notation: -2,-1,1,2,3,+1,+2,etc.  Color can be a spelled out color like: red or yellow or in standard RGB notation with the pound sign included, like: \#0000FF
<br><br>
Face: <INPUT NAME="layout_store_font_style" TYPE="TEXT" SIZE=15 
MAXLENGTH="40" VALUE="$layout_store_font_style">
&nbsp;&nbsp;&nbsp;&nbsp;
Font Size: <INPUT NAME="layout_store_font_size" TYPE="TEXT" SIZE=2 
MAXLENGTH="2" VALUE="$layout_store_font_size">
&nbsp;&nbsp;&nbsp;&nbsp;
Font Color: <INPUT NAME="layout_store_font_color" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_font_color">
</font>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD colspan=2><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter Font Face and Font Size used for cart contents table numbers:</b><br>Font can be multiple fonts separatated by commas: Verdana,Arial,Helvetica,sans-serif.  Sizes can be standard notation: -2,-1,1,2,3,+1,+2,etc.  Color can be a spelled out color like: red or yellow or in standard RGB notation with the pound sign included, like: \#0000FF
<br><br>
Face: <INPUT NAME="layout_store_font_style2" TYPE="TEXT" SIZE=15 
MAXLENGTH="40" VALUE="$layout_store_font_style2">
&nbsp;&nbsp;&nbsp;&nbsp;
Font Size: <INPUT NAME="layout_store_font_size2" TYPE="TEXT" SIZE=2 
MAXLENGTH="2" VALUE="$layout_store_font_size2">
&nbsp;&nbsp;&nbsp;&nbsp;
Font Color: <INPUT NAME="layout_store_font_color2" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_font_color2">
</font>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR><br><br></TD>
</TR>

<TR>
<TD COLSPAN=2 BGCOLOR="#E0E5FF"><center><h3><font face="Arial, Helvetica, sans-serif">Order Table Display Layout</font></h3></center></TD>
</TR>

<TR>
<TD colspan=2><br><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter Table attributes for the Order Info Display Table:</b><br>this is the table that lists such things as shipping, subtotals, discountss given and the grand total. The order table contents can be seen during "view cart" and the rest of the check out process.  Color can be a spelled out color like: red or yellow or in standard RGB notation with the pound sign included, like: \#0000FF<br><br>
Border Width: <INPUT NAME="layout_store_order_table_border" TYPE="TEXT" SIZE=2 
MAXLENGTH="2" VALUE="$layout_store_order_table_border">
&nbsp;&nbsp;&nbsp;&nbsp;
Cell Padding: <INPUT NAME="layout_store_order_table_cellpadding" TYPE="TEXT" SIZE=2 
MAXLENGTH="2" VALUE="$layout_store_order_table_cellpadding">
&nbsp;&nbsp;&nbsp;&nbsp;
Cell Spacing: <INPUT NAME="layout_store_order_table_cellspacing" TYPE="TEXT" SIZE=2 
MAXLENGTH="2" VALUE="$layout_store_order_table_cellspacing">
Background Color: <INPUT NAME="layout_store_order_table_bgcolor" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_order_table_bgcolor">
</font>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD colspan=2><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter header background color for the Order Display Table:</b><br>this is the table that lists such things as shipping, subtotals, discountss given and the grand total. The order table contents can be seen during "view cart" and the rest of the check out process.  Color can be a spelled out color like: red or yellow or in standard RGB notation with the pound sign included, like: \#0000FF<br><br>
Background Color: <INPUT NAME="layout_store_order_table_header_bgcolor" TYPE="TEXT" SIZE=7 
MAXLENGTH="10" VALUE="$layout_store_order_table_header_bgcolor">
</font>
</TD>
</TR>
<TR>
<TD COLSPAN=2><HR></TD>
</TR>
<TR>
<TD colspan=2><font size="2" face="Arial, Helvetica, sans-serif">
<b>Enter header titles for the Order Display Table:</b><br>this is the table that lists such things as shipping, subtotals, discountss given and the grand total. The order table contents can be seen during "view cart" and the rest of the check out process.<br><br>
Shipping Label: <INPUT NAME="sc_totals_table_ship_label" TYPE="TEXT" SIZE=20 
MAXLENGTH="30" VALUE="$sc_totals_table_ship_label">&nbsp;&nbsp;&nbsp;&nbsp;
Discount Label: <INPUT NAME="sc_totals_table_disc_label" TYPE="TEXT" SIZE=20 
MAXLENGTH="30" VALUE="$sc_totals_table_disc_label"><br><br>
Sales Tax Label: <INPUT NAME="sc_totals_table_stax_label" TYPE="TEXT" SIZE=20 
MAXLENGTH="30" VALUE="$sc_totals_table_stax_label">&nbsp;&nbsp;&nbsp;&nbsp;
Grand Total Label: <INPUT NAME="sc_totals_table_gtot_label" TYPE="TEXT" SIZE=20 
MAXLENGTH="30" VALUE="$sc_totals_table_gtot_label"><br><br>
Item Cost Subtotal Label: <INPUT NAME="sc_totals_table_itot_label" TYPE="TEXT" SIZE=30 
MAXLENGTH="35" VALUE="$sc_totals_table_itot_label"><br>
Order Totals Header Label: <INPUT NAME="sc_totals_table_thdr_label" TYPE="TEXT" SIZE=30 
MAXLENGTH="35" VALUE="$sc_totals_table_thdr_label">
</font>
</TD>
</TR>
<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT NAME="LayoutSettings" TYPE="SUBMIT" VALUE="Submit">
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
