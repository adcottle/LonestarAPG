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
