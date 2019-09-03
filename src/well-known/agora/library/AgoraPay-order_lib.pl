#######################################################################
#                    Order Form Definition Variables                  #
#######################################################################

$versions{'AgoraPay-order_lib.pl'} = "20020312";

$sc_order_response_vars{"AgoraPay"}="AgoraPay";
$sc_use_secure_header_at_checkout = 'yes';
&add_codehook("printSubmitPage","print_AgoraPay_SubmitPage");
&add_codehook("set_form_required_fields","AgoraPay_fields");
&add_codehook("gateway_response","check_for_AgoraPay_response");
###############################################################################
sub check_for_AgoraPay_response {
  if ($form_data{'AgoraPay'} eq 'AgoraPay') {
    $cart_id = $form_data{'p4'};
    &set_sc_cart_path;
    &load_order_lib;
    &codehook("AgoraPay_order");
    &process_AgoraPay_Order;
    &call_exit;
   }
 }
###############################################################################
sub AgoraPay_fields{
local($myname)="AgoraPay";

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
sub AgoraPay_order_form_prep{ # load the customer info ...
  if ($sc_AgoraPay_form_prep == 0) {
    if (-f "$sc_verify_order_path"){
      &read_verify_file;  
     } else {
      &codehook("load_customer_info");
     }
    $sc_AgoraPay_form_prep = 1;
   }
  return "";
 }
###############################################################################
sub AgoraPay_table_setup{
#
# To use this, put this in the email_text in the manager for HTML:
#
#	<!--agorascript-pre
#	  return $AgoraPay_cart_table;
#	-->
#
# or for text in an email:
#
#	<!--agorascript-pre
#	  return $AgoraPay_prod_in_cart;
#	-->
# 

local (@my_cart_fields,$my_cart_row_number,$result);
local ($count,$price,$product_id,$quantity,$total_cost,$total_qty)=0;
local ($name,$cost);

 $AgoraPay_prod_in_cart = '';
 $AgoraPay_cart_table = '';
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
     $AgoraPay_prod_in_cart .= "  --PRODUCT INFORMATION--\n\n";
    }
   $result .= "<TR><TD>$quantity</TD><TD>$product_id</TD>\n";
   $result .= "<TD>$name</TD><TD>$cost</TD>";
   $result .= "</TR>\n";
   $AgoraPay_prod_in_cart .= &cart_textinfo(*my_cart_fields);
  } # End of while (<CART>)
 close (CART);
 if ($result ne '') {
   $result .= "</TABLE></TD></TR></TABLE>\n";
  }
 $AgoraPay_cart_table = $result;
}

###############################################################################

sub print_AgoraPay_SubmitPage

{
local($invoice_number, $customer_number, $displayTotal);
local($test_mode,$zemail_text);
local($myname)="AgoraPay";

if (!($form_data{'gateway'} eq $myname)) { return;} 
if ($myname ne $sc_gateway_name) { # secondary gateway, load settings
  &require_supporting_libraries(__FILE__,__LINE__,
     "./admin_files/$myname-user_lib.pl");
 }

$displayTotal = &display_price($authPrice);

$invoice_number = $current_verify_inv_no;
$customer_number = $cart_id;
$customer_number =~ s/_/./g;
&AgoraPay_table_setup;
$zemail_text = &script_and_substitute($email_text,"AgoraPay");

if ($merchant_live_mode =~ /yes/i){
  $test_mode = "";
 } else {
  $test_mode = "<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"test_mode\">";
 }

print <<ENDOFTEXT;

<FORM METHOD=POST ACTION=\"$sc_order_script_url\">

<INPUT TYPE=HIDDEN NAME=\"1-cost\" VALUE=\"$authPrice\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p1\">
<INPUT TYPE=\"HIDDEN\" NAME=\"p1\" VALUE=\"$zfinal_shipping\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"Ecom_ShipTo_Method\">
<INPUT TYPE=\"HIDDEN\" NAME=\"Ecom_ShipTo_Method\" VALUE=\"$form_data{'Ecom_ShipTo_Method'}\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p2\">
<INPUT TYPE=HIDDEN NAME=\"p2\" VALUE=\"$zfinal_discount\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p3\">
<INPUT TYPE=HIDDEN NAME=\"p3\" VALUE=\"$zfinal_sales_tax\">

<INPUT TYPE=\"HIDDEN\" NAME=\"vendor_id\" VALUE=\"$sc_gateway_username\">
<INPUT TYPE=\"HIDDEN\" NAME=\"home_page\" VALUE=\"$sc_store_url\">
<INPUT TYPE=\"HIDDEN\" NAME=\"ret_addr\" VALUE=\"$sc_store_url\">
<INPUT TYPE=\"HIDDEN\" NAME=\"email_text\" VALUE=\"$zemail_text\">

<INPUT TYPE=\"HIDDEN\" NAME=\"1-desc\" VALUE=\"Online Order\">
<INPUT TYPE=\"HIDDEN\" NAME=\"1-qty\" VALUE=\"1\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p4\">
<INPUT TYPE=\"HIDDEN\" NAME=\"p4\" VALUE=\"$customer_number\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p5\">
<INPUT TYPE=\"HIDDEN\" NAME=\"p5\" VALUE=\"$invoice_number\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p6\">
<INPUT TYPE=\"HIDDEN\" NAME=\"p6\" VALUE=\"$displayTotal\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"AgoraPay\">
<INPUT TYPE=\"HIDDEN\" NAME=\"AgoraPay\" VALUE=\"AgoraPay\">

<INPUT TYPE=HIDDEN NAME=\"showaddr\" VALUE=\"1\">
<INPUT TYPE=HIDDEN NAME=\"nonum\" VALUE=\"0\">

<INPUT TYPE=HIDDEN NAME=\"mername\" VALUE=\"$mername\">
<INPUT TYPE=HIDDEN NAME=\"acceptcards\" VALUE=\"$acceptcards\">
<INPUT TYPE=HIDDEN NAME=\"acceptchecks\" VALUE=\"$acceptchecks\">
<INPUT TYPE=HIDDEN NAME=\"accepteft\" VALUE=\"$accepteft\">
<INPUT TYPE=HIDDEN NAME=\"altaddr\" VALUE=\"$altaddr\">

<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"first_name\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"last_name\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"address\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"city\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"state\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"zip\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"country\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"phone\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"email\">

<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"sfname\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"slname\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"saddr\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"scity\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"sstate\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"szip\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"sctry\">

<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"total\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"authcode\">
$test_mode
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"when\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"xid\">

<TABLE WIDTH="500" BGCOLOR="#C0FFFF" CELLPADDING="0" CELLSPACING="0">
<TR>
<TD>

<TABLE WIDTH="500" BGCOLOR="#000080" CELLPADDING="0" CELLSPACING="0">
<TR BGCOLOR="#C0FFFF">
<TD BGCOLOR="#C0FFFF"><FONT FACE="ARIAL" SIZE="2" COLOR="#000000">
Please verify the following information. When you are confident 
that it is correct, click the 'Secure Orderform' button to enter 
your payment information, or
<a href="${sc_stepone_order_script_url}?order_form_button.x=1">
click here</a> to make corrections:
</FONT></TD>
<TD  BGCOLOR="#C0FFFF">
</TR>
<TR BGCOLOR="#C0FFFF">
<td>
Ship To $form_data{'Ecom_ShipTo_Postal_PostalCode'}
$form_data{'Ecom_ShipTo_Postal_StateProv'}
via $form_data{'Ecom_ShipTo_Method'}<br>
</td>
</tr>
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
sub process_AgoraPay_Order {
local($subtotal, $total_quantity,
      $total_measured_quantity,
      $text_of_cart, $weight,
      $required_fields_filled_in, $product, $quantity, $options);
local($stevo_shipping_thing) = "";
local($stevo_shipping_names) = "";
local($ship_thing_too,$ship_instructions);

&load_verify_file;

$mySIG= "./admin_files/sig_ver_$$.SIG";

open(SIGV,">$mySIG");
print SIGV $form_data{'signature'};
close(SIGV);

($junk,$my_str) = split(/http:\/\//,$form_data{'signature'},2);
($junk,$my_str) = split(/\?/,$my_str,2);
($my_str,$junk) = split(/\n/,$my_str,2);

@itrans = split(/[&;]/,$my_str); 

# parse the signed response, not what was on the command line ... 
# code borrowed from cgi-lib.pl

foreach $i (0 .. $#itrans) {
   # Convert plus to space
   $itrans[$i] =~ s/\+/ /g;

   # Split into key and value.  
   ($key, $val) = split(/=/,$itrans[$i],2); # splits on the first =.

   # Convert %XX from hex numbers to alphanumeric
   $key =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
   $val =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;

   # Associate key and value
   $itrans{$key} .= "\0" if (defined($itrans{$key})); #\0 = multiple separator
   $itrans{$key} .= $val;
 }

if ($sc_pgp_or_gpg =~ /GPG/i) { # verify with GPG
  $command =  "$sc_pgp_or_gpg_path ";
  $command .= "--home ./pgpfiles --always-trust --verify ";
  $ENV{'PATH'}="/bin:/usr/bin";
  $result = `$command $mySIG 2>&1`;
  if (($result =~ /Good Signature/i) &&
      ($result =~ /AgoraPay/i)) {
    $verification = "Passed GNU Privacy Guard signature verification.";
   } else {
    $verification = "$result\n";
# Could not verify AgoraPay signature because:\n$result\n";
   }
 }

if ($sc_pgp_or_gpg =~ /PGP/i) { # verify with Pretty Good Privacy
  $command =  "$sc_pgp_or_gpg_path";
  chop($command);
  $command .= "v "; # verification 
  $command .= "";
  $ENV{'PATH'}="/bin:/usr/bin";
  $ENV{'PGPPATH'}="./pgpfiles";
  $result = `$command $mySIG 2>&1`;
  if (($result =~ /Good Signature/i) &&
      ($result =~ /AgoraPay/i)) {
    $verification = "Passed PGP signature verification.";
   } else {
#    $verification = "\n$result\n";
   }
 }

unlink("$mySIG");

if ($cart_id ne $itrans{'p4'}) {
  $verification .= "\nWARNING! CART ID DOES NOT MATCH EXPECTED VALUE!!\n\n";
 }

$orderDate = &get_date;

print qq!
<HTML>
$sc_special_page_meta_tags
<HEAD>
<TITLE>$messages{'ordcnf_08'}</TITLE>
$sc_standard_head_info</HEAD>
<BODY $sc_standard_body_info>
!;

&StoreHeader;

$text_of_cart .= "Order Date:    $orderDate\n";
$text_of_cart .= "Gateway:       AgoraPay\n\n";

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
if ($sc_orderlib_use_SBW_for_ship_ins =~ /yes/i) {
  ($ship_thing_too,$ship_instructions) = 
   &ship_put_in_boxes($stevo_shipping_thing,$stevo_shipping_names,
   $sc_verify_Origin_ZIP,$sc_verify_boxes_max_wt); 
 }

$text_of_confirm_email .= $messages{'ordcnf_07'};

$text_of_confirm_email .= "$text_of_cart\n";

$text_of_cart .= "  --ORDER INFORMATION--\n\n";

# $text_of_cart .= "VERIFICATION:  $verification\n";
$text_of_cart .= "CUST ID:       $itrans{'p4'}\n";
$text_of_confirm_email .= "CUST ID:       $itrans{'p4'}\n";

$text_of_cart .= "ORDER ID:      $itrans{'p5'}\n";
$text_of_confirm_email .= "ORDER ID:      $itrans{'p5'}\n";

if ($itrans{'p1'})
{
$text_of_cart .= "SHIPPING:      $itrans{'p1'}\n";
$text_of_confirm_email .= "SHIPPING:      $itrans{'p1'}\n";
}
if ($sc_use_SBW =~ /yes/i)
{
 $text_of_confirm_email .= "SHIP VIA:      $itrans{'Ecom_ShipTo_Method'}\n";
}

if ($itrans{'p2'})
{
$text_of_cart .= "DISCOUNT:      $itrans{'p2'}\n";
$text_of_confirm_email .= "DISCOUNT:      $itrans{'p2'}\n";
}

if ($itrans{'p3'})
{
$text_of_cart .=          "TOT. SALESTAX: $itrans{'p3'}\n";
$text_of_confirm_email .= "TOT. SALESTAX: $itrans{'p3'}\n";
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

$text_of_cart .= "TOTAL:         $itrans{'p6'}\n\n";
$text_of_confirm_email .= "TOTAL:         $itrans{'p6'}\n\n";

$text_of_cart .= "AUTH CODE      $itrans{'authcode'}\n";
$text_of_cart .= "TIME:          $itrans{'when'}\n";
$text_of_cart .= "TRANS ID:      $itrans{'xid'}\n\n";
$text_of_cart .= "BILLING INFORMATION --------------\n\n";
$text_of_cart .= "NAME:          $itrans{'first_name'} $itrans{'last_name'}\n";
$text_of_cart .= "ADDRESS:       $itrans{'address'}\n";
$text_of_cart .= "CITY:          $itrans{'city'}\n";
$text_of_cart .= "STATE:         $itrans{'state'}\n";
$text_of_cart .= "ZIP:           $itrans{'zip'}\n";
$text_of_cart .= "COUNTRY:       $itrans{'country'}\n";
$text_of_cart .= "PHONE:         $itrans{'phone'}\n";
$text_of_cart .= "EMAIL:         $itrans{'email'}\n\n";
$text_of_cart .= "SHIPPING INFORMATION --------------\n\n";
$text_of_cart .= "NAME:          $itrans{'sfname'} $itrans{'slname'}\n";
$text_of_cart .= "ADDRESS:       $itrans{'saddr'}\n";
$text_of_cart .= "CITY:          $itrans{'scity'}\n";
$text_of_cart .= "STATE:         $itrans{'sstate'}\n";
$text_of_cart .= "ZIP:           $itrans{'szip'}\n";
$text_of_cart .= "COUNTRY:       $itrans{'sctry'}\n\n";
if ($sc_use_SBW =~ /yes/i) {
  $text_of_cart .= "SHIP VIA:      $itrans{'Ecom_ShipTo_Method'}\n";
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

if ($sc_use_pgp =~ /yes/i) {
  &require_supporting_libraries(__FILE__, __LINE__, "$sc_pgp_lib_path");
  $text_of_cart = &make_pgp_file($text_of_cart,"$sc_pgp_temp_file_path/$$.pgp");
  $text_of_cart = "\n" . $text_of_cart . "\n";
 }

if ($sc_send_order_to_email =~ /yes/i) {
  &send_mail($sc_admin_email, $sc_order_email, "Agora.cgi Order",$text_of_cart);
 }

&log_order($text_of_cart,$itrans{'p5'},$itrans{'p4'});

if (($cartData) && ($itrans{'email'} ne "")) {
  &send_mail($sc_admin_email, $itrans{'email'}, $messages{'ordcnf_08'},
           "$text_of_confirm_email");
 }
$sc_affiliate_order_unique = $itrans{'p5'};
$sc_affiliate_order_total = $itrans{'p6'};
  
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
