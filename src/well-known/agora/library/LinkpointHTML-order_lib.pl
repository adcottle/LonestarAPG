##############################################################################
#                       Order Form Definition Variables                      #
##############################################################################
$versions{'Linkpoint-order_lib.pl'} = "20020312";
$sc_use_secure_header_at_checkout = 'yes';
$sc_LinkpointHTML_form_prep = 0;
&add_codehook("printSubmitPage","print_LinkpointHTML_SubmitPage");
&add_codehook("set_form_required_fields","LinkpointHTML_fields");
$sc_order_response_vars{"LinkpointHTML"}="oid";
&add_codehook("gateway_response","check_for_LinkpointHTML_response");
###############################################################################
sub check_for_LinkpointHTML_response {
  if ($form_data{'oid'}) {
    ($cart_id,$lp_inv) = split(/\|/,$form_data{'oid'},2);
    &set_sc_cart_path;
    &load_order_lib;
    &codehook("LinkpointHTML_order");
    &process_LinkpointHTML_order;
    &call_exit;
   }
 }
###############################################################################
sub LinkpointHTML_order_form_prep{ # load the customer info ...
  if ($sc_LinkpointHTML_form_prep == 0) {
    if (-f "$sc_verify_order_path"){
      &read_verify_file;  
     } else {
      &codehook("load_customer_info");
     }
    $sc_LinkpointHTML_form_prep = 1;
   }
  return "";
 }

###############################################################################
sub LinkpointHTML_fields{
local($myname)="LinkpointHTML";

if (!($form_data{'gateway'} eq $myname)) { return;} 

%sc_order_form_array =(
	'Ecom_ShipTo_Postal_Name', 'Billing/Shipping Name',
	'Ecom_BillTo_Postal_Name_First', 'First Name',
	'Ecom_BillTo_Postal_Name_Last', 'Last Name',
	'Ecom_BillTo_Postal_Street_Line1', 'Billing Address Street',
	'Ecom_BillTo_Postal_City', 'Billing Address City',
	'Ecom_BillTo_Postal_StateProv', 'Billing Address State',
	'Ecom_BillTo_PostalCode', 'Billing Address Zip',
	'Ecom_BillTo_Postal_CountryCode', 'Billing Address Country',
	'Ecom_ShipTo_Postal_Street_Line1', 'Shipping Address Street',
	'Ecom_ShipTo_Postal_City', 'Shipping Address City',
	'Ecom_ShipTo_Postal_StateProv', 'Shipping Address State',
	'Ecom_ShipTo_Postal_PostalCode', 'Shipping Address Zip',
	'Ecom_ShipTo_Postal_CountryCode', 'Shipping Address Country',
	'Ecom_BillTo_Telecom_Phone_Number', 'Phone Number',
	'Ecom_BillTo_Online_Email', 'Email',
	'Ecom_Payment_Card_Type', 'Type of Card',
	'Ecom_Payment_Card_Number', 'Card Number',
	'Ecom_Payment_Card_ExpDate_Month', 'Card Expiration Month',
	'Ecom_Payment_Card_ExpDate_Day', 'Card Expiration Day',
	'Ecom_Payment_Card_ExpDate_Year', 'Card Expiration Year');

@sc_order_form_required_fields = (
	'Ecom_BillTo_Online_Email',
	'Ecom_ShipTo_Postal_Name',
	'Ecom_ShipTo_Postal_Street_Line1', 
	'Ecom_ShipTo_Postal_City', 
	"Ecom_ShipTo_Postal_StateProv",
	"Ecom_ShipTo_Postal_PostalCode");
}

###############################################################################
sub LinkpointHTML_verification_table {
  local ($rslt)="";
  $rslt = "<table border=0 width=100%>\n<tr>\n";
  $rslt.= "<td width=\"50%\" align=right>Shipping Method:</td>\n";
  $rslt.= '<td width = "50%" align=left>' .
	$form_data{'Ecom_ShipTo_Method'} . "&nbsp;</td>\n";
  $rslt.= "</tr>\n";
  $rslt.= "<td width=\"50%\" align=right>Email:</td>\n";
  $rslt.= '<td width = "50%" align=left>' .
	$form_data{'Ecom_BillTo_Online_Email'} . "&nbsp;</td>\n";
  $rslt.= "</tr>\n";
  $rslt.= "<td width=\"50%\" align=right>Name:</td>\n";
  $rslt.= '<td width = "50%" align=left>' .
	$form_data{'Ecom_ShipTo_Postal_Name'} . "&nbsp;</td>\n";
  $rslt.= "</tr>\n";
  $rslt.= "<tr>\n";
  $rslt.= "<td width=\"50%\" align=right>Street:</td>\n";
  $rslt.= '<td width = "50%" align=left>' .
	$form_data{'Ecom_ShipTo_Postal_Street_Line1'} . "&nbsp;</td>\n";
  $rslt.= "</tr>\n";
  $rslt.= "<tr>\n";
  $rslt.= "<td width=\"50%\" align=right>City:</td>\n";
  $rslt.= '<td width = "50%" align=left>' .
	$form_data{'Ecom_ShipTo_Postal_City'} . "&nbsp;</td>\n";
  $rslt.= "</tr>\n";
  $rslt.= "<tr>\n";
  $rslt.= "<td width=\"50%\" align=right>State:</td>\n";
  $rslt.= '<td width = "50%" align=left>' .
	$form_data{'Ecom_ShipTo_Postal_StateProv'} . "&nbsp;</td>\n";
  $rslt.= "</tr>\n";
  $rslt.= "<tr>\n";
  $rslt.= "<td width=\"50%\" align=right>Zip:</td>\n";
  $rslt.= '<td width = "50%" align=left>' .
	$form_data{'Ecom_ShipTo_Postal_PostalCode'} . "&nbsp;</td>\n";
  $rslt.= "</tr>\n";
  $rslt.= "</table>\n";
  return $rslt;
 }
###############################################################################

sub print_LinkpointHTML_SubmitPage

{
local($invoice_number, $customer_number);
local($myname)="LinkpointHTML";

if (!($form_data{'gateway'} eq $myname)) { return;} 
if ($myname ne $sc_gateway_name) { # secondary gateway, load settings
  &require_supporting_libraries(__FILE__,__LINE__,
	"./admin_files/$myname-user_lib.pl");
 }

$invoice_number = $current_verify_inv_no;
$customer_number = $cart_id;
$customer_number =~ s/_/./g;

$my_oid = $cart_id . "|" . $invoice_number;
$mytable = &LinkpointHTML_verification_table;
&read_verify_file;

print <<ENDOFTEXT;

<FORM METHOD=POST ACTION=\"$sc_order_script_url\">
<INPUT TYPE=HIDDEN NAME='mode' value="payplus">
<INPUT TYPE=HIDDEN NAME='shippingamount' VALUE=\"$zfinal_shipping\">
<INPUT TYPE=HIDDEN NAME='salestaxamount' VALUE=\"$zfinal_sales_tax\">
<INPUT TYPE=HIDDEN NAME='shipping' VALUE=\"$zfinal_shipping\">
<INPUT TYPE=HIDDEN NAME='tax' VALUE=\"$zfinal_sales_tax\">
<INPUT TYPE=HIDDEN NAME='subtotal' VALUE=\"$zsubtotal\">
<INPUT TYPE=HIDDEN NAME='chargetotal' VALUE=\"$authPrice\">
<INPUT TYPE=HIDDEN NAME='subtotalamount' VALUE=\"$zsubtotal\">
<INPUT TYPE=HIDDEN NAME='storename' VALUE=\"$sc_gateway_username\">
<INPUT TYPE=HIDDEN NAME='oid' VALUE=\"$my_oid\">
<INPUT TYPE=HIDDEN NAME='email' VALUE=\"$eform_Ecom_BillTo_Online_Email\">
<INPUT TYPE=HIDDEN NAME='bname' VALUE=\"$eform_Ecom_ShipTo_Postal_Name\">
<INPUT TYPE=HIDDEN NAME='baddr1' VALUE='$eform_Ecom_ShipTo_Postal_Street_Line1'> 
<INPUT TYPE=HIDDEN NAME='bcity' VALUE=\"$eform_Ecom_ShipTo_Postal_City\"> 
<INPUT TYPE=HIDDEN NAME='bstate' VALUE=\"$eform_Ecom_ShipTo_Postal_StateProv\">
<INPUT TYPE=HIDDEN NAME='bzip' VALUE=\"$eform_Ecom_ShipTo_Postal_PostalCode\">
<TABLE WIDTH="500" BGCOLOR="#C0FFFF" CELLPADDING="0" CELLSPACING="0">
<TR>
<TD>
<CENTER>
<TABLE WIDTH="480" BGCOLOR="#000080" CELLPADDING="0" CELLSPACING="0">
<TR BGCOLOR="#C0FFFF">
<TD BGCOLOR="#C0FFFF"><FONT FACE="ARIAL" SIZE="2" COLOR="#000000">
<b>Please verify the following information. When you are confident 
that it is correct, click the 'Secure Orderform' button to enter 
your payment information, or
<a href="${sc_stepone_order_script_url}?order_form_button.x=1">
click here</a> to make corrections:
</b></FONT></TD>
<TD  BGCOLOR="#C0FFFF">
</TR>
<TR BGCOLOR="#C0FFFF">
<TD BGCOLOR="#C0FFFF"><FONT FACE="ARIAL" SIZE="2" COLOR="#000000">
$mytable
</TD></TR>
<TR BGCOLOR="#C0FFFF">
<TD>
<CENTER>
<INPUT TYPE=SUBMIT VALUE="Secure Orderform">
</CENTER>
</TD>
</TR>
</TABLE>
</CENTER>

</TD>
</TR>
</TABLE>

</FORM>
</CENTER>

ENDOFTEXT

}
###############################################################################

sub process_LinkpointHTML_order {

local($subtotal, $total_quantity,
      $total_measured_quantity,
      $text_of_cart,
      $required_fields_filled_in, $product, $quantity, $options);
local($stevo_shipping_thing) = "";
local($stevo_shipping_names) = "";
local($ship_thing_too,$ship_instructions);

&load_verify_file;

$orderDate = &get_date;

print qq!
<HTML>
$sc_special_page_meta_tags
<HEAD>
<TITLE>$messages{'ordcnf_08'}</TITLE>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
$sc_standard_head_info</HEAD>
<BODY $sc_standard_body_info>
!;

&StoreHeader;

$text_of_cart .= "Order Date:    $orderDate\n";
$text_of_cart .= "Gateway:       LinkpointHTML\n\n";

$text_of_cart .= "  --PRODUCT INFORMATION--\n\n";

open (CART, "$sc_cart_path") ||
&file_open_error("$sc_cart_path", "display_cart_contents", __FILE__, __LINE__);

while (<CART>) {
  $cartData++;
  @cart_fields = split (/\|/, $_);
  $quantity = $cart_fields[0];
  $product_price = $cart_fields[3];
  $product = $cart_fields[4];
  $options = $cart_fields[$cart{"options"}];
  $options =~ s/<br>//g;
  $text_of_cart .= &cart_textinfo(*cart_fields);
  $stevo_shipping_thing .= "|quantity\*$weight";
  $stevo_shipping_names .= "|$product\($options\)";
  &codehook("process-cart-item");
 }
close(CART);

$sc_orderlib_use_SBW_for_ship_ins = $sc_use_SBW;
&codehook("orderlib-ship-instructions");
if ($sc_orderlib_use_SBW_for_ship_ins =~ /yes/i) {
  ($ship_thing_too,$ship_instructions) = 
   &ship_put_in_boxes($stevo_shipping_thing,$stevo_shipping_names,
   $sc_verify_Origin_ZIP,$sc_verify_boxes_max_wt); 
 }

$text_of_confirm_email .= $messages{'ordcnf_07'};

$text_of_confirm_email .= $text_of_cart;
$text_of_confirm_email .= "\n";
$text_of_cart .= "  --ORDER INFORMATION--\n\n";

&add_text_of_both("Order ID",$form_data{'oid'});
&add_text_of_cart("STATUS",$form_data{'status'});
&add_text_of_cart("APPROVAL CODE",$form_data{'approval_code'});
&add_text_of_cart("Charge Total",$form_data{'chargetotal'});
&add_text_of_cart("CC Type",$form_data{"cctype"});
&add_text_of_cart("Card #",$form_data{"cardnumber"});
&add_text_of_cart("Exp Month",$form_data{"expmonth"});
&add_text_of_cart("Exp Year",$form_data{"expyear"});
$text_of_cart .= "\n";

&add_text_of_both("SUBTOTAL",$sc_verify_subtotal);
$sc_verify_subtotal3 = $sc_verify_subtotal;

if ($form_data{'shippingamount'}){
  &add_text_of_both("SHIPPING",$sc_verify_shipping);
 }

if ($form_data{'salestaxamount'}){
  &add_text_of_both("SALES TAX",$sc_verify_tax);
 }

$text_of_cart .= "TOTAL:         $form_data{'chargetotal'}\n\n";
$text_of_confirm_email .= "TOTAL:         $form_data{'chargetotal'}\n\n";
$text_of_cart .= "BILLING INFORMATION --------------\n\n";
$text_of_cart .= "NAME:          $form_data{'bname'}\n";
$text_of_cart .= "ADDRESS1:      $form_data{'baddr1'}\n";
$text_of_cart .= "ADDRESS2:      $form_data{'baddr2'}\n";
$text_of_cart .= "CITY:          $form_data{'bcity'}\n";
$text_of_cart .= "STATE:         $form_data{'bstate'}\n";
$text_of_cart .= "PROVINCE       $form_data{'bstate2'}\n";
$text_of_cart .= "ZIP:           $form_data{'bzip'}\n";
$text_of_cart .= "COUNTRY:       $form_data{'bcountry'}\n";
$text_of_cart .= "PHONE:         $form_data{'phone'}\n";
$text_of_cart .= "FAX:           $form_data{'fax'}\n";
$text_of_cart .= "EMAIL:         $form_data{'email'}\n\n";
$text_of_cart .= "SHIPPING INFORMATION --------------\n\n";
$text_of_cart .= "NAME:          $form_data{'sname'}\n";
$text_of_cart .= "ADDRESS1:      $form_data{'saddr1'}\n";
$text_of_cart .= "ADDRESS2:      $form_data{'saddr2'}\n";
$text_of_cart .= "CITY:          $form_data{'scity'}\n";
$text_of_cart .= "STATE:         $form_data{'sstate'}\n";
$text_of_cart .= "PROVINCE       $form_data{'sstate2'}\n";
$text_of_cart .= "ZIP:           $form_data{'szip'}\n";
$text_of_cart .= "COUNTRY:       $form_data{'scountry'}\n\n";

if ($sc_use_SBW =~ /yes/i) {
  &add_text_of_cart("SHIP VIA",$vform_Ecom_ShipTo_Method);
 }

if ($ship_instructions ne "") {
  $text_of_cart .= "Shipping Instructions: \n$ship_instructions\n\n";
 }

$text_of_cart .= $XCOMMENTS_ADMIN;
$text_of_confirm_email .= $XCOMMENTS;

# 'Init' the emails ...
$text_of_cart = &init_shop_keep_email . $text_of_cart;
$text_of_confirm_email = &init_customer_email . $text_of_confirm_email;

# and add the rest ...
$text_of_admin_email .= &addto_shop_keep_email;
$text_of_confirm_email .= &addto_customer_email;

if ($sc_use_pgp =~ /yes/i)
{
&require_supporting_libraries(__FILE__, __LINE__, "$sc_pgp_lib_path");
$text_of_cart = &make_pgp_file($text_of_cart, "$sc_pgp_temp_file_path/$$.pgp");
$text_of_cart = "\n" . $text_of_cart . "\n";
}

if ($sc_send_order_to_email =~ /yes/i) {
  &send_mail($sc_order_email, $sc_order_email, "AgoraCart Order",$text_of_cart);
 }

&log_order($text_of_cart,$lp_inv,$cart_id);

if (($cartData) && ($form_data{'email'} ne "")){
  &send_mail($sc_admin_email, $form_data{'email'}, $messages{'ordcnf_08'}, 
           "$text_of_confirm_email");
 }
$sc_affiliate_order_unique = $form_data{'oid'};
$sc_affiliate_order_total = $sc_verify_subtotal3;
  
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=500>
<TR>
<TD WIDTH=500>
<BR>
<FONT FACE=ARIAL>
$messages{'ordcnf_01'}
$messages{'ordcnf_02'}
<br>
$sc_affiliate_image_call
</FONT>
</TD>
</TR>
</TABLE>
<CENTER>  

ENDOFTEXT

# This empties the cart after the order is successful
&empty_cart;

# and the footer is printed

&StoreFooter;

print qq!
</BODY>
</HTML>
!;

} # End of process_LinkpointHTML_order

#################################################################
1; # Library
