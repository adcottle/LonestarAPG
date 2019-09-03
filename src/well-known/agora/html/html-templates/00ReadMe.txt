"Fly Pages"  aka included (.inc) pages
May 7, 2003
-------------

Notes:
1)  Also see the parsed HTML document in the DOCS directory!


As of version 3.2, there is a new way to display cart contents.  If the
system detects display_cart=1 (or dc=1) in the URL or in POST form data
then the cart will be displayed.  Formerly syntax such as

  <A HREF="agora.cgi?add_to_cart_button.x=yes&%%href_fields%%&viewOrder=yes">
  <FONT FACE=ARIAL>View Cart</FONT>

was used to view the cart.  With the simplified view cart code it becomes

  <A HREF="agora.cgi?dc=1&%%href_fields%%"><FONT FACE=ARIAL>View Cart</FONT>

This simplifies the HTML and prevents false error messages about reloaded
pages.  

The producPage.inc file options have changed considerably since agora.cgi
was first released.  Agorascript has greatly enhanced the ability to
display products.  With the ppinc= option, there are many ways to mix and
match the display of product information.

Here are some of the files available for displaying products "on-the-fly":

  productPage.inc      current standard display, 2 across, agorascript
                        if odd product left, it uses both columns to
                        display the last item.
  productPage-1a.inc   no agorascript, 1 item across
                        shows: options, image, product name, description, price,
                        add to cart button, checkout link
  productPage-1b.inc   no agorascript, 1 item across
                        shows: product name, description, price, add to cart button, checkout link
                        not shown: options, image, product ID
  productPage-1c.inc   no agorascript, 1 item across
                        shows: product name, product ID, price, add to cart button, checkout link,
                        and link to "more information" (goes to seach2.inc with single item shown)
                        not shown: options, image, description
  productPage-1c.inc   no agorascript, 1 item across
                        shows: product name, price, add to cart button, checkout link,
                        and link to "more information and image" (goes to seach2.inc with single item shown)
                        not shown: options, image, description, product ID

  productPage-2a.inc    agorascript, 2 items across, duplicate copy of productPage.inc
  productPage-2a0.inc   agorascript, 2 items across, another way
  productPage-2a1.inc   agorascript, 2 items across, yet another way
  productPage-4a.inc    agorascript, 4 items across, image, product number, price, "more info" link

Here are a few other files to look at:
  productPage-agorascript_example.inc   agorascript example of table format
  productPage-search.inc                used in search displays - overview
  productPage-search2.inc               to show single items after search, 1c, 1d, or 4a .inc productPages
  productPage-agorascript_example.inc   agorascript example of table format
                                         will display all the items from the database.
  productPage.inc.2.per.line.if.not.using.options.at.all.rename.this.file.for.speed
                                         if you are not using option files on any of
                                         your products and never plan to, then rename
                                         this file to productPage.inc .  This will speed up your store.

****************************************************************************

        ** Agora.cgi 3.0a 00ReadMe.txt for productPage.in file **

This file describes the HTML for the dynamically created product pages
that can be designed to the users tastes. Tokens are used here to display
the values generated from the database and the script. Simply place the
appropriate tokens in the customizable productPage.inc HTML file and
the fields will appear there on your pages!

The following tokens are REQUIRED! Please take a look at how they are used 
below, and be careful not to break them when you edit the file.

%%cartID%%
%%itemID%%
%%make_hidden_fields%%
%%scriptURL%%

The following fields are optional and can be used if desired. Remember, the 
token called %%optionFile%% will display all of the HTML from the option
file assigned to the product being displayed.

%%description%%
%%image%%
%%name%%
%%optionFile%%
%%price%%
%%shipping%%

The following fields are optional, they are the user defined fields set in 
the Store Manager.

%%userFieldOne%%
%%userFieldTwo%%
%%userFieldThree%%
%%userFieldFour%%
%%userFieldFive%%

Pro Members also have these available in their versions:
%%userFieldSix%%
%%userFieldSeven%%
%%userFieldEight%%
%%userFieldNine%%
%%userFieldTen%%

#########################################################################

Sample simple productPage.inc file (productPage-1a.inc) shipped with AgoraCart:

<TR> 
<TD COLSPAN = "3"><HR></TD>
</TR>

<TR WIDTH="550"> 
  
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
  
<TD WIDTH="265">

<FONT FACE="ARIAL" SIZE="2">

<b>%%name%%</b>

<br>

%%description%%

<br>

<font color="#FF0000">%%price%%</font>

<br>

</FONT>

</TD>

</FORM>

</TR>

<TR> 
<td>&nbsp;</td>
<td>&nbsp;</td>
<td align="right">

<A HREF="%%scripturl%%?dc=1&%%href_fields%%">
<FONT FACE=ARIAL>Check Out</FONT>
</A>

</TD>
</TR>
