#######################################################################

$versions{'agora_html_lib.pl'} = "20021020";

#######################################################################
sub load_server_side_cookies {
  &codehook("before_server_cookie_load");
  undef(%agora); 
  undef(%agora_original_values);
  $sc_server_cookies_loaded = '1';
  if (-e "$sc_server_cookie_path" && -r "$sc_server_cookie_path"){ 
    eval('require "$sc_server_cookie_path"'); 
   }
  if (&get_agora('LAST_VISIT_TIMESTAMP') eq '') { 
    if ($sc_shall_i_log_accesses eq "yes") { 
      &log_access_to_store;
     }
   }
  &set_agora('LAST_VISIT_TIMESTAMP',time());
  &codehook("after_server_cookie_load");
 }
#######################################################################
sub set_agora {
  local($inx,$val) = @_;
  $agora{$inx} = $val;
  return $val;
 }
#########################################################################
sub get_agora {
  local($inx) = @_;
  return $agora{$inx};
 }
#########################################################################
sub get_agora_orig {
  local($inx) = @_;
  return $agora_original_values{$inx};
 }
#########################################################################
sub chk_agora {
  local($inx) = @_;
  if ($agora_original_values{$inx} eq $agora{$inx}) {
    return '1';
   } else {
    return '';
   }
 }
#########################################################################
sub ain_agora { 
  local($inx,$val) = @_;
  if ((&get_agora($inx) eq '') && ($val ne '')) {
    &set_agora($inx,$val);
    return '1';
   } else {
    return '';
   }
 }
#########################################################################
sub agora_cookie_save {
  local($inx);
  open(SERVCOOKIE,">$sc_server_cookie_path");
  print SERVCOOKIE "# Library of Server Cookies\n";
  foreach $inx (sort(keys %agora)) {
    print SERVCOOKIE "\$agora{'$inx'} = &str_decode('" . 
	&str_encode($agora{$inx}) . "');\n";
   }
  print SERVCOOKIE '{local($inx);' .
	'foreach $inx (keys %agora) {' .
	'$agora_original_values{$inx} = $agora{$inx};}' . "}\n";
  print SERVCOOKIE "#\n1;\n";
  close(SERVCOOKIE);
 }
#########################################################################
sub str_encode { 
  local($str)=@_;
  local($mypat)='[\x00-\x1F"\x27#%/+;<>?\x7F-\xFF]';
  $str =~ s/($mypat)/sprintf("%%%02x",unpack('c',$1))/ge;
  $str =~ tr/ /+/;
  return $str;
 }
#######################################################################
sub str_decode { 
  local($str)=@_;
  $str =~ tr/+/ /;
  $str =~ s/%(..)/pack("c",hex($1))/ge;
  return $str;
 }
#######################################################################
sub load_file_lines_to_str {#
  local ($location) = @_;
  local (@lines)=();
  open (XX_FILE, "<$location");
  @lines = <XX_FILE>;
  close (XX_FILE);
  return join("",@lines);
 }
#######################################################################
sub load_file_to_str {
  local ($location) = @_;
  local ($content)='';
  open (XX_FILE, "<$location");
  binmode(XX_FILE);
  local $/ = undef;
  $contents = <XX_FILE>;
  close (XX_FILE);
  return $content;
 }
#######################################################################
sub load_opt_file {
  local($files_to_load) = @_;
  local($very_first_part,$stuff_after,$arg,$newpath,$myans,$tack_on);
  local($path) = "";
  local($field) = "";
  if ($files_to_load ne "") {
    $field = $files_to_load;
    $field =~ s/ //g;
    $field =~ s/,/%%\n%%Load_Option_File /g;
    $field = '%%Load_Option_File ' . $field . '%%';
    $field = &load_opt_file_engine($field);
   }
  return $field;
 }
#######################################################################
sub load_opt_file_engine { # do the actual loading of options file(s)
  local($field) = @_;
  local($very_first_part,$stuff_after,$arg,$newpath,$myans,$tack_on);
  local(%file_list);

  while ($field =~ /(%%Load_Option_File )([^%]+)(%%)/i) {
    $arg = $2;
    $arg =~ s/ //g;
    if ($arg =~ /,/) { 
      $arg =~ s/,/%%%%Load_Option_File /g;
      $myans = "%%Load_Option_File $arg%%";
     } else {
      $newpath = "$sc_options_directory_path/$arg";
      if ($file_list{$newpath} eq '') { 
        $file_list{$newpath} = "1";
        $myans = &load_file_lines_to_str($newpath);
       } else {
        $myans = " (reload of option $arg attempted!) ";
       }
     }
    ($very_first_part,$myans,$stuff_after) =  
	split(/<h3>--cut here--<\/h3>/i,$myans,3);
    if ($myans eq "") {
      $myans = $very_first_part;
      $tack_on = '';
     } else {
      $tack_on = $very_first_part . $stuff_after;
     }
    if ($myans eq "") {
      $myans = "(option file $arg not found)";
     }
    $field =~ s/(%%Load_Option_File )([^%]+)(%%)/$myans/i;
    if (($tack_on ne '') && (!($field =~ /<h3>--cut here--<\/h3>/i))) {
      $field  = '<H3>--cut here--</H3>' . $field;
      $field .= '<H3>--cut here--</H3>';
     }
    $field .= $tack_on;
   }
  return $field;
 }
#######################################################################
sub cart_web_options {
 local($a1) = @_;
 my $a2;
 if ($a1 eq "") { $a1 = "&nbsp;";}
 my @xx = split(/$sc_opt_sep_marker/,$a1); 
 if ($sc_opt_web_strip_part_number =~ /yes/i) {
   for ($a2=0; $a2 <= $#xx; $a2++) {
     if (substr($xx[$a2],0,1) eq "#") {
       # strip off the part number 
       ($temp,$xx[$a2]) = split(/ /,$xx[$a2],2); 
      }
    }
  }
  return join "<br>",@xx;
 }
#######################################################################
sub cart_email_options {
 local($a1) = @_;
 my $a2,$jchar;
 $jchar = ' ' x $sc_opt_email_leading_spaces;
 my @xx = split(/$sc_opt_sep_marker/,$a1); 
 return join "\n".$jchar,@xx;
 }
#######################################################################
sub make_random_chars {
# name says it all
 local ($part1,$part2,$valid_chars,$chars,$inx);
 $part1 = "abcdefghijklmnopqrstuvwxyz";
 $part2 = $part1;
 $part2 =~ tr/a-z/A-Z/;
 $valid_chars= $part1 . $part2 . "0123456789_-";
 $chars="";
 for ($inx=0;($inx < 2); $inx++) {
   $chars .= substr($valid_chars,rand(length($valid_chars)),1);
  }
 $chars .= substr(rand(9),0,1);
 for ($inx=0;($inx < 2); $inx++) {
   $chars .= substr($valid_chars,rand(length($valid_chars)),1);
  }
 $chars .= substr(rand(9),0,1);
 return $chars;
}
#######################################################################
sub add_csv {
 local ($what, $str) = @_;

 if (($what =~ /\,/) || ($what =~ /\"/)) { #need to quote it
  $what =~ s/\"/\"\"/g;
  $what = '"' . $what . '"';
 }

 if ($str ne "") {
  $what = $str . "," . $what;
  }

 return $what;

}
#######################################################################
sub eval_custom_logic {

 local ($logic,$whoami,$file,$line) = @_;
 local ($err_code, $result) = "";

 if ($logic ne "") {
   $result = eval($logic);
   $err_code = $@;
   if ($err_code ne "") { 
     &update_error_log("$whoami $err_code ",$file,$line);
     $result="";
    }
  }

 return $result;

}
#######################################################################
sub product_page_header {

local ($page_title,$prod_message) = @_;

local ($hidden_fields) = &make_hidden_fields;
local ($my_hdr);
$my_hdr = qq~
<HTML>
<HEAD>
<TITLE>$page_title - $form_data{'product'}</TITLE>
$sc_standard_head_info</HEAD>
<BODY $sc_standard_body_info>
~;
$my_hdr = &agorascript($my_hdr,"","sub product_page_header",__FILE,__LINE__);

&codehook("product_page_header");
print $my_hdr;

&StoreHeader;

if ($prod_message ne "") {
  print "$prod_message\n";
 }
printf($sc_product_display_header, @sc_db_display_fields);

}
#######################################################################
sub product_page_footer {
local($keywords,$zmessage);
$keywords = $form_data{'keywords'};

$keywords =~ s/ /+/g;

local($prod_message) = @_;

$zmessage = qq~
$sc_product_display_footer

$prod_message~;

&codehook("product_page_footer_top");
print $zmessage;
&StoreFooter;

$zmessage=qq~
</BODY>
</HTML>~;
&codehook("product_page_footer_bot");
print $zmessage;

}

sub product_message {
local($keywords);
local($db_status, $rowCount, $nextHits) = @_;
local($warn_message);
local($prevHits) = $nextHits;

$keywords = $form_data{'keywords'};
$save_next= $form_data{'next'}; 

$keywords =~ s/ /+/g;


if ($db_status ne "") 
{

	if ($db_status =~ /max.*row.*exceed.*/i) 
	{

$warn_message =  
	"<DIV ALIGN=CENTER><table width=$sc_search_nav_width " . 
	"bgcolor=$sc_search_nav_bgcolor>";
$warn_message .= "\n<tr>\n <td align=center><FONT $sc_search_nav_font>\n";

if ($maxCount < $rowCount) {
  $my_last = $maxCount;
 } else {
  $my_last = $rowCount;
 }
if ($minCount < 0) {
  $my_first = 1;
 } else {
  $my_first = $minCount + 1;
 }
if ($minCount < $nextHits) {
  $my_prevHits = $maxCount - $nextHits;
 } else {
  $my_prevHits = $prevHits;
 }

if ($my_first == $my_last) {
  $warn_message .= "Found $rowCount items, showing " .
  $my_last . ". &nbsp;&nbsp;";
 } else {
  $warn_message .= "Found $rowCount items, showing " .
  ($my_first) . " to " . $my_last . ". &nbsp;&nbsp;";
 }

		if($form_data{'next'} > "0")
		{
		$form_data{'next'}=$prevCount;
		$href_fields = &make_href_fields;
		$href_info = "'$sc_main_script_url?$href_fields'";
		$warn_message .= qq!
<a href=$href_info>Previous $my_prevHits Matches</a>&nbsp;&nbsp;
!;
		}

		if ($maxCount == $rowCount-1)
		{
			$nextHits = (@database_rows-$maxCount);
			if ($nextHits == 1)
			{
			$form_data{'next'}=$maxCount;
			$href_fields = &make_href_fields;
			$href_info = "'$sc_main_script_url?$href_fields'";
			$warn_message .= qq!
<a href=$href_info>Last Match</a>&nbsp;&nbsp;
!;
			}

		}

	if ($maxCount < $rowCount && $maxCount != $rowCount-1)
	{

		if ($maxCount >= $rowCount-$nextHits )
		{
		$lastCount = $rowCount-$maxCount;
		$form_data{'next'}=$maxCount;
		$href_fields = &make_href_fields;
		$href_info = "'$sc_main_script_url?$href_fields'";
		$warn_message .= qq!
<a href=$href_info>Last $lastCount Matches</a>&nbsp;&nbsp;
!;
		}
		else
		{
		$form_data{'next'}=$maxCount; 
		$href_fields = &make_href_fields;
		$href_info = "'$sc_main_script_url?$href_fields'";
		$warn_message .= qq!
<a href=$href_info>Next $nextHits Matches</a>	
!;
	}

	}

        $warn_message .= "</font></td></tr></table>\n";
	$warn_message .= "</DIV>";

	}

}

$form_data{'next'} = $save_next;# must restore our original state!
return $warn_message;

}

#######################################################################
sub html_search_page_footer {

print qq~

<CENTER>
<INPUT TYPE = "submit" NAME = "modify_cart_button" VALUE = "View/Modify Cart">
$sc_no_frames_button
<INPUT TYPE = "submit" NAME = "order_form_button" VALUE = "Checkout Stand">
</FORM>
</CENTER>  
</BODY>
</HTML>~;

}
#######################################################################
sub standard_page_header {
 local($type_of_page) = @_;
 local ($hidden_fields) = &make_hidden_fields;
 local($header);

 $header = qq~
<HTML>
<HEAD>
$sc_special_page_meta_tags
<TITLE>$type_of_page</TITLE>
$sc_standard_head_info</HEAD>
<BODY $sc_standard_body_info>
~;

 &codehook("standard_page_header");
 print $header;

}
#######################################################################
sub modify_form_footer {
local($footer)="";
open (MODIFYFOOTER, "$sc_templates_dir/change_quantity_footer.inc") ||
&file_open_error("$sc_cart_path", "cartfooter", __FILE__, __LINE__);

while (<MODIFYFOOTER>) {
  $footer .= $_;
 }
close MODIFYFOOTER;
$footer = &script_and_substitute_footer($footer);
&codehook("modify_form_footer");
print $footer;
&StoreFooter;

}

#######################################################################
sub delete_form_footer {
local($footer)="";
open (DELETEFOOTER, "$sc_templates_dir/delete_items_footer.inc") ||
&file_open_error("$sc_cart_path", "cartfooter", __FILE__, __LINE__);

while (<DELETEFOOTER>){
  $footer .= $_;
 }
close DELETEFOOTER;
$footer = &script_and_substitute_footer($footer);
&codehook("delete_form_footer");
print $footer;
&StoreFooter;

}
#######################################################################
sub cart_footer {
local($grand_total,$quantity) = @_;
local($file_title,$footer)="";

$file_title = "$sc_templates_dir/empty_cart_footer.inc";
if (($quantity > 0) || (!(-f $file_title))) {
  $file_title = "$sc_templates_dir/cart_footer.inc";
 }

open (CARTFOOTER, "$file_title") ||
&file_open_error("$sc_cart_path", "cartfooter", __FILE__, __LINE__);

while (<CARTFOOTER>) {
  $footer .= $_;
 }
close CARTFOOTER;
$footer = &script_and_substitute_footer($footer);
&codehook("cart_footer");
print $footer;
&StoreFooter;

}
#######################################################################
sub script_and_substitute_footer {
 local ($footer) = @_;
 local ($cart_id_for_html);
 local($offlineSecureURL)="";

 if($sc_gateway_name eq "Offline") {
   $offlineSecureURL =
"</FORM>
<FORM METHOD\=POST ACTION\=\"$sc_order_script_url\">
<INPUT TYPE\=HIDDEN NAME\=\"cart_id\" VALUE\=\"$cart_id\">";
  }

  $footer = &agorascript($footer,"pre","sub modify_form_footer",
	__FILE__,__LINE__);

  $footer =~ s/%%URLofImages%%/$URL_of_images_directory/g;
  $footer =~ s/%%cart_id%%/%%ZZZ%%/g;
  $footer =~ s/%%sc_order_script_url%%/$sc_order_script_url/g;
  $footer =~ s/%%StepOneURL%%/$sc_stepone_order_script_url/ig;
  $footer =~ s/%%offlineSecureURL%%/$offlineSecureURL/g;

  while ($footer =~ /%%ZZZ%%/) {
    $cart_id_for_html = &cart_id_for_html;
    $footer =~ s/%%ZZZ%%/$cart_id_for_html/;
  }

  $footer = &agorascript($footer,"post","sub modify_form_footer",
	__FILE__,__LINE__);
  $footer = &agorascript($footer,"","sub modify_form_footer",
	__FILE__,__LINE__);

  return $footer;

 }
#######################################################################
sub bad_order_note {

local($button_to_set) = @_;
$button_to_set = "try_again" if ($button_to_set eq "");

&standard_page_header("Error");

&StoreHeader;

print qq!
<CENTER>
<TABLE WIDTH="500">
<TR>
<TD>
<FONT FACE="ARIAL">
<P>
<BR>
I'm sorry, it appears that you did not enter a valid numeric
quantity (whole numbers greater than zero). Please use your 
browser's Back button and try again. Thanks\!<BR>
<P>
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
!;

&StoreFooter;

&call_exit;

}
#######################################################################
sub make_hidden_fields {
local($hidden,$db_query_row,$temp,$db_form_field);
$cart_id_for_html = &cart_id_for_html;
$hidden = qq!
<INPUT TYPE = "hidden" NAME = "cart_id" VALUE = "$cart_id_for_html">
<INPUT TYPE = "hidden" NAME = "page" VALUE = "$form_data{'page'}">!;

if ($form_data{'keywords'} ne "") 
{
$temp = $form_data{'keywords'};
$temp =~ s/\0/ /g; #multi values should be sep. by blanks
$temp =~ s/(\s+)/ /g; #de-multi-blank it
$temp =~ s/(^\s)//g;  #remove leading blank, if there
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "keywords" VALUE = "$temp">!;
}

if ($form_data{'cartlink'} ne "") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "cartlink" VALUE = "$form_data{'cartlink'}">!;
}

if ($form_data{'next'} ne "") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "next" VALUE = "$form_data{'next'}">!;
}

if ($form_data{'ppinc'} ne "") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "ppinc" VALUE = "$form_data{'ppinc'}">!;
}

if ($form_data{'maxp'} ne "") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "maxp" VALUE = "$form_data{'maxp'}">!;
}

if ($form_data{'exact_match'} ne "") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "exact_match" VALUE = "$form_data{'exact_match'}">!;
}

if ($form_data{'case_sensitive'} ne "") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "case_sensitive" VALUE = "$form_data{'case_sensitive'}">!;
}

foreach $db_query_row (@sc_db_query_criteria) 
{
$db_form_field = (split(/\|/, $db_query_row))[0];
if ($form_data{$db_form_field} ne "" && $db_form_field ne "keywords") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "$db_form_field" VALUE = "$form_data{$db_form_field}">!;
}

}

&codehook("make_hidden_fields_bot");
return ($hidden);

}

#######################################################################
sub make_href_fields {
local($href) = "";
local($db_query_row, $db_form_field, $temp);

$cart_id_for_html = &str_encode(&cart_id_for_html);
$href = "cart_id=$cart_id_for_html";

if ($form_data{'page'} ne "")
{ 
$href .= "&page=" . &str_encode($form_data{'page'});
}

if ($form_data{'keywords'} ne "") 
{
$temp = $form_data{'keywords'};
$temp = &str_encode($temp);
$href .= "&keywords=$temp";
}

if ($form_data{'next'} ne "") 
{
$href .= "&next=$form_data{'next'}";
}

if ($form_data{'maxp'} ne "") 
{
$href .= "&maxp=$form_data{'maxp'}";
}

if ($form_data{'ppinc'} ne "") 
{
$href .= "&ppinc=" . &str_encode($form_data{'ppinc'});
}

if ($form_data{'exact_match'} ne "") 
{
$href .= "&exact_match=$form_data{'exact_match'}";
}

if ($form_data{'case_sensitive'} ne "") 
{
$href .= "&case_sensitive=$form_data{'case_sensitive'}";
}

foreach $db_query_row (@sc_db_query_criteria) 
{
$db_form_field = (split(/\|/, $db_query_row))[0];
if ($form_data{$db_form_field} ne "" && $db_form_field ne "keywords") 
{
$href .= "&$db_form_field=" . &str_encode($form_data{$db_form_field});
}

}

&codehook("make_href_fields_bot");
return ($href);

}

#######################################################################
sub PrintNoHitsBodyHTML {
print qq~
<HTML>
<HEAD>
<TITLE>Search Found No Entries</TITLE>
$sc_standard_head_info</HEAD>
<BODY $sc_standard_body_info>

~;

&StoreHeader;

print qq!

<CENTER>  
<TABLE WIDTH=450>

<TR>
<TD>
&nbsp;
</TD>
</TR>

<TR>
<TD>
<FONT FACE=ARIAL>
I'm sorry, no matches were found. Please try your search again.
</TD>
</TR>

<TR>
<TD>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
</TD>
</TR>

</TABLE>
</CENTER>
!;

&StoreFooter;

print qq!

</BODY>
</HTML>

!;

}
#######################################################################
sub capture_STDOUT {
 $capture_STDOUT++;
 $CAPTURE_SAVE[$capture_STDOUT] = select(); 

 open(MYSTDOUT,">$sc_capture_path$capture_STDOUT");
 select(MYSTDOUT);
 $CAPTURE_CURRENT[$capture_STDOUT] = MYSTDOUT;
} 
#######################################################################

sub uncapture_STDOUT {
 local($contents)="";

 if ($capture_STDOUT < 1) { 
   return "";
  }
 select($CAPTURE_SAVE[$capture_STDOUT]); 
 close($CAPTURE_CURRENT[$capture_STDOUT]);
{
 open(MYFILE,"$sc_capture_path$capture_STDOUT"); 
 local $/=undef;
 $contents=<MYFILE>;
 close(MYFILE);
}
 unlink("$sc_capture_path$capture_STDOUT"); 
 $capture_STDOUT = $capture_STDOUT - 1;
 return "$contents";

} 
#######################################################################
sub agorascript {
 local ($str, $type, $zhtml, $zfile, $zline) = @_;
 local ($script_start, $script_start_short, $part1, $part1a, $part2)="";
 local ($kount,$iterations)=0;
 local ($err_code,$return_val,$ztype)="";
 local ($on_agorascript_error)="warn exit ";
 
 if ($type ne "") {
   $ztype = "-$type";
  } else {
   $ztype = "";
  } 
 $script_start_short = "agorascript$ztype";
 $script_start = "<!--agorascript$ztype";
 $script_end = "-->";

$str =~ s/<!--AGSC//ig;
$str =~ s/AGSC-->//ig;

$str =~ s/<!--  agorascript/<!-- agorascript/g;
$str =~ s/<!-- agorascript/<!--agorascript/g;
$str =~ s/<!--agorascript$ztype\n/<!--agorascript$ztype /g;# 

$part1=$str;
while (($iterations < 25) && ($str =~ /${script_start_short} /)) {
 $iterations++;
 $kount=0;
 ($part1,$part2) = split(/${script_start} /,$str,2);
 while ($part2 ne "") {
  ($the_script,$part2) = split(/$script_end/,$part2,2);
  $the_script =~ /([^\xFF]*)/;# should I make this ^M???
  $the_script = $1;
  if ($sc_use_agorascript =~ /yes/i) {
   $return_val = eval($the_script);
   $err_code = $@;
  }
  if ($err_code ne "") { 
    if ($on_agorascript_error =~ /warn/i) { 
       &update_error_log("agorascript$ztype #$iterations.$kount error" .
                         "($zhtml) $err_code ",$zfile,$zline);
      }
    if ($on_agorascript_error =~ /screen/i) { 
       print "<CENTER><DIV ALIGN=LEFT><TABLE WIDTH=550><TR><TD><PRE>\n";
       print "AGORASCRIPT ERROR:\n";
       print "agorascript-$type instance #$kount\n";
       print "Filename: $zhtml\n";
       print "Error: $err_code\n";
       print "</PRE></TD></TR></TABLE></DIV></CENTER>\n"; 
      }
    if ($on_agorascript_error =~ /exit/i) { 
      open(ERROR, $error_page);
      while (<ERROR>) {
        print $_;
       }
      close (ERROR);
      &call_exit;
     }
    if ($on_agorascript_error =~ /discard/i) { 
      $return_val = ""; 
     }
   }
  $part1 .= $return_val;
  $kount++;
  ($part1a,$part2) = split(/$script_start/,$part2,2);
  $part1 .= $part1a;
 } # end of inner while
 $str = $part1;
 $str =~ s/<!--  agorascript-/<!-- agorascript-/g;
 $str =~ s/<!-- agorascript-/<!--agorascript-/g;
} # end of outter while

 return $part1;

}

#######################################################################
sub StoreHeaderFooter {
local ($zfile,$ztitle) = @_;
local ($the_file,$very_first_part,$junk);
local ($item_ordered_message) = "";
local ($myproduct);

$myproduct = $form_data{'product'};
if ($sc_convert_product_token_underlines ne "") {
  $myproduct =~ s/\_/$sc_convert_product_token_underlines/g;
 }

open (MYFILE, "$zfile");
read(MYFILE,$the_file,204800);
close (MYFILE);

($very_first_part,$the_file,$junk) = 
	split(/<h3>--cut here--<\/h3>/i,$the_file,3);
if ($the_file eq "") {
  $the_file = $very_first_part;
 }

if ($cart_id eq "") { print "EMPTY CART VALUE! -- $ztitle<br>\n";}
if ($cart_id_for_html eq "") { print "EMPTY HTML CART VALUE! -- $ztitle<br>\n";}

$href_fields = &make_href_fields;
$hidden_fields = &make_hidden_fields;
$cart_id_for_html = "%%ZZZ%%";

if (($form_data{'add_to_cart_button'} ne "" )&&
    ($sc_shall_i_let_client_know_item_added =~ /yes/i)) {
  $item_ordered_message = $sc_item_ordered_msg_token;
 }

$the_file = &agorascript($the_file,"pre","$ztitle",__FILE,__LINE__);

$the_file =~ s/%%item_ordered_msg%%/$item_ordered_message/g;
$the_file =~ s/%%StepOneURL%%/$sc_stepone_order_script_url/ig;
$the_file =~ s/%%ScriptURL%%/$sc_main_script_url/ig;
$the_file =~ s/%%ScriptPostURL%%/$sc_main_script_url/ig;
$the_file =~ s/%%gateway_username%%/$sc_gateway_username/g;
$the_file =~ s/cart_id=%%cart_id%%/cart_id=/g;
$the_file =~ s/cart_id=/cart_id=$cart_id_for_html/g;
$the_file =~ s/%%cart_id%%/$cart_id_for_html/g;
$the_file =~ s/%%href_fields%%/$href_fields/g;
$the_file =~ s/%%make_hidden_fields%%/$hidden_fields/g;
$the_file =~ s/%%ppinc%%/$form_data{'ppinc'}/g;
$the_file =~ s/%%maxp%%/$form_data{'maxp'}/g;
$the_file =~ s/%%page%%/$page/g;
$the_file =~ s/%%cartlink%%/$cartlink/g;
$the_file =~ s/%%date%%/$date/g;
$the_file =~ s/%%product%%/$myproduct/g;
$the_file =~ s/%%p_id%%/$form_data{'p_id'}/g;
$the_file =~ s/%%keywords%%/$keywords/g;
$the_file =~ s/%%next%%/$form_data{'next'}/g;
$the_file =~ s/%%exact_match%%/$form_data{'exact_match'}/g;
$the_file =~ s/%%exact_case%%/$form_data{'exact_case'}/g;
$the_file =~ s/%%URLofImages%%/$URL_of_images_directory/g;
$the_file =~ s/%%agoracgi_ver%%/$versions{'agora.cgi'}/g;

while ($the_file =~ /%%ZZZ%%/) {
  $cart_id_for_html = &cart_id_for_html;
  $the_file =~ s/%%ZZZ%%/$cart_id_for_html/;
}

$the_file = &agorascript($the_file,"post","$ztitle",__FILE,__LINE__);

return $the_file;

}
#######################################################################
sub StoreHeader {
 print &GetStoreHeader;
}
sub GetStoreHeader {
 return &StoreHeaderFooter("$sc_store_header_file","Store Header");
}
#######################################################################
sub StoreFooter {
 print &GetStoreFooter;
}
sub GetStoreFooter {
 return &StoreHeaderFooter("$sc_store_footer_file","Store Footer");
}
#######################################################################
sub SecureStoreHeader {
 print &GetSecureStoreHeader;
}
sub GetSecureStoreHeader {
 return &StoreHeaderFooter("$sc_secure_store_header_file",
        "Secure Store Header");
}
#######################################################################
sub SecureStoreFooter {
 print &GetSecureStoreFooter;
}
sub GetSecureStoreFooter {
 return &StoreHeaderFooter("$sc_secure_store_footer_file",
        "Secure Store Footer");
}
#######################################################################
sub load_cart_copy {

 local(@cart_fields,$temp);
 local($kount)=100;

 open (CART, "$sc_cart_path") ||
 &file_open_error("$sc_cart_path", "load_cart_contents", 
  __FILE__, __LINE__);

 while (<CART>) {
   chop;    
   $temp = $_;
   $kount++;
   $cart_copy{$kount} = $temp;
  }
 close(CART);
 $sc_cart_copy_made = "yes";
}

#######################################################################
sub save_cart_copy {

 local(@cart_fields,$cart_row_number,$temp,$inx);

 open (CART, ">$sc_cart_path") ||
 &file_open_error("$sc_cart_path", "save_cart_contents", 
  __FILE__, __LINE__);

 foreach $inx (sort (keys %cart_copy)) {
   $temp = $cart_copy{$inx};
   print CART $temp,"\n";
  }
 close(CART);
}
########################################################################
sub update_special_variable_options {
  local ($var_opt_action) = @_;
  my ($inx_into_cart_copy,$inx,$inx_into_cart_copy);
  my ($cart_line,$temp,$code,$option_file,$script_type);
  my ($options_list,@temp_data,%orig_row_options,$display_option_price);
  my ($o_name,$o_price,$o_ship,$c_name,$c_price,$c_ship);
  my ($options_list,$options,$zkey,$zdata,$change,%to_do_list);
  local (@cart_row,%cart_row_options);
  local ($var_opt_used) = 'no';
  if ($sc_disable_variable_options =~ /yes/i) { return;}
  &load_cart_copy;
  foreach $inx_into_cart_copy (sort(keys %cart_copy)) {
    $cart_line = $cart_copy{$inx_into_cart_copy};
    @cart_row = split(/\|/,$cart_line);
    $options_list = $cart_row[$cart{"options_ids"}];
    @temp_data = split(/$sc_opt_sep_marker/,$options_list);
    undef(%cart_row_options);
    undef(%orig_row_options);
    foreach $inx (@temp_data) { 
      ($zkey,$zdata) = split(/\*/,$inx,2);
      $zdata =~ s/\~/\|/g;
      $cart_row_options{$zkey} = $zdata;
      $orig_row_options{$zkey} = $zdata;
     }
    $codelist = $cart_row[$cart{"user1"}];
    if ($codelist ne '') {
      $var_opt_used = 'yes';
      @code_items = split(/\;/,$codelist);
      foreach $code (@code_items) {
        ($option_file,$script_type) = split(/,/,$code,2);
        $option_file = "$sc_options_directory_path/$option_file";
        if (-f "$option_file") {
          open (ZOPTFILE, "<$option_file") ||
            &file_open_error("$option_file","Variable Options",
              __FILE__,__LINE__);
          read (ZOPTFILE,$code,204800);
          close (ZOPTFILE);
          $code = &agorascript($code,$script_type,"Variable Options",
              __FILE__,__LINE__);
         }
       }
     }
    $options_list = '';
    $options = '';
    undef(%to_do_list);
    foreach $zkey (sort(keys %cart_row_options)) {
      $to_do_list{$zkey}=1;
     }
    foreach $zkey (sort(keys %orig_row_options)) {
      $to_do_list{$zkey}=1;
     }
    foreach $zkey (sort(keys %to_do_list)) {
      $cart_option = $cart_row_options{$zkey}; 
      $orig_option = $orig_row_options{$zkey}; 
      if ($options_list ne '') { $options_list .= $sc_opt_sep_marker;}
      ($o_name,$o_price,$o_ship) = split(/\|/,$orig_option,3);
      ($c_name,$c_price,$c_ship) = split(/\|/,$cart_option,3);
      $change = $c_price - $o_price;
      $inx = $cart{'price_after_options'};
      $cart_row[$inx] = $cart_row[$inx] + $change;
      $change = $c_ship - $o_ship;
      $inx = $cart{'shipping'};
      $cart_row[$inx] = $cart_row[$inx] + $change;
      if ($cart_option ne '') {
        $temp = $cart_option;
        $temp =~ s/\|/\~/g;
        $options_list .= $zkey . '*' . $temp;
        if ((0 + $c_price) == 0) { #price zero, do not display it 
          $display_option_price = "";
         } else { # price non-zero, must format it
          $display_option_price = " " . &display_price($c_price);
         }
        if ($options ne "") { $options .= "$sc_opt_sep_marker"; }
        $options .= "$c_name$display_option_price";
       }
     }
    $cart_row[$cart{'options_ids'}] = $options_list;
    $cart_row[$cart{'options'}] = $options;
    $cart_copy{$inx_into_cart_copy} = join('|',@cart_row);
   }
  if ($var_opt_used =~ /yes/i) {
    &save_cart_copy;
   }
 }
#######################################################################
sub create_display_fields {
local (@database_fields) = @_;
local ($id_index,$display_index,$category);
local ($continue)='yes';
&codehook("create_display_fields_top");
if ($continue ne 'yes') {return;}

@display_fields = ();
@temp_fields = @database_fields;
foreach $display_index (@sc_db_index_for_display) 

{

if ($display_index == $sc_db_index_of_price)

{  
$temp_fields[$sc_db_index_of_price] =
&display_price($temp_fields[$sc_db_index_of_price]);
}

push(@display_fields, $temp_fields[$display_index]);
}

@item_ids = ();

foreach $id_index (@sc_db_index_for_defining_item_id) 
{
$database_fields[$id_index] =~ s/\"/~qq~/g;
$database_fields[$id_index] =~ s/\>/~gt~/g;
$database_fields[$id_index] =~ s/\</~lt~/g;

push(@item_ids, $database_fields[$id_index]);
	
}

$itemID = join("\|",@item_ids);

$ppinc_root_name = '';
if ($sc_ppinc_product_db_field ne '') { 
  $ppinc_root_name = $database_fields[$db{$sc_ppinc_product_db_field}];
 }
if ($ppinc_root_name eq '') { 
  $category = $database_fields[$db{'product'}];
  if ($sc_use_category_name_as_ppinc_root =~ /yes/i){
    if (-f "$sc_templates_dir/${category}.inc") {$ppinc_root_name = $category;}
   } else {
    $ppinc_root_name = $category_ppinc{$category};
   }
 }
if ($ppinc_root_name eq '') { 
  $ppinc_root_name = 'productPage';
 }
&codehook("create_display_fields_bot");
}
#######################################################################
sub itemID { 
 local ($my_modifier) = @_;
 local (@stuff) = @item_ids;
 if ($my_modifier ne '') {
   @stuff[0] .= $sc_web_pid_sep_char . $my_modifier;
  }
 return "item-" . join("\|",@stuff);
}
#######################################################################
sub prodID { 
 local ($my_modifier) = @_;
 local (@stuff) = @item_ids;
 if ($my_modifier ne '') {
   @stuff[0] .= $sc_web_pid_sep_char . $my_modifier;
  }
 return $stuff[0];
}
#######################################################################
sub QtyBox { 
 local ($my_modifier,$qty) = @_;
 local ($my_box) = $qty_box_html;
 local ($my_pid) = &prodID($my_modifier);
 local ($my_item_id) = &itemID($my_modifier);
 $my_box =~ s/%%itemID%%/$my_item_id/ig;
 $my_box =~ s/%%prodID%%/$my_pid/ig;
 $my_box =~ s/%%ProductID%%/$my_pid/ig;
 $my_box =~ s/%%Product_ID%%/$my_pid/ig;
 $my_box =~ s/%%Qty%%/$qty/ig;
 return $my_box;
}
#######################################################################
sub displayProductPage {
 print &prep_displayProductPage(&get_sc_ppinc_info);
}
#######################################################################
sub prep_displayProductPage {
local ($the_whole_page) = @_;
local ($keywords, $imageURL, $hidden_fields, $href_fields, $my_ppinc);
local ($myproduct);
local ($suppress_qty_box)='';
local ($qty_box_html) = '';
local ($qty)='';
local ($arg)="";
local ($xarg,$xarg1,$xarg2);
local ($myans)="";
local ($auto_opt_no)=0;

if ($sc_default_qty_to_display ne '') {
  $qty = $sc_default_qty_to_display;
 }
$myproduct = $form_data{'product'};
if ($sc_convert_product_token_underlines ne "") {
  $myproduct =~ s/\_/$sc_convert_product_token_underlines/g;
 }
$keywords = $form_data{'keywords'}; 
$keywords =~ s/ /+/g;

$href_fields = &make_href_fields;
$hidden_fields = &make_hidden_fields;
$cart_id_for_html = "%%ZZZ%%";

$the_whole_page =~ s/%%optionFile%%/$display_fields[3]/ig;

while ($the_whole_page =~ /(%%Load_Option_File )([^%]+)(%%)/i) {
  local($option_location);
  local($field) = "";
  $option_location = $2;
  $option_location =~ s/ //g;

  $field = &load_opt_file($option_location);
  $field = &option_prep($field,$option_location,$item_ids[0]);
  $the_whole_page =~ s/(%%Load_Option_File )([^%]+)(%%)/$field/i;
 }

$the_whole_page = &agorascript($the_whole_page,"pre",
                  "$my_ppinc",__FILE__,__LINE__);

&codehook("before_ppinc_token_substitution");

$imageURL = $display_fields[0];
$imageURL =~ s/%%URLofImages%%/$URL_of_images_directory/g;
if ($qty_box_html eq '') {
  $qty_box_html = $sc_default_qty_box_html;
 }
$the_whole_page =~ s/%%Qty_Box%%/%%QtyBox/ig;
if ($suppress_qty_box) {
  $the_whole_page =~ s/%%QtyBox%%/&nbsp;/ig;
 } else {
  $the_whole_page =~ s/%%QtyBox%%/$qty_box_html/ig;
 }

while ($the_whole_page =~ /(%%QtyBox-)([^%]+)(%%)/i) {
  $arg = $2;
  ($arg1,$arg2,$junk) = split(/,/,$arg . ",$qty,",3);
  $arg1 =~ s/'//g;
  $arg1 =~ s/"//g;
  $arg2 =~ s/'//g;
  $arg2 =~ s/"//g;
  $myans = &QtyBox($arg1,$arg2);
  $the_whole_page =~ s/(%%QtyBox-)([^%]+)(%%)/$myans/i;
}

while ($the_whole_page =~ /(%%itemID-)([^%]+)(%%)/i) {
  $arg = $2;
  ($arg1,$arg2) = split(/,/,$arg,2);
  $arg1 =~ s/'//g;
  $arg1 =~ s/"//g;
  $myans = &itemID($arg1);
  $the_whole_page =~ s/(%%itemID-)([^%]+)(%%)/$myans/i;
}

while ($the_whole_page =~ /(%%prodID-)([^%]+)(%%)/i) {
  $arg = $2;
  ($arg1,$arg2) = split(/,/,$arg,2);
  $arg1 =~ s/'//g;
  $arg1 =~ s/"//g;
  $myans = &prodID($arg1);
  $the_whole_page =~ s/(%%prodID-)([^%]+)(%%)/$myans/i;
}

$the_whole_page =~ s/%%Qty%%/$qty/ig;
$the_whole_page =~ s/%%URLofImages%%/$URL_of_images_directory/ig;
$the_whole_page =~ s/%%scriptURL%%/$sc_main_script_url/ig;
$the_whole_page =~ s/%%StepOneURL%%/$sc_stepone_order_script_url/ig;
$the_whole_page =~ s/%%ScriptPostURL%%/$sc_main_script_url/ig;
$the_whole_page =~ s/%%gateway_username%%/$sc_gateway_username/ig;
$the_whole_page =~ s/%%CartID%%/%%cart_id%%/ig;
$the_whole_page =~ s/%%cartID%%/%%cart_id%%/ig;
$the_whole_page =~ s/cart_id=%%cart_id%%/cart_id=/ig;
$the_whole_page =~ s/cart_id=/cart_id=$cart_id_for_html/ig;
$the_whole_page =~ s/%%cartID%%/$cart_id_for_html/ig;
$the_whole_page =~ s/%%cart_id%%/$cart_id_for_html/ig;
$the_whole_page =~ s/%%agoracgi_ver%%/$versions{'agora.cgi'}/ig;
$the_whole_page =~ s/%%make_hidden_fields%%/$hidden_fields/ig;
$the_whole_page =~ s/%%ppinc%%/$form_data{'ppinc'}/ig;
$the_whole_page =~ s/%%maxp%%/$form_data{'maxp'}/ig;
$the_whole_page =~ s/%%page%%/$page/ig;
$the_whole_page =~ s/%%cartlink%%/$cartlink/ig;
$the_whole_page =~ s/%%product%%/$myproduct/ig;
$the_whole_page =~ s/%%p_id%%/$form_data{'p_id'}/ig;
$the_whole_page =~ s/%%keywords%%/$keywords/ig;
$the_whole_page =~ s/%%next%%/$form_data{'next'}/ig;
$the_whole_page =~ s/%%exact_match%%/$form_data{'exact_match'}/ig;
$the_whole_page =~ s/%%exact_case%%/$form_data{'exact_case'}/ig;
$the_whole_page =~ s/%%form_user1%%/$form_data{'user1'}/ig;
$the_whole_page =~ s/%%form_user2%%/$form_data{'user2'}/ig;
$the_whole_page =~ s/%%form_user3%%/$form_data{'user3'}/ig;
$the_whole_page =~ s/%%form_user4%%/$form_data{'user4'}/ig;
$the_whole_page =~ s/%%form_user5%%/$form_data{'user5'}/ig;
$the_whole_page =~ s/%%href_fields%%/$href_fields/ig;
$the_whole_page =~ s/%%image%%/$imageURL/ig;
$the_whole_page =~ s/%%name%%/$display_fields[1]/ig;
$the_whole_page =~ s/%%description%%/$display_fields[2]/ig;
$the_whole_page =~ s/%%price%%/$display_fields[4]/ig;
$the_whole_page =~ s/%%cost%%/$item_ids[2]/ig;
$the_whole_page =~ s/%%shippingPrice%%/$display_fields[5]/ig;
$the_whole_page =~ s/%%shipping%%/$display_fields[5]/ig;
$the_whole_page =~ s/%%shippingWeight%%/$display_fields[5]/ig;
$the_whole_page =~ s/%%userFieldOne%%/$display_fields[6]/ig;
$the_whole_page =~ s/%%userFieldTwo%%/$display_fields[7]/ig;
$the_whole_page =~ s/%%userFieldThree%%/$display_fields[8]/ig;
$the_whole_page =~ s/%%userFieldFour%%/$display_fields[9]/ig;
$the_whole_page =~ s/%%userFieldFive%%/$display_fields[10]/ig;
$the_whole_page =~ s/%%itemID%%/item-$itemID/ig;
$the_whole_page =~ s/%%Product_ID%%/%%prodID%%/ig;
$the_whole_page =~ s/%%ProductID%%/%%prodID%%/ig;
$the_whole_page =~ s/%%prodID%%/$item_ids[0]/ig;
$the_whole_page =~ s/%%CategoryID%%/$item_ids[1]/ig;

while ($the_whole_page =~ /%%ZZZ%%/) {
  $cart_id_for_html = &cart_id_for_html;
  $the_whole_page =~ s/%%ZZZ%%/$cart_id_for_html/;
}

while ($the_whole_page =~ /%%AutoOptionNo%%/i) {
  $auto_opt_no = $auto_opt_no + 1;
  if ($auto_opt_no < 100) {$auto_opt_no = "0$auto_opt_no";} 
  if ($auto_opt_no < 10) {$auto_opt_no = "0$auto_opt_no";} 
  $the_whole_page =~ s/%%AutoOptionNo%%/$auto_opt_no/i;
}

$the_whole_page = &agorascript($the_whole_page,"autoopt",
                  "$my_ppinc",__FILE__,__LINE__);

while ($the_whole_page =~ /(%%eval)([^%]+)(%%)/i) {
  $arg = $2;
  $myans = eval($arg);
  if ($@ ne ""){ $myans = "%% Eval Error on: $arg %%";}
  $the_whole_page =~ s/(%%eval)([^%]+)(%%)/$myans/i;
}

&codehook("after_ppinc_token_substitution");

$the_whole_page = &agorascript($the_whole_page,"post",
                  "$my_ppinc",__FILE__,__LINE__);

return $the_whole_page;

}
#######################################################################
sub get_sc_ppinc_info {
 local ($my_ppinc,$the_whole_page,$keywords,$orig_ppinc);
 local ($used_default) = 0;

 if ($sc_ppinc_info ne "") { 
  # no need to load it, already have it
   return $sc_ppinc_info;    
  }

 $my_ppinc = "$sc_templates_dir/$ppinc_root_name";
 if ($form_data{'ppinc'} ne "") {
   $form_data{'ppinc'} =~ /([\w-_]+)/;
   $name = $1;
   $test = $my_ppinc ."-" . $name . ".inc";
   if (-f $test) {
     $my_ppinc = $test;
    } else {
     $my_ppinc .= ".inc";
    }
  } else {
   $my_ppinc .= ".inc";
  }

 if (!(-f "$my_ppinc")) {
   $orig_ppinc = $my_ppinc;
   $my_ppinc = "$sc_templates_dir/productPage.inc";
   $used_default = 1;
  }

 open (PAGE, "$my_ppinc") ||
   &file_open_error("$sc_cart_path", "get ppinc -- $my_ppinc", 
     __FILE__, __LINE__);

 read(PAGE,$the_whole_page,102400); 
 close PAGE;

 ($very_first_part,$the_whole_page,$junk) = 
	split(/<h3>--cut here--<\/h3>/i,$the_whole_page,3);
 if ($the_whole_page eq "") {
   $the_whole_page = $very_first_part;
  }

 if (($sc_debug_mode =~ /yes/i) && ($used_default == 1)) {
   $the_whole_page = "<!-- Used Default, $orig_ppinc not found. -->\n" . 
    $the_whole_page;
  }

 $sc_ppinc_info = $the_whole_page; 
 $last_ppinc_name = $my_ppinc;
 return $sc_ppinc_info;

}
##############################################################################
sub std_two_across {
local ($myans)="";
if ($rowCount == (1+$minCount)) { #first one
  $ags_row_item=0;
  $ags_tot_item=0;
  $myans .= '<tr><td colspan=3><table width="100%" border=1>'."\n";
 }
$ags_row_item++;
$ags_tot_item++;
if (($rowCount == ($maxCount)) || ($rowCount == ($num_returned)))
 { # very last one, need to join these two cells, no border
  if ($ags_row_item == 1) { # first and only one
    $myans .= '<td width="100%" colspan=2><table width=100% border=0>'."\n";
    $myans .= '<tr>'."\n";
   }
 }
if ($ags_row_item == 2) { 
  $ags_row_item=0; 
  $myans .= '<td width="50%"><table width=100% border=0>'."\n";
 } else { 
  $myans .= '<tr><td width="50%"><table width=100% border=0>'."\n";
 }

$myans .= qq~
<TR WIDTH="100%"> 
<TD ALIGN="CENTER" WIDTH="160" VALIGN="MIDDLE">
<FONT FACE="ARIAL" SIZE="2">
<FORM METHOD = "post" ACTION = "%%scriptURL%%">
%%make_hidden_fields%%
<BR>
%%optionFile%%
<BR>
<P>
<!--BEGIN SELECT QUANTITY BUTTON-->
<TABLE>
<TR ALIGN="CENTER">
 <TD VALIGN="MIDDLE">%%QtyBox%%</TD>
 <TD VALIGN="MIDDLE"><INPUT TYPE="IMAGE"
 NAME="add_to_cart_button" VALUE="Add To Cart"
 SRC="%%URLofImages%%/add_to_cart.gif" BORDER="0">
 </TD>
</TR>
</TABLE>
<!--END SELECT QUANTITY BUTTON-->
</TD>
<TD ALIGN="CENTER" WIDTH="150">%%image%%</TD>
</tr>
~;

if (($rowCount == ($maxCount)) || ($rowCount == ($num_returned)))
 { # very last one
  if ($ags_row_item == 1) { # first and only one
    $myans .= '</table></td>'."\n";
    $myans .= '<td width="50%"><table width=100%>'."\n";
   }
 }

$myans .= qq~
<tr><TD colspan=2>
<FONT FACE="ARIAL" SIZE="2">
<b>%%name%%</b>
<br>
%%description%%
</FONT>
</TD>
</FORM>
</TR>
<TR> 
<td>
<FONT FACE="ARIAL" SIZE="2" color="#FF0000">%%price%%</font>
</td>
<td align="right">
<A HREF="${sc_main_script_url}?dc=1&%%href_fields%%"><FONT 
FACE=ARIAL>Check Out</FONT>
</A>
</TD>
</TR>
~;

if ($ags_row_item == 1) { # first one
  $myans .= '</table></td>'."\n";
 } else { # second one
  $myans .= '</table></td></tr>'."\n";
 }
if (($rowCount == ($maxCount)) || ($rowCount == ($num_returned)))
 { # very last one, need to join these two cells, no border
  if ($ags_row_item == 1) { # first and only one
    $myans .= '</tr></table></td>'."\n";
   }
 }
if (($rowCount == ($maxCount)) || ($rowCount == ($num_returned)))
 {
  $myans .= '</table></td></tr>'."\n";
 }
return $myans;
}
#############################################################################
sub vf_get_data {
  local ($VF_file,$fname,$ID,@RECORD) = @_;
  my $field,$xans,@REC;
  @REC = @RECORD; 
  return &vf_eval($fname);
 }

sub vf_eval {
  local ($fname) = @_;
  my $xcmd,$hname;
 # need to get the field itself from the field name
  $xcmd = '$field = $' . $VF_DEF{$VF_file} . '{"' . $fname . '"}';
  eval($xcmd);
  return &vf_do_eval_work($field);
 }

sub vf_do_eval_work {
  local ($field) = @_;
  my $ans,$result,$temp,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9;
  $ans='';
  if ($VF_HOOK{$VF_file} ne '') {
    eval('&' . "$VF_HOOK{$VF_file};");
   } else {
    if (substr($field,0,1) eq '*') { 
      eval(substr($field,1,9999));
      $err_code = $@;
      if ($err_code ne "") {
        &update_error_log("V-field ${field}($VF_file) error: $err_code",
		__FILE__,__LINE__);
       }
     } else { 
      $ans = $RECORD[$field];
     }
   }
  return $ans;
 }
############################################################################
1; # library

