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
 <TD VALIGN="MIDDLE"><INPUT TYPE="TEXT" NAME="%%itemID%%" SIZE="3"
 MAXLENGTH="3" VALUE="1"></TD><TD VALIGN="MIDDLE"><INPUT TYPE="IMAGE"
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
<td colspan=3>
<table width=100% border=0>
 <tr>
  <td align=right colspan=1>&nbsp;</td>
  <td align=right colspan=1>
<A HREF="%%scripturl%%?cart_id=&p=%%CategoryID%%">
<FONT FACE=ARIAL>Show This Category</FONT></A>
  </td>
  <td align="right" colspan=1>

<A HREF="%%scripturl%%?dc=1&%%href_fields%%">
<FONT FACE=ARIAL>Check Out</FONT>
</A>
  </td>
</tr>
</table>
</TD>
</TR>
