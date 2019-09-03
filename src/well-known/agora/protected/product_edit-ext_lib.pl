# file ./store/protected/product_edit-ext_lib.pl

$versions{'product_edit'} = "20010909";

{
 local ($modname) = 'product_edit';
 &register_extension($modname,"Product DB Edit",$versions{$modname});
 &register_menu('display_screen',"display_catalog_screen",
	$modname,"Display Product DB Catalog");
 &register_menu('add_screen',"add_product_screen",
	$modname,"Write New Product");
 &register_menu('edit_screen',"edit_product_screen",
	$modname,"Edit Product");
 &register_menu('skip_edit_screen',"edit_product_screen",
	$modname,"BASE -- needed if editing products");
 &register_menu('delete_screen',"delete_product_screen",
	$modname,"Delete Product Screen");
 &register_menu('AddProduct',"action_add_product",
	$modname,"Add Product Form");
 &register_menu('EditProduct',"action_edit_product",
	$modname,"Edit Product Form");
 &register_menu('SubmitEditProduct',"action_submit_edit_product",
	$modname,"Write Edited Product");
 &register_menu('DeleteProduct',"action_delete_product",
	$modname,"Delete a product");
 &add_item_to_manager_menu("Product Add","add_screen=yes","");
 &add_item_to_manager_menu("Product Edit","edit_screen=yes","");
 &add_item_to_manager_menu("Product Delete","delete_screen=yes","");
}


if ($mc_max_items_per_page eq '') {
  $mc_max_items_per_page = 25; 
 }
if ($mc_put_edit_helper_at_top eq '') { 
  $mc_put_edit_helper_at_top = 'no'; 
 }
if ($mc_put_edit_helper_at_bot eq '') { 
  $mc_put_edit_helper_at_bot = 'yes'; 
 }

################################################################################
sub display_categories {

local ($link_to) = @_;
local ($maxcols) = 3;
local (%category_list,%db_ele);

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0 CELLPADDING=0 CELLSPACING=0>
	<TR WIDTH=550>
	<TD colspan=$maxcols>
        <center><FORM METHOD=POST ACTION=manager.cgi>
	<INPUT TYPE=SUBMIT NAME=$link_to 
          VALUE=" Display All Items in All Categories">
	<INPUT TYPE=HIDDEN NAME=category VALUE="_ALL_">
	</FORM></center>
	</TD>
	</TR>
ENDOFTEXT

$element_id = $db{"product"};
&get_prod_db_element($element_id,*db_ele);

foreach $sku (keys %db_ele) {
  $category = $db_ele{$sku};
  $category_list{$category}++;
} 

$items = 0;

foreach $category (sort(keys(%category_list))) {
 $items++;
###
 if ($items == 1) {
   print "<TR WIDTH=550>\n";
  }
 print <<ENDOFTEXT;
	<TD colspan=1>
	<CENTER>
	<FORM METHOD=POST ACTION=manager.cgi>
	<INPUT TYPE=SUBMIT NAME=$link_to 
         VALUE="$category ($category_list{$category})">
	<INPUT TYPE=HIDDEN NAME=category VALUE="$category">
	</FORM>
	</CENTER>
	</TD>
ENDOFTEXT

 if ($items == $maxcols) {
   $items = 0;
   print "</TR>\n";
  }

 }
# End of foreach

 if ($items > 0) {
   $items = 0;
   print "</TR>\n";
  }


print <<ENDOFTEXT;
	</TABLE>
	</CENTER>
ENDOFTEXT

}

#############################################################################################

sub display_items_in_category {

local ($button,$col_header,$link,$return_link) = @_;
local ($items) = 0;
local ($first,$last);
local (%category_list,%db_ele);
local ($product_id,$found_it,@db_row,$raw_data);

###

$element_id = $db{"product"};
&get_prod_db_element($element_id,*db_ele);
$first = $in{'first'};
if (($first+0) lt 1) { $first = 1;}
$last = $first -1 +$mc_max_items_per_page;
$table_text = '';
foreach $sku (sort(keys %db_ele)) {
  $category = $db_ele{$sku};

if ($sku) {

if ($in{'category'} eq "_ALL_" || $in{'category'} eq $category) {

 if ($items <= $last) {
   $found_it = &get_prod_db_row($sku, *db_row, *raw_data, "no");
  } else {
   $raw_data='';
   @db_row=();
  }
$price = $db_row[$db{"price"}];
$name  = $db_row[$db{"name"}];
#($sku, $category, $price, $short_description, $image, 
# $long_description, $options) = split(/\|/,$_);

 $items++;
 if (($items >= $first) && ($items <= $last)) {
   $table_text .= qq~
	<TR WIDTH=550>
	<TD WIDTH=125>
<INPUT TYPE="SUBMIT" NAME="$link\WhichProduct" VALUE="$sku">
</TD>
	<TD WIDTH=100>
	$category
	</TD>
	<TD WIDTH=275>
	$name
	</TD>
	<TD WIDTH=75>
	$price
	</TD>
	</TR>
   ~;
   }
 }
}

} 

if ($items < $last) {$last = $items;}
$link_info = 
"manager.cgi?${return_link}=yes&category=$in{'category'}";
$nav_info = "Found $items items, showing $first to $last.";
$nav_info .= "&nbsp;&nbsp;&nbsp;";
if ($first > 1) {
  $newfirst = $first - $mc_max_items_per_page;
  $nav_info .= "<A HREF='$link_info&first=$newfirst'>Previous</A>";
  $nav_info .= "&nbsp;&nbsp;&nbsp;";
 }
if ($items > $last) {
  $newfirst = $last + 1;
  $nav_info .= "<A HREF='$link_info&first=$newfirst'>Next</A>";
  $nav_info .= "&nbsp;&nbsp;&nbsp;";
 }

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0 CELLPADDING=4 CELLSPACING=0>
<TR WIDTH=550>
<TD ALIGN="CENTER">
$nav_info
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT

print <<ENDOFTEXT;
<CENTER>
<FORM METHOD=POST ACTION=manager.cgi>
<INPUT TYPE=HIDDEN NAME=$link\Product VALUE="$button">
<INPUT TYPE=HIDDEN NAME=category VALUE=$in{'category'}>
<INPUT TYPE=HIDDEN NAME="first" VALUE="$in{'first'}">
<TABLE WIDTH=550 BORDER=1 CELLPADDING=5 CELLSPACING=0>
	<TR WIDTH=550>
	<TD WIDTH=125>
	$col_header
	</TD>
	<TD WIDTH=100>
	<B>Category</B>
	</TD>

	<TD WIDTH=275>
	<B>Description</B>
	</TD>

	<TD WIDTH=75>
	<B>Price</B>
	</TD>

	</TR>
$table_text
ENDOFTEXT

if ($items <= 0) {
 print <<ENDOFTEXT;
	<TR>
	<TD colspan=5>
        <center><FORM METHOD=POST ACTION=manager.cgi>
	<INPUT TYPE=SUBMIT NAME=$return_link
          VALUE=" Display List Of Categories">
	<INPUT TYPE=HIDDEN NAME=category VALUE="">
	</FORM></center>
	</TD>
	</TR>
ENDOFTEXT
 }

print <<ENDOFTEXT;

</TABLE>
</FORM>
</CENTER>
ENDOFTEXT

}
################################################################################
sub DisplayRequestedProduct

{

print <<ENDOFTEXT;


<TR WIDTH=500>
<TD WIDTH=125>
$sku
</TD>
<TD WIDTH=125>
$category
</TD>
<TD WIDTH=125>
$short_description
</TD>
<TD WIDTH=125>
$price
</TD>
</TR>

ENDOFTEXT

}
#######################################################################################
sub add_product_screen

{
local($add_product_success) = @_;

##

local($sku, $category, $price, $short_description, $image, 
      $long_description, $shipping_price, $userDefinedOne, 
      $userDefinedTwo, $userDefinedThree, $userDefinedFour, 
      $userDefinedFive, $options);

$new_sku = &get_next_prod_key;
if ($mc_assign_final_sku_at_update =~ /yes/i) {
  $new_sku .= "*";
 }
##

$options_file_list = &make_file_option_list("./html/options","");

print &add_item_form;

}
############################################################################
sub edit_item_form {
 
return &edit_item_form_new;

}
############################################################################
sub add_item_form {
 
return &add_item_form_new;

}
############################################################################
sub add_item_form_new {
local ($form,$msg,$imgup)="";

if ($mc_file_upload_ok =~ /yes/) { 
  $imgup = "<tr><td colspan=4>Upload Image File(s): " .
           "<input type=file name=upfile1 size=20> &nbsp;&nbsp;" . 
           "<input type=file name=upfile2 size=20></td></tr>\n";
 }

if($add_product_success eq "yes"){
$msg .= qq~<br><FONT FACE=ARIAL SIZE=2 COLOR=RED>Product number <a 
target="_BLANK"
href="../agora.cgi?p_id=$in_sku"><b>$in_sku</b></a> has been added
to the catalog.</FONT>~;
} elsif($add_product_success eq "no") {
$msg .= qq~<br><FONT FACE=ARIAL SIZE=2 COLOR=RED>PRODUCT ID # already 
exists in datafile! Unable to add product, please 
choose a new PRODUCT ID # number.</FONT>~;
} 

$form = qq~<HTML>
<HEAD>
<TITLE>Add Product $new_sku</TITLE>
</HEAD>
<BODY BGCOLOR=WHITE>
<form METHOD="POST" ACTION="manager.cgi" enctype="multipart/form-data">
  <div align="center"><center><table BORDER="0" CELLPADDING="0"
CELLSPACING="0" WIDTH="755">
    <tr><td><table border=0 cellpadding=2 ><tr>
     <td colspan=3 width="72%">
<strong> $manager_banner_main 
Quick Entry</strong>&nbsp;&nbsp;&nbsp;$msg</td>
<td><INPUT 
TYPE=SUBMIT NAME="edit_screen" 
VALUE="Done Entering Products"><INPUT TYPE=HIDDEN NAME="first"
VALUE="$in{'first'}"></td>
</td>
    </tr></table></td>
    </tr>
<tr><td colspan=4><table BORDER="1" CELLPADDING="2" CELLSPACING="0"
WIDTH="755">
  
    <tr>
      <td colspan="1" width="30%"><font FACE="ARIAL" SIZE="2"><b>PRODUCT ID #</b> (normally do
      not change this!)&nbsp; </font><input NAME="sku" VALUE="$new_sku" 
      TYPE="TEXT" SIZE="10" MAXLENGTH="10"></td>
      <td colspan="2" width="40%"><div align="left"><table border="0" cellpadding="0"
      cellspacing="0">
        <tr>
          <td><font FACE="ARIAL" SIZE="2"><b>Price</b> - No \$ sign
          needed</font></td>
          <td>&nbsp; <input NAME="price" SIZE="10" MAXLENGTH="10"></td>
        </tr>
        <tr>
          <td><font FACE="ARIAL" SIZE="2"><b>Shipping Price (Std)</b> or<br>
          <b>Shipping Wt (lbs -SBW module)</b></font></td>
          <td>&nbsp; <input NAME="shipping_price" SIZE="10" MAXLENGTH="10"></td>
        </tr>
      </table>
      </div></td>
      <td width="30%"><font FACE="ARIAL" SIZE="2"><b>Option File</b> 
        - choose from the list of files in the options directory<br>
      </font><select NAME="option_file" size="1">
        <option>blank.html</option>
$options_file_list
      </select> </td>
    </tr>
    <tr>
      <td colspan=1><font FACE="ARIAL" SIZE="2"><b>Category</b> - One 
        word only</font><br><input NAME="category" TYPE="TEXT" SIZE="25"
        MAXLENGTH="35"></td>
      <td colspan=2><font FACE="ARIAL" SIZE="2"><b>Product Name</b> 
        - 3 or 4 words</font><br>
        <input NAME="name" TYPE="TEXT" SIZE="35" MAXLENGTH="35"></td>
      <td colspan=1><font FACE="ARIAL" SIZE="2"><b>Image File</b> -
      name.gif/.jpg/.png</font><br>
      <input NAME="image" TYPE="TEXT" SIZE="25" MAXLENGTH="55"></td>
    </tr>
$imgup
    <tr> 
      <td colspan="4" width="100%"><div align=center><table
        cellpadding="1" cellspacing="0">
        <tr>
          <td><font FACE="ARIAL" 
            SIZE="2"><b>Description</b> - Enter the
            Text &amp; HTML describing the product. </font><br>
            <textarea NAME="description" ROWS="5" COLS="85" 
            wrap="soft"></textarea></td>
        </tr>
      </div></table></td>
    </tr>
    <tr>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">2nd Image: </font><input
      NAME="userDefinedOne" SIZE="35" MAXLENGTH="128" style="font-family: Courier, monospace"></td>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">User 2: </font><input
      NAME="userDefinedTwo" SIZE="35" MAXLENGTH="128" style="font-family: Courier, monospace"></td>
    </tr>
    <tr>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">User 3: </font><input
      NAME="userDefinedThree" SIZE="35" MAXLENGTH="128" style="font-family: Courier, monospace"></td>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">User 4: </font><input
      NAME="userDefinedFour" SIZE="35" MAXLENGTH="128" 
      style="font-family: Courier, monospace"></td>
    </tr>
    <tr>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">User 5: </font><input
      NAME="userDefinedFive" SIZE="35" MAXLENGTH="128" style="font-family: Courier, monospace"></td>
      <td colspan="2" width="50%">&nbsp;&nbsp; <input TYPE="SUBMIT" NAME="AddProduct"
      VALUE="Add Product">&nbsp;&nbsp;&nbsp; <input TYPE="RESET" VALUE="Clear Form"> </td>
    </tr>
  </table></td></tr>
  </table>
  </center></div>
</form>
</body>
</html>~;
return $form;
}
############################################################################
sub edit_item_form_new {
local ($form,$msg,$imgup)="";

if ($mc_file_upload_ok =~ /yes/) { 
  $imgup = "<tr><td colspan=4>Upload Image File(s): " .
           "<input type=file name=upfile1 size=20> &nbsp;&nbsp;" . 
           "<input type=file name=upfile2 size=20></td></tr>\n";
 }

$form = qq~<HTML>
<HEAD>
<TITLE>Edit Product $sku</TITLE>
</HEAD>
<BODY BGCOLOR=WHITE>
<BODY BGCOLOR=WHITE>
<form METHOD="POST" ACTION="manager.cgi" enctype="multipart/form-data">
  <div align="center"><center><table BORDER="0" CELLPADDING="0"
CELLSPACING="0" WIDTH="755">
    <tr><td><table border=0 cellpadding=2 ><tr>
     <td colspan=3 width="80%"><strong> $manager_banner_main 
Quick Edit</strong>&nbsp;&nbsp;&nbsp;$msg</td>
<td><INPUT TYPE=SUBMIT NAME="skip_edit_screen" 
     VALUE="Skip This Record"><INPUT TYPE=HIDDEN NAME="first"
VALUE="$in{'first'}"></td>
    </tr></table></td>
    </tr>
<tr><td colspan=4><table BORDER="1" CELLPADDING="2" CELLSPACING="0"
WIDTH="755">  
    <tr>
      <td colspan="1" width="30%"><font FACE="ARIAL" SIZE="2"><b>PRODUCT
      ID # $sku</b> (change to save as NEW record)&nbsp; </font><input 
      NAME="new_sku" VALUE="$sku" TYPE="TEXT" SIZE="10" MAXLENGTH="10"></td>
      <td colspan="2" width="40%"><div align="left"><table border="0" cellpadding="0"
      cellspacing="0">
        <tr>
          <td><font FACE="ARIAL" SIZE="2"><b>Price</b> - No \$ sign
          needed</font></td>
          <td>&nbsp; <input NAME="price" SIZE="10" MAXLENGTH="10"
           value="$price"></td>
        </tr>
        <tr>
          <td><font FACE="ARIAL" SIZE="2"><b>Shipping Price (Std)</b> or<br>
          <b>Shipping Wt (lbs -SBW module)</b></font></td>
          <td>&nbsp; <input NAME="shipping_price" SIZE="10" MAXLENGTH="10"
           value="$shipping_price"></td>
        </tr>
      </table>
      </div></td>
      <td width="30%"><font FACE="ARIAL" SIZE="2"><b>Option File</b> - the list of files in the
      options directory<br>
      </font><select NAME="option_file" size="1">
        <option>$options</option>
$options_file_list
      </select> </td>
    </tr>
    <tr>
      <td colspan=1><font FACE="ARIAL" SIZE="2"><b>Category</b> - One 
        word only</font><br><input NAME="category" TYPE="TEXT" SIZE="25"
        MAXLENGTH="35" value="$category"></td>
      <td colspan=2><font FACE="ARIAL" SIZE="2"><b>Product Name</b> 
        - 3 or 4 words</font><br>
        <input NAME="name" TYPE="TEXT" SIZE="35" MAXLENGTH="35"
       value="$short_description"></td>
      <td colspan=1><font FACE="ARIAL" SIZE="2"><b>Image File</b> -
      name.gif/.jpg/.png</font><br>
      <input NAME="image" TYPE="TEXT" SIZE="25" MAXLENGTH="55"
       value="$image"></td>
    </tr>
$imgup
    <tr> 
      <td colspan="4" width="100%"><div align=center><table
        cellpadding="1" cellspacing="0">
        <tr>
          <td><font FACE="ARIAL" 
            SIZE="2"><b>Description</b> - Enter the
            Text &amp; HTML describing the product. </font><br>
            <textarea NAME="description" ROWS="5" COLS="85" 
            wrap="soft">$long_description</textarea></td>
        </tr>
      </div></table></td>
    </tr>
    <tr>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">2nd Image: </font><input
      value='$userDefinedOne' 
      NAME="userDefinedOne" SIZE="35" MAXLENGTH="128" style="font-family: Courier, monospace"></td>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">User 2: </font><input
      value='$userDefinedTwo'
      NAME="userDefinedTwo" SIZE="35" MAXLENGTH="128" style="font-family: Courier, monospace"></td>
    </tr>
    <tr>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">User 3: </font><input
      value='$userDefinedThree' 
      NAME="userDefinedThree" SIZE="35" MAXLENGTH="128" style="font-family: Courier, monospace"></td>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">User 4: </font><input
      value='$userDefinedFour' 
      NAME="userDefinedFour" SIZE="35" MAXLENGTH="128" 
      style="font-family: Courier, monospace"></td>
    </tr>
    <tr>
      <td colspan="2" width="50%"><font face="ARIAL" size="2" color="RED">User 5: </font><input
      value='$userDefinedFive' 
      NAME="userDefinedFive" SIZE="35" MAXLENGTH="128" style="font-family: Courier, monospace"></td>
      <td colspan="2" width="50%">&nbsp;&nbsp; <INPUT TYPE=SUBMIT 
      NAME="SubmitEditProduct" VALUE="Submit Edit">&nbsp;&nbsp;&nbsp;
      <input TYPE="RESET" VALUE="Undo Edit">
      <INPUT TYPE=HIDDEN NAME=save_category VALUE="$in{'category'}">
      <INPUT TYPE=HIDDEN NAME="ProductEditSku" VALUE="$sku"></td>
    </tr>
  </table></td></tr>
  </table>
  </center></div>
</form>
</body>
</html>~;
return $form;
}
############################################################################
sub edit_product_screen
{

local ($message,@categories,$cat_str,$inx);
local ($helper,$helper_top,$helper_bot);

print &$manager_page_header("Edit Product","","","","");

if ($in{'skip_edit_screen'} ne "") {
  $edit_error_message = "Record $in{'ProductEditSku'} Skipped.";
  $in{'ProductEditSku'} = "";
  if ($in{'save_category'} ne "") {
    $in{'category'} = $in{'save_category'};
   }
 }

if ($in{'category'} ne "") {
  $message = "Click an 'Item # to Edit' button to make changes to" . 
             " a product in your catalog. ";
  $message .='&nbsp;&nbsp;<a href="manager.cgi?edit_screen=yes&">' .
	'Click here</a> to display the categories in your catalog.';
 } else {
  $message = "Click below to select the category to display."; 
 }

@categories = &get_prod_db_category_list;
$cat_str = '';
foreach $inx (@categories) {
  $cat_str .= "<OPTION>$inx</OPTION>\n";
 }

if (($mc_put_edit_helper_at_top =~ /yes/i) ||
    ($mc_put_edit_helper_at_bot =~ /yes/i)) {
$helper = qq~
<HR>
<TABLE WIDTH=100% BORDER=0 CELLPADDING=0 CELLSPACING=0>
<TR>
<TD WIDTH=40%>
<FORM METHOD="POST" ACTION="manager.cgi">
<CENTER>
<INPUT TYPE=SUBMIT NAME=Helper VALUE="Edit Item -->">
<input type=text name="EditWhichProduct" size=12>
<INPUT TYPE=HIDDEN NAME=category VALUE="$in{'category'}">
<INPUT TYPE=HIDDEN NAME=EditProduct VALUE="Edit">
</CENTER>
</FORM>
</TD>
<TD WIDTH=60%>
<FORM METHOD="POST" ACTION="manager.cgi">
<CENTER>
<INPUT TYPE=SUBMIT NAME="edit_screen" 
         VALUE="Show Category -->">
<SELECT NAME=category>$cat_str</SELECT>
</CENTER>
</FORM>
</TD>
</TR>
</TABLE>
~;
}

if ($mc_put_edit_helper_at_top =~ /yes/i) {
  $helper_top = $helper;
 }
if ($mc_put_edit_helper_at_bot =~ /yes/i) {
  $helper_bot = $helper;
 }

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=550>
</CENTER>

<CENTER>
<TABLE WIDTH=550>
<TR>
<TD WIDTH=550>
<FONT FACE=ARIAL>
This is the Edit-A-Product screen of the <b>AgoraCart</b> product manager. 
$message $helper_top<hr></td></TR>
</TABLE>
</CENTER>

ENDOFTEXT

if ($in{'ProductEditSku'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0>
<CENTER>
<TR WIDTH=550 BORDER=0>
<TD WIDTH=550 BORDER=0>
<CENTER><FONT FACE=ARIAL SIZE=2 COLOR=RED>
Product ID \# $in{'ProductEditSku'} successfully edited</FONT></CENTER>
</TD>
</TR>
</CENTER>
</TABLE>
</CENTER>
ENDOFTEXT
}

if ($edit_error_message ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0>
<CENTER>
<TR WIDTH=550 BORDER=0>
<TD WIDTH=550 BORDER=0>
<CENTER><FONT FACE=ARIAL SIZE=2 COLOR=RED>
$edit_error_message</FONT></CENTER>
</TD>
</TR>
</CENTER>
</TABLE>
</CENTER>
ENDOFTEXT
}

if ($conv_result ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0>
<CENTER>
<TR WIDTH=550 BORDER=0>
<TD WIDTH=550 BORDER=0>
<CENTER><FONT FACE=ARIAL SIZE=2 COLOR=RED>$conv_result</FONT></CENTER>
</TD>
</TR>
</CENTER>
</TABLE>
</CENTER>
ENDOFTEXT
}

if ($in{'category'} ne "") {
 &display_items_in_category("Edit",
	"<b>Item # to Edit</b>",
	"Edit",
	"edit_screen");
 } else {
 &display_categories("edit_screen");
 }

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0 CELLPADDING=0>
<tr><td>
$helper_bot
<HR>
</td></tr>
</table>
</center>
ENDOFTEXT
print &$manager_page_footer;
}
#############################################################################################

sub delete_product_screen
{
local ($message,$my_script, $my_body_tag);

$my_body_tag = $mc_standard_body_tag;
if ($in{'category'} ne "") {
  $my_body_tag .= ' onLoad="WarnDelete()"';
 }

$my_script = qq~
<SCRIPT>
function WarnDelete()
{
alert("CAREFUL! Clicking  Delete will immediately remove a product from the database");
}
</SCRIPT>~;

print &$manager_page_header("Delete Product",$my_script,$my_body_tag,"","");

if ($in{'category'} ne "") {
  $message ='<a href="manager.cgi?delete_screen=yes&">' .
	'Click here</a> to display the categories in your catalog.';
 } else {
  $message = "Click below to select the category to display."; 
 }

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL COLOR=RED>
WARNING!</FONT>
<FONT FACE=ARIAL>Clicking an <b>'Item # to Delete'</b> button will 
IMMEDIATELY remove that product from your catalog. &nbsp;You've been warned!
<br>$message</TD>
</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

ENDOFTEXT

if ($in{'DeleteWhichProduct'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0>
<CENTER>
<TR WIDTH=550 BORDER=0>
<TD WIDTH=550 BORDER=0>
<CENTER><FONT FACE=ARIAL SIZE=2 COLOR=RED>
Product ID \# $in{'DeleteWhichProduct'} successfully
deleted</FONT></CENTER>
</TD>
</TR>
</CENTER>
</TABLE>
</CENTER>
ENDOFTEXT
}

if ($in{'category'} ne "") {
 &display_items_in_category(
        "Delete",
        "<B><FONT COLOR=RED>Item # to Delete</FONT></B>",
        "Delete",
        "delete_screen");
 } else {
 &display_categories("delete_screen");
 }

print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0 CELLPADDING=0>
<tr><td><HR></td></tr>
</table>
</center>
ENDOFTEXT
print &$manager_page_footer;

}
#############################################################################################
sub display_perform_edit_screen

{

$options_file_list = &make_file_option_list("./html/options","");

print &edit_item_form;

}
################################################################################
sub action_add_product
{
local($my_new_rec)="";
local($product_id,@db_row);
local($found_it)="";
local($mode,$in_sku);
local($sku, $category, $price, $short_description, $image, 
      $long_description, $shipping_price, $userDefinedOne, 
      $userDefinedTwo, $userDefinedThree, $userDefinedFour,
      $userDefinedFive, $options);


$in_sku = $in{"sku"};
if (substr($in_sku,length($in_sku)-1,1) eq "*") {
  $in_sku = substr($in_sku,0,length($in_sku)-1);
  if ($in_sku eq "") {
    $mode = "";
   } else {
    $mode = &check_db_with_product_id($in_sku,*db_row);
   }
  if ($mode) { 
    $in_sku = &get_next_prod_key;
   }
  $found_it = "";
 } else {
  $found_it = &check_db_with_product_id($in_sku,*db_row);
 }

if ($found_it) {
  $add_product_status="no";
  &add_product_screen($add_product_status);
  &call_exit;
 }

$formatted_description = $in{'description'};
$formatted_description =~ s/\r/ /g;
$formatted_description =~ s/\t/ /g;
$formatted_description =~ s/\n/ /g;

$image = $in{'image'};
if ($image eq "") {
  $image = "notavailable.gif";
 }
$formatted_image = &create_image_string($image);

##
if ($in{'option_file'} ne "")

{
	if (-e "./html/options/$in{'option_file'}")
	{
	$formatted_option_file = "\%\%OPTION\%\%$in{'option_file'}";
	}
	else
	{
	$formatted_option_file = "\%\%OPTION\%\%blank.html";
	}
}

else

{
$formatted_option_file = "\%\%OPTION\%\%blank.html";
}
##

$in{'category'} =~ s/\ //g; 
if ($in{'category'} eq "") {
  $in{'category'} = "*Nameless*";
 }

$my_new_rec = "$in_sku|$in{'category'}|$in{'price'}|$in{'name'}" .
   "|$formatted_image|$formatted_description|$in{shipping_price}" .
   "|$in{'userDefinedOne'}|$in{'userDefinedTwo'}" .
   "|$in{'userDefinedThree'}|$in{'userDefinedFour'}" .
   "|$in{'userDefinedFive'}|$formatted_option_file";

&add_new_record_to_prod_db($my_new_rec);

$add_product_status="yes";
&add_product_screen($add_product_status);

}
################################################################################
sub display_catalog_screen{
 $in{'category'}="";
 &edit_product_screen;
}
################################################################################
sub action_edit_product
{
	
local($sku, $category, $price, $short_description, $image, 
      $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, 
      $userDefinedThree, $userDefinedFour, $userDefinedFive, 
      $options);
local($product_id,$found_it,@db_row,$raw_data);

$found_it = &get_prod_db_row($in{'EditWhichProduct'},*db_row, *raw_data, "no");

($sku, $category, $price, $short_description, $image, 
 $long_description, $shipping_price, $userDefinedOne, 
 $userDefinedTwo, $userDefinedThree, $userDefinedFour, 
 $userDefinedFive,$options) = split(/\|/,$raw_data);

chomp($options);

if ($sku ne $in{'EditWhichProduct'}) {
  if ($found_it) {
    $long_description = "Error, expected sku of $in{'EditWhichProduct'}, " 
	. "found $sku instead!";
  }
  $sku = $in{'EditWhichProduct'};
 } 

$options =~ s/%%OPTION%%//g;
$image =~ s/.*%%URLofImages%%\///g;
$image =~ s/.png.*/.png/g;
$image =~ s/.gif.*/.gif/g;
$image =~ s/.jpg.*/.jpg/g;
($image,$junkjunkjunk)=split(/\"/,$image,2); # safety net

&display_perform_edit_screen;


}

################################################################################
sub action_submit_edit_product
{
### Begin
local($sku, $category, $price, $short_description, $image, 
	$long_description, $shipping_price, $userDefinedOne, 
	$userDefinedTwo, $userDefinedThree, $userDefinedFour, 
	$userDefinedFive, $options);
local($temp);

$formatted_description = $in{'description'};
$formatted_description =~ s/\r/ /g;
$formatted_description =~ s/\t/ /g;
$formatted_description =~ s/\n/ /g;

$image = $in{'image'};
if ($image eq "") {
  $image = "notavailable.gif";
 }
$formatted_image = &create_image_string($image);

##
if ($in{'option_file'} ne "")

{
	if (-e "./html/options/$in{'option_file'}")
	{
	$formatted_option_file = "\%\%OPTION\%\%$in{'option_file'}";
	}
	else
	{
	$formatted_option_file = "\%\%OPTION\%\%blank.html";
	}
}

else

{
$formatted_option_file = "\%\%OPTION\%\%blank.html";
}
##

$in{'category'} =~ s/\ //g; # NO BLANKS ALLOWED!
if ($in{'category'} eq "") {
  $in{'category'} = "*Nameless*";
 }

$raw_line =  
 "$in{'ProductEditSku'}|$in{'category'}|$in{'price'}|$in{'name'}" .
 "|$formatted_image|$formatted_description|$in{'shipping_price'}" .
 "|$in{'userDefinedOne'}|$in{'userDefinedTwo'}|$in{'userDefinedThree'}" .
 "|$in{'userDefinedFour'}|$in{'userDefinedFive'}|$formatted_option_file";

if (substr($in{'new_sku'},length($in{'new_sku'})-1,1) eq "*") {
  $temp = substr($in{'new_sku'},0,length($in{'new_sku'})-1);
  if (($in{'new_sku'} eq "*") || ($temp ne $in{'ProductEditSku'})) {
    if ($temp ne "") { #test if it is there first ...
      $found_it = &check_db_with_product_id($temp,*db_row);
      if ($found_it) { 
	$in{'new_sku'} = &get_next_prod_key;
       } else {
	$in{'new_sku'} = $temp;
       }
     } else {
      $in{'new_sku'} = &get_next_prod_key;
     }
   } else { 
    $in{'new_sku'} = $temp;
   }
 }

if (($in{'new_sku'} eq "") || ($in{'new_sku'} eq $in{'ProductEditSku'})) {
  $result = &put_prod_db_raw_line($in{'ProductEditSku'},$raw_line,"no");
 } else { # new product
  $found_it = &check_db_with_product_id($in{'new_sku'},*db_row);
  if ($found_it) {
    $in{'ProductEditSku'}="";
    $edit_error_message="Sorry, that item (" . $in{'new_sku'} .
                        ") is already in the database.";
    $edit_error_message.= "&nbsp; Hit browser BACK BUTTON to re-edit.";
   } else {
    $in{'ProductEditSku'}=$in{'new_sku'};
    $edit_error_message="(NOTE: That item was ADDED to the database)";
    $raw_line =  
      "$in{'ProductEditSku'}|$in{'category'}|$in{'price'}|$in{'name'}" .
      "|$formatted_image|$formatted_description|$in{'shipping_price'}" .
      "|$in{'userDefinedOne'}|$in{'userDefinedTwo'}|$in{'userDefinedThree'}" .
      "|$in{'userDefinedFour'}|$in{'userDefinedFive'}|$formatted_option_file";
    &add_new_record_to_prod_db($raw_line);
   }
 }

$in{'category'} = $in{'save_category'}; 
&edit_product_screen;

### End
}
################################################################################

sub action_delete_product
{

&del_prod_from_db($in{'DeleteWhichProduct'});

&delete_product_screen;

}
#########################################################################
1; # Library
