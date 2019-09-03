<TR> 
<TD COLSPAN = "3"><HR></TD>
</TR>

<TR WIDTH="550"> 
<TD WIDTH="365">

<FONT FACE="ARIAL" SIZE="2">
<FORM METHOD = "post" ACTION = "%%scriptURL%%">
%%make_hidden_fields%%
<b>%%name%%</b>

<br>

%%description%%

<br>
%%optionFile%%
<br>

</FONT>

</TD>
<TD ALIGN="CENTER" WIDTH="100"><font color="#FF0000"><B>%%price%%</B></font></TD>
  
<TD ALIGN="CENTER" WIDTH="160" VALIGN="MIDDLE">

<FONT FACE="ARIAL" SIZE="2">

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
<A HREF="agora.cgi?dc=1&%%href_fields%%">
<FONT FACE=ARIAL size="2"><B>Check Out</B></FONT>
</A>
</TD>

</FORM>

</TR>
