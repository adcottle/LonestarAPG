#######################################################################
#                    Order Form Definition Variables                  #
#######################################################################

$versions{'Offline-order_lib.pl'} = "20021006";

$order_lib_cc_validate = "yes";
$sc_use_secure_header_at_checkout = 'yes';
$sc_offline_form_prep = 0;

&add_codehook("printSubmitPage","print_Offline_SubmitPage");
&add_codehook("set_form_required_fields","Offline_fields");
&add_codehook("gateway_response","check_for_Offline_response");
&add_codehook("open_for_business","check_for_Offline_submit");
$sc_order_response_vars{"Offline"}="process_order";
if ($sc_loading_primary_gateway =~ /yes/i) { #Hook into things ...
  &add_codehook("pre_header_navigation","Offline_pre_header_processing");
 } 
if ($offline_picserve eq '') {
  $offline_picserve = $sc_picserve_url;
 }
if ($offline_picserve eq '') {
  $offline_picserve = 'picserve.cgi';
}
###############################################################################
sub check_for_Offline_submit {
  if (&form_check('submit_order_form_button')) {
    if ($form_data{'gateway'} eq '') {
      $form_data{'gateway'} = $sc_gateway_name;
     }
    if ($form_data{'gateway'} eq 'Offline') {    
      &Offline_response_prep;
     }
   }
 }
###############################################################################
sub check_for_Offline_response {
  if ($form_data{'process_order'}) {
    $cart_id = $form_data{'cart_id'};
    &set_sc_cart_path;
    &load_order_lib;
    &codehook("Offline_order");
    &process_Offline_Order;
    &call_exit;
   }
 }
###############################################################################
sub Offline_check_and_load {
local($myname)="Offline";
#
if ($myname ne $sc_gateway_name) { 
  &require_supporting_libraries(__FILE__,__LINE__,
     "./admin_files/$myname-user_lib.pl");
 }
if ($sc_Offline_CC_validation ne '') {
  $sc_CC_validation = $sc_Offline_CC_validation;
 }
$sc_stepone_order_script_url = $sc_order_script_url;
}
###############################################################################
sub Offline_response_prep {
&Offline_check_and_load;
if ($form_data{'Ecom_ShipTo_Postal_PostalCode'} eq "") {
  if ($form_data{'Ecom_BillTo_PostalCode'} ne "") {
  $form_data{'Ecom_ShipTo_Postal_PostalCode'} = 
       $form_data{'Ecom_BillTo_PostalCode'};
   }
 }

if ($form_data{'Ecom_ShipTo_Postal_Name_Last'} eq "") {
  if ($form_data{'Ecom_BillTo_Postal_Name_Last'} ne "") {
  $form_data{'Ecom_ShipTo_Postal_Name_Last'} = 
       $form_data{'Ecom_BillTo_Postal_Name_Last'};
   }
 }

if ($form_data{'Ecom_ShipTo_Postal_Name_First'} eq "") {
  if ($form_data{'Ecom_BillTo_Postal_Name_First'} ne "") {
  $form_data{'Ecom_ShipTo_Postal_Name_First'} = 
       $form_data{'Ecom_BillTo_Postal_Name_First'};
   }
 }

if ($form_data{'Ecom_ShipTo_Postal_Street_Line1'} eq "") {
  if ($form_data{'Ecom_BillTo_Postal_Street_Line1'} ne "") {
    $form_data{'Ecom_ShipTo_Postal_Street_Line1'} = 
       $form_data{'Ecom_BillTo_Postal_Street_Line1'};
    $form_data{'Ecom_ShipTo_Postal_Street_Line2'} = 
       $form_data{'Ecom_BillTo_Postal_Street_Line2'};
    $form_data{'Ecom_ShipTo_Postal_Street_Line3'} = 
       $form_data{'Ecom_BillTo_Postal_Street_Line3'};
   }
 }

if ($form_data{'Ecom_ShipTo_Postal_City'} eq "") {
  if ($form_data{'Ecom_BillTo_Postal_City'} ne "") {
  $form_data{'Ecom_ShipTo_Postal_City'} = 
       $form_data{'Ecom_BillTo_Postal_City'};
   }
 }

if ($form_data{'Ecom_ShipTo_Postal_StateProv'} eq "") {
  if ($form_data{'Ecom_BillTo_Postal_StateProv'} ne "") {
  $form_data{'Ecom_ShipTo_Postal_StateProv'} = 
       $form_data{'Ecom_BillTo_Postal_StateProv'};
   }
 }

$sc_paid_by_ccard = "";
$form_data{"Ecom_Payment_Orig_Card_Type"} = 
		$form_data{"Ecom_Payment_Card_Type"};
$form_data{"Ecom_Payment_Orig_Card_Number"} = 
		$form_data{"Ecom_Payment_Card_Number"};
if ($form_data{"Ecom_Payment_Card_Type"} ne "" ) {
  if ((!($form_data{"Ecom_Payment_Card_Type"} =~ /check/i)) &&
    (!($form_data{"Ecom_Payment_Card_Type"} =~ /cheque/i)) &&
    (!($form_data{"Ecom_Payment_Card_Type"} =~ /PO/i))) {
  # must be a Credit Card
    $sc_paid_by_ccard = "yes";
    $form_data{"Ecom_Payment_Pay_Type"} = 'CC'; 
   } else {
    $sc_paid_by_ccard = "no";
    if (($sc_allow_pay_by_PO =~ /yes/i )  &&
    ($form_data{"Ecom_Payment_Card_Type"} =~ /PO/i)) {
      $form_data{"Ecom_Payment_Card_Type"} = "Purchase Order"; 
      $form_data{"Ecom_Payment_Card_Number"} = 
        $form_data{"Ecom_Payment_PO_Number"};
      $form_data{"Ecom_Payment_Pay_Type"} = 'PO'; 
    } elsif ($sc_allow_pay_by_check =~ /yes/i ) {
      $form_data{"Ecom_Payment_Card_Type"} .= ", Bank Name is " .
        $form_data{"Ecom_Payment_Bank_Name"};
      $form_data{"Ecom_Payment_Card_Number"} = "R: " .
        $form_data{"Ecom_Payment_BankRoute_Number"} . " A:" .  
        $form_data{"Ecom_Payment_BankAcct_Number"} . " #:" .
        $form_data{"Ecom_Payment_BankCheck_Number"};  
      $form_data{"Ecom_Payment_Pay_Type"} = 'CHECK'; 
     } 
   } 
 }
}
###############################################################################
sub Offline_order_form_prep {
  &Offline_check_and_load;
  if ($sc_offline_form_prep == 0) {
    if (-f "$sc_verify_order_path"){
      &read_verify_file;  
     } else {
      &codehook("load_customer_info");
     }
    $sc_offline_form_prep = 1;
   }
  return "";
 }
###############################################################################
sub Offline_pre_header_processing {
   if (($form_data{'order_form_button.x'} ne "") ||
       ($form_data{'submit_order_form_button'} ne "") ||
       ($form_data{'submit_order_form_button.x'} ne "") ||
       ($form_data{'order_form_button'} ne "")) {
     $sc_browser_header = 
	"Content-type: text/html\nCache-Control: no-cache\n" .
	"Pragma: no-cache\nExpires: Wed, 4 October 2000 00:00:00 GMT\n\n";
   }
 }
###############################################################################
sub Offline_fields {
local($myname)="Offline";

if (!($form_data{'gateway'} eq $myname)) { return;} 

%sc_order_form_array =('Ecom_BillTo_Postal_Name_First', 'First Name',
		       'Ecom_BillTo_Postal_Name_Last', 'Last Name',
		       'Ecom_BillTo_Postal_Street_Line1', 'Billing Address Street',
		       'Ecom_BillTo_Postal_City', 'Billing Address City',
		       'Ecom_BillTo_Postal_StateProv', 'Billing Address State',
		       'Ecom_BillTo_PostalCode', 'Billing Address Zip',
		       'Ecom_BillTo_Postal_CountryCode', 'Billing Address Country',
		       'Ecom_ShipTo_Postal_Name_First', 'Ship To First Name',
		       'Ecom_ShipTo_Postal_Name_Last', 'Ship To Last Name',
		       'Ecom_ShipTo_Postal_Street_Line1', 'Shipping Address Street',
		       'Ecom_ShipTo_Postal_City', 'Shipping Address City',
		       'Ecom_ShipTo_Postal_StateProv', 'Shipping Address State',
		       'Ecom_ShipTo_Postal_PostalCode', 'Shipping Address Zip',
		       'Ecom_ShipTo_Postal_CountryCode', 'Shipping Address Country',
		       'Ecom_BillTo_Telecom_Phone_Number', 'Phone Number',
		       'Ecom_BillTo_Online_Email', 'Email',
		       'Ecom_Payment_Card_Number', 'Card or Check Number',
		       'Ecom_Payment_Card_ExpDate_Month', 'Card Expiration Month',
		       'Ecom_Payment_Card_ExpDate_Day', 'Card Expiration Day',
		       'Ecom_Payment_Card_ExpDate_Year', 'Card Expiration Year',
		       'Ecom_Payment_Card_CVV', 'Card CVV Value');
			
{
  local($mytypes)='credit card';
  if ($sc_allow_pay_by_check =~ /yes/i ) {$mytypes .= "/check";}
  if ($sc_allow_pay_by_PO    =~ /yes/i ) {$mytypes .= "/PO";}
  $sc_order_form_array{'Ecom_Payment_Card_Type'} = "Payment type ($mytypes)";
 }

@sc_order_form_required_fields = ("Ecom_BillTo_Postal_Name_First",
				  "Ecom_BillTo_Postal_Name_Last",
				  "Ecom_BillTo_Postal_Street_Line1",
				  "Ecom_BillTo_Postal_City",
				  "Ecom_BillTo_Postal_StateProv",
				  "Ecom_BillTo_PostalCode",        
				  "Ecom_BillTo_Telecom_Phone_Number",
				  "Ecom_BillTo_Online_Email",
				  "Ecom_Payment_Card_Type",
				  "Ecom_Payment_Card_Number");

if ($sc_paid_by_ccard =~ /yes/i) { 
   push(@sc_order_form_required_fields,"Ecom_Payment_Card_ExpDate_Month");
   push(@sc_order_form_required_fields,"Ecom_Payment_Card_ExpDate_Year");
   push(@sc_order_form_required_fields,"Ecom_Payment_Card_CVV");
 }

}
###############################################################################
sub print_Offline_SubmitPage {

local($invoice_number, $customer_number);
local($myname)="Offline";
local($HREF_FIELDS) = &make_hidden_fields;

if (!($form_data{'gateway'} eq $myname)) { return;} 
&Offline_check_and_load;

$invoice_number = $current_verify_inv_no;
$sc_temp_invoice_number = $invoice_number;
$customer_number = $cart_id;
$customer_number =~ s/_/./g;

print &get_Offline_confirm_middle(*form_data,$invoice_number,
  $customer_number,$offline_ver_tbldef,$messages{'ordcnf_04'},
  $offline_ver_tbldef2,$authPrice,$time);

print <<ENDOFTEXT;
<TABLE WIDTH="500" BGCOLOR="#FFFFFF" CELLPADDING="2" CELLSPACING="0" BORDER=0>
<TR>
<TD WIDTH="50%">
<CENTER><BR>
<FORM METHOD=POST ACTION=\"$sc_order_script_url\">
<!--Order Financial Data-->
<INPUT TYPE=HIDDEN NAME=cart_id VALUE=\"$cart_id\">
<INPUT TYPE=HIDDEN NAME=AMOUNT VALUE=\"$formatted_price\">
<INPUT TYPE=HIDDEN NAME=PLAINAMOUNT VALUE=\"$authPrice\">
<INPUT TYPE=HIDDEN NAME=SUBTOTALAMT VALUE=\"$subtotal\">
<INPUT TYPE=HIDDEN NAME=SHIPPING VALUE=\"$zfinal_shipping\">
<INPUT TYPE=HIDDEN NAME=DISCOUNT VALUE=\"$zfinal_discount\">
<INPUT TYPE=HIDDEN NAME=SALESTAX VALUE=\"$zfinal_sales_tax\">
<INPUT TYPE=HIDDEN NAME=EXTRATAX1 VALUE=\"$zfinal_extra_tax1\">
<INPUT TYPE=HIDDEN NAME=EXTRATAX2 VALUE=\"$zfinal_extra_tax2\">
<INPUT TYPE=HIDDEN NAME=EXTRATAX3 VALUE=\"$zfinal_extra_tax3\">
<INPUT TYPE=HIDDEN NAME=CVV VALUE=\"$eform_data{'Ecom_Payment_Card_CVV'}\">
<!--Customer/Order Data-->
<INPUT TYPE=HIDDEN NAME=CUSTID VALUE=\"$customer_number\">
<INPUT TYPE=HIDDEN NAME=INVOICE VALUE=\"$invoice_number\">
<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"Online Order\">
<!--Billing Address-->
<INPUT TYPE=HIDDEN NAME=NAME VALUE=\"$eform_data{'Ecom_BillTo_Postal_Name_First'} $form_data{'Ecom_BillTo_Postal_Name_Last'}\">
<INPUT TYPE=HIDDEN NAME=ADDRESS VALUE=\"$eform_data{'Ecom_BillTo_Postal_Street_Line1'}\">
<INPUT TYPE=HIDDEN NAME=ADDRESS2 VALUE=\"$eform_data{'Ecom_BillTo_Postal_Street_Line2'}\">
<INPUT TYPE=HIDDEN NAME=ADDRESS3 VALUE=\"$eform_data{'Ecom_BillTo_Postal_Street_Line3'}\">
<INPUT TYPE=HIDDEN NAME=CITY VALUE=\"$eform_data{'Ecom_BillTo_Postal_City'}\">
<INPUT TYPE=HIDDEN NAME=STATE VALUE=\"$eform_data{'Ecom_BillTo_Postal_StateProv'}\">
<INPUT TYPE=HIDDEN NAME=ZIP VALUE=\"$eform_data{'Ecom_BillTo_PostalCode'}\">
<INPUT TYPE=HIDDEN NAME=COUNTRY VALUE=\"$eform_data{'Ecom_BillTo_Postal_CountryCode'}\">
<INPUT TYPE=HIDDEN NAME=PHONE VALUE=\"$eform_data{'Ecom_BillTo_Telecom_Phone_Number'}\">
<INPUT TYPE=HIDDEN NAME=EMAIL VALUE=\"$eform_data{'Ecom_BillTo_Online_Email'}\">
<!--Shipping Address-->
<INPUT TYPE=HIDDEN NAME=HW2SHIP VALUE=\"$eform_data{'Ecom_ShipTo_Method'}\">
<INPUT TYPE=HIDDEN NAME=SHIPNAME VALUE=\"$eform_data{'Ecom_ShipTo_Postal_Name_First'} $eform_data{'Ecom_ShipTo_Postal_Name_Last'}\">
<INPUT TYPE=HIDDEN NAME=SHIPTOSTREET VALUE=\"$eform_data{'Ecom_ShipTo_Postal_Street_Line1'}\">
<INPUT TYPE=HIDDEN NAME=SHIPTOSTREET2 VALUE=\"$eform_data{'Ecom_ShipTo_Postal_Street_Line2'}\">
<INPUT TYPE=HIDDEN NAME=SHIPTOSTREET3 VALUE=\"$eform_data{'Ecom_ShipTo_Postal_Street_Line3'}\">
<INPUT TYPE=HIDDEN NAME=SHIPTOCITY VALUE=\"$eform_data{'Ecom_ShipTo_Postal_City'}\">
<INPUT TYPE=HIDDEN NAME=SHIPTOSTATE VALUE=\"$eform_data{'Ecom_ShipTo_Postal_StateProv'}\">
<INPUT TYPE=HIDDEN NAME=SHIPTOZIP VALUE=\"$eform_data{'Ecom_ShipTo_Postal_PostalCode'}\">
<INPUT TYPE=HIDDEN NAME=SHIPTOCOUNTRY VALUE=\"$eform_data{'Ecom_ShipTo_Postal_CountryCode'}\">
<!--Billing Data-->
<INPUT TYPE=HIDDEN NAME=HCODE VALUE=\"$sc_pass_used_to_scramble\">
<INPUT TYPE="HIDDEN" NAME="process_order" VALUE="yes">
<INPUT TYPE="IMAGE" NAME="Submit" VALUE="Submit Order For Processing"
SRC="$offline_picserve?secpicserve=submit_order.gif" border=0>
&nbsp;&nbsp;&nbsp;&nbsp;
</FORM>
</CENTER>
</TD><TD WIDTH="50%">
<CENTER><BR>
<FORM METHOD=POST
ACTION="$sc_stepone_order_script_url">
<INPUT TYPE=HIDDEN NAME="order_form_button" VALUE="1">
$HREF_FIELDS
<INPUT TYPE=HIDDEN NAME="HCODE" VALUE="$sc_pass_used_to_scramble">
<INPUT TYPE=HIDDEN NAME="gateway" VALUE="Offline"> 
<INPUT TYPE=HIDDEN NAME="ofn" VALUE="Offline"> 
<INPUT TYPE="IMAGE" NAME="Make Changes" VALUE="Make Changes" 
SRC="$offline_picserve?secpicserve=make_changes.gif" BORDER=0>
</FORM>
</CENTER>
</TD>
</TR>
</TABLE>

</FONT>
</CENTER>
ENDOFTEXT
}

###############################################################
sub get_Offline_confirm_middle{
local(*form_data,$invoice_number,$customer_number,
$tbldef,$top_message,$tbldef2,$authPrice,$time) = @_;

local($my_ShipTo_Postal_Street,$my_BillTo_Postal_Street,$formatted_price);
local($answer)='';

$my_ShipTo_Postal_Street = $form_data{'Ecom_ShipTo_Postal_Street_Line1'};
if ($form_data{'Ecom_ShipTo_Postal_Street_Line2'} ne "") {
 $my_ShipTo_Postal_Street .= "<BR>$form_data{'Ecom_ShipTo_Postal_Street_Line2'}";
}
if ($form_data{'Ecom_ShipTo_Postal_Street_Line3'} ne "") {
 $my_ShipTo_Postal_Street .= "<BR>$form_data{'Ecom_ShipTo_Postal_Street_Line3'}";
}

$my_BillTo_Postal_Street = $form_data{'Ecom_BillTo_Postal_Street_Line1'};
if ($form_data{'Ecom_BillTo_Postal_Street_Line2'} ne "") {
 $my_BillTo_Postal_Street .= "<BR>$form_data{'Ecom_BillTo_Postal_Street_Line2'}";
}
if ($form_data{'Ecom_BillTo_Postal_Street_Line3'} ne "") {
 $my_BillTo_Postal_Street .= "<BR>$form_data{'Ecom_BillTo_Postal_Street_Line3'}";
}

$formatted_price = &format_price($authPrice);

$answer.= <<ENDOFTEXT;

<TABLE $tbldef>

<TR BGCOLOR="#FFFFFF">
<TD>
&nbsp;
</TD>
</TR>

<TR>
<TD>
<FONT FACE="ARIAL" SIZE="2" COLOR="#000000">
$top_message
</FONT>
</TD>
</TR>
</TABLE>

<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
<CENTER>
<TABLE $tbldef2>
<TR>
<TD COLSPAN=2>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
<B>Customer Information</B>
</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=100>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Customer Number
</FONT>
</TD>
<TD WIDTH=400>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$cart_id
</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Order Number
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$sc_temp_invoice_number
</FONT>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
<B>Billing Address</B>
</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Name
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_BillTo_Postal_Name_First'} $form_data{'Ecom_BillTo_Postal_Name_Last'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Street
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$my_BillTo_Postal_Street
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
City
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_BillTo_Postal_City'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
State
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_BillTo_Postal_StateProv'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Zip
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_BillTo_PostalCode'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Country
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK> 
$form_data{'Ecom_BillTo_Postal_CountryCode'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Phone
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_BillTo_Telecom_Phone_Number'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
E-Mail
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_BillTo_Online_Email'}
&nbsp;</FONT>
</TD>
</TR>

<!--Shipping Address-->

<TR>
<TD COLSPAN=2>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
<B>Shipping Information</B>
</FONT>
</TD>
</TR>

ENDOFTEXT

if ($form_data{'Ecom_ShipTo_Method'} ne ""){
$answer.= <<ENDOFTEXT;
<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Ship via:
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_ShipTo_Method'}
&nbsp;</FONT>
</TD>
</TR>
ENDOFTEXT
}

$answer.= <<ENDOFTEXT;
<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Name
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_ShipTo_Postal_Name_First'} $form_data{'Ecom_ShipTo_Postal_Name_Last'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Street
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$my_ShipTo_Postal_Street
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
City
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_ShipTo_Postal_City'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
State
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_ShipTo_Postal_StateProv'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Zip
</FONT>
</TD>
<TD WIDTH=350>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_ShipTo_Postal_PostalCode'}
&nbsp;</FONT>
</TD>
</TR>

<TR>
<TD WIDTH=150>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
Country
</FONT>
<TD>
<FONT FACE=ARIAL SIZE=-1 COLOR=BLACK>
$form_data{'Ecom_ShipTo_Postal_CountryCode'}
&nbsp;</FONT>
</TD>
</TR>

</TABLE>
ENDOFTEXT

return $answer;
}
###############################################################
sub process_Offline_Order {
local($subtotal, $total_quantity,
      $total_measured_quantity,
      $text_of_cart, $weight,
      $required_fields_filled_in, $product, $quantity, $options,
      $text_of_confirm_email, $text_of_admin_email, $emailCCnum, $logCCnum);
local($stevo_shipping_thing) = "";
local($stevo_shipping_names) = "";
local($order_ok_final_msg,$order_ok_final_msg_tbl);
local($ship_thing_too,$ship_instructions,$TEMP,$temp,$pass); 


local ($referringDomain, $acceptedDomain);

$acceptedDomain = $sc_order_script_url;
$referringDomain = $ENV{'HTTP_REFERER'};

$referringDomain =~ s/\?.*//g;
$referringDomain =~ s/http:\/\///g;
$referringDomain =~ s/\/.*//g;
$referringDomain =~ s/\/agora.cgi//g;

$acceptedDomain =~ s/\?.*//g;
$acceptedDomain =~ s/http:\/\///g;
$acceptedDomain =~ s/\/.*//g;
$acceptedDomain =~ s/\/agora.cgi//g;

if ($referringDomain =~ "^w*\.")
{
$referringDomain =~ s/^w*\.//i;
}

if ($acceptedDomain =~ "^w*\.")
{
$acceptedDomain =~ s/^w*\.//i;
}

if ($referringDomain ne $acceptedDomain)
{
print "$acceptedDomain is the accepted referrer.<br>";
print "$referringDomain is not a valid referrer<br>";
print "Refering Site Authentication Failed!";
&call_exit;   
}
		
$orderDate = &get_date;

print qq~
<HTML>
$sc_special_page_meta_tags
<HEAD>
<TITLE>$messages{'ordcnf_08'}</TITLE>
$sc_standard_head_info</HEAD>
<BODY $sc_standard_body_info>
~;

$text_of_cart .= "Order Date:    $orderDate\n";
$text_of_cart .= "Gateway:       Offline\n\n";

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
	$options =~ s/$sc_opt_sep_marker/, /g;
	$text_of_cart .= &cart_textinfo(*cart_fields);
	$stevo_shipping_thing .="|$quantity\*$weight";
	$stevo_shipping_names .="|$product\($options\)";
        &codehook("process-cart-item");
	}
close(CART);

if (!(-f "$sc_verify_order_path")){
&SecureStoreHeader;
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=500>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
$messages{'ordcnf_03'}
$messages{'ordcnf_02'}
</FONT>
</TD>
</TR>
</TABLE>
<CENTER>  

ENDOFTEXT

# and the footer is printed

&SecureStoreFooter;

print qq!
</BODY>
</HTML>
!;

&call_exit;

 }

&load_verify_file;

if ($sc_Offline_show_table =~ /yes/i) {
  $order_ok_final_msg = $messages{'ordcnf_09'};
  if ($order_ok_final_msg eq '') {
    $order_ok_final_msg = $messages{'ordcnf_01'};
    $order_ok_final_msg .= "Print this page for your records.  You will ";
    $order_ok_final_msg .= "receive an email receipt shortly.<br>\n";
    $order_ok_final_msg =
	"<TABLE WIDTH=500 $cart_table_def><TR><TD>" .
	$order_ok_final_msg .
	"</TD></TR></TABLE>\n";
   }
  $special_message = $order_ok_final_msg;
  { local(%form_data) = %vform;
    local($sc_use_verify_values_for_display) = "yes";
    &display_cart_table("verify");
  }
 } else {
  &SecureStoreHeader;
 }

if ($sc_scramble_cc_info =~ /yes/i ) {
  $vform{'Ecom_Payment_Orig_Card_Number'} = 
   $vform_Ecom_Payment_Orig_Card_Number;
  $vform{'Ecom_Payment_Card_Number'} =
   $vform_Ecom_Payment_Card_Number;
  $vform{'Ecom_Payment_BankAcct_Number'} = 
   $vform_Ecom_Payment_BankAcct_Number;
  $vform{'Ecom_Payment_BankRoute_Number'} = 
   $vform_Ecom_Payment_BankRoute_Number; 
  $vform{'Ecom_Payment_Bank_Name'} = 
   $vform_Ecom_Payment_Bank_Name; 
 }
foreach $inx (keys %vform) {
  $form_data{$inx} = $vform{$inx};
 }
&Offline_response_prep;

$form_data{'METHOD'} = $form_data{'Ecom_Payment_Card_Type'};
$form_data{'CARDNUM'} = $form_data{'Ecom_Payment_Card_Number'};
$form_data{'CARDNUM'} =~ s/\ \ /\ /g; 
$form_data{'CARDNUM'} =~ s/\ \ /\ /g; 
$form_data{'EXPDATE'} = 
"Month: $vform_Ecom_Payment_Card_ExpDate_Month " .
"Day: $vform_Ecom_Payment_Card_ExpDate_Day " . 
"Year: $vform_Ecom_Payment_Card_ExpDate_Year";
$my_EXPDATE = $form_data{'EXPDATE'};

if ($vform_Ecom_Payment_Pay_Type eq 'PO') {
  $emailMETHOD = $form_data{'METHOD'};
  $form_data{'CARDNUM'} = $vform_Ecom_Payment_PO_Number;
  $emailCCnum = $form_data{'CARDNUM'};
  $logCCnum = $form_data{'CARDNUM'};
 } else { # Check or CC
  if ($sc_use_pgp =~ /yes/i) { 
    $emailMETHOD = $form_data{'METHOD'};
    $emailCCnum = $form_data{'CARDNUM'};
    $logCCnum = $form_data{'CARDNUM'};
  } else {
    $emailMETHOD = "XXXX";
    $emailCCnum = "XXXXXXXX";
    $emailCCnum .= substr($form_data{'CARDNUM'},8,65);
    $logCCnum = substr($form_data{'CARDNUM'},0,8);
    $logCCnum .= "XXXXXXXX";
  }
}

$verify_error = "";

$sc_orderlib_use_SBW_for_ship_ins = $sc_use_SBW;
&codehook("orderlib-ship-instructions");
if ($sc_orderlib_use_SBW_for_ship_ins =~ /yes/i)
{
($ship_thing_too,$ship_instructions) = 
 &ship_put_in_boxes($stevo_shipping_thing,$stevo_shipping_names,
 $sc_verify_Origin_ZIP,$sc_verify_boxes_max_wt); 
}

$test_shipping = $form_data{'SHIPPING'};
$test_shipping =~ s/[^0-9\.]//g;
if (!($sc_verify_shipping == $test_shipping)){
  $verify_error .= "  Could not verify Shipping Cost" . "\n";
 }
$test = $form_data{'DISCOUNT'};
$test =~ s/[^0-9\.]//g;
if (!($sc_verify_discount == $test)){
  $verify_error .= "  Could not verify Discount Amount\n";
 }
$test = $form_data{'SALESTAX'};
$test =~ s/[^0-9\.]//g;
if (!($sc_verify_tax == $test)){
  $verify_error .= "  Could not verify Sales Tax\n";
 }

$running_total = $form_data{'PLAINAMOUNT'};
#$running_total =~ s/[^\d\.]//g;# strip off non numeric stuff

if (!((0+$sc_verify_grand_total) == (0+$running_total))){
  $verify_error .= "  Could not verify order Total Amount\n";
  $verify_error .= "  expected: $sc_verify_grand_total\n";
  $verify_error .= "  observed: $running_total\n";
 }
if ($verify_error ne ""){
  $text_of_cart .= "** NOTE: Automatic verification not possible, this order\n" .
  "will be manually verified.  Reason automatic verification\n" . 
  "was not possible:\n" . $verify_error . "\n";
 }

$text_of_confirm_email .= $messages{'ordcnf_07'};
$text_of_confirm_email .= $text_of_cart;
$text_of_confirm_email .= "\n";
$text_of_cart .= "  --ORDER INFORMATION--\n\n";

$text_of_cart .= "CUSTID:        $form_data{'CUSTID'}\n";
$text_of_admin_email .= "CUSTID:        $form_data{'CUSTID'}\n";

$text_of_cart .= "INVOICE:       $form_data{'INVOICE'}\n";
$text_of_confirm_email .= "INVOICE:       $form_data{'INVOICE'}\n";
$sc_temp_invoice_number = $form_data{'INVOICE'};

$temp = &display_price($sc_verify_subtotal);
$text_of_cart .= "SUBTOTAL:      $temp\n";
$text_of_confirm_email .= "SUBTOTAL:      $temp\n";
$sc_verify_subtotal_temp3 = $temp;

if ($form_data{'SHIPPING'})
{
$temp = &display_price($form_data{'SHIPPING'});
$text_of_cart .= "SHIPPING:      $temp\n";
$text_of_confirm_email .= "SHIPPING:      $temp\n";
}

if ($sc_use_SBW =~ /yes/i)
{
 $text_of_confirm_email .= "SHIP VIA:      $form_data{'HW2SHIP'}\n";
}

if ($form_data{'DISCOUNT'})
{
$text_of_cart .= "DISCOUNT:      $form_data{'DISCOUNT'}\n";
$text_of_confirm_email .= "DISCOUNT:      $form_data{'DISCOUNT'}\n";
}

if ($form_data{'SALESTAX'})
{
$text_of_cart .= "SALES TAX:     $form_data{'SALESTAX'}\n";
$text_of_confirm_email .= "SALES TAX:     $form_data{'SALESTAX'}\n";
}

if ($form_data{'EXTRATAX1'})
{
$temp = substr(substr($sc_extra_tax1_name,0,13).":               ",0,15);
$text_of_cart .= "$temp$form_data{'EXTRATAX1'}\n";
$text_of_confirm_email .= "$temp$form_data{'EXTRATAX1'}\n";
}

if ($form_data{'EXTRATAX2'})
{
$temp = substr(substr($sc_extra_tax2_name,0,13).":               ",0,15);
$text_of_cart .= "$temp$form_data{'EXTRATAX2'}\n";
$text_of_confirm_email .= "$temp$form_data{'EXTRATAX2'}\n";
}

if ($form_data{'EXTRATAX3'})
{
$temp = substr(substr($sc_extra_tax3_name,0,13).":               ",0,15);
$text_of_cart .= "$temp$form_data{'EXTRATAX3'}\n";
$text_of_confirm_email .= "$temp$form_data{'EXTRATAX3'}\n";
}

$temp = &display_price($sc_verify_grand_total);

$text_of_cart .= "TOTAL:         $temp\n";
$text_of_confirm_email .= "TOTAL:         $temp\n\n";

$text_of_admin_email = $text_of_cart;

$text_of_cart .= "METHOD:        $form_data{'METHOD'}\n";
$text_of_admin_email .= "METHOD:        $emailMETHOD\n";

$text_of_cart .= "NUMBER:        $logCCnum\n";
$text_of_admin_email .= "NUMBER:        $emailCCnum\n";

if ($sc_verify_paid_by_ccard =~ /yes/i) {
$text_of_cart .= "EXP:           $my_EXPDATE\n";
$text_of_admin_email .= "EXP:           $form_data{'EXPDATE'}\n";
}

if ($form_data{'Ecom_Payment_Card_CVV'} ne "") {
$text_of_cart .= "CVV2:           $form_data{'Ecom_Payment_Card_CVV'}\n";
$text_of_admin_email .= "CVV2:           $form_data{'Ecom_Payment_Card_CVV'}\n";
}

$text_of_cart .= "DESCRIPTION:   $form_data{'DESCRIPTION'}\n\n";
$text_of_admin_email .= "DESCRIPTION:   $form_data{'DESCRIPTION'}\n\n";

$text_of_cart .= "BILLING INFORMATION --------------\n\n";
$text_of_admin_email .= "BILLING INFORMATION --------------\n\n";

$text_of_cart .= "NAME:          $form_data{'NAME'}\n";
$text_of_admin_email .= "NAME:          $form_data{'NAME'}\n";

$text_of_cart .= "ADDRESS:       $form_data{'ADDRESS'}\n";
$text_of_admin_email .= "ADDRESS:       $form_data{'ADDRESS'}\n";

if ($form_data{'ADDRESS2'} ne "") {
  $text_of_cart .= "               $form_data{'ADDRESS2'}\n";
  $text_of_admin_email .= "               $form_data{'ADDRESS2'}\n";
 }

if ($form_data{'ADDRESS3'} ne "") {
  $text_of_cart .= "               $form_data{'ADDRESS3'}\n";
  $text_of_admin_email .= "               $form_data{'ADDRESS3'}\n";
 }

$text_of_cart .= "CITY:          $form_data{'CITY'}\n";
$text_of_admin_email .= "CITY:          $form_data{'CITY'}\n";

$text_of_cart .= "STATE:         $form_data{'STATE'}\n";
$text_of_admin_email .= "STATE:         $form_data{'STATE'}\n";

$text_of_cart .= "ZIP:           $form_data{'ZIP'}\n";
$text_of_admin_email .= "ZIP:           $form_data{'ZIP'}\n";

$text_of_cart .= "COUNTRY:       $form_data{'COUNTRY'}\n";
$text_of_admin_email .= "COUNTRY:       $form_data{'COUNTRY'}\n";

$text_of_cart .= "PHONE:         $form_data{'PHONE'}\n";
$text_of_admin_email .= "PHONE:         $form_data{'PHONE'}\n";

$text_of_cart .= "EMAIL:         $form_data{'EMAIL'}\n\n";
$text_of_admin_email .= "EMAIL:         $form_data{'EMAIL'}\n\n";

$text_of_cart .= "SHIPPING INFORMATION --------------\n\n";
$text_of_admin_email .= "SHIPPING INFORMATION --------------\n\n";

$text_of_cart .= "SHIP VIA:      $form_data{'HW2SHIP'}\n";
$text_of_admin_email .= "SHIP VIA:      $form_data{'HW2SHIP'}\n";

$text_of_cart .= "NAME:          $form_data{'SHIPNAME'}\n";
$text_of_admin_email .= "NAME:          $form_data{'SHIPNAME'}\n";

$text_of_cart .= "ADDRESS:       $form_data{'SHIPTOSTREET'}\n";
$text_of_admin_email .= "ADDRESS:       $form_data{'SHIPTOSTREET'}\n";

if ($form_data{'SHIPTOSTREET2'} ne "") {
  $text_of_cart .= "               $form_data{'SHIPTOSTREET2'}\n";
  $text_of_admin_email .= "               $form_data{'SHIPTOSTREET2'}\n";
 }

if ($form_data{'SHIPTOSTREET3'} ne "") {
  $text_of_cart .= "               $form_data{'SHIPTOSTREET3'}\n";
  $text_of_admin_email .= "               $form_data{'SHIPTOSTREET3'}\n";
 }

$text_of_cart .= "CITY:          $form_data{'SHIPTOCITY'}\n";
$text_of_admin_email .= "CITY:          $form_data{'SHIPTOCITY'}\n";

$text_of_cart .= "STATE:         $form_data{'SHIPTOSTATE'}\n";
$text_of_admin_email .= "STATE:         $form_data{'SHIPTOSTATE'}\n";

$text_of_cart .= "ZIP:           $form_data{'SHIPTOZIP'}\n";
$text_of_admin_email .= "ZIP:           $form_data{'SHIPTOZIP'}\n";

$text_of_cart .= "COUNTRY:       $form_data{'SHIPTOCOUNTRY'}\n\n";
$text_of_admin_email .= "COUNTRY:       $form_data{'SHIPTOCOUNTRY'}\n\n";

if ($ship_instructions ne "") {
  $text_of_cart .= "Shipping Instructions: \n$ship_instructions\n\n"; 
  $text_of_admin_email .= "Shipping Instructions:\n$ship_instructions\n\n"; 
 } 

$text_of_cart .= $XCOMMENTS;
$text_of_admin_email .= $XCOMMENTS_ADMIN;
$text_of_confirm_email .= $XCOMMENTS;

$temp = &init_shop_keep_email;
$text_of_cart = $temp . $text_of_cart;
$text_of_admin_email = $temp . $text_of_admin_email;
$text_of_confirm_email = &init_customer_email . $text_of_confirm_email;

$temp = &addto_shop_keep_email;
$text_of_cart .= $temp;
$text_of_admin_email .= $temp;
$text_of_confirm_email .= &addto_customer_email;

if ($sc_use_pgp =~ /yes/i)
{
&require_supporting_libraries(__FILE__, __LINE__, "$sc_pgp_lib_path");
$text_of_cart = &make_pgp_file($text_of_cart, "$sc_pgp_temp_file_path/$$.pgp");
$text_of_cart = "\n" . $text_of_cart . "\n";

$text_of_admin_email = &make_pgp_file($text_of_admin_email, "$sc_pgp_temp_file_path/$$.pgp");
$text_of_admin_email = "\n" . $text_of_admin_email . "\n";
}

if ($sc_send_order_to_email =~ /yes/i)
{
&send_mail($sc_admin_email, $sc_order_email, "Online Order",$text_of_admin_email);
}

&log_order($text_of_cart,$form_data{'INVOICE'},$form_data{'CUSTID'});

if (($cartData) && ($form_data{'EMAIL'} ne ""))
{
&send_mail($sc_admin_email, $form_data{'EMAIL'},$messages{'ordcnf_08'},
           "$text_of_confirm_email");
}
  
if ($sc_Offline_show_table =~ /yes/i) {
  $order_ok_final_msg_tbl = $messages{'ordcnf_10'}; 
  if ($order_ok_final_msg_tbl eq '') {
   # Default so something is there, use $messages{'ordcnf_10'} though 
   # to customize, set it in the Free Form Logic (either location.)
    $order_ok_final_msg_tbl = &get_date . "<br><br>Order Confirmation:";
   }
  $temp = 
    &get_Offline_confirm_middle(*form_data,$invoice_number,
    $customer_number,$offline_ver_tbldef,$order_ok_final_msg_tbl,
    $offline_ver_tbldef2,$authPrice,$time) . "<br>\n";
 } else {
  $temp = $messages{'ordcnf_01'};
 }
$sc_affiliate_order_unique = $form_data{'INVOICE'};
$sc_affiliate_order_total = $sc_verify_subtotal_temp3;

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=500>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
$temp
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>  
ENDOFTEXT

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=500>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
$messages{'ordcnf_02'}
<br>
$sc_affiliate_image_call
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>  

ENDOFTEXT

&empty_cart;

&SecureStoreFooter;

print qq!
</BODY>
</HTML>
!;

} 

#################################################################

1; # Library
