
<!--BEGIN HEADER TABLE-->
<table WIDTH=765 HEIGHT=28 BGCOLOR="#680098" BORDER=0 CELLPADDING=0 CELLSPACING=0>
<tr>
<td HEIGHT=40 ALIGN=CENTER>
<font face="Verdana, Arial" size=+1 color="#FFFFFF"><b>Powered by AgoraCart - AgoraCart.com
</b><br></font><font face="Verdana, Arial" size=2 color="white"><i>Thanks for Visiting our Store!</i></font>
</td><td HEIGHT=40 ALIGN=right><font face="Verdana, Arial" color="#ffffff" size=2><form METHOD="POST" ACTION="agora.cgi">
<input TYPE="hidden" NAME="cart_id" VALUE="%%cart_id%%"><input TYPE="text" NAME="keywords" SIZE=20 MAXLENGTH=40>
<input TYPE="hidden" NAME="ppinc=search" VALUE="search">
  <input TYPE="submit" NAME="search_request_button" VALUE=" Search "> </form></font>
</td></tr></TABLE>
<TABLE WIDTH=765 BORDER=0 CELLSPACING=0 CELLPADDING=0 align=top>
<TR><TD WIDTH=145 valign=top background="agora.cgi?secpicserve=steelgrey.jpg" bgcolor="#cccccc" height=100%>
<b><font face="Arial,Helvetica" color="#FF0000" size=2><CENTER>Shopping Categories:</CENTER></font><font face="Arial,Helvetica" color="#FF0000" size=1>
<!--agorascript-pre { # code to count up the CART contents
local(%db_ele,$sku,$category,%category_list);
if (!($sc_db_lib_was_loaded =~ /yes/i))
 { &require_supporting_libraries (__FILE__, __LINE__, "$sc_db_lib_path"); }
&capture_STDOUT;
&get_prod_db_element($db{"product"},*db_ele);
foreach $sku (keys %db_ele) {
  $category = $db_ele{$sku};
  $category_list{$category}++;
}
foreach $category (sort(keys %category_list)) {
   $category2 = $category;
  $category2=~s/_/ /g;
  print "&nbsp;&nbsp;<a href=\"agora.cgi?cart_id=%%cart_id%%&product=",
    "$category\"> $category2 </a><br>\n";
}
&uncapture_STDOUT; }
--></font></b>
<BR><HR><BR>
<CENTER><font face="Arial,Helvetica" color=red size=2><B>Look For Gifts under this Price:</B></font>
<form METHOD="POST" ACTION="agora.cgi"><input 
TYPE="hidden" NAME="cart_id" VALUE="%%cart_id%%">$ <input TYPE="text" NAME="query_price_high_range" SIZE=7 MAXLENGTH=10><BR>
<input TYPE="hidden" NAME="ppinc" VALUE="search">
  <input TYPE="submit" NAME="search_request_button" VALUE=" Search "></form></CENTER><br><br>
<font face="Arial,Helvetica" color="#FF0000" size=2><CENTER><b>Company Info:</b></CENTER></font>
<!--agorascript-pre 
&capture_STDOUT; 
&cartlinks;
  print "<font face=\"Arial\" size=\"2\">";
$cartlinks =~ s/<br>/<br>&nbsp;&nbsp;/ig;
# take make links underlined
$cartlinks =~ s/style=\"text-decoration: none\"//ig;
# to layout horizontally with 3 spaces
# $cartlinks =~ s/<br>/&nbsp;&nbsp;&nbsp;/ig;
# to layout horizontally with | dividers spaces
# $cartlinks =~ s/<br>/&nbsp;&nbsp;|&nbsp;&nbsp;/ig;
print "&nbsp;&nbsp;";
print $cartlinks;
  print "</font>";
&uncapture_STDOUT;  -->
<br>
<br>
</TD><TD WIDTH="620" valign=top>
<!--agorascript-pre {
local (@my_cart_fields,$my_cart_row_number,$result);
local ($count,$price,$product_id,$quantity,$total_cost,$total_qty)=0;
if ((!(-f "$sc_cart_path"))||($sc_processing_order =~ /yes/i)) {return ""}
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
   $total_cost = $total_cost + $quantity * $price;
   $total_qty = $total_qty + $quantity;
  } # End of while (<CART>)
close (CART);
if ($count > 0) {
  $result = '<div align="center">' .
      '<center><table border=0 width=100% cellspacing=0  bgcolor="#cccccc" background="agora.cgi?secpicserve=steelgrey.jpg"><tr>' .
      '<td width="25%" align=left>&nbsp;&nbsp;' .
      '<a href="agora.cgi?dc=1&%%href_fields%%' . 
      '"><font color="#0000ff">View Cart</font></a></td>' .
     '<td width="50%" align=center><font color="#000000">' .
     "Items in shopping cart: $total_qty &nbsp;\n&nbsp; " . 
      "<br>Item cost subtotal:&nbsp; " . &display_price($total_cost) . 
      "</font></td>\n" .
      '<td width="25%" align=right>' .
      '<a href="%%StepOneURL%%?order_form_button.x=1&%%href_fields%%' . 
      '"><font color="#0000ff">Check Out</font></a>&nbsp;&nbsp;</td>' .
      "</tr></table></center></div>";
 } else {
  $result = "";
 }
 return $result;
}-->

<!--END HEADER TABLE-->
