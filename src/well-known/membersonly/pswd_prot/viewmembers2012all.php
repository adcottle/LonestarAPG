<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>LSC Member List</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="generator" content="NoteTab Pro 4.95">
<meta name="author" content="Debbie Parker Wayne">
<link rel="stylesheet" href="../../../lscapg.css" type="text/css">
<script type="text/javascript" src="../../../lscapg.js"></script>
</head>

<body>

<table align="center" border="0"  summary="page body" width="800">

<tr><td colspan="3">
<img src="../../../images/logo.jpg" width="798" height="133" border="0" alt="logo">
<br/>
<br/>
</td></tr>
<tr><td colspan="3">
<div class="navbar">

<table class="navbar" summary="links">
<tr><td>
<a href="http://www.apgen.org/">APG</a> &nbsp;&nbsp;|&nbsp;&nbsp; 
<a href="../../../index.html">Lone Star Chapter</a> &nbsp;&nbsp;|&nbsp;&nbsp;    
<a href="../../../bylaws.htm">Chapter Bylaws</a> &nbsp;&nbsp;|&nbsp;&nbsp;
<a href="../../../ethics.htm">Code of Ethics</a> &nbsp;&nbsp;|&nbsp;&nbsp;
<a href="../../../contact.htm">Contact Us</a>
</td></tr><tr><td>
<a href="../../../events.htm">Events</a> &nbsp;&nbsp;|&nbsp;&nbsp;
<a href="../../../services.htm">Services</a> &nbsp;&nbsp;|&nbsp;&nbsp;
<a href="../../../hirepro.htm">Hiring a Pro</a> &nbsp;&nbsp;|&nbsp;&nbsp;
<a href="../../../bepro.htm">Becoming a Pro</a> &nbsp;&nbsp;|&nbsp;&nbsp;
<a href="../../../issues.htm">Issues</a>&nbsp;&nbsp;|&nbsp;&nbsp;
<a href="../../../links.htm">Links</a>
</td></tr>
<tr><td>
<a href="http://lonestarapg.com/forum/">Members Only Section</a>
&nbsp;&nbsp;|&nbsp;&nbsp;
<a href="../../../forumguide/forumug.htm">Forum User's Guide</a>
&nbsp;&nbsp;|&nbsp;&nbsp;
<a href="../../../join.htm">Join / Renew / Change Info</a>
<br /><br />
</td></tr>

</table>
</div>

</td></tr>

<tr><td colspan="3">


<div class="textdiv">

<a name="#top"></a>
<h1>Lone Star Chapter APG Member List</h1>

<?php

$con = mysql_connect ("localhost", "lones6_view", "viewmembers") or die ('I cannot connect to the database because: ' . mysql_error());
mysql_select_db ("lones6_members", $con);

$result = mysql_query("SELECT * FROM member ORDER BY surname");
$activecount = 0;
$dallas = 0;
$south = 0;
$houston = 0;
$east = 0;
$west = 0;
$arkansas = 0;
$louisiana = 0;
$oklahoma = 0;
$newmex = 0;
$texas = 0;
$other = 0;


echo "<table border=0 cellspacing=2>
<tr>
<td><b>Surname, Given</b></td>
<td><b>Credentials</b></td>
<td><b>e-mail / Business Name /  Website</b></td>
<td><b>Address</b></td>
<td><b>Phone / FAX</b></td>
<td><b>Membership </b></td>
</tr>";

while($row = mysql_fetch_array($result)) 
{
  if ($row['membershipexpire'] == '2013-12-31'){
    $activecount++;
    echo "<tr><td colspan=7><hr /> </td> </tr>";
    echo "<tr>";
    echo "<td>" . $activecount . ". <br />" . $row['surname'] . ", " . $row['given'] . "&nbsp;</td>";
    echo "<td>" . $row['postnomials'] . "&nbsp;</td>";
    echo "<td>" . $row['email'] . "<br />" . $row['busname'] . "<br />" . $row['website'] . "&nbsp;</td>"; 
    echo "<td>" . $row['streetadrs'] . "&nbsp;<br />";
    echo $row['city'] . "&nbsp;" . $row['state'] . "&nbsp;" . $row['zip'] . "&nbsp;</td>";
    echo "<td>" . $row['phone'] . "<br />". $row['fax'] . "&nbsp;</td>";
    echo "<td>Joined: " . $row['membershipdate'] . "<br />";
    echo "<b>Expires: " . $row['membershipexpire'] . "</b><br />" . "Level: " . $row['level'] . "<br />";
    echo $row['category'] . "<br />";
    echo $row['position'] . "&nbsp;</td>";
    echo "</tr>";
    if ($row['state'] == 'TX') {
      $texas++;
      if ($row['active'] == 'D') $dallas++;
      if ($row['active'] == 'H') $houston++;
      if ($row['active'] == 'S') $south++;
      if ($row['active'] == 'E') $east++;
      if ($row['active'] == 'W') $west++;
    }
    if ($row['state'] == 'AR') $arkansas++;
    if ($row['state'] == 'LA') $louisiana++;
    if ($row['state'] == 'OK') $oklahoma++;
    if ($row['state'] == 'NM') $newmex++;
  }
}
echo "<tr><td colspan=7><hr />Total members: " . $activecount . "<br />Arkansas: " . $arkansas;
echo "&nbsp;&nbsp;&nbsp;&nbsp;  Louisiana: " . $louisiana . " &nbsp;&nbsp;&nbsp;&nbsp; Oklahoma: " . $oklahoma  . " &nbsp;&nbsp;&nbsp;&nbsp; New Mexico: " . $newmex;

echo "<br />Texas: " . $texas . "&nbsp;&nbsp;&nbsp;&nbsp;       DFW area: " . $dallas . " &nbsp;&nbsp;&nbsp;&nbsp;   Houston/SE: " . $houston
. "&nbsp;&nbsp;&nbsp;&nbsp;    Austin/San Antonio/SW: " . $south . " &nbsp;&nbsp;&nbsp;&nbsp;   East/Central: " . $east . "  &nbsp;&nbsp;&nbsp;&nbsp;  West: " . $west;

echo "</td> </tr>";



$result = mysql_query("SELECT * FROM member ORDER BY surname");
$activecount = 0;
$dallas = 0;
$south = 0;
$houston = 0;
$east = 0;
$west = 0;
$arkansas = 0;
$louisiana = 0;
$oklahoma = 0;
$newmex = 0;
$texas = 0;
$other = 0;



echo "<tr bgcolor=\"#fffbc6\"><td colspan=7><hr /><br><br><br>Expired Memberships </td> </tr>";
echo "<table border=0 cellspacing=2>
<tr bgcolor=\"#fffbc6\">
<td><b>Surname, Given</b></td>
<td><b>Credentials</b></td>
<td><b>e-mail / Business Name /  Website</b></td>
<td><b>Address</b></td>
<td><b>Phone / FAX</b></td>
<td><b>Membership </b></td>
</tr>";



while($row = mysql_fetch_array($result)) 
{
  if ($row['membershipexpire'] <= '2012-12-31'){
    $activecount++;
    echo "<tr  bgcolor=\"#fffbc6\"><td colspan=7><hr /> </td> </tr>";
    echo "<tr  bgcolor=\"#fffbc6\">";
    echo "<td>" . $activecount . ". <br />" . $row['surname'] . ", " . $row['given'] . "&nbsp;</td>";
    echo "<td>" . $row['postnomials'] . "&nbsp;</td>";
    echo "<td>" . $row['email'] . "<br />" . $row['busname'] . "<br />" . $row['website'] . "&nbsp;</td>"; 
    echo "<td>" . $row['streetadrs'] . "&nbsp;<br />";
    echo $row['city'] . "&nbsp;" . $row['state'] . "&nbsp;" . $row['zip'] . "&nbsp;</td>";
    echo "<td>" . $row['phone'] . "<br />". $row['fax'] . "&nbsp;</td>";
    echo "<td>Joined: " . $row['membershipdate'] . "<br />";
    echo "<b>Expires: " . $row['membershipexpire'] . "</b><br />" . "Level: " . $row['level'] . "<br />";
    echo $row['category'] . "<br />";
    echo $row['position'] . "&nbsp;</td>";
    echo "</tr>";
    if ($row['state'] == 'TX') {
      $texas++;
      if ($row['active'] == 'D') $dallas++;
      if ($row['active'] == 'H') $houston++;
      if ($row['active'] == 'S') $south++;
      if ($row['active'] == 'E') $east++;
      if ($row['active'] == 'W') $west++;
    }
    if ($row['state'] == 'AR') $arkansas++;
    if ($row['state'] == 'LA') $louisiana++;
    if ($row['state'] == 'OK') $oklahoma++;
    if ($row['state'] == 'NM') $newmex++;
  }
}
echo "<tr  bgcolor=\"#fffbc6\"><td colspan=7><hr />Total expired members: " . $activecount . "<br />Arkansas: " . $arkansas;
echo "&nbsp;&nbsp;&nbsp;&nbsp;  Louisiana: " . $louisiana . " &nbsp;&nbsp;&nbsp;&nbsp; Oklahoma: " . $oklahoma  . " &nbsp;&nbsp;&nbsp;&nbsp; New Mexico: " . $newmex;

echo "<br />Texas: " . $texas . "&nbsp;&nbsp;&nbsp;&nbsp;       DFW area: " . $dallas . " &nbsp;&nbsp;&nbsp;&nbsp;   Houston/SE: " . $houston
. "&nbsp;&nbsp;&nbsp;&nbsp;    Austin/San Antonio/SW: " . $south . " &nbsp;&nbsp;&nbsp;&nbsp;   East/Central: " . $east . "  &nbsp;&nbsp;&nbsp;&nbsp;  West: " . $west;

echo "</td> </tr>";


mysql_close($con);
?>


</div>
</td></tr></table>

<br /><br />
<p class="certifications">
CG, Certified Genealogist, and CGL, Certified Genealogical Lecturer are service marks of the <a href="http://www.bcgcertification.org/">Board for Certification of Genealogists</a>® (BCG), used under license by professionals who pass periodic competency evaluations by the Board. 
<br />
AG and Accredited Genealogist are service marks of the <a href="http://www.icapgen.org/">International Commission for the Accreditation of Genealogists</a>® (ICAPGen), used under license by professionals who pass competency evaluations by ICAPGen.
<br />
CPL, Certified Professional Landman
</p>


<p class="footing">

<a href="http://lonestarapg.com/">http://lonestarapg.com/</a>
<br />

<br />
 Copyright &copy; 2012, Lone Star Chapter, APG, All Rights Reserved.<br />
See <a href="../../contact.htm">contacts page </a> for mailing address.</p>

</body>
</html>