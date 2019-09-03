############################################################

$versions{'agora_order_lib.pl'} = "20021020";

&require_supporting_libraries (__FILE__, __LINE__,
   		"$sc_mail_lib_path",
   		"$sc_ship_lib_path");

&codehook("order_library_init");
############################################################
sub add_to_the_cart {
local (@database_rows, @database_fields, @item_ids, @display_fields);
local ($qty,$line,$line_no,$cart_row_qty,$cart_row_middle);
local ($junk,$zzzitem,$temp,$web_id_number)="";
local (%item_opt_verify,@lines,@testme);
local ($need_bad_order_note,$wildcard_id_number) = '';
local ($order_count)=0;
&checkReferrer;

if (!($sc_db_lib_was_loaded =~ /yes/i)) {
  &require_supporting_libraries (__FILE__, __LINE__, "$sc_db_lib_path"); 
 }

open (CART, "+>>$sc_cart_path") || &file_open_error("$sc_cart_path", "Add to Shopping Cart", __FILE__, __LINE__);

$highest_item_number = 100; 

seek (CART, 0, 0); 

while (<CART>) 

{

chomp $_;

my @row = split (/\|/, $_); 

my $item_number_info = pop (@row);
($item_number,$item_modifier) = split(/\*/,$item_number_info,2);

$highest_item_number = $item_number if ($item_number > $highest_item_number);

}

close (CART);

&update_special_variable_options('reset');

@items_ordered = sort(keys (%form_data));

foreach $item (@items_ordered)
{


if (($item =~ /^item-/i || $item =~ /^option/i) && $form_data{$item} ne "")
{


$item =~ s/^item-//i;

if ($item =~ /^option/i)
{
push (@options, $item);
}


else
{

#	if (($form_data{"item-$item"} =~ /\D/) || ($form_data{"item-$item"} == 0))
	$form_data{"item-$item"} =~ s/ //g; # get rid of any blanks
	if (($form_data{"item-$item"} =~ /\D/) || ($form_data{"item-$item"} < 0))
	{
	if (!($sc_ignore_bad_qty_on_add)) {$need_bad_order_note = 1;}
	}

	else
	{
	$quantity = $form_data{"item-$item"};
	if ($quantity > 0) {
	  push (@items_ordered_with_options, "$quantity\|$item\|");
	  $order_count++;
	 }
	}

}

}

}

if (($order_count == 0) or ($need_bad_order_note)) { 
  $sc_shall_i_let_client_know_item_added = 'no'; 
  $temp = &get_agora('TRANSACTIONS');
  @temp = split(/\n/,$temp);
  $junk=pop(@temp);
  if ($junk eq $sc_unique_cart_modifier) {
    $temp = join("\n",@temp) . "\n";
    &set_agora('TRANSACTIONS',$temp);
   }
  if ($need_bad_order_note) {
    &bad_order_note;
   } else {
    &finish_add_to_the_cart;
   }
  return;
 }

foreach $item_ordered_with_options (@items_ordered_with_options)

{
&codehook("foreach_item_ordered_top");

$options = "";
$option_subtotal = "";
$option_grand_total = "";
$item_grand_total = "";

$item_ordered_with_options =~ s/~qq~/\"/g;
$item_ordered_with_options =~ s/~gt~/\>/g;
$item_ordered_with_options =~ s/~lt~/\</g;

@cart_row = split (/\|/, $item_ordered_with_options);
&codehook("foreach_item_ordered_split_cart_row");
$web_id_number = $cart_row[$sc_cart_index_of_item_id];
if ($sc_web_pid_sep_char ne '') {
  ($cart_row[$sc_cart_index_of_item_id],$junk) =
  split(/$sc_web_pid_sep_char/,$cart_row[$sc_cart_index_of_item_id],2);
  $item_id_number = $cart_row[$sc_cart_index_of_item_id];
  $wildcard_id_number = $item_id_number . $sc_web_pid_sep_char . "*";
 } else {
  $item_id_number = $cart_row[$sc_cart_index_of_item_id];
  $wildcard_id_number = '';
}
$item_quantity = $cart_row[$sc_cart_index_of_quantity];
$item_price = $cart_row[$sc_cart_index_of_price];
$item_shipping = $cart_row[$cart{"shipping"}];
$item_option_numbers = "";
$item_user1 = "";
$item_user2 = "";
$item_user3 = "";
$item_agorascript = "";
undef(%item_opt_verify);

$found = &check_db_with_product_id($item_id_number,*database_fields);
&create_display_fields(@database_fields);
&codehook("cart_add_read_db_item");
foreach $zzzitem (@database_fields) {
  $field = $zzzitem;
  if ($field =~ /^%%OPTION%%/i) {
    ($empty, $option_tag, $option_location) = split (/%%/, $field);

    $field = &load_opt_file($option_location);

    $junk = &option_prep($field,$option_location,$item_id_number);
    $junk = &prep_displayProductPage($junk);

    $item_agorascript .= $field;

   }
 }
&codehook("cart_add_read_item_agorascript");

foreach $option (@options)
{
($option_marker, $option_number, $option_item_number) = split (/\|/, $option);

if (($option_item_number eq "$web_id_number") || 
    ($option_item_number eq "$wildcard_id_number"))
{

$field = &agorascript($item_agorascript,"add-to-cart-opt-" . $option_number,
		"$option_location",__FILE__,__LINE__);

($option_name,$option_price,$option_shipping)=split(/\|/,$form_data{$option});
if($option_name) {
  if ($sc_use_verified_opt_values =~ /yes/i) { 
    $temp = $item_opt_verify{$option . '|' . $option_name};
    ($option_price,$option_shipping) = split(/\|/,$temp,2);
    if ($temp ne "") {
      $temp = $option_name . '|' . $temp;
     } else {
      $option_name=""; # erase it, unverifiable
     }
   } else {
    $temp = $form_data{$option};
   }
  if($option_name) {
   $temp =~ s/\|/~/g; # cannot have pipes, change to ~ char
   if ($item_option_numbers eq ""){
     $item_option_numbers = "${option_number}*$temp";
    } else {
     $item_option_numbers .= $sc_opt_sep_marker . "${option_number}*$temp";
    }

   if ((0 + $option_price) == 0) { 
     $display_option_price = "";
    } else { # price non-zero, must format it
     $display_option_price = " " . &display_price($option_price);
    }
   if ($options ne "") { 
     $options .= "$sc_opt_sep_marker";
    }
   $options .= "$option_name$display_option_price";
   }
}


&codehook("process_cart_options");
$item_shipping = $item_shipping + $option_shipping;
$unformatted_option_grand_total = $option_grand_total + $option_price;
$option_grand_total = &format_price($unformatted_option_grand_total);

}

}

$item_number = ++$highest_item_number;

$unformatted_item_grand_total = $item_price + $option_grand_total;
$item_grand_total = &format_price("$unformatted_item_grand_total");

$cart_row[$cart{"shipping"}] = $item_shipping;
$cart_row[$cart{"shipping_calc_flag"}] = "";

$cart_row[$cart{"options_ids"}] = $item_option_numbers;

$field = &agorascript($item_agorascript,"add-to-cart",
		"$option_location",__FILE__,__LINE__);

&codehook("before_build_cart_row");
$cart_row[$cart{"user1"}] = $item_user1;
$cart_row[$cart{"user2"}] = $item_user2;
$cart_row[$cart{"user3"}] = $item_user3;
foreach $field (@cart_row) {
  $cart_row .= "$field\|";
 }

$cart_row .= "$options\|$item_grand_total";
($cart_row_qty,$cart_row_middle) = split(/\|/,$cart_row,2);
$cart_row .= "\|$item_number\n";


&codehook("foreach_item_ordered_end");
&add_one_row_to_cart($cart_row,$cart_row_qty,$cart_row_middle);
$cart_row = '';

}

&update_special_variable_options('calculate');

&finish_add_to_the_cart;

} 
############################################################
sub add_one_row_to_cart {

 local ($cart_row,$cart_row_qty,$cart_row_middle) = @_;
 local(@lines,@newlines,@testme,$qty,$orig_line,$line);

&codehook("before_add_cart_rows");

if (-e "$sc_cart_path")
{
open (CART, "$sc_cart_path") || &file_open_error("$sc_cart_path", "Add to Shopping Cart", __FILE__, __LINE__);
@lines = (<CART>);
close (CART);
open (CART, ">$sc_cart_path") || &file_open_error("$sc_cart_path", "Add to Shopping Cart", __FILE__, __LINE__);
local(@newlines) = ();
foreach $line (@lines) {
  $orig_line = $line;
  ($qty,$line) = split(/\|/,$line,2);
  (@testme) = split(/\|/,$line); 
  $line_no = pop(@testme);
  $line = join('|',@testme);
  if ($line eq $cart_row_middle) {
    $orig_line = ($qty+$cart_row_qty) . '|' . $line . '|' . $line_no;
    $cart_row_middle = '';
   }
  push(@newlines,$orig_line);
 }
if ($cart_row_middle ne '') {
  push(@newlines,$cart_row);
 }
@newlines = (sort { &middle_of_cart($a) <=> &middle_of_cart($b) } @newlines);
foreach $line (@newlines) {
  print CART "$line";
 }
close (CART);
}
else
{
open (CART, ">$sc_cart_path") || &file_open_error("$sc_cart_path", "Add to Shopping Cart", __FILE__, __LINE__);
print CART "$cart_row";
close (CART);
}
&codehook("after_add_cart_rows");

}
############################################################
sub middle_of_cart {
  local ($line) = @_;
  local ($qty,@testme,$line_no);
  ($qty,$line) = split(/\|/,$line,2);
  (@testme) = split(/\|/,$line); 
  $line_no = pop(@testme);
  $line = join('|',@testme);
  return $line;
 }
############################################################################
sub display_order_form {
  local($line,$the_file,@lines,$temp);
  local($subtotal);
  local($total_quantity);
  local($total_measured_quantity);
  local($text_of_cart);
  local($stevo_shipping_thing);
  local($hidden_fields);
  local($have_form_tag) = "no";
  local($form_name)=$sc_html_order_form_path;
  local($have_terminated_form_tag) = "no";
  local($continue) = 1;

  &codehook("order_form_entry");
  if ($continue == 0) { return;}

if ($sc_allow_ofn_choice =~ /yes/i) {
  if ($form_data{'order_form'} ne "") {
    $temp = "$sc_html_dir/forms/$form_data{'order_form'}-orderform.html";
    if (-f $temp) {
      $temp =~ /([^\xFF]*)/; 
      $form_name = $1;
     }
   }  else { # added by mister ed after K-3
    $temp = "$sc_html_dir/forms/combo-orderform.html";
    if (-f $temp) {
      $temp =~ /([^\xFF]*)/; 
      $form_name = $1;
     }
}
 }

&codehook("order_form_pre_read");
open (ORDERFORM, "$form_name") || &file_open_error("$form_name", 
		"Display Order Form File Error",__FILE__,__LINE__);

{
local $/=undef;
$the_file=<ORDERFORM>;
}

$the_file = &agorascript($the_file,"orderform","Order Form Prep 1",
			 __FILE__, __LINE__);

&codehook("order_form_prep");
$the_file =~ s/\\/\\\\/g;
$the_file =~ s/\@/\\\@/g;
$the_file =~ s/\"/\\\"/g;
$the_file =~ /([^\xFF]*)/;# untaint
eval('$the_file = "' . $1 . '";');

$the_file = &script_and_substitute($the_file,"Order Form Prep 2");
@lines = split(/\n/,$the_file);

$done=0;
foreach $myline (@lines) {

$line = $myline . "\n";

if ($line =~ /<body/i) { 
  $line="<BODY $sc_standard_body_info>\n"; 
 }


if ($line =~ /<FORM/i) {

#<INPUT TYPE = "hidden" NAME = "cart_id" VALUE = "$cart_id">

$hidden_fields = &make_hidden_fields;

if (($have_form_tag eq "yes") && ($have_terminated_form_tag eq "no")) {

  print "</FORM>\n\n";
  $have_terminated_form_tag = "yes";
 } else { 
  $have_form_tag = "yes";
 }

if ($sc_replace_orderform_form_tags =~ /yes/i) {
  print qq!\n<FORM METHOD = "POST" ACTION = "$sc_order_script_url">!;
  print $hidden_fields;
 } else {
  print "\n$line\n$hidden_fields\n";
 }

$line = "";


} 

if ($line =~ /<h2>cart.*contents.*h2>/i) {

if (($have_form_tag eq "yes") && ($have_terminated_form_tag eq "no")) {
  print "</FORM>\n\n";
  $have_terminated_form_tag = "yes";
 } 
$have_form_tag = "yes";

($subtotal, 
 $total_quantity,
 $total_measured_quantity,
 $text_of_cart,
 $stevo_shipping_thing) = &display_cart_table("orderform");      

$line = "";
}

if ($line =~ /\<\/body\>/i) {
  $done=1;
 } else {
  &codehook("print_order_form_line");
  print $line;
 }

} 

if  (($sc_gateway_name eq "Offline") ||
     ($sc_use_secure_footer_for_order_form =~ /yes/i)){
  &SecureStoreFooter;
 } else {
  &StoreFooter;
 }

print qq~
</BODY>
</HTML>
~;
  
} 
############################################################
sub vform_check {
  local($field,$val,$returnv) = @_;
  if ($vform{$field} eq $val) {return $returnv;}
  return "";
 }
############################################################
sub print_order_totals {
local($continue) = 1;

&codehook("print_order_totals_top");
if ($continue == 0) { return;}

print qq~
<br>
<TABLE $order_table_def>
<TR>
<TD $order_heading_def>$cart_font_style
<B>$sc_totals_table_thdr_label</B></FONT></TD>
</TR>
<TR>
<TD $order_item_def>$cart_font_style${sc_totals_table_itot_label}:</FONT></TD>
<TD $order_item_def>$cartnum_font_style $price</FONT></TD>
</TR>
~;

if ($zfinal_shipping > 0)
{
print "<TR>\n";
print "<TD $order_item_def>$cart_font_style ",
      $sc_ship_method_shortname,
      $sc_totals_table_ship_label,
      ":</FONT></TD>\n";
$val =  &format_price($zfinal_shipping);
print "<TD $order_item_def>$cart_font_style $val</FONT></TD>\n";
print "</TR>\n";
}
if ($zfinal_discount > 0)
{
print "<TR>\n";
print "<TD $order_item_def>$cart_font_style ",
      $sc_totals_table_disc_label,
      ":</FONT></TD>\n";
$val =  &format_price($zfinal_discount);
print "<TD $order_item_def>$cart_font_style $val</FONT></TD>\n";
print "</TR>\n";
}
if ($zfinal_sales_tax > 0)
{
print "<TR>\n";
print "<TD $order_item_def>$cart_font_style ",
      $sc_totals_table_stax_label,
      ":</FONT></TD>\n";
$val =  &format_price($zfinal_sales_tax);
print "<TD $order_item_def>$cart_font_style $val</FONT></TD>\n";
print "</TR>\n";
}
if ($zfinal_extra_tax1 > 0)
{
print "<TR>\n";
print "<TD $order_item_def>$cart_font_style $sc_extra_tax1_name",
      ":</FONT></TD>\n";
$val =  &format_price($zfinal_extra_tax1);
print "<TD $order_item_def>$cart_font_style $val</FONT></TD>\n";
print "</TR>\n";
}
if ($zfinal_extra_tax2 > 0)
{
print "<TR>\n";
print "<TD $order_item_def>$cart_font_style $sc_extra_tax2_name",
      ":</FONT></TD>\n";
$val =  &format_price($zfinal_extra_tax2);
print "<TD $order_item_def>$cart_font_style $val</FONT></TD>\n";
print "</TR>\n";
}
if ($zfinal_extra_tax3 > 0)
{
print "<TR>\n";
print "<TD $order_item_def>$cart_font_style $sc_extra_tax3_name",
      ":</FONT></TD>\n";
$val =  &format_price($zfinal_extra_tax3);
print "<TD $order_item_def>$cart_font_style $val</FONT></TD>\n";
print "</TR>\n";
}
print "<TR>\n";
#print "<TD $order_item_def>$cart_font_style &nbsp; </FONT></TD>\n";
#print "<TD $order_item_def>${cartnum_font_style}--------</FONT></TD>\n";
print "<TD $order_item_def colspan=2><IMG SRC=\"",
      "picserve.cgi?secpicserve=line.gif\"",
      " border=0 height=2 width=46></FONT></TD>\n";
print "</TR>\n";
print "<TR>\n";
print "<TD $order_item_def>${cart_font_style}",
      $sc_totals_table_gtot_label,
      ":</FONT></TD>\n";
print "<TD $order_item_def>$cartnum_font_style
$grand_total</FONT></TD>\n";
print "</TR>\n";
print "</TABLE>\n";
}

############################################################
sub process_order_form {
local($subtotal, $total_quantity,
      $total_measured_quantity,
      $text_of_cart,
      $required_fields_filled_in);
local($hidden_fields) = &make_hidden_fields;
local($continue) = 1;

&codehook("process_order_form_top");
if ($continue == 0) { return;}

print qq~
<HTML>
<HEAD>
<TITLE>Step Two</TITLE>
$sc_standard_head_info</HEAD>
<BODY $sc_standard_body_info>
~;

($subtotal, 
 $total_quantity,
 $total_measured_quantity,
 $text_of_cart,
 $stevo_shipping_thing) = 
 &display_cart_table("verify");      

$required_fields_filled_in = "yes";

if ($form_data{'gateway'} eq "") {
  $form_data{'gateway'} = $sc_gateway_name;
 }

&codehook("set_form_required_fields");#

foreach $required_field (@sc_order_form_required_fields) {
if ($form_data{$required_field} eq "") {
    $required_fields_filled_in = "no";

$we_need_to_exit++;

print <<ENDOFTEXT;

<CENTER>
<HR WIDTH=500>
<TABLE WIDTH=500>
<TR>
<TD>
<FONT FACE=ARIAL COLOR=RED>
You forgot to fill in $sc_order_form_array{$required_field}.
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT
  }

} 

if ($we_need_to_exit > 0)
{
    print "<HR WIDTH=500>\n";
    print qq~<center><FORM METHOD=POST
ACTION="$sc_stepone_order_script_url">
<INPUT TYPE=HIDDEN NAME="order_form_button" VALUE="1">
$hidden_fields
<INPUT TYPE=HIDDEN NAME="HCODE" VALUE="$sc_pass_used_to_scramble">
<INPUT TYPE=HIDDEN NAME="gateway" VALUE="$form_data{'gateway'}"> 
<INPUT TYPE=HIDDEN NAME="ofn" VALUE="$form_data{'gateway'}"> 
<INPUT TYPE="IMAGE" NAME="Make Changes" VALUE="Make Changes" 
SRC="picserve.cgi?secpicserve=make_changes.gif" BORDER=0>
</FORM>~;
    print "</center>\n";
    &SecureStoreFooter;

    print qq!
    </BODY>
    </HTML>
    !;
    &call_exit;
}

if (($sc_paid_by_ccard =~ /yes/i) && ($sc_CC_validation =~ /yes/i)) {

  &require_supporting_libraries (__FILE__, __LINE__,
		"./library/credit_card_validation_lib.pl");

  $CC_exp_date = $form_data{'Ecom_Payment_Card_ExpDate_Month'} . '/' .
                 $form_data{'Ecom_Payment_Card_ExpDate_Day'} . '/' .
                 $form_data{'Ecom_Payment_Card_ExpDate_Year'};

  ($error_code, $error_message) = &validate_credit_card_information(
                                  $form_data{"Ecom_Payment_Card_Type"},
                                  $form_data{"Ecom_Payment_Card_Number"},
                                  $CC_exp_date);

  if($error_code != 0)
  {
    $required_fields_filled_in = "no";
    $order_error_do_not_finish = "yes";
print <<ENDOFTEXT;

<CENTER>
<HR WIDTH=500>
<TABLE WIDTH=500>
<TR>
<TD>
<FONT FACE=ARIAL COLOR=RED>
$error_message</FONT>
</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT
  }  

}

  if($order_error_do_not_finish =~ /yes/i)
  {
    print "<HR WIDTH=500>\n";
    print qq~<center><FORM METHOD=POST
ACTION="$sc_stepone_order_script_url">
<INPUT TYPE=HIDDEN NAME="order_form_button" VALUE="1">
$hidden_fields
<INPUT TYPE=HIDDEN NAME="HCODE" VALUE="$sc_pass_used_to_scramble">
<INPUT TYPE=HIDDEN NAME="gateway" VALUE="$form_data{'gateway'}"> 
<INPUT TYPE=HIDDEN NAME="ofn" VALUE="$form_data{'gateway'}"> 
<INPUT TYPE="IMAGE" NAME="Make Changes" VALUE="Make Changes" 
SRC="picserve.cgi?secpicserve=make_changes.gif" BORDER=0>
</FORM>~;
    print "</center>\n";
    &SecureStoreFooter;

    print qq!
    </BODY>
    </HTML>
    !;
    &call_exit;
  }  

if ($required_fields_filled_in eq "yes") {

  foreach $form_field (sort(keys(%sc_order_form_array))) {
    $text_of_cart .= 
      &format_text_field($sc_order_form_array{$form_field})
      . "= $form_data{$form_field}\n";
  }
  $text_of_cart .= "\n";

if ($sc_use_pgp =~ /yes/i) {
    &require_supporting_libraries(__FILE__, __LINE__,
    "$sc_pgp_lib_path");

$text_of_cart = &make_pgp_file($text_of_cart,
               "$sc_pgp_temp_file_path/$$.pgp");
$text_of_cart = "\n" . $text_of_cart . "\n";

  }

if ($form_data{'gateway'} eq "") {
  # set default value, backwards compatable!
  $form_data{'gateway'} = $sc_gateway_name;
 }
  
&codehook("printSubmitPage");# used to be &printSubmitPage;

} else {

print <<ENDOFTEXT;

<CENTER>
<HR WIDTH=500>
<TABLE WIDTH=500>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>$messages{'ordprc_01'}</FONT></TD>
</TR>
</TABLE>
<HR WIDTH=500>
<CENTER>  

ENDOFTEXT

} 

&SecureStoreFooter;

print qq!
</BODY>
</HTML>
!;

} 
############################################################
sub calculate_final_values {
  local($subtotal,
        $total_quantity,
        $total_measured_quantity,
        $are_we_before_or_at_process_form) = @_;
  local(@testlines,$junk1,$junk2);
  local($temp_total) = 0;
  local($grand_total) = 0;
  local($mypass,$save1,$save2,$save3,$save4,$save5,$save6,$save7,$save8);
  local($final_shipping, $shipping);
  local($final_discount, $discount);
  local($final_sales_tax, $sales_tax) = 0;
  local($final_extra_tax1, $extra_tax1) = 0;
  local($final_extra_tax2, $extra_tax2) = 0;
  local($final_extra_tax3, $extra_tax3) = 0;
  local($calc_loop) = 0;

$temp_total = $subtotal;

$max_loops=3;
&codehook("before_final_values_loop");
for (1..$max_loops) {
$shipping = 0;
$discount = 0;
$sales_tax = 0;
$extra_tax1 = 0;
$extra_tax2 = 0;
$extra_tax3 = 0;
$calc_loop = $_;
&codehook("begin_final_values_loop_iteration");
if ($are_we_before_or_at_process_form =~ /before/i)
{

if ($sc_calculate_discount_at_display_form ==
    $calc_loop) {
    $discount = 
    &calculate_discount($temp_total,
    $total_quantity,
    $total_measured_quantity);
    } # End of if discount gets calculated here

if ($sc_calculate_shipping_at_display_form ==
    $calc_loop) {
    $shipping = &define_shipping_logic($total_measured_quantity,
                $stevo_shipping_thing);
    } 

if ($sc_calculate_sales_tax_at_display_form ==
    $calc_loop) {
    $sales_tax = 
    &calculate_sales_tax($temp_total);
   } 

if ($sc_calculate_extra_tax1_at_display_form ==
    $calc_loop) {
    $extra_tax1 = 
    &calculate_extra_tax1($temp_total);
   } 

if ($sc_calculate_extra_tax2_at_display_form ==
    $calc_loop) {
    $extra_tax2 = 
    &calculate_extra_tax2($temp_total);
   } 

if ($sc_calculate_extra_tax3_at_display_form ==
    $calc_loop) {
    $extra_tax3 = 
    &calculate_extra_tax3($temp_total);
   } 

   } else {

if ($sc_calculate_discount_at_process_form ==
    $calc_loop) {
    $discount = 
    &calculate_discount($temp_total,
    $total_quantity,
    $total_measured_quantity);
    } 

if ($sc_calculate_shipping_at_process_form ==
    $calc_loop) {
    $shipping = &define_shipping_logic($total_measured_quantity,
                $stevo_shipping_thing);
   } 

if ($sc_calculate_sales_tax_at_process_form ==
    $calc_loop) {
    $sales_tax = 
    &calculate_sales_tax($temp_total);
   } 

if ($sc_calculate_extra_tax1_at_process_form ==
    $calc_loop) {
    $extra_tax1 = 
    &calculate_extra_tax1($temp_total);
   } 

if ($sc_calculate_extra_tax2_at_process_form ==
    $calc_loop) {
    $extra_tax2 = 
    &calculate_extra_tax2($temp_total);
   } 

if ($sc_calculate_extra_tax3_at_process_form ==
    $calc_loop) {
    $extra_tax3 = 
    &calculate_extra_tax3($temp_total);
   } # End of extra tax3 calculations

} 

if (!($total_quantity > 0)) {$shipping=0;}
&codehook("end_final_values_loop_iteration_before_calc");

$final_discount = $discount if ($discount > 0);
$final_shipping = $shipping if ($shipping > 0);
$final_sales_tax = $sales_tax if ($sales_tax > 0);
$final_extra_tax1 = $extra_tax1 if ($extra_tax1 > 0);
$final_extra_tax2 = $extra_tax2 if ($extra_tax2 > 0);
$final_extra_tax3 = $extra_tax3 if ($extra_tax3 > 0);
$temp_total = $temp_total - $discount + $shipping + $sales_tax 
               + $extra_tax1 + $extra_tax2 + $extra_tax3;
&codehook("end_final_values_loop_iteration_after_calc");
} 

$grand_total = $temp_total;

if ($sc_verify_inv_no eq '') {
  open(MYFILE,"$sc_verify_order_path");
  @testlines = <MYFILE>;
  close(MYFILE);
  @testlines = grep(/sc_verify_inv_no/,@testlines);
  ($junk1,$sc_verify_inv_no,$junk2) = split(/\"/,@testlines[0],3);
 }

if ($sc_verify_inv_no ne '') {
  $current_verify_inv_no = $sc_verify_inv_no;
 } else {
  $current_verify_inv_no = &generate_invoice_number;
 }
$zz_shipping_thing = $sc_shipping_thing;
$zz_shipping_thing =~ s/\|/\" . \n  \"\|/g;

if (($sc_test_repeat == 0) &&
 (($form_data{'submit_order_form_button'} ne "") ||
   ($form_data{'submit_order_form_button.x'} ne ""))) {
  open(MYFILE,">$sc_verify_order_path") ||
                &file_open_error("$sc_verify_order_path",
                "Order Form Verify File Error",__FILE__,__LINE__);
  print MYFILE "#\n#These Values were calculated for the order:\n";
  print MYFILE "\$sc_verify_ip_addr = \"$ENV{'REMOTE_ADDR'}\";\n";
  print MYFILE "\$sc_verify_shipping = ", (0+$final_shipping),";\n";
  print MYFILE "\$sc_verify_shipping_zip = \"", 
                (0+$form_data{'Ecom_ShipTo_Postal_PostalCode'}),"\";\n";
  print MYFILE "\$sc_verify_shipping_thing = \"",
		$zz_shipping_thing,"\";\n";
  print MYFILE "\$sc_verify_shipto_postal_stateprov = \"", 
                $form_data{'Ecom_ShipTo_Postal_StateProv'},"\";\n";
  print MYFILE "\$sc_verify_shipto_method = \"", 
                $form_data{'Ecom_ShipTo_Method'},"\";\n";
  print MYFILE "\$sc_verify_discount = ",(0+$final_discount),";\n";
  print MYFILE "\$sc_verify_tax = ",(0+$final_sales_tax),";\n";
  print MYFILE "\$sc_verify_etax1 = ",(0+$final_extra_tax1),";\n";
  print MYFILE "\$sc_verify_etax2 = ",(0+$final_extra_tax2),";\n";
  print MYFILE "\$sc_verify_etax3 = ",(0+$final_extra_tax3),";\n";
  print MYFILE "\$sc_verify_subtotal = ",(0+$subtotal),";\n";
  print MYFILE "\$sc_verify_grand_total = ",(0+$grand_total),";\n";
  print MYFILE "\$sc_verify_boxes_max_wt = \"",$sc_verify_boxes_max_wt,"\";\n";
  print MYFILE "\$sc_verify_Origin_ZIP = \"",$sc_verify_Origin_ZIP,"\";\n";
  print MYFILE "\$sc_verify_inv_no = \"",$current_verify_inv_no,"\";\n";
  print MYFILE "\$sc_verify_paid_by_ccard = \"",$sc_paid_by_ccard,"\";\n";

  $mypass = &make_random_chars;
  $mypass .= &make_random_chars;
  $mypass .= &make_random_chars;
  $mypass .= &make_random_chars;
  $sc_pass_used_to_scramble = $mypass;

  if ($sc_test_repeat ne 0) { 
    $form_data{'Ecom_Payment_Card_Number'} = '';
    $form_data{'Ecom_Payment_BankAcct_Number'} = '';
    $form_data{'Ecom_Payment_BankRoute_Number'} = '';
    $form_data{'Ecom_Payment_Bank_Name'} = '';
    $form_data{'Ecom_Payment_Orig_Card_Number'} = '';
   }

if ($sc_scramble_cc_info =~ /yes/i ) {
  $save1 = $form_data{'Ecom_Payment_Card_Number'};
  $form_data{'Ecom_Payment_Card_Number'} = 
	&scramble($save1,$mypass,0);
  $save2 = $form_data{'Ecom_Payment_BankAcct_Number'};
  $form_data{'Ecom_Payment_BankAcct_Number'} = 
	&scramble($save2,$mypass,0);
  $save3 = $form_data{'Ecom_Payment_BankRoute_Number'};
  $form_data{'Ecom_Payment_BankRoute_Number'} = 
	&scramble($save3,$mypass,0);
  $save4 = $form_data{'Ecom_Payment_Bank_Name'};
  $form_data{'Ecom_Payment_Bank_Name'} = 
	&scramble($save4,$mypass,0);
  $save5 = $form_data{'Ecom_Payment_Orig_Card_Number'};
  $form_data{'Ecom_Payment_Orig_Card_Number'} = 
	&scramble($save5,$mypass,0);
}

  foreach $inx (sort(keys %form_data)) {
    $value = $form_data{$inx};
    $value =~ s/\'/\"/g;
    print MYFILE "\$vform_$inx = '$value'\;\n";
    print MYFILE "\$vform{'$inx'} = '$value'\;\n";
    $value =~ s/\"/\&quot\;/g;
    print MYFILE "\$eform_$inx = '$value'\;\n";
    print MYFILE "\$eform{'$inx'} = '$value'\;\n";
    $eform_data{$inx} = $value; 
   }

if ($sc_scramble_cc_info =~ /yes/i ) {
  $form_data{'Ecom_Payment_Card_Number'} = $save1;
  $form_data{'Ecom_Payment_BankAcct_Number'} = $save2;
  $form_data{'Ecom_Payment_BankRoute_Number'} = $save3;
  $form_data{'Ecom_Payment_Bank_Name'} = $save4;
  $form_data{'Ecom_Payment_Orig_Card_Number'} = $save5;
}

  print MYFILE "1;\n";
  close(MYFILE);
}

&codehook("end_final_values");
return ($final_shipping,
        $final_discount,
        $final_sales_tax,
        $final_extra_tax1,
        $final_extra_tax2,
        $final_extra_tax3,
        &format_price($grand_total));

} 
############################################################
sub calculate_shipping {
  local($subtotal,
        $total_quantity,
        $total_measured_quantity) = @_;

  return(&calculate_general_logic(
           $subtotal,
           $total_quantity,
           $total_measured_quantity,
           *sc_shipping_logic,
           *sc_order_form_shipping_related_fields));

} 
############################################################
sub calculate_discount {
  local($subtotal,
        $total_quantity,
        $total_measured_quantity) = @_;
 
  &codehook("calculate_discount_top");
  return(&calculate_general_logic(
           $subtotal,
           $total_quantity,
           $total_measured_quantity,
           *sc_discount_logic,
           *sc_order_form_discount_related_fields));
} 
############################################################
sub calculate_general_logic {
  local($subtotal,
        $total_quantity,
        $total_measured_quantity,
        *general_logic,
        *general_related_form_fields) = @_;

  local($general_value);

  local($x, $count);
  local($logic);
  local($criteria_satisfied);
  local(@fields);

  local(@related_form_values) = ();
  
$count = 0;

foreach $x (@general_related_form_fields) {

$related_form_values [$count] = $form_data{$x};
$count++;

}

foreach $logic (@general_logic) {

$criteria_satisfied = "yes";

@fields = split(/\|/, $logic);  


    for (1..@related_form_values) {
      if (!(&compare_logic_values(
            $related_form_values[$_ - 1],
            $fields[$_ - 1]))) {
            $criteria_satisfied = "no";
      }
    } 

    for (1..@related_form_values) {
      shift(@fields);
    }


    if (!(&compare_logic_values(
          $subtotal,
          $fields[0]))) {
          $criteria_satisfied = "no";
    }
 
    shift (@fields);

    if (!(&compare_logic_values(
          $total_quantity,
          $fields[0]))) {
          $criteria_satisfied = "no";
    }
  
    shift (@fields);


    if (!(&compare_logic_values(
          $total_measured_quantity,
          $fields[0]))) {
       $criteria_satisfied = "no";
    }


    shift (@fields);


    if ($criteria_satisfied eq "yes") {

    if ($fields[0] =~ /%/) {
        $fields[0] =~ s/%//;
        $general_value = $subtotal * $fields[0] / 100;
      } else {
        $general_value = $fields[0];
      }
    }

    
  } 

  return(&format_price($general_value));

} 
############################################################
sub calculate_extra_tax1 {
  local($subtotal) = @_;
  local($extra_tax) = 0;
  if ($sc_use_tax1_logic =~ /yes/i) {
    $sc_extra_tax1_name = "Tax1" if $sc_extra_tax1_name eq "";
    $extra_tax = &eval_custom_logic($sc_extra_tax1_logic,
               "Extra Tax 1",__FILE__,__LINE__);
   }
  return (&format_price($extra_tax));
} 

sub calculate_extra_tax2 {
  local($subtotal) = @_;
  local($extra_tax) = 0;
  if ($sc_use_tax2_logic =~ /yes/i) {
    $sc_extra_tax2_name = "Tax2" if $sc_extra_tax2_name eq "";
    $extra_tax = &eval_custom_logic($sc_extra_tax2_logic,
               "Extra Tax 2",__FILE__,__LINE__);
   }
  return (&format_price($extra_tax));
} 

sub calculate_extra_tax3 {
  local($subtotal) = @_;
  local($extra_tax) = 0;
  if ($sc_use_tax1_logic =~ /yes/i) {
    $sc_extra_tax3_name = "Tax3" if $sc_extra_tax3_name eq "";
    $extra_tax = &eval_custom_logic($sc_extra_tax3_logic,
               "Extra Tax 3",__FILE__,__LINE__);
   }
  return (&format_price($extra_tax));
} 
############################################################
sub calculate_sales_tax {
  local($subtotal) = @_;
  local($sales_tax) = 0;
  local($tax_form_variable);
  local($continue)=1;
  &codehook("calc_sales_tax_top");
  if ($continue == 0) {
    return (&format_price($sales_tax));
   }

  $tax_form_variable = $form_data{$sc_sales_tax_form_variable};
  if ($tax_form_variable eq "") {
    $tax_form_variable = $vform{$sc_sales_tax_form_variable};
   }

  if ($sc_sales_tax_form_variable ne "") {
    foreach $value (@sc_sales_tax_form_values) {
      if (($value =~ 
          /^${tax_form_variable}$/i) &&
         (${tax_form_variable} ne ""))  {
        $sales_tax = $subtotal * $sc_sales_tax;
      }
    }
 
  } else {
    $sales_tax = $subtotal * $sc_sales_tax;
  }

  &codehook("calc_sales_tax_bot");
  return (&format_price($sales_tax));

} 
############################################################
sub compare_logic_values {
  local($input_value, $value_to_compare) = @_;
  local($lowrange, $highrange);

if ($value_to_compare =~ /-/) {

    ($lowrange, $highrange) = split(/-/, $value_to_compare);


    if ($lowrange eq "") {
      if ($input_value <= $highrange) {
        return(1);
      } else {
        return(0);
      }

    } elsif ($highrange eq "") {
      if ($input_value >= $lowrange) {
        return(1);
      } else {
        return(0);
      }

    } else {
      if (($input_value >= $lowrange) &&
         ($input_value <= $highrange)) {
        return(1);
      } else {
        return(0);
      }
    }

  } else {
    if (($input_value =~ /$value_to_compare/i) ||
        ($value_to_compare eq "")) {
      return(1);
    } else {
      return(0);
    }
  }
} 
############################################################
sub cart_textinfo {
 local (*cart_fields) = @_;
 local ($quantity, $product, $product_name, $options, $product_price);
 local ($inx, $result, $p_id, $title, $mydata, $display_index);
 local ($field_name, $query_result, $cart_line_id, @my_row);


 $cart_line_id 	= $cart_fields[$cart{'unique_cart_line_id'}];
 $quantity 	= $cart_fields[$cart{"quantity"}];
 $p_id 		= $cart_fields[$cart{"product_id"}];
 $product 	= $cart_fields[$cart{"product"}];
 $product_name	= $cart_fields[$cart{"name"}];
 $options 	= $cart_fields[$cart{"options"}];
 $product_price	= $cart_fields[$cart{"price"}];

 if (!($sc_db_lib_was_loaded =~ /yes/i)) 
  {
   &require_supporting_libraries(__FILE__, __LINE__,"$sc_db_lib_path");
  }
 $query_result = &check_db_with_product_id($p_id,*my_row);
 $result = '';
 $inx=0;

 $result  = "Quantity:      $quantity\nProduct:       " . $product_name .
		' (' . &display_price($product_price) . " ea.)\n";
            
 foreach $field_name (@sc_textcol_name)
  {
   $display_index = $cart{$field_name};
   $title = $sc_textcart_display_fields[$inx] . ":                   ";
   $title = substr($title,0,14) . " ";
   if ($display_index < 0) { 
     $mydata = $my_row[(0-$display_index)];
    } else { #normal, in the cart
     $mydata = &vf_get_data("CART",$field_name,$cart_line_id,@cart_fields);
    }
   if ($sc_textcart_display_factor[$inx] =~ /yes/i) {
     $mydata = $mydata * $cart_fields[$cart{"quantity"}];
    }
   if ($sc_textcart_display_format[$inx] =~ /2-Decimal/i) {
     $mydata = &format_price($mydata);
    }
   if ($sc_textcart_display_format[$inx] =~ /2-D Price/i) {
     $mydata = &display_price($mydata);
    }
   $result .= $title . $mydata . "\n";
   $inx++;
  }

 $result .= "\n";
 return $result;

}
############################################################
sub log_order {
 local ($text_of_cart,$invoice,$customer_id) = @_;
 local ($filename);

 $customer_id =~ /([\w\-\=\+\/]+)\.(\w+)/;
 $customer_id = "$1.$2";
 $invoice =~ /(\w+)/;
 $invoice = "$1";

&codehook("log_order_top");

if ($sc_send_order_to_log =~ /yes/i) {
  $filename = "./log_files/$sc_order_log_name";
  &get_file_lock("$filename.lockfile");
  open (ORDERLOG, "+>>$filename");
  print ORDERLOG "*-" x 30 . "\n";
  print ORDERLOG $text_of_cart;
  print ORDERLOG "-*" x 30 . "\n";
  close (ORDERLOG);

  ## write out individual orders
  ## open in append mode just in case order exists already
  # $filename = $sc_order_log_directory_path ."/";
  # $filename .= "${invoice}-${customer_id}";
  # &get_file_lock("$filename.lockfile");
  # open (ORDERLOG, ">>$filename");
  # print ORDERLOG "-" x 60 . "\n";
  # print ORDERLOG $text_of_cart;
  # print ORDERLOG "-" x 60 . "\n";
  # close (ORDERLOG);

  &release_file_lock("$filename.lockfile");

 }

&codehook("log_order_bot");

}
############################################################
sub decode_verify_vars {
  local($save1,$mypass);

  if (($sc_test_repeat ne 0) || 
    (($form_data{'HCODE'} eq "") && ($sc_scramble_cc_info =~ /yes/i ))) {
    $vform_Ecom_Payment_BankAcct_Number = '';
    $vform_Ecom_Payment_BankCheck_Number = '';
    $vform_Ecom_Payment_BankRoute_Number = '';
    $vform_Ecom_Payment_Bank_Name = '';
    $vform_Ecom_Payment_Card_Number = '';
    $vform_Ecom_Payment_Orig_Card_Number = '';
   } else {
    if ($sc_scramble_cc_info =~ /yes/i ) {
      $mypass = $form_data{'HCODE'};
      $save1 = $vform_Ecom_Payment_Orig_Card_Number;
      $vform_Ecom_Payment_Orig_Card_Number = 
  	&scramble($save1,$mypass,1);
      $save1 = $vform_Ecom_Payment_Card_Number;
      $vform_Ecom_Payment_Card_Number = 
	&scramble($save1,$mypass,1);
      $save1 = $vform_Ecom_Payment_BankAcct_Number;
      $vform_Ecom_Payment_BankAcct_Number = 
	&scramble($save1,$mypass,1);
      $save1 = $vform_Ecom_Payment_BankRoute_Number;
      $vform_Ecom_Payment_BankRoute_Number = 
	&scramble($save1,$mypass,1);
      $save1 = $vform_Ecom_Payment_Bank_Name;
      $vform_Ecom_Payment_Bank_Name = 
	&scramble($save1,$mypass,1);
     }
   }
  &codehook("done_verify_decode");
 }
############################################################
sub load_verify_file {
  &read_verify_file;
  &clear_verify_file;
}
############################################################
sub clear_verify_file {
  &codehook("before-clear-verify-file");
  eval("unlink  \"$sc_verify_order_path\";");
  &codehook("after-clear-verify-file");
}
############################################################
sub read_verify_file {
  local($str1,$str2,$str3);
  &codehook("before-read-verify-file");
  eval("require \"$sc_verify_order_path\";");
  &decode_verify_vars;
  &codehook("after-read-verify-file");
  $str1 = "ORDER NOTES -------------------\n\n";
  $str2 = "Order originated from IP ADDR: $sc_verify_ip_addr\n\n";
  $str3 = &format_XCOMMENTS;
  $XCOMMENTS_ADMIN = $str1 . $str2 . $str3;
  $XCOMMENTS = $str1 . $str3;
  &codehook("end-read-verify-file");
 }
############################################################
sub empty_cart {
  &codehook("before-empty-cart");
#  eval("unlink $sc_cart_path;");
  open (CART,">$sc_cart_path") || 
    &order_warn("This cart cannot be emptied --- OS permissions problem?");
  print CART "";
  close (CART);
  &codehook("after-empty-cart");
 }
############################################################
sub order_warn {
  local($str)=@_;
  print "<BR><B>$str</B><BR>\n";
 }
############################################################
sub add_text_of_cart {
 local ($name,$value) = @_;
 local ($temp);
 $temp = substr(substr($name,0,13).":               ",0,15);
 $text_of_cart .= "$temp$value\n";
}
############################################################
sub add_text_of_conf {
 local ($name,$value) = @_;
 local ($temp);
 $temp = substr(substr($name,0,13).":               ",0,15);
 $text_of_confirm_email .= "$temp$value\n";
}
############################################################
sub add_text_of_both {
 local ($name,$value) = @_;
 local ($temp);
 $temp = substr(substr($name,0,13).":               ",0,15);
 $text_of_cart .= "$temp$value\n";
 $text_of_confirm_email .= "$temp$value\n";
}
#################################################################
sub display_calculations {
local($subtotal,
      $are_we_before_or_at_process_form,
      $total_measured_quantity,
      $text_of_cart) = @_;

local($final_shipping,
	$final_discount,
	$final_sales_tax,
	$final_extra_tax1,
	$final_extra_tax2,
	$final_extra_tax3,
        $grand_total);

if ($sc_use_verify_values_for_display =~ /yes/i) {
	($sc_ship_method_shortname,$junk) = 
		split(/\(/,$sc_verify_shipto_method,2);
	($final_shipping,
	$final_discount,
	$final_sales_tax,
	$final_extra_tax1,
	$final_extra_tax2,
	$final_extra_tax3,
        $grand_total) =
	($sc_verify_shipping,$sc_verify_discount,
	$sc_verify_tax,$sc_verify_etax1,
	$sc_verify_etax2,$sc_verify_etax3,
	$sc_verify_grand_total);
 } else {
	($final_shipping,
	$final_discount,
	$final_sales_tax,
	$final_extra_tax1,
	$final_extra_tax2,
	$final_extra_tax3,
        $grand_total) =
	&calculate_final_values($subtotal,
	$total_quantity,
	$total_measured_quantity,
	$are_we_before_or_at_process_form);
}

$zsubtotal = $subtotal;
$zfinal_shipping = $final_shipping;
$zfinal_discount = $final_discount;
$zfinal_sales_tax = $final_sales_tax;
$zfinal_extra_tax1 = $final_extra_tax1;
$zfinal_extra_tax2 = $final_extra_tax2;
$zfinal_extra_tax3 = $final_extra_tax3;
$zgrand_total = $grand_total;

if ($final_shipping > 0)
{
$final_shipping = &format_price($final_shipping);
$final_shipping = &display_price($final_shipping);

$text_of_cart .= &format_text_field("Shipping:") . 
"= $final_shipping\n\n";
};

if ($final_discount > 0)
{
$final_discount = &format_price($final_discount);
$pass_final_discount = &format_price($final_discount);
$final_discount = &display_price($final_discount);

$text_of_cart .= &format_text_field("Discount:") . 
"= $final_discount\n\n";
}

if ($final_sales_tax > 0)
{
$final_sales_tax = &format_price($final_sales_tax);
$pass_final_sales_tax = &format_price($final_sales_tax);
$final_sales_tax = &display_price($final_sales_tax);

$text_of_cart .= &format_text_field("Sales Tax:") . 
"= $final_sales_tax\n\n";
}

$authPrice = $grand_total;
$grand_total = &display_price($grand_total);

&print_order_totals;

if ($are_we_before_or_at_process_form =~ /at/i) 
{
print <<ENDOFTEXT;
</FORM>
ENDOFTEXT
}

$text_of_cart .= &format_text_field("Grand Total:") . 
"= $grand_total\n\n";

return ($text_of_cart);

}
###############################################################################
sub explode {
 local ($what,*zdata) = @_;
 local ($temp,$ans,$command);

 &codehook("explode_top");
 $temp = $zdata{$what};
 $temp =~ /([\w\-\=\+\/]+)/;
 $temp = $1;
 $ans=$temp . " ";
 $command = '$ans .= $' . $what . '{"' . $temp . '"};'; 
 eval($command); 
 &codehook("explode_bot");
 return $ans;
}
####################################################################
sub format_XCOMMENTS {
 local ($str)="";
 local ($inx,$mykey,$val);
 &codehook("format_XCOMMENTS_top");
 foreach $mykey (sort(grep(/\_XCOMMENT\_/,(keys %vform)))) {
   if ($vform{$mykey} ne "") {
     ($junk,$val) = split(/\_XCOMMENT\_/,$mykey,2);
     $val =~ s/\_/\ /g;
     $str .= $val . ":\n" . $vform{$mykey} . "\n\n";
    }
  }
 &codehook("format_XCOMMENTS_bot");
 return $str;
}
####################################################################
# Copyright Steve Kneizys 11-FEB-2000, used by permission.
# This subroutine is not meant to be encryption ... it simply
# scrambles things a tad so it doesn't look like it used to
# so that prying eyes don't know what it is at a quick glance.
# This program can be written MUCH more simply, but ...
# "security through obscurity"!  Don't want to violate USA
# export restrictions ... otherwise we'd really encrypt things.
#
# Usage: &scramble($the_string,$phrase,$direction);
#
# $direction: encode with 0 then decode with 1 (or vice versa!)
# $phrase: passphrase to recover the answer
#
####################################################################
sub scramble {
  local($what,$salt,$direction) = @_;
  local ($a1,$a2);
  if ($what eq "") {return "";}
  $what = &scramble_engine($what,$salt,$direction);
  $what = &scramble_engine(reverse($what),$salt,$direction);
  return $what;
 }

sub scramble_engine {
local ($key,$mysalt,$backout) = @_;
local ($part1)="abcdefghijklmnopqrstuvwxyz";
local ($part2,$part3,$the_code,$the_ref,$ans,$ans2,$inx);
local ($val)=0;
local ($val2)=0;
local ($val3)=0;
local ($val4)=0;
local ($scramble_variable) = 25;
local ($a1,$a2,$last_char,$this_char,$rev_last_char,$rev_this_char) = "";
$part2 = $part1;
$part2 =~ tr/a-z/A-Z/;
$the_code = " 1234567890,.<>/?;:[}]{\|=+-_)(*&^%$#@!~" . $part1 . $part2;
$the_list = $the_code;
$the_ref = reverse($the_code);
$ml = length($the_code);

$mysalt .= "*";
for ($x1=1; $x1 < length($mysalt); $x1++) {
  $inx = index($the_ref,substr($mysalt,$x1,1));
  if ($inx >0) {
     $part1 = substr($mysalt,$x1,1) . substr($the_ref,0,$inx);
     $part2 = substr($the_ref,$inx+1,999);
#print $x1," ",substr($mysalt,$x1,1)," ",$inx,"\n";
#print $the_ref,"\n";
#print $part1,$part2,"\n";
     $the_ref = reverse($part1 . $part2);
    }
 }

for ($x1=1; $x1 < $scramble_variable ;$x1++) { 
  $part1 = substr($the_ref,0,10);
  $part2 = substr($the_ref,10,25);
  $part3 = substr($the_ref,35,(length($the_ref)-35));
  $the_ref = reverse($part2 . reverse($part1) . $part3);
 }

#print "code=$the_code\n";
#print " ref=$the_ref\n";

$val=0;$val2=0;$val3=0;$val4=0;

$key = reverse($key);
while ($key ne "") {  
  $inx = chop($key);
  $last_char = $this_char;
  $this_char = $inx;
#  print "inx = $inx ",ord($inx), "\n";
  if (index($the_code,$inx) >= 0) { # found in our set
#$val=0;$val2=0;$val3=0;$val4=0;
    $val = index($the_code,$inx) + $val;
    $val3 = index($the_ref,$inx);
    $val2 = $val3 - $val4;
    $val4 = $val3;
    while ($val2 < 0) {
      $val2 = $val2 + length($the_ref);
     }
    while ($val >= length($the_ref)) {
      $val = $val - length($the_ref);
     }
 #   print "val,val2 = $val, $val2\n";
    $ans .= substr($the_code,$val2,1);
    $ans2 .= substr($the_ref,$val,1);
   } else {
    $ans .= $inx;
    $ans2 .= $inx;
   } 
 }
#print "ans = $ans    ans2 = $ans2 \n";
 if ($backout == "1") {
   return $ans2;
  } else {
   return $ans;
  } 
}
#######################################################################
sub output_modify_quantity_form {

&standard_page_header("Change Quantity");
&display_cart_table("changequantity");
&modify_form_footer;
}
#######################################################################
sub modify_quantity_of_items_in_cart {

&checkReferrer;
@incoming_data = keys (%form_data);

foreach $key (@incoming_data)
{
if (($key =~ /[\d]/) && ($form_data{$key} =~ /\D/) && 
(!($form_data{$key} < 0)) && (!($form_data{$key} > 0)))
{
$form_data{$key}="";
}

unless ($key =~ /[\D]/ && $form_data{$key} =~ /[\D]/)
{
	if ($form_data{$key} ne "")
	{
	push (@modify_items, $key);
	}
}

}

open (CART, "<$sc_cart_path") || &file_open_error("$sc_cart_path", "Modify Quantity of Items in the Cart", __FILE__, __LINE__);

while (<CART>)
{
@database_row = split (/\|/, $_);
$cart_row_number = pop (@database_row);
push (@database_row, $cart_row_number);
$old_quantity = shift (@database_row);
chop $cart_row_number;
 
foreach $item (@modify_items)
{

if ($item eq $cart_row_number)
{

if ($form_data{$item} =~ /\-/) {
  $form_data{$item} =~ s/\-//g;
  $form_data{$item} = 0 - $form_data{$item};
 }  
if (($form_data{$item} < 0) || ($form_data{$item} =~ /\+/)) {
  &codehook("item_quantity_to_be_modified");
  $form_data{$item} =~ s/\+//g;
  $form_data{$item} = $old_quantity + $form_data{$item};
 }
$form_data{$item} = 0 + $form_data{$item};
if ($form_data{$item} le 0) {
  $shopper_row .= "\|"; 
 } else {
  $shopper_row .= "$form_data{$item}\|";

  foreach $field (@database_row)
  {
  $shopper_row .= "$field\|";
  }
 }

$quantity_modified = "yes";
&codehook("item_quantity_modified");
chop $shopper_row; 

}


}

if ($quantity_modified ne "yes")
{
$shopper_row .= $_;
}

$quantity_modified = "";

}

close (CART);

open (CART, ">$sc_cart_path") || &file_open_error("$sc_cart_path", "Modify Quantity of Items in the Cart", __FILE__, __LINE__);

print CART "$shopper_row";

close (CART);

&update_special_variable_options('calculate');

&codehook("modify_quantity_of_items_in_cart_bot");

&finish_modify_quantity_of_items_in_cart;

}
#######################################################################
sub finish_modify_quantity_of_items_in_cart {
 &codehook("finish_modify_quantity_of_items_in_cart");
 &display_cart_contents;
}
#######################################################################
sub output_delete_item_form {

&standard_page_header("Delete Item");
&display_cart_table("delete");
&delete_form_footer;

}
#######################################################################
sub delete_from_cart {

&checkReferrer;

@incoming_data = keys (%form_data);
foreach $key (@incoming_data)
{

unless ($key =~ /[\D]/)
{
if ($form_data{$key} ne "")
{
push (@delete_items, $key);
}

}

}

open (CART, "<$sc_cart_path") || &file_open_error("$sc_cart_path", "Delete Item From Cart", __FILE__, __LINE__);

while (<CART>)
{
@database_row = split (/\|/, $_);
$cart_row_number = pop (@database_row);
$db_id_number = pop (@database_row);
push (@database_row, $db_id_number);
push (@database_row, $cart_row_number);
chop $cart_row_number;
$old_quantity = shift (@database_row);

$delete_item = "";
foreach $item (@delete_items)
{

if ($item eq $cart_row_number)
{
$delete_item = "yes";
&codehook("mark_item_for_delete");
}

# End of foreach $item (@add_items)
}

if ($delete_item ne "yes")
{
$shopper_row .= $_;
}

# End of while (<CART>)
}

close (CART);

open (CART, ">$sc_cart_path") || &file_open_error("$sc_cart_path", "Delete Item From Cart", __FILE__, __LINE__);

print CART "$shopper_row";
close (CART);

&finish_delete_from_cart;

}
#######################################################################
sub finish_delete_from_cart {
  &codehook("finish_delete_from_cart");
  &display_cart_contents;
}
#######################################################################   
sub display_cart_contents {
local ($my_gt,$my_tq,$tmq,$tc,$st) = "";

local (@cart_fields);
local ($field, $cart_id_number, $quantity, $display_number,
$unformatted_subtotal, $subtotal, $unformatted_grand_total,
$grand_total);

$sc_special_page_meta_tags = "\n";
$sc_special_page_meta_tags .= '<META HTTP-EQUIV="Cache-Control"' . 
                              ' Content="no-cache">';
$sc_special_page_meta_tags .= "\n";
$sc_special_page_meta_tags .= '<META HTTP-EQUIV="Pragma"' . 
                              ' Content="no-cache">';
$sc_special_page_meta_tags .= "\n";
&standard_page_header("View/Modify Cart"); 
   
($my_gt,$my_tq,$tmq,$tc,$st) = &display_cart_table("");

&cart_footer((0+$my_gt),(0+$my_tq));
&call_exit;

}
#######################################################################
sub cart_table_header {
local ($modify_type) = @_;

&codehook("cart_table_header_top");

if ($modify_type ne "") {
  $modify_type = "<TH $cart_heading_def>" . 
               "$cart_font_style\&nbsp\;$modify_type\&nbsp\;</FONT></TH>";
  &codehook("display_cart_heading_modify_item");
 }

if (($sc_use_secure_header_at_checkout =~ /yes/i) && 
	(($reason_to_display_cart =~ /orderform/i) || 
	 ($reason_to_display_cart =~ /verify/i))) {
  &SecureStoreHeader;
 } else {
  &StoreHeader;
 }

$hidden_fields = &make_hidden_fields;
&codehook("cart_table_header");

if ($special_message ne "") {
  print $special_message;
 }

print qq~

<CENTER>
<FORM METHOD="POST" ACTION="$sc_main_script_url">
$hidden_fields

<TABLE $cart_table_def>
<TR>
$cart_font_style
$modify_type
~;

foreach $field (@sc_cart_display_fields)
{
$cart_heading_item = 
"<TH $cart_heading_def>$cart_font_style&nbsp;$field&nbsp;</FONT></TH>\n";
&codehook("display_cart_heading_item");
print $cart_heading_item;
}

}
#######################################################################
sub display_cart_table {

local($reason_to_display_cart) = @_;
local(@cart_fields);
local($cart_id_number,$cart_line_id,$field_name);
local($quantity);
local($unformatted_subtotal);
local($subtotal);
local($unformatted_grand_total);
local($grand_total);
local($stevo_shipping_thing,$temp) = "";
local($price);
local($test_price);
local($text_of_cart);
local($total_quantity) = 0;
local($total_measured_quantity) = 0;
local($display_index);
local($counter);
local($display_me,$found_it);
local($hidden_field_name);
local($hidden_field_value);
local($display_counter);
local($product_id, @db_row);

&codehook("display_cart_top");

if ($reason_to_display_cart =~ /change*quantity/i) 
{
&cart_table_header("New Quantity");
} 

elsif ($reason_to_display_cart =~ /delete/i) 
{
&cart_table_header("Delete Item");
} 

else 
{
&cart_table_header("");
}

if (!(-f "$sc_cart_path")) { 
  open (CART, ">$sc_cart_path") ||
       &file_open_error("$sc_cart_path", 
			"display_cart_contents create null file", 
			__FILE__, __LINE__);
  close(CART);
 }
open (CART, "$sc_cart_path") ||
&file_open_error("$sc_cart_path", "display_cart_contents", __FILE__, __LINE__);

while (<CART>)
{

print "<TR>";	

chop;    

$temp = $_;
@cart_fields = split (/\|/, $temp);
$cart_row_number = pop(@cart_fields);
push (@cart_fields, $cart_row_number);
$cart_copy{$cart_row_number} = $temp;
&codehook("display_cart_row_read");

$quantity 	= $cart_fields[$cart{"quantity"}];
$product_id 	= $cart_fields[$cart{"product_id"}];

#if (($reason_to_display_cart =~ /orderform/i) && ($sc_order_check_db =~ /yes/i)) 

if (!($sc_db_lib_was_loaded =~ /yes/i)) {
  &require_supporting_libraries (__FILE__, __LINE__, "$sc_db_lib_path");
 }

undef(@db_row);
$found_it = &check_db_with_product_id($product_id,*db_row); 
&codehook("display_cart_db_row_read");

$item_agorascript = "";

foreach $zzzitem (@db_row) {
  $field = $zzzitem;
  if ($field =~ /^%%OPTION%%/i) {
    ($empty, $option_tag, $option_location) = split (/%%/, $field);

    $field = &load_opt_file($option_location);

    $item_agorascript .= $field;

   }
 }
&codehook("display_cart_item_agorascript");
$zzfield = &agorascript($item_agorascript,"display-cart",
		"$product_id",__FILE__,__LINE__);
 
#  if (($reason_to_display_cart =~ /process.*order/i)...
if (($reason_to_display_cart =~ /orderform/i) 
   && ($sc_order_check_db =~ /yes/i)) {
if (!($found_it)) 
 {

print qq~
</TR>
</TABLE>

<DIV ALIGN=CENTER>
<TABLE WIDTH=400>
<TR>
<TD>
&nbsp;
</TD>
</TR>
<TR>
<TD>
<P>
<FONT FACE=ARIAL>
I'm sorry, Product ID: $product_id was not found in 
the database. Your order cannot be processed without 
this validation. Please contact the 
<a href=mailto:$sc_admin_email>site administrator</a>.
</FONT>
</TD>
</TR>
</TABLE>
</DIV>

</BODY>
</HTML>~;
&call_exit;

 } 

else 

 {

#	if ($db_row[$sc_db_index_of_price] ne $cart_fields[$sc_cart_index_of_price]) 
	$test_price =  &vf_get_data("PRODUCT",
		$sc_db_price_field_name,
		$db_row[$sc_db_index_of_product_id],
		@db_row);
	if ($test_price ne $cart_fields[$sc_cart_index_of_price]) 
	{
	print qq~
	</TR>
	</TABLE>
	<DIV ALIGN=CENTER>
	<TABLE WIDTH=500>
	<TR>
	<TD>
	<P>
	<FONT FACE=ARIAL>
	Price for product id:$product_id did not match
	database! Your order will NOT be processed without 
	this validation!
	</TD>
	</TR>
	</TABLE>
	</DIV>
	</BODY>
	</HTML>~; 
	&call_exit;
	}
 }

}

$total_quantity += $quantity;

if ($reason_to_display_cart =~ /change*quantity/i) 
{
print qq!
<TD $cart_item_def>
<INPUT TYPE = "text" NAME = "$cart_row_number" SIZE ="3">
</TD>!;
} 

elsif ($reason_to_display_cart =~ /delete/i) 
{
print qq!
<TD $cart_item_def>
<INPUT TYPE = "checkbox" NAME = "$cart_row_number">!;
}

$display_counter = 0;
$text_of_cart .= "\n\n";

foreach $field_name (@sc_col_name)
{ 

 $display_index = $cart{$field_name};
 $cart_line_id = $cart_fields[$cart{'unique_cart_line_id'}];

if ($display_index >= 0) {
 if ($cart_fields[$display_index] eq "")
 {

  $text_of_cart .= &format_text_field(
  $sc_cart_display_fields[$display_counter]) .
  "= nothing entered\n";
  $cart_fields[$display_index] = "&nbsp;";
 }       

 $display_me = &vf_get_data("CART",$field_name,$cart_line_id,@cart_fields);
 if ($sc_cart_display_factor[$display_counter] =~ /yes/i) {
   $display_me = $display_me * $quantity;
  }

 }

$sc_display_special_request = 0;
$zzfield = &agorascript($item_agorascript,"display-cart-" . $display_index,
		"$product_id",__FILE__,__LINE__);
&codehook("cart_table_special_request_decision");
if (!($sc_display_special_request == 0)) {
  &codehook("cart_table_special_request");
 }
#elsif ($display_index == 0) {}
elsif ($field_name eq "quantity") {
  if (($reason_to_display_cart ne "") || 
#  if (($reason_to_display_cart =~ /change*quantity/i) || 
#      ($reason_to_display_cart =~ /delete/i) ||
     (!($sc_qty_box_on_cart_display =~ /yes/i))) {
    print qq!<TD $cart_item_def>$cart_font_style$display_me</FONT></TD>\n!;
   } else {
    print qq!
<TD $cart_item_def>
<INPUT TYPE = "text" NAME = "$cart_row_number" VALUE = "$display_me"
SIZE ="3">
</TD>!;
   } 
 }

elsif ($display_index == $sc_cart_index_of_price)
{
$price = &display_price($display_me); 
print qq!<TD $cart_item_def>$cart_font_style$price</FONT></TD>\n!;
$text_of_cart .= &format_text_field(
$sc_cart_display_fields[$display_counter]) .
"= $price\n";
}

elsif ($display_index == $sc_cart_index_of_price_after_options)
{
#$lineTotal = &format_price(($quantity*$cart_fields[$display_index])+
# ($cart_fields[0]*$cart_fields[6]));
$lineTotal = &format_price($display_me);
$lineTotal = &display_price($lineTotal);
print qq!<TD $cart_item_def>$cart_font_style$lineTotal</FONT></TD>\n!;
$text_of_cart .= &format_text_field(
$sc_cart_display_fields[$display_counter]) .
"= $lineTotal\n";
}

elsif ($display_index < 0) 
{
$display_me = $db_row[(0-$display_index)];
if ($sc_cart_display_factor[$display_counter] =~ /yes/i) {
  $display_me = $display_me * $quantity; 
 }
if ($display_me =~ /^%%img%%/i)
{
($empty, $image_tag, $image_location) = split (/%%/, $display_me);
$display_me = '<IMG SRC="' . "$URL_of_images_directory/$image_location" . 
              '" BORDER=0>';
}
 if($display_index == "-6") {
   if ($sc_use_SBW =~ /yes/i) {
     $display_me = $display_me; 
    } else { # display total price
     $display_me = &display_price($display_me);
    }
 }
$display_me =~ s/%%URLofImages%%/$URL_of_images_directory/g;
print qq!<TD $cart_item_def>$cart_font_style$display_me</FONT></TD>\n!;
}

elsif ($display_index == $sc_cart_index_of_image)
{
$display_me = $cart_fields[$display_index];
$display_me =~ s/%%URLofImages%%/$URL_of_images_directory/g;
print qq!<TD $cart_item_def>$cart_font_style$display_me</FONT></TD>\n!;
}

elsif ($display_index == $sc_cart_index_of_measured_value)
{
if ($sc_use_SBW =~ /yes/i) { #display total pounds
  $shipping_price = $display_me; 
 } else { # display total price

if ($sc_use_SBW2 =~ /yes/i) {
  $shipping_price = $display_me;
 } else {
  $shipping_price = &display_price($display_me); 
   }
 }
print qq!
<TD $cart_item_def>$cart_font_style$shipping_price</FONT></TD>\n
!;
$text_of_cart .= &format_text_field($sc_cart_display_fields[$display_counter]) .
"= $price\n
";
}

else
{
print qq!<TD $cart_item_def>$cart_font_style$display_me</FONT></TD>\n!;

	if ($display_index != 5)
	{
	$text_of_cart .= &format_text_field(
	$sc_cart_display_fields[$display_counter]) .
	"= $cart_fields[$display_index]\n";
	}

}

$display_counter++;

}

$total_measured_quantity += ($quantity*$cart_fields[6]);  
$shipping_total = $total_measured_quantity;
$stevo_shipping_thing .= '|' . $quantity . '*' . $cart_fields[6] 
	. '*' . $cart_fields[$sc_cart_index_of_price_after_options];

$unformatted_subtotal = ($cart_fields[$sc_cart_index_of_price_after_options]);
$subtotal = &format_price($quantity*$unformatted_subtotal);
$unformatted_grand_total = $grand_total + $subtotal;
$grand_total = &format_price($unformatted_grand_total);
                
$price = &display_price($subtotal);

$text_of_cart .= &format_text_field("Quantity") .
"= $quantity\n";

$text_of_cart .= &format_text_field("Subtotal For Item") .
"= $price\n";

}

close (CART);
$sc_shipping_thing = $shipping_total . $stevo_shipping_thing;

$sc_cart_copy_made = "yes";

$price = &display_price($grand_total);

$shipping_total = &display_price($shipping_total);

if ($reason_to_display_cart =~ /verify/i) 
{
print <<ENDOFTEXT;
<INPUT TYPE=HIDDEN NAME=TOTAL VALUE=$grand_total>

ENDOFTEXT
}

&cart_table_footer($price);

if ($reason_to_display_cart =~ /verify/i)
{
&display_calculations($grand_total,"at",
$total_measured_quantity,$text_of_cart,$stevo_shipping_thing);
}
else
{
#&display_calculations($grand_total,"change/delete",
&display_calculations($grand_total,"before",
$total_measured_quantity,$text_of_cart,$stevo_shipping_thing);
}

$text_of_cart .= "\n\n" . &format_text_field("Subtotal:") .
"= $price\n\n";

return($grand_total, $total_quantity, $total_measured_quantity,
$text_of_cart, $stevo_shipping_thing);

}
#######################################################################
sub cart_table_footer {
local($price, $shipping_total) = @_;
local($footer);
$footer = qq~
</TABLE>
~;
&codehook("cart_table_footer");
print $footer;

}
#######################################################################
sub generate_invoice_number {
  local ($invoice_number)='';
  &codehook("generate_invoice_number");
  if ($invoice_number eq '') {
    $invoice_number = time;
   }
  return $invoice_number;
 }
#######################################################################
sub init_shop_keep_email {
 local ($email)='';
 &codehook("init_shop_keep_email");
 return $email;
}
#######################################################################
sub addto_shop_keep_email {
local ($email)='';
 &codehook("addto_shop_keep_email");
 return $email;
}
#######################################################################
sub init_customer_email {
 local ($email)='';
 &codehook("init_customer_email");
 return $email;
}
#######################################################################
sub addto_customer_email {
 local ($email)='';
 &codehook("addto_customer_email");
 return $email;
}
#######################################################################
1;
