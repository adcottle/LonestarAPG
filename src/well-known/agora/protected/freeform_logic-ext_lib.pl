# file ./store/protected/freeform_logic-ext_lib.pl

$versions{'freeform_logic'} = "20021020";

{
 local ($modname) = 'freeform_logic';
 &register_extension($modname,"Custom Store Logic",$versions{$modname});
 &add_settings_choice("free form logic"," Free Form Logic ",
	"freeform_settings_screen");
 &register_menu('freeform_settings_screen',"change_free_settings_screen",
	$modname,"Display Free Form (custom) Logic");
 &register_menu('ChangeFreeSettings',"action_change_free_settings",
	$modname,"Write Free Form (custom) Logic");
}
#######################################################################################
sub action_change_free_settings {
  local($info);
  local($myset)="";

  &ReadParse;
  $info = &my_escape($in{'mc_free_form_logic_row_count'});
  $myset .= "\$mc_free_form_logic_row_count = " .
                 "\"$info\";\n";
  $info = &my_escape($in{'sc_free_form_logic'});
  $myset .= "\$sc_free_form_logic = " . 
                 "\"$info\";\n";
  $myset .= "#\n";
  $info = &my_escape($in{'sc_free_form_logic_too'});
  $myset .= "\$sc_free_form_logic_too = " . 
                 "\"$info\";\n";
  $myset .= "#\n";
  $myset .= "if (\$main_program_running =~ /yes/i) {\n";
  $myset .= '  &add_codehook("after_loading_setup_db","run_freeform_logic");'
		. "\n";
  $myset .= '  &add_codehook("pre_header_navigation","run_freeform_logic");'
		. "\n";
  $myset .= '  &add_codehook("open_for_business","run_freeform_logic_too");'
		. "\n";
  $myset .= " }\n";
  $myset .= "\$sc_free_form_logic_done = 0; \n";
  $myset .= "sub run_freeform_logic { \n";
  $myset .= "  local(\$f)=__FILE__;\n";
  $myset .= "  local(\$l)=__LINE__;\n";
  $myset .= "  if (\$sc_free_form_logic_done) {return '';}\n";
  $myset .= "  \$sc_free_form_logic_done = 1; \n";
  $myset .= "  eval(\$sc_free_form_logic);\n";
  $myset .= "  if (\$@ ne \"\") {\n";
  $myset .= '    &update_error_log("Free Form Logic err: $@",$f,$l);' . "\n";
  $myset .= "    open(ERROR, \$error_page);\n";
  $myset .= "    while (<ERROR>) { print \$_; }\n";
  $myset .= "    close (ERROR);\n";
  $myset .= "    &call_exit;\n";
  $myset .= "   }\n";
  $myset .= " }\n";
  $myset .= "sub run_freeform_logic_too { \n";
  $myset .= "  local(\$f)=__FILE__;\n";
  $myset .= "  local(\$l)=__LINE__;\n";
  $myset .= "  eval(\$sc_free_form_logic_too);\n";
  $myset .= "  if (\$@ ne \"\") {\n";
  $myset .= '    &update_error_log("Free Form Too Logic err: $@",$f,$l);'."\n";
  $myset .= "    open(ERROR, \$error_page);\n";
  $myset .= "    while (<ERROR>) { print \$_; }\n";
  $myset .= "    close (ERROR);\n";
  $myset .= "    &call_exit;\n";
  $myset .= "   }\n";
  $myset .= " }\n";
  &update_store_settings('freeformlogic',$myset); # freeformlogic settings
  &change_free_settings_screen;
 }
################################################################################
sub change_free_settings_screen
{
print &$manager_page_header("FreeForm Logic","","","","");

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=580>
</CENTER>

<FORM ACTION="manager.cgi" METHOD="POST">
<CENTER>
<TABLE WIDTH=580>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Welcome to the <b>AgoraCart</b> System Manager
Free Form Logic settings.  This logic is run after the 
shopping cart loads the agora.setup.db file or at the
'open_for_business' code hook.</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT

if($in{'system_edit_success'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=2 COLOR=RED>System settings have been 
successfully updated. </FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

&make_lists_of_various_options;
if ($mc_free_form_logic_row_count < 4) {
  $mc_free_form_logic_row_count=4;
 }
if ($mc_free_form_logic_row_count >200) {
  $mc_free_form_logic_row_count=200;
 }

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<CENTER>
<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="1" align=left>
<b>Free Form Logic:</b>
</TD>
<TD COLSPAN="1" align=right>
Rows of logic to show:<INPUT TYPE=TEXT SIZE=5 
NAME="mc_free_form_logic_row_count"
VALUE="$mc_free_form_logic_row_count">
</TD>
</TR>

<TR>
<TD COLSPAN="2"><br>
<b>1)&nbsp; Logic run at code hook after loading agora.setup.db 
file:</b><br>
<TEXTAREA NAME="sc_free_form_logic" cols="68" 
rows="$mc_free_form_logic_row_count"
wrap=off>$sc_free_form_logic</TEXTAREA> 
</TD>
</TR>

<TR>
<TD COLSPAN="2"><br>
<b>2)&nbsp Logic run at 'open_for_business' code hook:</b><br>
<TEXTAREA NAME="sc_free_form_logic_too" cols="68" 
rows="$mc_free_form_logic_row_count"
wrap=off>$sc_free_form_logic_too</TEXTAREA> 
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT NAME="ChangeFreeSettings" TYPE="SUBMIT" VALUE="Submit">
&nbsp;&nbsp;
<INPUT TYPE="RESET" VALUE="Reset">
</CENTER>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<HR>
</TD>
</TR>

</TABLE>

</CENTER>
</FORM>
ENDOFTEXT
print &$manager_page_footer;
}
################################################################################
1; # Library
