
<!--BEGIN HEADER TABLE-->
<table WIDTH=765 HEIGHT=28 BGCOLOR="#680098" BORDER=0 CELLPADDING=0 CELLSPACING=0>
<tr>
<td HEIGHT=40 ALIGN=CENTER>
<font face="Verdana, Arial" size=+1 color="#FFFFFF"><b>Powered by AgoraCart - AgoraCart.com
</b><br></font><font face="Verdana, Arial" size=2 color="white"><i>Thanks for Visiting our Store!</i></font>
</td><td HEIGHT=40 ALIGN=right><font face="Verdana, Arial" color="#ffffff" size=2><form METHOD="POST" ACTION="
<!--agorascript-post { &capture_STDOUT;
print "$sc_store_url";
&uncapture_STDOUT;
} -->">
<input TYPE="hidden" NAME="cart_id" VALUE="%%cart_id%%"><input TYPE="text" NAME="keywords" SIZE=20 MAXLENGTH=40>
<input TYPE="hidden" NAME="ppinc" VALUE="search">
  <input TYPE="submit" NAME="search_request_button" VALUE=" Search "> </form></font>
</td></tr></TABLE>
<TABLE WIDTH=765 BORDER=0 CELLSPACING=0 CELLPADDING=0 align=top>
<TR><TD WIDTH=145 valign=top background="agora.cgi?secpicserve=steelgrey.jpg" height=100%><br>
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
  print "&nbsp;&nbsp;<a href=\"$sc_store_url?cart_id=%%cart_id%%&product=",
    "$category\"> $category2 </a><br>\n";
}
&uncapture_STDOUT; }
--></font></b>
<BR><HR><BR>
<CENTER><font face="Arial,Helvetica" color=red size=2><B>Look For Gifts under this Price:</B></font>
<form METHOD="POST" ACTION="<!--agorascript-post { &capture_STDOUT;
print "$sc_store_url";
&uncapture_STDOUT;
} -->"><input 
TYPE="hidden" NAME="cart_id" VALUE="%%cart_id%%">$ <input TYPE="text" NAME="query_price_high_range" SIZE=7 MAXLENGTH=10><BR>
<input TYPE="hidden" NAME="ppinc=search" VALUE="search">
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

<!--END HEADER TABLE-->
