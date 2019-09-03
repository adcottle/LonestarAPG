<!--agorascript-pre
{
$ags_across = 4; # Number in a row
$ags_row_wd=int(100.0/$ags_across);
local ($myans)="";
if ($rowCount == (1+$minCount)) { #first one
  $ags_row_item=0;
  $ags_row_nmbr=0;
  $ags_tot_item=0;
  $myans .= '<tr><td colspan=3><table width="100%" border=1>'."\n";
 }
$ags_row_item++;
$ags_tot_item++;
if ($ags_row_item > 1) { # last one
  if ($ags_row_item == $ags_across) {
    $ags_row_item=0; #reset counter
    $ags_row_nmbr++;
    }
  $myans .= '<td width="'.$ags_row_wd.'%" valign="top">';
 } else { #first one
  $myans .= '<tr><td width="'.$ags_row_wd.'%" valign="top">';
 }
$myans.=qq~<FORM METHOD = "post" ACTION = "%%scriptURL%%">
%%make_hidden_fields%%
<table width=100%>
~;
return $myans;
}
-->
<TR WIDTH="100%"> 
<TD ALIGN="CENTER" WIDTH="100%">%%image%%</TD>
</tr>
<tr><TD>
<FONT FACE="ARIAL" SIZE="2">
<b>Product: %%ProductID%%</b>
<br>
<font color="#FF0000">%%price%%</font>
<br>
</FONT>
</TD>
</TR>
<TR> 
<td align="left">
<A HREF="%%scripturl%%?cart_id=&p_id=%%ProductID%%&xm=on&ppinc=search2">
<FONT FACE=ARIAL>More Info</FONT></A>
<br>
</TD>
</TR>
<!--agorascript-pre
{
local ($myans)="";
if ($ags_row_item == 0) { # last one
  $myans .= '</table></FORM></td></tr>'."\n";
 } else { # first one
  $myans .= '</table></FORM></td>'."\n";
 }
if (($rowCount == ($maxCount)) || ($rowCount == ($num_returned)))
 { # very last one
  if (!($ags_row_item == 0)) { # finish the row
#    if ($ags_row_nmbr > 0) { # finish the row with blanks
      while ($ags_row_item <  $ags_across) {
        $ags_row_item++;
        $myans .= '<td width="'.$ags_row_wd.'%">&nbsp; </td>';
       }
#     }
    $myans .= '</tr>'."\n";
   }
  $myans .= '</table></td></tr>'."\n";
 }
return $myans;
}
-->
