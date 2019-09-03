# file ./store/protected/versions-ext_lib.pl

$versions{'versions'} = "20021020";
{
 local($modname) = "versions";
 &register_extension($modname,"Module Versions",$versions{$modname});
 &register_menu('versions',"show_manager_versions",
	$modname,"Show Module Versions");
}
################################################################################
sub show_manager_versions {
  print &$manager_page_header("$sc_gateway_name Gateway","","","","");
  print "<br><br>Info and Versions of loaded libraries:<br>\n";
  print "<table border=1 cellpadding=2 cellspacing=2>\n";
  foreach $junk (sort(keys(%versions)))
   {
    print "<tr><td>$junk </td><td>$versions{$junk}</td></tr>\n";
   }
  print "</table>\n";
  $junk .= `grep -h "versions{'" ./custom/* |grep "}="`;
  $junk .= `grep -h "versions{'" ./custom/* |grep "} ="`;
  $junk .= `grep -h "versions{'" $mgrdir/* |grep "}="`;
  $junk .= `grep -h "versions{'" $mgrdir/* |grep "} ="`;
  $junk .= `grep -h "versions{'" $mgrdir/custom/* |grep "}="`;
  $junk .= `grep -h "versions{'" $mgrdir/custom/* |grep "} ="`;
  $junk .= `grep -h "versions{'" ./library/* |grep "}="`;
  $junk .= `grep -h "versions{'" ./library/* |grep "} ="`;
  $junk =~s/\n/ /g;
  $junk =~ /([\w\-\=\+\/\;\{\}\'\ \.\"\$]+)/;
  $junk = $1;

  while ($junk ne "") {
    $result = $lib;
    ($junk1,$key,$junk) = split(/\'/,$junk,3);
    ($junk1,$val,$junk) = split(/\"/,$junk,3);
    if ($versions{$key} eq "") {
      $versions{$key} = $val;
     }
    ($junk1,$junk) = split(/versions/,$junk,2);
   }

################################################################################
    print "<br><br>Environment (shell) variables:<br>\n";
    print "<table border=1 cellpadding=2 cellspacing=2>\n";
    foreach $junk (sort(keys(%ENV)))
     {
      print "<tr><td>$junk </td><td>$ENV{$junk}</td></tr>\n";
     }
    print "</table>\n";
################################################################################
  print &$manager_page_footer;
  &call_exit;
 }
################################################################################
1; 
