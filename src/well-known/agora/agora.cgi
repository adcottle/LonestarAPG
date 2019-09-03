#!/usr/bin/perl -T

$versions{'agora.cgi'} = "4.0K-4b Standard" . $ENV{"AGORAWRAP"};
$versions{'perl'} = "$]";
$versions{'OSNAME'} = "$^O";
$versions{'server'} = $ENV{'SERVER_SOFTWARE'} if $ENV{'SERVER_SOFTWARE'};

# Version history is available at... 
# http://www.agoracart.com/
#
# AgoraCart is based on Selena Sol's freeware 'Web Store' 
# available at http://www.extropia.com with many modifications 
# made independently by Carey Internet Services before splitting 
# off and becoming this package known as AgoraCart (aka agora.cgi).
# The package distributed here is Copyright 2002-2003 by K-Factor
# Technologies, Inc. at AgoraCart.com with additional Copyrights 1999-2001
# by Steven P. Kneizys and is distributed free of charge
# consistent with the GNU General Public License Version 2
# dated June 1991.
#
# This program is free software that you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# Version 2 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# Pursuant to the License Agreement, this copyright notice may not be
# removed or altered in any way.
#

$| = 1;
$ENV{"PATH"} = "/bin:/usr/bin";
$test=`whoami`;
$versions{'whoami'} = $test if $test;
$versions{'id'} = `id`;

if ((-f "./wrap_agc.o") && (!($ARGV[0] =~ /nowrap/i))) { # use wrapper
  $ENV{"AGORAWRAP"}="*";
  print `./wrap_agc.o`;
  &call_exit;
 }

$time = time;
$main_program_running = "yes";
push(@INC,"./library/additions");
&require_supporting_libraries (__FILE__, __LINE__,
		"./admin_files/agora_user_lib.pl",
		"./library/cgi-lib.pl");

&read_and_parse_form_data;

&require_supporting_libraries (__FILE__, __LINE__,
		"./library/agora.setup.db");
&codehook("after_loading_setup_db");

&require_supporting_libraries (__FILE__, __LINE__,
		"./admin_files/$sc_gateway_name-user_lib.pl",
		"$sc_html_setup_file_path", 
		"$sc_cookie_lib");

$sc_loading_primary_gateway = "yes";
&require_supporting_libraries(__FILE__,__LINE__,"$sc_process_order_lib_path");
$sc_loading_primary_gateway = "no";

&codehook("before_loading_custom_libs");
opendir (USER_LIBS, "./custom") || &codehook("cannot-open-custom-dir");
@mylibs = sort(readdir(USER_LIBS));
closedir (USER_LIBS);

foreach $zlib (@mylibs) {
  $lib = $zlib;
  $lib =~ /([\w\-\=\+]+)(\.pl)/i;
  $zfile = "$1$2";
  $zlib =~ /([^\n|;]+)/;
  $lib = $1;
  if ((-f "./custom/$lib") && ($lib eq $zfile)) {
    &require_supporting_libraries(__FILE__, __LINE__,"./custom/$lib");
   }
 }
&codehook("after_loading_custom_libs");

&get_cookie;
&alias_and_override;
&error_check_form_data;
$cart_id = $form_data{'cart_id'};

if ($cookie{'cart_id'} eq "" && $form_data{'cart_id'} eq "") {
  &delete_old_carts;
  &assign_a_unique_shopping_cart_id;
  $cart_id_history .= "set new cart value "; 
  &codehook("got_a_new_cart");
 } else {
  if ($form_data{'cart_id'} eq "") {
    $cart_id = $cookie{'cart_id'};
    $cart_id_history .= "from cookie "; 
    &set_sc_cart_path;
   } else {
    $cart_id = $form_data{'cart_id'};
    $cart_id_history .= "set from form data "; 
    &set_sc_cart_path;
   }
 }

&codehook("pre_header_navigation");
print $sc_browser_header;
$sc_header_printed = 1;

#print "cart_id: $cart_id $cart_id_for_html $cart_id_history<br>\n";
$are_any_query_fields_filled_in = "no";
&codehook("open_for_business");
foreach $query_field (@sc_db_query_criteria)
{
@criteria = split(/\|/, $query_field);

	if ($form_data{$criteria[0]} ne "")
	{
	$are_any_query_fields_filled_in = "yes";
	}
}

if (($search_request ne "") && ($are_any_query_fields_filled_in eq "no")) {
  $page = "searchpage.html"; 
  $search_request = "";
  if (!(-f "$sc_html_product_directory_path/$page")){ 
    $page = "";
    $form_data{'product'} = "."; # show everything    
    $are_any_query_fields_filled_in = "yes";
   } else {
    $form_data{'page'} = $page; 
   }
 }

&codehook("special_navigation");

if (&form_check('display_cart')) 
{
&load_order_lib;
&display_cart_contents;
&call_exit;
}

if (&form_check('add_to_cart_button'))
{
&load_order_lib;
&add_to_the_cart;
&call_exit;
}

elsif (&form_check('modify_cart_button'))
{
&load_order_lib;
&display_cart_contents;
&call_exit;
}

elsif (&form_check('change_quantity_button'))
{
&load_order_lib;
&output_modify_quantity_form;
&call_exit;
}

elsif (&form_check('submit_change_quantity_button'))
{
&load_order_lib;
&modify_quantity_of_items_in_cart;
&call_exit;
}

elsif (&form_check('delete_item_button'))
{
&load_order_lib;
&output_delete_item_form;
&call_exit;
}

elsif (&form_check('submit_deletion_button'))
{   
&load_order_lib;
&delete_from_cart;
&call_exit;
}

elsif (&form_check('order_form_button'))
{
&load_order_lib;
&display_order_form;
&call_exit;
}

elsif (&form_check('clear_order_form_button'))
{
&load_order_lib;
&clear_verify_file;
&codehook("display_cleared_order_form");
&display_order_form;
&call_exit;
}

elsif (&form_check('submit_order_form_button')) 
{
&load_order_lib;
if ($sc_test_repeat) {
  &display_order_form;
 } else {
  &process_order_form;
 }
&call_exit;
}

elsif (($page ne "" || $search_request ne ""
		    || &form_check('continue_shopping_button')
		    || $are_any_query_fields_filled_in =~ /yes/i) &&
	($form_data{'return_to_frontpage_button'} eq "")) 

{
&display_products_for_sale;
&call_exit;
}

$sc_processing_order="yes"; 
&codehook("gateway_response");
$sc_processing_order="no"; 

&output_frontpage;
&call_exit;

#########################################################################
sub load_order_lib{
  &codehook("load_order_lib_before");
  &require_supporting_libraries (
	__FILE__, 
	__LINE__, 
	"$sc_order_lib_path"); 
  &codehook("load_order_lib_after");
 }
#########################################################################
sub form_check {
  local ($name) = @_;
  local ($name2) = $name . ".x";

  if (($form_data{$name} ne "") || ($form_data{$name2} ne "")) {
    return 1;
   } else {
    return "";
   } 
 }
#######################################################################
sub require_supporting_libraries
{
local ($file, $line, @require_files) = @_;
local ($require_file);
&request_supporting_libraries("warn exit",$file, $line, @require_files);
}

sub request_supporting_libraries
{

local ($what_to_do_on_error, $file, $line, @require_files) = @_;
local ($require_file);

foreach $require_file (@require_files)
{
if (-e "$require_file" && -r "$require_file")
{ 
$result = eval('require "$require_file"'); 
if ($@ ne "") {
 if($what_to_do_on_error =~ /warn/i) {
  if ($error_header_done ne "yes") {
     $error_header_done = "yes";
     print "Content-type: text/html\n\n";
    }
   print "<div><table width=500><tr><td>\n";
   print "Error loading library $require_file:<br><br>\n  $@\n";
   print "<br><br>Please contact the site administrator to ", 
         "fix the error.&nbsp; \($ENV{'SERVER_ADMIN'}\)<br>\n";
   print "</td></tr></table></div>\n";
  }
 if($what_to_do_on_error =~ /exit/i) {
   &call_exit;
  }
 }
}

else
{

 if($what_to_do_on_error =~ /warn/i) {
  if ($error_header_done ne "yes") {
     $error_header_done = "yes";
     print "Content-type: text/html\n\n";
    }
print "I am sorry but I was unable to require $require_file at line
$line in $file.  <br>\nWould you please make sure that you have the
path correct and that the permissions are set so that I have
read access?  Thank you.&nbsp; \($ENV{'SERVER_ADMIN'}\)<br>\n";
  }

 if($what_to_do_on_error =~ /exit/i) {
   &call_exit;
  }
}

} 
} 

#######################################################################
sub read_and_parse_form_data

{
local ($junk);

&ReadParse(*form_data);

if ($form_data{'picserve'} ne "") {
  &serve_picture($form_data{'picserve'},$sc_path_of_images_directory);
  &call_exit;
 }
if ($form_data{'secpicserve'} ne "") {
  &serve_picture($form_data{'secpicserve'},"./protected/images/");
  &call_exit;
 }

}
#########################################################################
# Writen by Steve K to serve images 04-FEB-2000
# Note: using the http:// format is less efficient
# converted to taint-mode sub 2/5/2000

sub serve_picture {

 local ($qstr,$sc_path_of_images_directory) = @_;
 local ($test, $test2, $my_path_to_image);

 $qstr =~ /([\w\-\=\+\/\.\:]+)/;
 $qstr = "$1";

 $my_path_to_image = $sc_path_of_images_directory . $qstr ;
 $test = substr($my_path_to_image,0,6);
 $test2 = substr($my_path_to_image,(length($my_path_to_image)-3),3);

 if ($test2=~ /jpg/i || $test2 =~ /gif/i || $test2 =~ /png/i) {
  if ($test2=~ /jpg/i) {# .jpg is jpeg file
    $test2 = "jpeg";
   }
  if ($test=~ /http:\//i || $test =~ /https:/i) { 
   } else { 
    print "Content-type: image/$test2\n\n";
    if (!(-f $my_path_to_image)) {
      $my_path_to_image = $sc_path_of_images_directory ."/" . $qstr ;
     }
    open (MYPIC,$my_path_to_image);
    binmode(MYPIC);
    $size = 250000;
    while ($size > 0) {
      $size = read(MYPIC,$the_picture,$size); 
      print $the_picture;
     }
    close(MYPIC);
   }
 }
}
#######################################################################
sub alias_and_override { 
 local($item,$xx);
 local ($junk,$raw_text)="";
 local (@mylibs,$lib);
 local ($testval,$testval2,$found_response);

 &codehook("alias_and_override_top");

&special_security_f3_01172004;

if (($sc_gateway_name ne "iTransact") && ($sc_gateway_name ne "AgoraPay")) {
 &special_security_f1_01242002;}

 if (defined($form_data{'versions'}) && ($sc_debug_mode ne "no")) {
  print "Content-type: text/html\n\n";
  print "<HTML>\n<TITLE>VERSIONS</TITLE>\n<BODY BGCOLOR=WHITE>\n";
  print "<br><br>Info and Versions of loaded libraries:<br>\n";
  print "<table border=1 cellpadding=2 cellspacing=2>\n";
  foreach $junk (sort(keys(%versions)))
   {
    print "<tr><td>$junk </td><td>$versions{$junk}</td></tr>\n";
   }
  print "</table>\n";
  $junk .= `$sc_grep -h "versions{'" ./custom/* |$sc_grep "}="`;
  $junk .= `$sc_grep -h "versions{'" ./custom/* |$sc_grep "} ="`;
  $junk .= `$sc_grep -h "versions{'" ./protected/* |$sc_grep "}="`;
  $junk .= `$sc_grep -h "versions{'" ./protected/* |$sc_grep "} ="`;
  $junk .= `$sc_grep -h "versions{'" ./protected/custom/* |$sc_grep "}="`;
  $junk .= `$sc_grep -h "versions{'" ./protected/custom/* |$sc_grep "} ="`;
  $junk .= `$sc_grep -h "versions{'" ./library/* |$sc_grep "}="`;
  $junk .= `$sc_grep -h "versions{'" ./library/* |$sc_grep "} ="`;
  $junk =~s/\n/ /g;
  $junk =~ /([\w\-\=\+\/\;\{\}\'\ \.\"\$]+)/;
  $junk = $1;

  while ($junk ne "") {
    $result = $lib;
    ($junk1,$key,$junk) = split(/\'/,$junk,3);
    ($junk1,$val,$junk) = split(/\"/,$junk,3);
    if ($versions{$key} eq "") {
      $versions{$key} = $val;
     }
    ($junk1,$junk) = split(/versions/,$junk,2);
   }

#  if ($@ eq "") {
    print "<br><br>info and Versions of loaded and unloaded libraries:<br>\n";
    print "<table border=1 cellpadding=2 cellspacing=2>\n";
    foreach $junk (sort(keys(%versions)))
     {
      print "<tr><td>$junk </td><td>$versions{$junk}</td></tr>\n";
     }
    print "</table>\n";
#   }
  print "</BODY>\n</HTML>\n";
  &call_exit;
 }

  if (defined($form_data{'cart_id'})) {
    ($form_data{'cart_id'},$junk) = split(/\*/,$form_data{'cart_id'},2);
    $sc_unique_cart_modifier_orig = $junk;
    $sc_unique_cart_modifier = substr($sc_unique_cart_modifier_orig,0,6);
   }

  $found_response = "";
  foreach $testval (keys %sc_order_response_vars) {
   $testval2 = $sc_order_response_vars{$testval};
   if ($form_data{$testval2} ne "") {
     $found_response .= "*";
    }
  }
  if (("$sc_domain_name_for_cookie" ne $ENV{'HTTP_HOST'}) &&
      ($sc_allow_location_redirect =~ /yes/i ) &&
      ($form_data{'process_order.x'} eq "" ) &&
      ($form_data{'process_order'} eq "" ) &&
      ($form_data{'relay'} eq "" ) &&
      ($found_response eq "" ) &&
      ($form_data{'submit_order_form_button.x'} eq "" ) &&
      ($form_data{'submit_order_form_button'} eq "" ) &&
      ($form_data{'order_form_button.x'} eq "" ) &&
      ($form_data{'order_form_button'} eq "" )){ 
    if ($cookie{'cart_id'} ne "") {
      $cart_id = $cookie{'cart_id'};
     }
    if ($form_data{'cart_id'} ne "") {
      $cart_id = $form_data{'cart_id'};
      ($cart_id,$junk) = split(/\*/,$cart_id,2);
     }
    $sc_cart_path = "$sc_user_carts_directory_path/${cart_id}_cart";
    if (!(-f $sc_cart_path)){ 
      $cart_id = "";
     }
    $href = "$sc_store_url";
    if ($cart_id ne "") {
      $href .= "?cart_id=$cart_id";
     }
    print "Location: $href\n\n";
    &call_exit;
   }

  $search_request = ($form_data{'search_request_button'} || 
                     $form_data{'search_request_button.x'});

  if (($form_data{'maxp'} > 0) && ($form_data{'maxp'} < 301)) {
    $sc_db_max_rows_returned = $form_data{'maxp'};
   }
  if (defined($form_data{'srb'})) { #is an override/shortcut
    $search_request = $form_data{'srb'};
   }
  if (defined($form_data{'xc'})) {
    $form_data{'exact_case'} =  $form_data{'xc'};
   }
  if (defined($form_data{'xm'})) {
    $form_data{'exact_match'} =  $form_data{'xm'};
   }
  if (defined($form_data{'dc'})) {
    $form_data{'display_cart'} =  $form_data{'dc'};
   }
  if (defined($form_data{'pid'})) {
    $form_data{'p_id'} =  $form_data{'pid'};
   }
  if (defined($form_data{'ofn'})) {
    $form_data{'order_form'} =  $form_data{'ofn'};
   }
  if (defined($form_data{'p'})) {
    if ($form_data{'product'} ne "") {
     $form_data{'product'} .= " " . $form_data{'p'};
    } else {
     $form_data{'product'} =  $form_data{'p'};
    }
   }
  if (defined($form_data{'ppovr'})) {
    $form_data{'ppinc'} =  $form_data{'ppovr'};
   }
  if (defined($form_data{'k'})) {
    if ($form_data{'keywords'} ne "") {
     $form_data{'keywords'} .= " " . $form_data{'k'};
    } else {
     $form_data{'keywords'} =  $form_data{'k'};
    }
   }
  if (defined($form_data{'kovr'})) {
    $form_data{'keywords'} =  $form_data{'kovr'};
   }

 if (($form_data{'add_to_cart_button'} eq "") &&
     ($form_data{'add_to_cart_button.x'} ne "")) {
    $form_data{'add_to_cart_button'} = "1";
  }

 if ($form_data{'viewOrder'} eq "yes") {
  $sc_should_i_display_cart_after_purchase = "yes";
 } # else {
#  $sc_should_i_display_cart_after_purchase = "no";
# }

if (($sc_debug_mode =~ /yes/i) && ($sc_debug_track_cartid =~ /yes/i)) {
  if (($cookie{'cart_id'} ne "") && ($form_data{'cart_id'} ne "")) {
    $cart_id = $form_data{'cart_id'};
    ($cart_id,$junk) = split(/\*/,$cart_id,2);
    if ($cart_id ne $cookie{'cart_id'}) {
      local($mytext) = "Cart ID changed: cookie=$cookie{'cart_id'} ";
      $mytext .= "form=$form_data{'cart_id'}|";
      $mytext .= "form values:|";
      local($inx);
      foreach $inx (sort(keys %form_data)) {
        $mytext .= "  \$form_data{'$inx'} = $form_data{$inx}|";
       }
      &update_error_log($mytext, __FILE__, __LINE__);
     }
   }
 }

 &special_security_f2_01242002;

 &codehook("alias_and_override_end");

}
#######################################################################
sub error_check_form_data
{

$page = $form_data{'page'};
$page =~ /([\w\-\=\+\/]+)\.(\w+)/;
$page = "$1.$2";
$page_extension = ".$2";
$page = "" if ($page eq ".");
$page =~ s/^\/+//; # Get rid of any residual / prefix
$form_data{'page'} = $page; 

foreach $file_extension (@acceptable_file_extensions_to_display)
{
	if ($page_extension eq $file_extension || $page eq "")
	{
	$valid_extension = "yes";
	}
}
 if ($valid_extension ne "yes") {
  print "Content-type: text/html\n\n$sc_page_load_security_warning\n";
  &update_error_log("PAGE LOAD WARNING", __FILE__, __LINE__);
  &call_exit;
 }        

$form_data{'page'} = $page; 

if ($form_data{'page'} =~ /\.\.\//) {
  print "Content-type: text/html\n\nNo, you cannot go navigating";
  print " outside the html directory for pages, that is a security ";
  print " risk. Sorry!\n ";
  &call_exit;
 }

if ($form_data{'cartlink'} ne "") {
$cartlink = $form_data{'cartlink'};
$cartlink =~ /([\w\-\=\+\/]+)\.(\w+)/;
$cartlink = "$1.$2";
$page_extension = ".$2";
$cartlink = "" if ($cartlink eq ".");
$cartlink =~ s/^\/+//; 
$form_data{'cartlink'} = $cartlink;

foreach $file_extension (@acceptable_file_extensions_to_display)
{
	if ($page_extension eq $file_extension || $cartlink eq "")
	{
	$valid_extension = "yes";
	}
}
 if ($valid_extension ne "yes") {
  print "Content-type: text/html\n\n$sc_page_load_security_warning\n";
  &update_error_log("PAGE LOAD WARNING", __FILE__, __LINE__);
  &call_exit;
 }        

$form_data{'cartlink'} = $cartlink;

if ($form_data{'cartlink'} =~ /\.\.\//) {
  print "Content-type: text/html\n\nNo, you cannot go navigating";
  print " outside the html directory for pages, that is a security ";
  print " risk. Sorry!\n ";
  &call_exit;
 }
}

if ($form_data{'cart_id'} ne "") {
  if ($form_data{'cart_id'} =~ /^([\w\-\=\+\/]+)\.(\w+)/) {
    $temp = "$1.$2";
    if ($form_data{'cart_id'} ne $temp) { $temp = '';}
    $form_data{'cart_id'} = $temp;
    if ($form_data{'cart_id'} eq ".") {
      $form_data{'cart_id'} = "";
     }
   } else {
    $form_data{'cart_id'} = "";
   }
 }

if ($cookie{'cart_id'} ne "") {
  if ($cookie{'cart_id'} =~ /(^[\w\-\=\+\/]+)\.(\w+)/) {
    $cookie{'cart_id'} = "$1.$2";
    if ($cookie{'cart_id'} eq ".") {
      $cookie{'cart_id'} = "";
     }
   } else {
    $cookie{'cart_id'} = "";
   }
 }

}
#######################################################################
sub special_security_f1_01242002 {
 if (!($sc_debug_mode =~ /yes/i)) { delete($form_data{'versions'});}
 $form_data{'cart_id'} =~ s/</&lt;/g;
 $form_data{'cart_id'} =~ s/>/&gt;/g;
 for $xx (keys %form_data) { 
   $form_data{$xx}=~s/([^ \$\w\-=\+\.\/,@#!_\\[\]\^\{\}\:&;|~\*\x00\(\)]+)//g;
   if ($form_data{$xx}=~/([ \$\w\-=\+\.\/,@#!_\\[\]\^\{\}\:&;|~\*\x00\(\)]+)/){
      $form_data{$xx} = $1;
    } else {
      $form_data{$xx} = '';
    }
  }
 }
sub special_security_f2_01242002 {
  if (!($form_data{'cart_id'} =~ /^([\w\-\=\+\/]+)\.(\w+)/)) {
    $form_data{'cart_id'} = ''; 
    $sc_unique_cart_modifier_orig = '';
    $sc_unique_cart_modifier = '';
   }
 }

sub special_security_f3_01172004 {
if ($form_data{'option'} ne '') {
$form_data{'add_to_cart_button'} = '';
$form_data{'add_to_cart_button.x'} = '';
$sc_unique_cart_modifier_orig = '';
$sc_unique_cart_modifier = '';
}
}
#######################################################################
sub parse_options_to_verify{
  local($orig_str) = @_;
  local($str) = $orig_str;
  local($name) = "";
  local($nextname,$stuff,$parta,$partb,$val,@items);

  while ($str =~ /(name)([ \n\r]*)(=)([ \n\r]*)([\"\'])([^\"\']*)([\"\'])/i) {
    $nextname = $6;
    $str =~ s/(name)([ \n\r]*)(=)([ \n\r]*)([\"\'])([^\"\']*)([\"\'])/%##%/i;
    ($stuff,$str) = split(/%##%/,$str,2);
    if ($name ne "") {
     $items{$name} = $stuff;
     }
    $name = $nextname;
   } 

  if ($name ne "") {
    $items{$name} = $str;
   }

  foreach $name (keys %items) {
    $str = $items{$name};
    while ($str =~ /(value)([ \n\r]*)(=)([ \n\r]*)([\"\'])([^\"\']*)([\"\'])/i) {
      $val = $6;
      ($parta,$partb) = split(/\|/,$val,2);
      $item_opt_verify{$name . "|" . $parta} = $partb;
      $str =~ s/(value)([ \n\r]*)(=)([ \n\r]*)([\"\'])([^\"\']*)([\"\'])//i;
     }
   }

 return $orig_str;

 }
#######################################################################
sub option_prep {
local ($field,$option_location,$product_id)= @_;
local ($very_first_part,$junk);
local ($arg,$arg1,$arg2);

$field = &agorascript($field,"optpre","$option_location",__FILE__,__LINE__);

$field =~ s/%%PRODUCT_ID%%/$product_id/ig;
$field =~ s/%%PRODUCTID%%/$product_id/ig;
$field =~ s/%%prodID%%/$product_id/ig;

$field = &agorascript($field,"optpost","$option_location",__FILE__,__LINE__);
# if ($chop =~ /yes/i) {
   ($very_first_part,$field,$junk) =  
	split(/<h3>--cut here--<\/h3>/i,$field,3);
   if ($field eq "") {
     $field = $very_first_part;
    }
   if ($field eq "") {
     $field = "(file $option_location not found)";
    }
#  }

 return $field;

}
#######################################################################
sub check_cart_expiry {
  &check_cart_type_file_expiry("$sc_cart_path");
  &check_cart_type_file_expiry("$sc_verify_order_path");
  &check_cart_type_file_expiry("$sc_server_cookie_path");
 }

sub check_cart_type_file_expiry {
local($cart_type_file_path) = @_;
if (-M "$cart_type_file_path" > $sc_number_days_keep_old_carts)
{
if ($cart_type_file_path =~ /cart/i) {
  &codehook("delete-cart");
 } else {
  &codehook("delete-non-cart");
 }
unlink("$cart_type_file_path");
}
}

sub delete_old_carts
{

opendir (USER_CARTS, "$sc_user_carts_directory_path") || &file_open_error("$sc_user_carts_directory_path", "Delete Old Carts", __FILE__, __LINE__);
@carts = grep(/\.[0-9]/,readdir(USER_CARTS));
closedir (USER_CARTS);

foreach $cart (@carts)
{
$sc_cart_path = "$sc_user_carts_directory_path/$cart";
$sc_cart_path =~ /([\w\-\=\+\/\.]+)/;
$sc_cart_path = "$1";
$sc_cart_path = "" if ($sc_cart_path eq ".");
$sc_cart_path =~ s/^\/+//; 
&check_cart_type_file_expiry("$sc_cart_path");
}

}

#######################################################################
sub assign_a_unique_shopping_cart_id
{
srand (time|$$);

$cart_id = int(rand(10000000));
$cart_id .= ".$$";
$cart_id =~ s/-//g;
&codehook("assign-cart_id-modifier");

$sc_cart_path = "$sc_user_carts_directory_path/${cart_id}_cart";
$cart_count = 0;

while (-e "$sc_cart_path")
{
	if ($cart_count == 4)
	{
	print "$sc_randomizer_error_message";
	&update_error_log("COULD NOT CREATE UNIQUE CART ID", __FILE__, __LINE__);
	&call_exit;
	}

$cart_id = int(rand(10000000));
$cart_id .= "_$$";    
$cart_id =~ s/-//g;
&codehook("assign-cart_id-modifier");
$sc_cart_path = "$sc_user_carts_directory_path/${cart_id}_cart";
$cart_count++;

} 

&set_sc_cart_path; 
&codehook("assign-cart_id");
&SetCookies;

}

#######################################################################   
sub log_access_to_store {
  $date = &get_date;
  &get_file_lock("$sc_access_log_path.lockfile");
  open (ACCESS_LOG, ">>$sc_access_log_path");

  $remote_addr = $ENV{'REMOTE_ADDR'};
  $request_uri = $ENV{'REQUEST_URI'};
  $http_user_agent = $ENV{'HTTP_USER_AGENT'};

  if ($ENV{'HTTP_REFERER'} ne "") {
    $http_referer = $ENV{'HTTP_REFERER'};
   } else {
    $http_referer = "possible bookmarks";
   }

  $remote_host = $ENV{'REMOTE_HOST'};

  #$shortdate = `date +"%T"`; # time
  #$shortdate = `date +"%D %T"`; # date and time
  $shortdate = &get_date_short;
  chomp ($shortdate);
  $unixdate = time;

  $new_access = "$form_data{'url'}\|$shortdate\|$request_uri" .
	"\|$cookie{'visit'}\|$remote_addr\|$http_user_agent" .
	"\|$http_referer\|$unixdate\|";

  chop $new_access;
  print ACCESS_LOG "$new_access\n";
  close (ACCESS_LOG);

  &release_file_lock("$sc_access_log_path.lockfile");

 }
#######################################################################   
sub output_frontpage {
  &codehook("output_frontpage");
  &display_page("$sc_store_front_path", "Output Frontpage", __FILE__,__LINE__);
 }
############################################################
sub finish_add_to_the_cart {
&codehook("finish_add_to_the_cart");
if (($sc_use_html_product_pages eq "yes") || 
   (($sc_use_html_product_pages eq "maybe") && ($page ne "")))
{
	if ($sc_should_i_display_cart_after_purchase eq "yes")
	{
	&display_cart_contents;
	}
	else
	{
	&display_page("$sc_html_product_directory_path/$page",  
		"Display Products for Sale");
	}
}
else
{
	if ($sc_should_i_display_cart_after_purchase eq "yes")
	{
	&display_cart_contents;
	}

	elsif ($are_any_query_fields_filled_in =~ /yes/i)
	{
	$page = "";
	&display_products_for_sale;
	}

	else
	{
	&create_html_page_from_db;
	}
}

}
#######################################################################
sub display_products_for_sale
{

if (($sc_use_html_product_pages eq "yes") || 
  (($sc_use_html_product_pages eq "maybe") && ($page ne "")))
{

if (($search_request ne "") && ($sc_use_html_product_pages eq "yes")){
&standard_page_header("Search Results");
require "$sc_html_search_routines_library_path";
&html_search;
&html_search_page_footer;
&call_exit;
}

&display_page("$sc_html_product_directory_path/$page", "Display Products for Sale", __FILE__, __LINE__);
}

else
{
&create_html_page_from_db;
}

}
#######################################################################   
sub create_html_page_from_db
{
local ($body_html,$prod_message,$status,$total_row_count);
 #if ($page ne "" && $search_request eq "" && 
 #    $form_data{'continue_shopping_button'} eq "")

if (($page ne "" ) && (!($sc_use_html_product_pages eq "no"))) 
{
&display_page("$sc_html_product_directory_path/$form_data{'page'}", 
              "Display Products for Sale", __FILE__, __LINE__);
&call_exit;
}

($body_html,$prod_message,$status,$total_row_count) = 
	&create_html_page_from_db_body;
&product_page_header($sc_product_display_title,$prod_message);
print $body_html;
&product_page_footer($prod_message);
&call_exit;
}

#######################################################################   
sub create_html_page_from_db_body
{
local ($my_output,$prod_message);
local (@database_rows, @database_fields, @item_ids, @display_fields);
local ($total_row_count, $id_index, $display_index, $found, $product_id);
local ($row, $field, $empty, $option_tag, $option_location, $output);

if (!($sc_db_lib_was_loaded =~ /yes/i)) {
  &require_supporting_libraries (__FILE__, __LINE__, "$sc_db_lib_path"); 
 }

($status,$total_row_count) = &submit_query(*database_rows);

if (($form_data{'next'}+$sc_db_max_rows_returned) < 1) {
  $form_data{'next'} = 0;
 }

$nextCount = $form_data{'next'}+$sc_db_max_rows_returned;
$prevCount = $form_data{'next'}-$sc_db_max_rows_returned;

$minCount = $form_data{'next'};
$maxCount = $form_data{'next'}+$sc_db_max_rows_returned;

if ($maxCount < @database_rows) {
  $my_max_count = $maxCount; 
 } else {
  $my_max_count = @database_rows;
 }

$num_returned = @database_rows;
$nextHits = $sc_db_max_rows_returned;

$prod_message = &product_message($status,$num_returned,$nextHits);

if ($form_data{'add_to_cart_button.x'} ne "" && 
    $sc_shall_i_let_client_know_item_added eq "yes") {
  $my_output .= "$sc_item_ordered_message";
 }

$last_product_displayed = "no";

foreach $row (@database_rows)
{
$rowCount++;

$prevHits = $sc_db_max_rows_returned;
$nextHits = $sc_db_max_rows_returned;

if ($rowCount > $minCount && $rowCount <= $maxCount)
{

#@database_fields = split (/\|/, $row);
$product_id = $row;
$found = &check_db_with_product_id($product_id,*database_fields);
&codehook("create_html_page_read_db_item");
foreach $field (@database_fields)

{
if ($field =~ /^%%IMG%%/i)
{
($empty, $image_tag, $image_location) = split (/%%/, $field);
$field = '<IMG SRC="' . "$URL_of_images_directory/$image_location" . 
	 '" BORDER=0>';
}

if ($field =~ /^%%OPTION%%/i)
{
($empty, $option_tag, $option_location, $junk) = split (/%%/, $field, 4);
$field = "";

$field = &load_opt_file($option_location);

$field = &option_prep($field,$option_location,$product_id);

}

if ($field =~ /^%%FILE%%/i)
{
($empty, $option_tag, $option_location) = split (/%%/, $field);
$field = "";
{
open (OPTION_FILE, "<$sc_generic_directory_path/$option_location");
local $/=undef;
$field=<OPTION_FILE>;
close (OPTION_FILE);
}
$field = &agorascript($field,"pre","$option_location",__FILE__,__LINE__);

$cart_id_for_html = &cart_id_for_html;
$field =~ s/%%PRODUCT_ID%%/$database_fields[$sc_db_index_of_product_id]/g;
$field =~ s/%%PRODUCTID%%/$database_fields[$sc_db_index_of_product_id]/g;
$field =~ s/%%URLofImages%%/$URL_of_images_directory/g;
$field =~ s/%%cart_id%%/$cart_id_for_html/g;

$field = &agorascript($field,"post","$option_location",__FILE__,__LINE__);

($very_first_part,$field,$junk) = 
	split(/<h3>--cut here--<\/h3>/i,$field,3);
if ($field eq "") {
  $field = $very_first_part;
 }
if ($field eq "") {
  $field = "(file $option_location not found)";
 }

}

}

if ($rowCount == (1 + $minCount)) {
  $first_product_displayed = "yes";
 } else {
  $first_product_displayed = "no";
  if ($rowCount == $maxCount) {
    $last_product_displayed = "yes";
    }
 }

&create_display_fields(@database_fields);

$my_output .= &prep_displayProductPage(&get_sc_ppinc_info);

}

}

return ($my_output,$prod_message,$status,$total_row_count);

}

#######################################################################
sub file_open_error
{

local ($bad_file, $script_section, $this_file, $line_number) = @_;
&update_error_log("FILE OPEN ERROR-$bad_file", $this_file, $line_number);

open(ERROR, $error_page);

while (<ERROR>)

{  
print $_;
}
  
close (ERROR);

}
#######################################################################
sub display_page
{
local ($page, $routine, $file, $line) = @_;
local($the_file)="";
local($href_fields,$hidden_fields);

$href_fields = &make_href_fields;
$hidden_fields = &make_hidden_fields;
$cart_id_for_html = "%%ZZZ%%";

   if ($form_data{'cartlink'} ne "")
   {
      open (PAGE, "<./html/$cartlink") || &file_open_error("$category", "$routine", $file, $line);
   } else {

open (PAGE, "<$page") || &file_open_error("$page", "$routine", $file, $line);
}

while (<PAGE>)

{  

if (($form_data{'add_to_cart_button'} ne "") &&
    ($sc_allow_sneak_in_message =~ /yes/i)  &&
    ($sc_shall_i_let_client_know_item_added =~ /yes/i)) {
  if ($_ =~ /<FORM/) {
    $the_file .= "$_";
    $the_file .= "$sc_item_ordered_message";
    $_ = ""; 
   }
 }

$the_file .= $_;
}
  
close (PAGE);
$the_file = &script_and_substitute($the_file,$page);
print $the_file;

}
#################################################################
sub script_and_substitute {
 local ($the_file,$page)=@_;
 local($href_fields,$hidden_fields,$item_ordered_message,$my_text)="";
 local($arg,$myans);

$href_fields = &make_href_fields;
$hidden_fields = &make_hidden_fields;
$cart_id_for_html = "%%ZZZ%%";

if (($form_data{'add_to_cart_button'} ne "" )&&
    ($sc_shall_i_let_client_know_item_added =~ /yes/i)) {
  $item_ordered_message = $sc_item_ordered_msg_token;
 }

$the_file = &agorascript($the_file,"pre","$page",__FILE__,__LINE__);

$the_file =~ s/%%item_ordered_msg%%/$item_ordered_message/ig;
$the_file =~ s/%%CartID%%/%%cart_id%%/g;
$the_file =~ s/%%cartID%%/%%cart_id%%/ig;
$the_file =~ s/cart_id=%%cart_id%%/cart_id=/ig;
$the_file =~ s/cart_id=/cart_id=$cart_id_for_html/ig;
$the_file =~ s/%%cart_id%%/$cart_id_for_html/ig;
$the_file =~ s/%%page%%/$form_data{'page'}/ig;
$the_file =~ s/%%cartlink%%/$form_data{'cartlink'}/ig;
$the_file =~ s/%%date%%/$date/ig;
$the_file =~ s/%%agoracgi_ver%%/$versions{'agora.cgi'}/ig;
$the_file =~ s/%%URLofImages%%/$URL_of_images_directory/ig;
$the_file =~ s/%%ScriptURL%%/$sc_main_script_url/ig;
$the_file =~ s/%%ScriptPostURL%%/$sc_main_script_url/ig;
$the_file =~ s/%%sc_order_script_url%%/$sc_order_script_url/ig;
$the_file =~ s/%%storeURL%%/$sc_store_url/ig;
$the_file =~ s/%%StepOneURL%%/$sc_stepone_order_script_url/ig;
$the_file =~ s/%%href_fields%%/$href_fields/ig;
$the_file =~ s/%%make_hidden_fields%%/$hidden_fields/ig;
$the_file =~ s/%%ppinc%%/$form_data{'ppinc'}/ig;
$the_file =~ s/%%maxp%%/$form_data{'maxp'}/ig;
$the_file =~ s/%%product%%/$form_data{'product'}/ig;
$the_file =~ s/%%p_id%%/$form_data{'p_id'}/ig;
$the_file =~ s/%%keywords%%/$keywords/ig;
$the_file =~ s/%%next%%/$form_data{'next'}/ig;
$the_file =~ s/%%exact_match%%/$form_data{'exact_match'}/ig;
$the_file =~ s/%%exact_case%%/$form_data{'exact_case'}/ig;

while ($the_file =~ /(%%eval)([^%]+)(%%)/i) {
  $arg = $2;
  $myans = eval($arg);
  if ($@ ne ""){ $myans = "%% Eval Error on: $arg %%";}
  $the_file =~ s/(%%eval)([^%]+)(%%)/$myans/i;
}

while ($the_file =~ /%%ZZZ%%/) {
  $cart_id_for_html = &cart_id_for_html;
  $the_file =~ s/%%ZZZ%%/$cart_id_for_html/;
}

$the_file = &agorascript($the_file,"post","$page",__FILE__,__LINE__);
$the_file = &agorascript($the_file,"","$page",__FILE__,__LINE__);

while ($the_file =~ /%%StoreHeader%%/i) {
  $my_text = &GetStoreHeader;
  $the_file =~ s/%%StoreHeader%%/$my_text/i;
}
while ($the_file =~ /%%StoreFooter%%/i) {
  $my_text = &GetStoreFooter;
  $the_file =~ s/%%StoreFooter%%/$my_text/i;
}

return $the_file;

}
#################################################################
sub update_error_log {
local ($type_of_error, $file_name, $line_number) = @_;
local ($log_entry, $email_body, $variable, @env_vars);

@env_vars = sort(keys(%ENV));
$date = &get_date;

if ($sc_debug_mode eq "yes")
{
if ($sc_header_printed ne 1) {
  if ($sc_browser_header eq "") {
    $sc_browser_header = "Content/type: text/html;\n\n";
   }
  print $sc_browser_header;
 }

local($browser_text) = $type_of_error;
$browser_text =~ s/\|/\<br\>\n/g;

print '<DIV ALIGN=LEFT><TABLE WIDTH=500><TR><TD>' . "\n<PRE>";
print "ERROR:$browser_text<br>",
      "FILE: $file_name<br>",
      "LINE: $line_number<BR>\n";
print '</PRE></TD></TR></TABLE></DIV>' . "\n";

}

if ($sc_shall_i_log_errors eq "yes")
{

$log_entry = "$type_of_error\|FILE=$file_name\|LINE=$line_number\|";
$log_entry .= "DATE=$date\|";

&get_file_lock("$sc_error_log_path.lockfile");
open (ERROR_LOG, ">>$sc_error_log_path") || &CgiDie ("The Error Log could not be opened");

foreach $variable (@env_vars)

{
$log_entry .= "$variable: $ENV{$variable}\|";
}  

$log_entry =~ s/\n/<br>/g; #
print ERROR_LOG "$log_entry\n";
close (ERROR_LOG);  

&release_file_lock("$sc_error_log_path.lockfile");

}

if ($sc_shall_i_email_if_error eq "yes")

{
$email_body = "$type_of_error\n\n";
$email_body .= "FILE = $file_name\n";
$email_body .= "LINE = $line_number\n";
$email_body .= "DATE=$date\|"; 

foreach $variable (@env_vars)
{
$email_body .= "$variable = $ENV{$variable}\n";
}  

&send_mail("$sc_admin_email", "$sc_admin_email", "Web Store Error", "$email_body");

}


}
#################################################################
sub get_date {
local (@days, @months); 
local ($connector) = ' at ';
@days = ('Sunday','Monday','Tuesday','Wednesday','Thursday', 'Friday',
	'Saturday');
@months = ('January','February','March','April','May','June','July',
	   'August','September','October','November','December');
return &get_date_engine;
}

sub get_date_short {
local (@days, @months); 
local ($connector) = ' ';
@days = ('Sun','Mon','Tue','Wed','Thu', 'Fri', 'Sat');
@months = ('Jan','Feb','Mar','Apr','May','Jun',
	'Jul','Aug','Sep','Oct','Nov','Dec');
return &get_date_engine;
}

sub get_date_engine
{

local ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$date);

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

if ($hour < 10) 

{ 
$hour = "0$hour"; 
}

if ($min < 10) 

{ 
$min = "0$min"; 
}

if ($sec < 10) 

{
$sec = "0$sec"; 
}

$year += 1900;
$date = "$days[$wday], $months[$mon] $mday, $year" .
	$connector . "$hour\:$min\:$sec";

return $date;

}       

#################################################################
sub display_price {
 local ($price) = @_;
 local ($format_price);
	
# set to 2 decimal places ... SPK 1/26/2000
$price = &format_price($price);

if ($sc_money_symbol_placement eq "front") {
  $format_price = "$sc_money_symbol$sc_money_symbol_spaces$price";
 } else {
  $format_price = "$price$sc_money_symbol_spaces$sc_money_symbol";
 }
return $format_price;
}

sub display_price_nospaces {
 local ($price) = @_;
 local ($holdme) = $sc_money_symbol_spaces;
 $sc_money_symbol_spaces='';
 $price = &display_price($price);
 $sc_money_symbol_spaces = $holdme;
 return $price;
}

#######################################################################
sub get_file_lock 

{

local ($lock_file) = @_;
local ($endtime);
local ($exit_get_file_lock)="";
&codehook("get_file_lock");
if ($exit_get_file_lock ne "") {return;}

$endtime = 55; # was 20 originally
$endtime = time + $endtime;
    
while (-e $lock_file && time < $endtime) 
{
sleep(1);
}

open(LOCK_FILE, ">$lock_file") || 
    &CgiDie ("I could not open the lockfile - check your permission " .
	     "settings ($lock_file)");
# flock(LOCK_FILE, 2); # 2 exclusively locks the file

} 
#######################################################################
sub release_file_lock 
{
local ($lock_file) = @_;
local ($exit_release_file_lock)="";
&codehook("release_file_lock");
if ($exit_release_file_lock ne "") {return;}

# flock(LOCK_FILE, 8); # 8 unlocks the file

close(LOCK_FILE);
unlink($lock_file);

} 
#######################################################################
sub format_price
{

local ($unformatted_price) = @_;
local ($formatted_price);
$formatted_price = sprintf ("%.2f", $unformatted_price);
return $formatted_price;

}
############################################################
sub format_text_field 

{

local($value, $width) = @_;
$width = 25 if (!$width);

return ($value . (" " x ($width - length($value))));

}
###########################################################################################
sub SetCookies
{
local(@test);
$cookie{'cart_id'} = "$cart_id";
$domain = $sc_domain_name_for_cookie;
@test = split(/\./,$domain);
#if ($test[2] eq '') { $domain = '.' . $domain;}
$secureDomain = $sc_secure_domain_name_for_cookie;
@test = split(/\./,$secureDomain);
#if ($test[2] eq '') { $secureDomain = '.' . $secureDomain;}
$path = $sc_path_for_cookie;
$securePath = $sc_secure_path_for_cookie;
$secure = "";
$now = time;
$twenty_four_hours = "86400";
$cookie_hours = $sc_cookie_days * $twenty_four_hours;
$expiration = $now+$cookie_hours;
&codehook("about_to_set_cookie");
if(!$form_data{'secure'}){
  &set_cookie($expiration,$domain,$path,$secure);
 } else {
  &set_cookie($expiration,$secureDomain,$securePath,$secure);
 }

} 
############################################################
sub checkReferrer
{
local ($referringDomain, $acceptedDomain);
local ($alt_domain)='';
local ($test_repeat,$raw_text);

$referringDomain = $ENV{'HTTP_REFERER'};
$acceptedDomain = $sc_domain_name_for_cookie;

if ($sc_disable_refer_domain_check =~ /yes/i) {
  $referringDomain = $acceptedDomain;
 }

if ($referringDomain eq "") {
  $referringDomain = $acceptedDomain;
}

if (!($sc_accept_only_full_domain)) {
  $alt_domain = $sc_domain_name_for_cookie;
  $alt_domain =~ s/\w*\.//;
 }

$referringDomain =~ s/\?.*//g;
$referringDomain =~ s/http:\/\///g;
$referringDomain =~ s/https:\/\///g;
$referringDomain =~ s/\/.*//g;
$referringDomain =~ s/\/agora.cgi//g;

if ($referringDomain =~ "^w*\.")
{
$referringDomain =~ s/^w*\.//i;
}

if ($acceptedDomain =~ "^w*\.")
{
$acceptedDomain =~ s/^w*\.//i;
}
 
$test_repeat = 0;
if ($sc_test_for_store_cart_change_repeats) {
  $test_repeat = $sc_test_repeat;
 }

if ((($referringDomain ne $acceptedDomain) && 
     ($referringDomain ne $sc_domain_name_for_cookie)) || ($test_repeat)) {
  if ($test_repeat) {
    if ($sc_repeat_fake_it =~ /yes/i) { 
      &repeat_fake_it;
     } else {
      $special_message = $messages{'chkref_01'};
      &display_cart_contents;
     }
   }
  elsif ($cart_id == $cookie{'cart_id'}) { 
    $special_message = $messages{'chkref_02'};
    &display_cart_contents;
   } else {
    print "$acceptedDomain is the accepted referrer.<br>";
    print "$referringDomain is not a valid referrer<br>";
    print $messages{'chkref_03'};
   }
  &call_exit;   
 }
}
############################################################
sub repeat_fake_it {
 if ($form_data{'add_to_cart_button.x'} ne "") {
   &finish_add_to_the_cart;
   &call_exit;
  }
 elsif ($form_data{'submit_change_quantity_button.x'} ne "") {
   &finish_modify_quantity_of_items_in_cart;
   &call_exit;
  }
 elsif ($form_data{'submit_deletion_button.x'} ne "") {   
   &finish_delete_from_cart;
   &call_exit;
  }
 else {
   $special_message = $messages{'chkref_01'};
   &display_cart_contents;
  }
}
############################################################
sub set_sc_cart_path {
 local($raw_text)="";
 local($base)="";
 $cart_id =~ /([\w\-\=\+\/]+)\.(\w+)/;
 $cart_id = "$1.$2";
 $form_data{'cart_id'} = $cart_id;

 $base			= "$sc_user_carts_directory_path/";
 $sc_cart_path		= "$base${cart_id}_cart";
 $sc_capture_path	= "$base${cart_id}_CAPTURE";
 $sc_server_cookie_path = "$base${cart_id}_COOKIES";
 $sc_verify_order_path	= "$base${cart_id}_VERIFY";
 $cart_id_for_html	= "$cart_id*" . &make_random_chars; 

 &check_cart_expiry;

 &load_server_side_cookies;

 $sc_test_repeat = 0;
 $raw_text = &get_agora('TRANSACTIONS');
 if ($sc_unique_cart_modifier ne '') {
   if (!($raw_text =~ /$sc_unique_cart_modifier/)){
     &set_agora('TRANSACTIONS', $raw_text . "$sc_unique_cart_modifier\n");
    } else {
     $sc_test_repeat = 1;
    }
  }

 &codehook("set_sc_cart_path_bot");

 return;
}
#######################################################################
sub cart_id_for_html{ 
 return "$cart_id*" . &make_random_chars;
}
#######################################################################
sub zcode_error {
  local ($ZCODE,$at,$file,$line)=@_;
  local ($xx)="-" x 60;
  $ZCODE =~ s/\n/\|/g;
  $at =~ s/\n/\|/g;
  &update_error_log("zcode compilation error: |$at|$ZCODE|$xx",
    $file,$line);
  &call_exit;
}
#######################################################################
sub codehook{
  local($hookname)=@_;
  local($codehook,$err_code,@hooklist);
  if ($codehooks{$hookname} ne "") {
    @hooklist = split(/\|/,$codehooks{$hookname});
    foreach $codehook (@hooklist) {
      eval("&$codehook;");
      $err_code = $@;
      if ($err_code ne "") { #script died, error of some kind
        &update_error_log("code-hook $hookname $codehook $err_code","","");
       }
     }
   }
 }
#######################################################################
sub add_codehook{
  local($hookname,$sub_name)=@_;
  local($codehook,$err_code,@hooklist);
  if ($sub_name eq "") { return;}
  @hooklist = split(/\|/,$codehooks{$hookname});
  foreach $codehook (@hooklist) {
    if ($codehook eq $sub_name) { 
      return;
     }
   }
  if ($codehooks{$hookname} eq "") {
    $codehooks{$hookname} = $sub_name;
   } else {
    $codehooks{$hookname} .= "|" . $sub_name;
   }
 }
#######################################################################
sub replace_codehook{
  local($hookname,$sub_name)=@_;
  $codehooks{$hookname} = $sub_name;
 }
#######################################################################
sub my_die {
  local ($msg) = @_;
  if ($sc_in_throes_of_death eq "yes") {die $msg;}
  $sc_in_throes_of_death="yes";
  &call_exit;
  die $msg;
}
#######################################################################
sub cartlinks
{
   $cartlinks = "<a href=\"$sc_store_url?cart_id=$cart_id\" style=\"text-decoration: none\">Home</a>\n";
   opendir(PAGES,"./html")||die("Cannot open Directory!");
   @clinknames = readdir(PAGES);
   for $clinknames(@clinknames)
   {
      $clinkname = (split (/\./, $clinknames))[0];
      $page2_extension = (split (/\./, $clinknames))[1];
      $clinkname =~ s/_/ /ig;
      $clinkname =~ s/-/ /ig;
      if ($page2_extension eq "htm" or $page2_extension eq "html")
      {
      if ($clinkname && $clinkname ne "" && $clinkname ne "index" && $clinkname ne "error" && $clinkname ne "frontpage")
      {
         $cartlinks .= "<br><a href=\"$sc_store_url?cartlink=$clinknames&cart_id=$cart_id\"  style=\"text-decoration: none\">$clinkname</a>\n";
      }
}
   }
   close (PAGES)
}

#######################################################################
sub call_exit {
  &agora_cookie_save;
  codehook("cleanup_before_exit");
  if ($sc_in_throes_of_death ne "yes") {
    exit;
   }
 }
