#######################################################################
#                    Order Form Definition Variables                  #
#######################################################################

# 4/24/00 SPK ADDED THESE TAGS:
#<INPUT TYPE=HIDDEN NAME=x_ADC_URL VALUE=\"$sc_store_url\">
#<INPUT TYPE=HIDDEN NAME=x_ADC_Relay_Response VALUE=\"true\">

$versions{'AuthorizeNet-order_lib.pl'} = "20030306";

&add_codehook("printSubmitPage","print_AuthorizeNet_SubmitPage");
&add_codehook("set_form_required_fields","AuthorizeNet_fields");
$sc_order_response_vars{"AuthorizeNet"}="x_response_code";
&add_codehook("gateway_response","check_for_AuthorizeNet_response");
###############################################################################
sub check_for_AuthorizeNet_response {
  if ($form_data{'x_response_code'}) {
    $cart_id = $form_data{'x_cust_id'};
    &set_sc_cart_path;
    &load_order_lib;
    &codehook("AuthorizeNet_order");
    &process_AuthorizeNet_Order;
    &call_exit;
   }
 }
###############################################################################
sub AuthorizeNet_order_form_prep{ # load the customer info ...
  if ($sc_AuthorizeNet_form_prep == 0) {
    if (-f "$sc_verify_order_path"){
      &read_verify_file;  
     } else {
      &codehook("load_customer_info");
     }
    $sc_AuthorizeNet_form_prep = 1;
   }
  return "";
 }
###############################################################################
sub AuthorizeNet_fields{
local($myname)="AuthorizeNet";

if (!($form_data{'gateway'} eq $myname)) { return;} 

%sc_order_form_array =('Ecom_BillTo_Postal_Name_First', 'First Name',
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
	"Ecom_ShipTo_Postal_StateProv",
	"Ecom_ShipTo_Postal_PostalCode");

}
###############################################################################
sub AuthorizeNet_verification_table {
  local ($rslt)="";
  $rslt = "<table border=0 width=100%>\n<tr>\n";
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
sub anet_table_setup{
#
# To use this, put this in the x_Header_Html in the manager:
#
#	<!--agorascript-pre
#	  return $anet_cart_table;
#	-->
#
# and in the email footer you can use:
#
#	<!--agorascript-pre
#	  return $anet_prod_in_cart;
#	-->
# 

local (@my_cart_fields,$my_cart_row_number,$result);
local ($count,$price,$product_id,$quantity,$total_cost,$total_qty)=0;
local ($name,$cost);

 $anet_prod_in_cart = '';
 $anet_cart_table = '';
 $result='';
 open (CART, "$sc_cart_path") || &file_open_error("$sc_cart_path", 
            "display_cart_contents_in_header", __FILE__, __LINE__);
 while (<CART>)
  {
   $count++;
   chop;    
   @my_cart_fields = split (/\|/, $_);
   $my_cart_row_number = pop(@my_cart_fields);
   push (@my_cart_fields, $my_cart_row_number);
   $quantity = $my_cart_fields[0];
   $product_id = $my_cart_fields[1];
   $price = $my_cart_fields[$sc_cart_index_of_price_after_options]; 
   $name = $my_cart_fields[$cart{"name"}];
   $name = substr($name,0,35);
   $cost = &format_price($quantity * $price);
   $total_cost = $total_cost + $quantity * $price;
   $total_qty = $total_qty + $quantity;
   $options = $my_cart_fields[$cart{"options"}];
   $options =~ s/<br>/ /g;
   if ($result eq '') {
     $result .= '<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 WIDTH=425>';
     $result .= "<TR><TD>Items Ordered:</TD></TR><TR><TD>\n";
     $result .= "<TABLE CELLPADDING=3 CELLSPACING=0 BORDER=1 WIDTH='100%'>\n";
     $result .= "<TR><TH>QTY</TH><TH>ID #</TH><TH>Description</TH>";
     $result .= "<TH>Cost</TH></TR>\n";
     $anet_prod_in_cart .= "  --PRODUCT INFORMATION--\n\n";
    }
   $result .= "<TR><TD>$quantity</TD><TD>$product_id</TD>\n";
   $result .= "<TD>$name</TD><TD>$cost</TD>";
   $result .= "</TR>\n";
   $anet_prod_in_cart .= &cart_textinfo(*my_cart_fields);
  } # End of while (<CART>)
 close (CART);
 if ($result ne '') {
   $result .= "</TABLE></TD></TR></TABLE>\n";
  }
 $anet_cart_table = $result;
}

###############################################################################
sub print_AuthorizeNet_SubmitPage

{
local($invoice_number, $customer_number);
local($test_mode,$mytable);
local($myname)="AuthorizeNet";

if (!($form_data{'gateway'} eq $myname)) { return;} 
if ($myname ne $sc_gateway_name) { # secondary gateway, load settings
  &require_supporting_libraries(__FILE__,__LINE__,
     "./admin_files/$myname-user_lib.pl");
 }

&codehook("AuthorizeNet-SubmitPage-top");

$mytable = &AuthorizeNet_verification_table;

if ($merchant_live_mode =~ /yes/i){
  $test_mode = "";
 } else {
  $test_mode = "<INPUT TYPE=HIDDEN NAME=x_Test_Request VALUE=\"TRUE\">";
 }
$tstamp = time;
if ($sc_tstamp3 =~ /add/i){
  $tstamp = $tstamp + $sc_tstamp2;
 }
if ($sc_tstamp3 =~ /subtract/i){
  $tstamp = $tstamp - $sc_tstamp2;
 }
$sequence = int(rand 1000);
require "./library/MD5.pl" || die "Can't require ./library/MD5.pl";
$fp = &hmac_hex
($sc_gateway_username ."^".$sequence."^".$tstamp."^".$authPrice."^",$txnkey);

$invoice_number = $current_verify_inv_no;
#$customer_number = $form_data{'cart_id'};
$customer_number = $cart_id;
$customer_number =~ s/_/./g;

&anet_table_setup;
$xx_Header_Html_Payment_Form =
	&script_and_substitute($x_Header_Html_Payment_Form,"Anet");
$xx_Footer_Html_Payment_Form =
	&script_and_substitute($x_Footer_Html_Payment_Form,"Anet");
$xx_Header_Html_Receipt =
	&script_and_substitute($x_Header_Html_Receipt,"Anet");
$xx_Footer_Html_Receipt =
	&script_and_substitute($x_Footer_Html_Receipt,"Anet");
$xx_Header_Email_Receipt =
	&script_and_substitute($x_Header_Email_Receipt,"Anet");
$xx_Footer_Email_Receipt =
	&script_and_substitute($x_Footer_Email_Receipt,"Anet");
# if ($x_Description eq '') {
#  $x_Description = "Online Order"; # default value
# }
# $xx_Description =
#	&script_and_substitute($x_Description,"Anet");

&codehook("AuthorizeNet-SubmitPage-print");

# <INPUT TYPE=HIDDEN NAME=x_Description VALUE=\"$xx_Description\">
print <<ENDOFTEXT;

<FORM METHOD=POST ACTION=\"$sc_order_script_url\">
<INPUT TYPE=HIDDEN NAME=x_amount VALUE=\"$authPrice\">
<INPUT TYPE=HIDDEN NAME=x_Freight VALUE=\"$zfinal_shipping\">
<INPUT TYPE=HIDDEN NAME=ud_Discount VALUE=\"$zfinal_discount\">
<INPUT TYPE=HIDDEN NAME=x_Tax VALUE=\"$zfinal_sales_tax\">
<INPUT TYPE=HIDDEN NAME=x_Login VALUE=\"$sc_gateway_username\">
<INPUT TYPE=HIDDEN NAME=x_Invoice_Num VALUE=\"$invoice_number\">
<INPUT TYPE=HIDDEN NAME=x_Description VALUE=\"$anet_desc\">
<INPUT TYPE=HIDDEN NAME=x_Cust_ID VALUE=\"$customer_number\">
<INPUT TYPE=HIDDEN NAME=x_Show_Form VALUE=\"PAYMENT_FORM\">
<INPUT TYPE=HIDDEN NAME=x_Receipt_Link_Method VALUE=\"POST\">
<INPUT TYPE=HIDDEN NAME=x_Receipt_Link_Text VALUE=\"YOU MUST CLICK HERE TO FINALIZE YOUR ORDER!\">
<INPUT TYPE=HIDDEN NAME=x_Receipt_Link_URL VALUE=\"$sc_store_url\">
$test_mode
<INPUT TYPE=HIDDEN NAME=x_ADC_URL VALUE=\"$sc_store_url\">
<INPUT TYPE=HIDDEN NAME=x_ADC_Relay_Response VALUE=\"true\">
<INPUT TYPE=HIDDEN NAME=x_Version VALUE=\"3.1\">

<INPUT TYPE=HIDDEN NAME=x_Logo_URL VALUE=\"$x_Logo_URL\">
<INPUT TYPE=HIDDEN NAME=x_Color_Background VALUE=\"$x_Color_Background\">
<INPUT TYPE=HIDDEN NAME=x_Color_Link VALUE=\"$x_Color_Link\">
<INPUT TYPE=HIDDEN NAME=x_Color_Text VALUE=\"$x_Color_Text\">
<INPUT TYPE=HIDDEN NAME=x_Header_Html_Payment_Form VALUE=\"$xx_Header_Html_Payment_Form\">
<INPUT TYPE=HIDDEN NAME=x_Footer_Html_Payment_Form VALUE=\"$xx_Footer_Html_Payment_Form\">
<INPUT TYPE=HIDDEN NAME=x_Header_Html_Receipt VALUE=\"$xx_Header_Html_Receipt\">
<INPUT TYPE=HIDDEN NAME=x_Footer_Html_Receipt VALUE=\"$xx_Footer_Html_Receipt\">
<INPUT TYPE=HIDDEN NAME=x_Header_Email_Receipt VALUE=\"$xx_Header_Email_Receipt\">
<INPUT TYPE=HIDDEN NAME=x_Footer_Email_Receipt VALUE=\"$xx_Footer_Email_Receipt\">
<INPUT TYPE=HIDDEN NAME=Ecom_ShipTo_Method VALUE=\"$form_data{'Ecom_ShipTo_Method'}\">
<INPUT TYPE=HIDDEN NAME=X_Ship_To_State VALUE=\"$form_data{'Ecom_ShipTo_Postal_StateProv'}\">
<INPUT TYPE=HIDDEN NAME=X_Ship_To_Zip VALUE=\"$form_data{'Ecom_ShipTo_Postal_PostalCode'}\">
<INPUT TYPE="HIDDEN" NAME=x_fp_sequence VALUE=\"$sequence\">
<INPUT TYPE="HIDDEN" NAME=x_fp_timestamp VALUE=\"$tstamp\">
<INPUT TYPE="HIDDEN" NAME=x_fp_hash VALUE=\"$fp\">

<TABLE WIDTH="500" BGCOLOR="#C0FFFF" CELLPADDING="0" CELLSPACING="0">
<TR>
<TD>

<TABLE WIDTH="500" BGCOLOR="#000080" CELLPADDING="0" CELLSPACING="0">
<TR BGCOLOR="#C0FFFF">
<TD BGCOLOR="#C0FFFF"><FONT FACE="ARIAL" SIZE="2" COLOR="#000000">
$messages{'ordcnf_06'}</FONT></TD>
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

</TD>
</TR>
</TABLE>

</FORM>
</CENTER>

ENDOFTEXT

}
############################################################################################

sub process_AuthorizeNet_Order {
local($subtotal, $total_quantity,
      $total_measured_quantity,
      $text_of_cart, $weight,
      $required_fields_filled_in, $product, $quantity, $options);
local($stevo_shipping_thing) = "";
local($stevo_shipping_names) = "";
local($mytext) = "";
local($ship_thing_too,$ship_instructions);

#
# Need to process this info someday ...
&load_verify_file;
#
# Now verify the order total and the shipping cost
#if ((!($sc_verify_shipping == $form_data{'x_freight'})) ||
#    (!($sc_verify_grand_total == $form_data{'x_amount'}))) {
#  $mytext =  "This order failed automatic verification, and has been \n";
#  $mytext .= "marked for manual verification.  The reason is:\n";
#if (!($sc_verify_shipping == $form_data{'x_freight'})) {
#    $mytext .= "Shipping amount: $form_data{'x_freight'}  ".
#               " (expected $sc_verify_shipping).\n";
#  }
#if (!($sc_verify_grand_total == $form_data{'x_amount'})) {
#    $mytext .= "Order Total: $form_data{'x_amount'}  ".
#               " (expected $sc_verify_grand_total).\n";
#  }
# }

                # First, we output the header of
                # the processing of the order

$orderDate = &get_date;

print qq!
<HTML>
$sc_special_page_meta_tags
<HEAD>
<TITLE>$messages{'ordcnf_08'}</TITLE>
$sc_standard_head_info</HEAD>
<BODY $sc_standard_body_info>
!;

&SecureStoreHeader; # Don't Use standard header

if ($form_data{'x_response_code'} > 1) { # there is a problem ...
  if ($form_data{'x_response_code'} == 2) { # declined ... dump cart ??
    &empty_cart;
   }
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=500>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
<P>&nbsp;</P>
$messages{'ordcnf_05'}<br>
$form_data{'x_response_reason_text'} <br>
<P>&nbsp;</P>
$messages{'ordcnf_02'}<br>
</FONT>
</TD>
</TR>
</TABLE>
<CENTER>  
ENDOFTEXT
&SecureStoreFooter;
print qq!
</BODY>
</HTML>
!;
&call_exit;
 }

# All went well at AuthorizeNet, proceed with processing

print $mytext;

$text_of_cart .= "${mytext}";
$text_of_cart .= "Order Date:    $orderDate\n";
$text_of_cart .= "Gateway:       AuthorizeNet\n\n";

$text_of_cart .= "  --PRODUCT INFORMATION--\n\n";

open (CART, "$sc_cart_path") ||
&file_open_error("$sc_cart_path", "display_cart_contents", __FILE__, __LINE__);

while (<CART>)
	{
	$cartData++;
	@cart_fields = split (/\|/, $_);
	$quantity = $cart_fields[0];
	$product_price = $cart_fields[3];
	$product = $cart_fields[4];
	$weight = $cart_fields[6];
	$options = $cart_fields[$cart{"options"}];
	$options =~ s/<br>/ /g;
        $text_of_cart .= &cart_textinfo(*cart_fields);
        $stevo_shipping_thing .="|$quantity\*$weight";
        $stevo_shipping_names .="|$product\($options\)";
        &codehook("process-cart-item");
	}
close(CART);

$sc_orderlib_use_SBW_for_ship_ins = $sc_use_SBW;
&codehook("orderlib-ship-instructions");
if ($sc_orderlib_use_SBW_for_ship_ins =~ /yes/i){
  ($ship_thing_too,$ship_instructions) = 
   &ship_put_in_boxes($stevo_shipping_thing,$stevo_shipping_names,
   $sc_verify_Origin_ZIP,$sc_verify_boxes_max_wt); 
 }

	$text_of_confirm_email .= $messages{'ordcnf_07'};

	$text_of_confirm_email .= $text_of_cart;
	$text_of_confirm_email .= "\n";

	$text_of_cart .= "  --ORDER INFORMATION--\n\n";

	$text_of_cart .= "CUSTID:        $form_data{'x_cust_id'}\n";
	$text_of_confirm_email .= "CUSTID:        $form_data{'x_cust_id'}\n";

	$text_of_cart .= "INVOICE:       $form_data{'x_invoice_num'}\n";
	$text_of_confirm_email .= "INVOICE:       $form_data{'x_invoice_num'}\n";

	if ($form_data{'x_freight'})
	{
	$text_of_cart .= "SHIPPING:      $form_data{'x_freight'}\n";
	$text_of_confirm_email .= "SHIPPING:      $form_data{'x_freight'}\n";
        if ($sc_use_SBW =~ /yes/i)
         {
           $text_of_confirm_email .= 
                        "SHIP VIA:      $form_data{'HW2SHIP'}\n";
         }
	}

	if ($form_data{'ud_Discount'})
	{
	$text_of_cart .= "DISCOUNT:      $form_data{'ud_Discount'}\n";
	$text_of_confirm_email .= "DISCOUNT:      $form_data{'ud_Discount'}\n";
	}

	if ($form_data{'x_tax'})
	{
	$text_of_cart .=          "TOT SALES TAX: $form_data{'x_tax'}\n";
	$text_of_confirm_email .= "TOT SALES TAX: $form_data{'x_tax'}\n";
	}

if ($sc_verify_tax > 0)
{
$temp = substr(substr("SALES TAX",0,13).":               ",0,15);
$text_of_cart .= "$temp$sc_verify_tax\n";
$text_of_confirm_email .= "$temp$sc_verify_tax\n";
}
if ($sc_verify_etax1 > 0)
{
$temp = substr(substr($sc_extra_tax1_name,0,13).":               ",0,15);
$text_of_cart .= "$temp$sc_verify_etax1\n";
$text_of_confirm_email .= "$temp$sc_verify_etax1\n";
}
if ($sc_verify_etax2 > 0)
{
$temp = substr(substr($sc_extra_tax2_name,0,13).":               ",0,15);
$text_of_cart .= "$temp$sc_verify_etax2\n";
$text_of_confirm_email .= "$temp$sc_verify_etax2\n";
}
if ($sc_verify_etax3 > 0)
{
$temp = substr(substr($sc_extra_tax3_name,0,13).":               ",0,15);
$text_of_cart .= "$temp$sc_verify_etax3\n";
$text_of_confirm_email .= "$temp$sc_verify_etax3\n";
}

	$text_of_cart .= "TOTAL:         $form_data{'x_amount'}\n";
	$text_of_confirm_email .= "TOTAL:         $form_data{'x_amount'}\n";

	$text_of_cart .= "METHOD:        $form_data{'x_method'}\n";
	$text_of_cart .= "TYPE:          $form_data{'x_type'}\n";
	$text_of_cart .= "DESCRIPTION:   $form_data{'x_description'}\n\n";
	
	$text_of_cart .= "RESP CODE:     $form_data{'x_response_code'}\n";
	$text_of_cart .= "RESP SUBCODE:  $form_data{'x_response_subcode'}\n";
	$text_of_cart .= "REASON CODE:   $form_data{'x_response_reason_code'}\n";
	$text_of_cart .= "REASON TEXT:   $form_data{'x_response_reason_text'}\n";
	$text_of_cart .= "AUTH CODE:     $form_data{'x_auth_code'}\n";
	$text_of_cart .= "AVS CODE:      $form_data{'x_avs_code'}\n";
	$text_of_cart .= "TRANS ID:      $form_data{'x_trans_id'}\n\n";
	
	$text_of_cart .= "BILLING INFORMATION --------------\n\n";
	$text_of_cart .= "NAME:          $form_data{'x_first_name'} $form_data{'x_last_name'}\n";
	$text_of_cart .= "COMPANY:       $form_data{'x_company'}\n";
	$text_of_cart .= "ADDRESS:       $form_data{'x_address'}\n";
	$text_of_cart .= "CITY:          $form_data{'x_city'}\n";
	$text_of_cart .= "STATE:         $form_data{'x_state'}\n";
	$text_of_cart .= "ZIP:           $form_data{'x_zip'}\n";
	$text_of_cart .= "COUNTRY:       $form_data{'x_country'}\n";
	$text_of_cart .= "PHONE:         $form_data{'x_phone'}\n";
	$text_of_cart .= "FAX:           $form_data{'x_fax'}\n";
	$text_of_cart .= "EMAIL:         $form_data{'x_email'}\n\n";
	$text_of_cart .= "SHIPPING INFORMATION --------------\n\n";
	$text_of_cart .= "SHIP VIA:      $form_data{'Ecom_ShipTo_Method'}\n";
	$text_of_cart .= "NAME:          $form_data{'x_ship_to_first_name'} $form_data{'x_ship_to_last_name'}\n";
	$text_of_cart .= "COMPANY:       $form_data{'x_ship_to_company'}\n";
	$text_of_cart .= "ADDRESS:       $form_data{'x_ship_to_address'}\n";
	$text_of_cart .= "CITY:          $form_data{'x_ship_to_city'}\n";
	$text_of_cart .= "STATE:         $form_data{'x_ship_to_state'}\n";
	$text_of_cart .= "ZIP:           $form_data{'x_ship_to_zip'}\n";
	$text_of_cart .= "COUNTRY:       $form_data{'x_ship_to_country'}\n\n";

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

if ($sc_send_order_to_email =~ /yes/i)
{
&send_mail($sc_admin_email, $sc_order_email, "Agora.cgi Order",$text_of_cart);
}

&log_order($text_of_cart,$form_data{'x_invoice_num'},$form_data{'x_cust_id'});

if (($cartData) && ($form_data{'x_email'} ne ""))
{
&send_mail($sc_admin_email, $form_data{'x_email'}, $messages{'ordcnf_08'},
           "$text_of_confirm_email");
}
$sc_affiliate_order_unique = $form_data{'x_invoice_num'};
$sc_affiliate_order_total = $form_data{'x_amount'};
  
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=500>
<TR>
<TD WIDTH=500>
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

} # End of process_order_form

#################################################################

1; # Library
