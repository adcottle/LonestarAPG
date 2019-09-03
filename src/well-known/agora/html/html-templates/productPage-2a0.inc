<!--agorascript-pre
{
local ($myans)="";
if ($rowCount == (1+$minCount)) { #first one
  $ags_row_item=0;
  $ags_tot_item=0;
  $myans .= '<tr><td colspan=3><table width="100%" border=1>'."\n";
 }
$ags_row_item++;
$ags_tot_item++;
if ($ags_row_item == 2) { # second one
  $ags_row_item=0; #reset counter
  $myans .= '<td width="50%"><table width=100%>'."\n";
 } else { #first one
  $myans .= '<tr><td width="50%"><table width=100%>'."\n";
 }
return $myans;
}
-->
<TR WIDTH="100%"> 
<TD ALIGN="CENTER" WIDTH="160" VALIGN="MIDDLE">
<FONT FACE="ARIAL" SIZE="2">
<FORM METHOD = "post" ACTION = "%%scriptURL%%">
%%make_hidden_fields%%
<BR>
%%optionFile%%
<BR>
<P>
<!--BEGIN SELECT manually specified QUANTITY BUTTON-->
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
</tr>
<tr><TD colspan=2>
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
<td align="right">
<A HREF="%%scripturl%%?dc=1&%%href_fields%%">
<FONT FACE=ARIAL>Check Out</FONT>
</A>
</TD>
</TR>
<!--agorascript-pre
{
local ($myans)="";
if ($ags_row_item == 1) { # first one
  $myans .= '</table></td>'."\n";
 } else { # second one
  $myans .= '</table></td></tr>'."\n";
 }
if (($rowCount == ($maxCount)) || ($rowCount == ($num_returned)))
 { # very last one
  if ($ags_row_item == 1) { # finished first one, add a blank dummy second
    $myans .= '<td>&nbsp;</td></tr>'."\n";
   }
  $myans .= '</table></td></tr>'."\n";
 }
return $myans;
}
-->
