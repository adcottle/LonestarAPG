## This file contains the user specific variables
## necessary for AgoraCart to operate

#:#:#: start CART settings
sub init_cart_settings {
@sc_cart_index_for_display = (
    $cart{"quantity"}
    ,$cart{"db_user1"}
    ,$cart{"name"}
    ,$cart{"web_options"}
    ,$cart{"shipping"}
    ,$cart{"price_after_options"}
    );
$sc_cart_display_str = 'Qty|Picture|Product|Options|Shipping Wt.<br>(lbs)|Cost';
@sc_cart_display_fields = split(/\|/,$sc_cart_display_str);
$sc_cart_display_col = 'quantity|db_user1|name|web_options|shipping|price_after_options';
@sc_col_name = split(/\|/,$sc_cart_display_col);
$sc_cart_display_fact = 'no|no|no|no|yes|yes';
@sc_cart_display_factor = split(/\|/,$sc_cart_display_fact);
$sc_cart_display_form = 'no|no|no|no|yes|yes';
@sc_cart_display_format = split(/\|/,$sc_cart_display_form);
@sc_textcart_index_for_display = (
    $cart{"email_options"}
    ,$cart{"price_after_options"}
    ,$cart{"price_after_options"}
    ,$cart{"shipping"}
    ,$cart{"shipping"}
    );
$sc_textcart_display_str = 'Options|Cost (each)|Item Subtotal|Wt. each|Total Wt.';
@sc_textcart_display_fields = split(/\|/,$sc_textcart_display_str);
$sc_textcart_display_col = 'email_options|price_after_options|price_after_options|shipping|shipping';
@sc_textcol_name = split(/\|/,$sc_textcart_display_col);
$sc_textcart_display_fact = 'no|no|yes|no|yes';
@sc_textcart_display_factor = split(/\|/,$sc_textcart_display_fact);
$sc_textcart_display_form = 'none|2-D Price|2-D Price|none|none';
@sc_textcart_display_format = split(/\|/,$sc_textcart_display_form);
}
if ($main_program_running =~ /yes/i) {
&add_codehook("after_loading_setup_db","init_cart_settings");
} else {
&init_cart_settings;
}
#:#:#: end CART settings
#:#:#: start FREEFORMLOGIC settings
$mc_free_form_logic_row_count = "25";
$sc_free_form_logic = "
# This gets executed after the agora.setup.db file is loaded
# by agora.cgi ... You can set 'html thingies', load libraries, etc.
#
# auto-load the database library ... need to do this for flexdbm
#&require_supporting_libraries(__FILE__,__LINE__,\"\$sc_db_lib_path\");

# Turn discount logic on for our 'form' variable
\$sc_calculate_discount_at_display_form = 1;
\$sc_calculate_discount_at_process_form = 1;
\@sc_order_form_discount_related_fields =
 ('cinfo_discount');

# define relationship of code to discount percentage
\@sc_discount_logic =
 (\"0||||0%\",
  \"1||||10%\",
  \"2||||20%\",
  \"3||||30%\",
  \"4||||40%\");

# define the minimum order amounts for codes 0,1,2,3,4
\@sc_dcode_min_amt = ('',50,100,175,250);

# Allow for master logon for the customer information
\$sc_master_cinfo_password = 'wonderful';
";
#
$sc_free_form_logic_too = "";
#
if ($main_program_running =~ /yes/i) {
  &add_codehook("after_loading_setup_db","run_freeform_logic");
  &add_codehook("pre_header_navigation","run_freeform_logic");
  &add_codehook("open_for_business","run_freeform_logic_too");
 }
$sc_free_form_logic_done = 0;
sub run_freeform_logic {
  local($f)=__FILE__;
  local($l)=__LINE__;
  if ($sc_free_form_logic_done) {return '';}
  $sc_free_form_logic_done = 1;
  eval($sc_free_form_logic);
  if ($@ ne "") {
    &update_error_log("Free Form Logic err: $@",$f,$l);
    open(ERROR, $error_page);
    while (<ERROR>) { print $_; }
    close (ERROR);
    &call_exit;
   }
 }
sub run_freeform_logic_too {
  local($f)=__FILE__;
  local($l)=__LINE__;
  eval($sc_free_form_logic_too);
  if ($@ ne "") {
    &update_error_log("Free Form Too Logic err: $@",$f,$l);
    open(ERROR, $error_page);
    while (<ERROR>) { print $_; }
    close (ERROR);
    &call_exit;
   }
 }
#:#:#: end FREEFORMLOGIC settings
#:#:#: start LAYOUT settings
$layout_store_page_font_color = "#000000";
$layout_store_page_linkfont_color = "#0000FF";
$layout_store_page_vlinkfont_color = "#0000FF";
$layout_store_page_bgcolor = "#FFFFFF";
$layout_store_page_bgimage = "";
$sc_standard_body_info = 'BORDER=#000000 Link=#0000FF vlink=#0000FF BGCOLOR="#FFFFFF"';
$layout_store_productpage_width = "550";
$sc_product_display_header = qq!<CENTER><TABLE BORDER=0 WIDTH=550>!;
$layout_store_productpage_thanks_size = "2";
$layout_store_productpage_thanks_color = "#FF0000";
$layout_store_productpage_thanks_font = "";
$layout_store_productpage_thanks_mess = "Thank you, your selection has been added to your order.";
$sc_item_ordered_message = '<TR><TD COLSPAN=3><CENTER><FONT FACE="Arial" SIZE=2 COLOR=#FF0000>Thank you, your selection has been added to your order.</FONT></CENTER></TD></TR>';
$layout_store_cart_table_border = "1";
$layout_store_cart_table_cellpadding = "4";
$layout_store_cart_table_cellspacing = "0";
$layout_store_cart_table_bgcolor = "#E8FFF8";
$cart_table_def = 'BORDER=1 CELLPADDING=4 CELLSPACING=0 BGCOLOR="#E8FFF8"';
$layout_store_cart_table_header_bgcolor = "#FFE0E0";
$cart_heading_def = 'BGCOLOR="#FFE0E0"';
$layout_store_order_table_border = "0";
$layout_store_order_table_cellpadding = "2";
$layout_store_order_table_cellspacing = "0";
$layout_store_order_table_bgcolor = "#F0F5FF";
$order_table_def = 'BORDER=0 CELLPADDING=2 CELLSPACING=0 BGCOLOR="#F0F5FF"';
$layout_store_order_table_header_bgcolor = "#E0E5FF";
$order_heading_def = 'align=center colspan=2 BGCOLOR="#E0E5FF"';
$sc_totals_table_ship_label = " Shipping";
$sc_totals_table_disc_label = "Discount";
$sc_totals_table_stax_label = "Sales Tax";
$sc_totals_table_gtot_label = "Grand Total";
$sc_totals_table_itot_label = "Item Cost Subtotal";
$sc_totals_table_thdr_label = "Order Totals";
$layout_store_font_style = "Arial";
$layout_store_font_size = "2";
$layout_store_font_color = "#000000";
$cart_font_style = '<FONT FACE="Arial" SIZE=2 color="#000000">';
$layout_store_font_style2 = "arial";
$layout_store_font_size2 = "2";
$layout_store_font_color2 = "#000000";
$cartnum_font_style = '<FONT FACE="arial" SIZE=2 color="#000000">';
#:#:#: end LAYOUT settings
#:#:#: start MAIN settings
$sc_set_0077_umask = 'no';
$original_umask = umask;
$sc_allow_ofn_choice = "no";
$sc_gateway_name = "Offline";
$sc_database_lib = "agora_db_lib.pl";
$sc_prod_db_pad_length = "5";
$sc_money_symbol = '$';
$sc_money_symbol_placement = "front";
$sc_http_affilliate_call = 'http';
$sc_affiliate_image_call = '';
$sc_send_order_to_email = "yes";
$sc_second_send_order_to_email = "no";
$sc_order_log_name = "your_order.log";
$sc_send_order_to_log = "yes";
$sc_order_email = 'lones6@lonestarapg.com';
$sc_first_order_email = 'lones6@lonestarapg.com';
$sc_second_order_email = 'sales2@yourdomain.com';
$sc_store_url = "http://lonestarapg.com/agora/agora.cgi";
$sc_ssl_location_url2 = "";
$sc_stepone_order_script_url = "";
$sc_admin_email = 'lones6@lonestarapg.com';
$sc_domain_name_for_cookie = "lonestarapg.com";
$sc_path_for_cookie = "/agora";
$sc_self_serve_images = "Yes";
$URL_of_images_directory = "picserve.cgi?picserve=";
$sc_path_of_images_directory =  "html/images";
$sc_db_max_rows_returned = "10";
$sc_order_check_db = "yes";
$sc_use_html_product_pages = "maybe";
$sc_should_i_display_cart_after_purchase = "no";
$sc_scramble_cc_info = "yes";
#:#:#: end MAIN settings
#:#:#: start PGP settings
$sc_use_pgp = "no";
$sc_pgp_change_newline = "";
$sc_pgp_or_gpg = "PGP";
$sc_pgp_or_gpg_path = "";
$sc_pgp_order_email = 'lones6@lonestarapg.com';
#:#:#: end PGP settings
#:#:#: start SHIPPING settings
$sc_calculate_shipping_loop = "3";
$sc_handling_charge = "2.00";
$sc_add_handling_cost_if_shipping_is_zero = 'no';
$sc_use_custom_shipping_logic = "no";
$sc_custom_shipping_logic = qq`# In this example Shipping Cost is based on the total order.
# \$1-\$29.99 is 10%, \$30-\$59.99 is 7.5%, etc. (TURN OFF UPS!)
# Code does not force exit, so handling charge will be added!
\@sc_shipping_logic = ( \"|1-29.99|||10.0%\",
                       \"|30-59.99|||7.5%\",
                       \"|60-89.99|||5.0%\",
                       \"|90-119.99|||2.5%\",
                       \"|120-|||0.00\");
#
\$shipping_price = &calculate_shipping(\$temp_total,
                  \$total_quantity, \$total_measured_quantity);`;
#
$sc_use_SBW = "no"; # "yes";
$sc_use_FEDEX = "yes";
$sc_use_UPS = "yes";
$sc_use_USPS = "yes";
$sc_use_socket = "http-lib";
$sc_FEDEX_max_wt = "49";
$sc_FEDEX_Origin_ZIP = "19022";
$sc_UPS_max_wt = "0";
$sc_UPS_Origin_ZIP = "19022";
$sc_UPS_RateChart = "Regular Daily Pickup";
$sc_USPS_max_wt = "49";
$sc_USPS_Origin_ZIP = "19022";
$sc_USPS_use_API = "";
$sc_USPS_userid = "uspsuserid";
$sc_USPS_password = "uspspass";
$sc_USPS_host_URL = "http://production.shippingapis.com/ShippingAPI.dll";
#:#:#: end SHIPPING settings
#:#:#: start TAX settings
$mc_tax_logic_rows = "3";
$sc_sales_tax = ".043";
$sc_sales_tax_state = "CO";
$sc_use_tax1_logic = "no";
$sc_use_tax2_logic = "no";
$sc_use_tax3_logic = "no";
$sc_extra_tax1_name = "City Tax";
$sc_extra_tax2_name = "";
$sc_extra_tax3_name = "";
$sc_extra_tax1_logic = qq`\$sc_city_tax_variable = \"Ecom_ShipTo_Postal_City\";
\$city_variable = \$form_data{\$sc_city_tax_variable};
if (\$city_variable =~ /Louisville/i) { # replace city name with yours
\$city_tax = (\$subtotal *0.14525);  # replace decimal values with your tax amount
                 }`;
$sc_extra_tax2_logic = qq``;
$sc_extra_tax3_logic = qq``;
#:#:#: end TAX settings
#
1;
