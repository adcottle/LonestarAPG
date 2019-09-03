#/usr/local/bin/perl -T
#
# Library assembled by Steve Kneizys to allow for the CSV
# import and export of the product database via manager.cgi
#
# First created January 21, 2000
#
# Updated for flatfile and flex dbm libraries 7/22/01
#
# Updated to import/export databases other than PRODUCT 10/20/01
#

$versions{'database'} = "20021020";

{
 local ($modname) = 'database';
 &register_extension($modname,"Database",$versions{$modname});
 &register_menu('UpdateTags',"STD_action_update_tags",
	$modname,"Update Image Tags");
 &register_menu('ConvertProduct',"STD_flatfile_action_convert_product",
	$modname,"Convert Web Store 1.02 type database");
 &register_menu('data_to_CSV',"STD_action_data_to_CSV",
	$modname,"Create CSV file of a database");
 &register_menu('data_to_TAB',"STD_action_data_to_CSV",
	$modname,"Create TAB file of a database");
 &register_menu('data_to_PIPE',"STD_action_data_to_PIPE",
	$modname,"Create PIPE file of a database");
 &register_menu('data_from_CSV',"STD_action_data_from_CSV",
	$modname,"Import CSV database");
 &register_menu('data_from_PIPE',"STD_action_data_from_PIPE",
	$modname,"Import PIPE database");
 &register_menu('data_from_TAB',"STD_action_data_from_TAB",
	$modname,"Import TAB delimited datase");
 &register_menu('database_screen',"STD_agora_database_screen",
	$modname,"Database Screen");
 &register_menu('action_data_from_file',"STD_action_data_from_file",
	$modname,"BASE -- required to import a file");
 &register_menu('action_data_to_file',"STD_action_data_to_file",
	$modname,"BASE -- required to export a file");

 $datafile = "./data_files/data.file"; 
 $datafile_conv = $datafile;
 open(OLDFILE, "$datafile");
 @lines = <OLDFILE>;
 @my_items = split(/\|/, $lines[0]);
 close(OLDFILE);
 if ($#my_items ne 6 ) {
   &add_item_to_manager_menu("Database","database_screen=yes","");
  } else {
   &add_item_to_manager_menu("Convert 1.02 DB","ConvertProduct=yes","");
  }

}
$mc_db_convert_per_pass = 500; 
$mc_db_convert_seconds  = 10;  

&codehook("manager_database_lib_init");

#########################################################################

sub STD_flatfile_action_convert_product
{

local ($URL_of_images_directory) = '%%URLofImages%%';

$datafile_conv = $datafile;

open(OLDFILE, "$datafile") || &my_die("Can't Open $datafile");

@lines = <OLDFILE>;
@my_items = split(/\|/, $lines[0]);
#print "Item count is $#my_items\n";
if ($#my_items ne 6 ) {
  $conv_result =  "This file doesn't have fields 0 to 6, it has 0 to $#my_items.\n";
  $conv_result .=  "<br>Perhaps it has already been converted?\n";
 } else {

  $conv_result .=  "Proceeding with conversion ... \n";

   open(NEWFILE,">$datafile_conv") || &my_die("Can't Open $datafile");

   foreach $line (@lines)
	{
   @st = split(/\|/,$line);

$image = $st[4];

$image = &parse_image_string($image);
if ($image eq "") {
  $image = "notavailable.gif";
 }
$formatted_image = &create_image_string($image);

   if ($st[0] > 0) {
     $st[0] = &pad_key((0+$st[0]),$sc_prod_db_pad_length);
    }
   $st[4] = $formatted_image;

   $myline  = "$st[0]|$st[1]|$st[2]|$st[3]|$st[4]";
   $myline .= "|$st[5]|0||||||$st[6]";

    print NEWFILE $myline;
#    print  $myline;

	}

  close (NEWFILE);
  $conv_result .=  "Done!<br>IMG tags and PAD LENGTH were also updated.\n";
  $conv_result .=  '<BR>If using a database other than "flat file" you ';
  $conv_result .=  "<br>will need to import the PIPE file that was just ";
  $conv_result .=  "<br>created (data.file in the data_files directory.)\n";
  }

close (OLDFILE);
&init_convert_menu_item;
$zitem = $menu_items{"database_screen"};
&$zitem;

### End
}

#######################################################################################
sub update_image_tag {
  local ($image) = @_;
  $image = &parse_image_string($image);
  if ($image eq "") {
    $image = "notavailable.gif";
   }
  $image = &create_image_string($image);
  return $image;
 }
#######################################################################################
sub STD_action_update_tags
{
#
# Updates the IMG tags
# Written by Steve Kneizys Jan 16, 2000
#
local(%db_ele,$sku,$category,%category_list,@db_row,$datafile_conv,$row);
local($zitem,$line,$raw_line);
local ($URL_of_images_directory) = '%%URLofImages%%';

foreach $row (sort (&get_prod_db_keys)) {
  &get_prod_db_row($row,*db_row,*raw_line,"no");
  chomp($raw_line);
  @st = split(/\|/,$raw_line);

  $image = $st[4];

  $image = &parse_image_string($image);
  if ($image eq "") {
    $image = "notavailable.gif";
   }
  $formatted_image = &create_image_string($image);

  &del_prod_from_db($st[0]);
  if ($st[0] > 0) {# pad if it is a positive number only
    $st[0] = &pad_key((0+$st[0]),$sc_prod_db_pad_length);
   }
  $st[4] = $formatted_image;
#  $myline  = "$st[0]|$st[1]|$st[2]|$st[3]|$st[4]";
#  $myline .= "|$st[5]|$st[6]|$st[7]|$st[8]";
#  $myline .= "|$st[9]|$st[10]|$st[11]|$st[12]";
  $st[$#db] .= ''; # optional, force the min length to be all fields
  $myline = join('|',@st);
  &put_prod_db_raw_line($st[0],$myline,"no");
}

$conv_result .=  "Database Image Tags and Pad Length Updated!!\n";

&init_convert_menu_item;
$zitem = $menu_items{"database_screen"};
&$zitem;

}
################################################################################
sub STD_action_data_to_CSV {
  my $thing_to_do = $menu_items{'action_data_to_file'};
  &$thing_to_do("CSV");
 }
################################################################################
sub STD_action_data_to_TAB {
  my $thing_to_do = $menu_items{'action_data_to_file'};
  &$thing_to_do("TAB");
 }
################################################################################
sub STD_action_data_to_PIPE {
  my $thing_to_do = $menu_items{'action_data_to_file'};
  &$thing_to_do("PIPE");
 }
################################################################################
sub STD_action_data_to_file {
local($conv_type) = @_;
local(%db_ele,$sku,$category,%category_list,@db_row,$datafile_conv,$row);
local($zitem,$line,$raw_line,$db_name);
#
# Outputs the data.file in CSV format
# Written by Steve Kneizys Jan 21, 2000
# Updated 10/10/00
#

$db_name = $in{'db_name'};
if ($db_name eq "") {
  $db_name = "PRODUCT";
 }

if ($in{'CSV_filename'} ne "") {
  $datafile_conv = "./data_files/$in{'CSV_filename'}";
  $datafile_conv =~ /([\w-.\/]+)/;  
  $datafile_conv = $1;
 } else {
  $datafile_conv = "./data_files/database.csv";
 }

open(NEWFILE,">$datafile_conv");# || &my_CSV_file_error($datafile_conv);

foreach $row (sort (&get_db_keys($db_name))) {
  &get_db_row($db_name,$row,*db_row,*raw_line,"no");
  chomp($raw_line);
  if ($conv_type =~ /CSV/i) {
    $line = &conv_to_CSV($raw_line);
   } else {
    $line = $raw_line;
    if ($conv_type =~ /TAB/i) {
      $line =~ s/\|/\t/g; 
     }
   }
  print NEWFILE "$line\n";  
}

close (NEWFILE);
$conv_result .="The $db_name database converted to $conv_type format " . 
	"in file: $datafile_conv\n";

close (OLDFILE);
&init_convert_menu_item;

$zitem = $menu_items{"database_screen"};
&$zitem;

}

#######################################################################################

sub my_CSV_file_error {
 local ($file) = @_;
 local($zitem);
 $conv_result .=  "ERROR: file $file could not be opened<br>\n";
 &init_convert_menu_item;
 $zitem = $menu_items{"database_screen"};
 &$zitem;
 exit;
}
################################################################################
sub STD_action_data_from_file {
local($conv_type) = @_;
local($save_conv_type,$inx,$first,$last,$last_converted);
local($last_pos,$qty,$start_tm);
local($pid,$other_stuff,$line,@lines,$zitem,$orig_line);
local($elapsed_mins,$orig_start_time,@st,$myline,$myaction);
#
# Inputs the database in CSV, PIPE, or TAB format
# Written by Steve Kneizys Jan 21, 2000
# Updated 10/10/00,07/22/01
#

$db_name = $in{'db_name'};
if ($db_name eq "") {
  $db_name = "PRODUCT";
 }
$orig_start_time = $in{'mytime'};
$last_pos = $in{'db_pos'};
$start_tm = time();
$first = 1 + $in{'db_record'};
$last = $first + $mc_db_convert_per_pass - 1;
$inx = 0;
$last_converted = $in{'db_record'};
if ($in{'CSV_filename'} ne "") {
  $datafile_conv = "./data_files/$in{'CSV_filename'}";
  open(OFILE, "$datafile_conv") || &my_CSV_file_error($datafile_conv);
  if ($first == 1) {
    $orig_start_time=time();
    if ($in{'INIT_DB'} ne "") {
      &init_a_database($db_name,'');
     }
   }
  if ($last_pos > 0) {
    $inx = $in{'db_record'};
    seek(OFILE,$last_pos,0);
   }
  while (<OFILE>) {
    $line = $_;
    $orig_line = $line;
    $inx++;
    if (($inx >= $first) && ($inx <= $last)
	&& ((time()-$start_tm) < $mc_db_convert_seconds)) {
      $last_pos = tell(OFILE);
      chop($line);
      $last_converted = $inx;
      &codehook("mgr_custom_conversion_logic_1");
      if ($conv_type eq "TAB") {
	$line =~ s/\t/\|/g;
       }
      if ($conv_type eq "CSV") {
        $line = &conv_from_CSV($line);
       }
      &codehook("mgr_custom_conversion_logic_2");
      @st = split(/\|/,$line);
      $pid = $st[0];
      &codehook("mgr_custom_conversion_logic_3");
      if ($db_name ne "PRODUCT") { 
        &codehook("mgr_custom_conversion_logic_not_product");
        $myline = $line;
       } else { 
        $st[0] =~ s/\ /\_/g; 
        $st[1] =~ s/\ /\_/g; 
  #      $st[1] =~ s/\-/\_/g;
        if (($in{'CSV_update_padding'} =~ /y/i) && ($st[0] > 0)) { # pad
         $st[0] = &pad_key((0+$st[0]),$sc_prod_db_pad_length);
        }
        if ($in{'CSV_update_image_tag'} ne '') { 
        $st[4] = &update_image_tag($st[4]);
         }
        &codehook("mgr_custom_conversion_logic_4");
       $st[$#db] .= ''; 
       $myline = join('|',@st);
        &codehook("mgr_custom_conversion_logic_5");
       }
      &put_db_raw_line($db_name,$st[0],$myline,"no");
     } else { 
      if ($in{'db_pos'} > 0) { 
        seek(OFILE,0,2);
       }
     }
   }
  $elapsed_mins=int((5 + time() - $orig_start_time)/6)/10;
  $conv_result .=  "$db_name database converted ";
  $conv_result .=  "from $conv_type format in file: $datafile_conv\n";
  $conv_result .=  "<br>Converted $last_converted records, ";
  $conv_result .=  "elapsed time: $elapsed_mins mins.\n";
 } else {
  $conv_result .=  "Database name not specified for import!\n";
 }
close (OFILE);

if ($first >= $inx) {
  &init_convert_menu_item;
  $zitem = $menu_items{"database_screen"};
  &$zitem;
 } else {
  $myaction = "CSV_filename=$in{'CSV_filename'}";
  $myaction .= "&CSV_update_image_tag=$in{'CSV_update_image_tag'}";
  $myaction .= "&CSV_update_padding=$in{'CSV_update_padding'}";
  $myaction .= "&db_record=$last_converted";
  $myaction .= "&db_pos=$last_pos";
  $myaction .= "&db_name=$db_name";
  $myaction .= "&mytime=" . $orig_start_time;
  &codehook("mgr_custom_conversion_myaction");
  if ($conv_type eq "CSV") {
    $myaction .= "&data_from_CSV=YES";
   } 
  if ($conv_type eq "PIPE") {
    $myaction .= "&data_from_PIPE=YES";
   }
  if ($conv_type eq "TAB") {
    $myaction .= "&data_from_TAB=YES";
   }
  $qty = $last_converted;
  if ($qty > $inx) { $qty = $inx;}
  $elapsed_mins=int((5 + time() - $orig_start_time)/6)/10;
  print <<ENDOFTEXT;
<HTML>
<HEAD>
<TITLE>$conv_type $db_name Database Conversion in progress . . .</TITLE>
<SCRIPT TYPE="text/javascript">
  function myreload()
  {
  location.href="manager.cgi?$myaction";
  }
</SCRIPT>
</HEAD>

<BODY BGCOLOR='#F0FFFF' onLoad="myreload()">
<br><br>
<B><H2>Imported $qty records for $db_name database so far ...</H2></B><br>
<br>
Elapsed time in minutes: $elapsed_mins<br><br>
<PRE>
The web browser should automatically reload for the next page ... if your
browser does not reconnect for the next group of records automatically, 
you can <a href="manager.cgi?$myaction">Click Here</a>.
</PRE>
<br>
</BODY>
</HTML>
ENDOFTEXT
 }
}
################################################################################
sub STD_action_data_from_TAB {
  my $thing_to_do = $menu_items{'action_data_from_file'};
  &$thing_to_do("TAB");
 }
################################################################################
sub STD_action_data_from_PIPE {
  my $thing_to_do = $menu_items{'action_data_from_file'};
  &$thing_to_do("PIPE");
 }
################################################################################
sub STD_action_data_from_CSV {
  my $thing_to_do = $menu_items{'action_data_from_file'};
  &$thing_to_do("CSV");
 }
################################################################################
sub STD_agora_database_screen
{
local($my_db_name_list,%myhash,$inx,$myopt,$count);

print &$manager_page_header("Database","","","","");

%myhash = %db_file_defs; # s››; 
$my_db_name_list='';
$myhash{'PRODUCT'}=1; 
$count=0;
foreach $inx (sort(keys %myhash)) {
  $count++;
  $myopt='';
  if ($inx =~ /product/i) { $myopt .= ' selected';}
  $my_db_name_list .= "<option$myopt>" . $inx . "</option>\n";
 }

$my_db_name_list = 
	"Name of database to import/export:\n" .
	"<SELECT NAME='db_name'>\n" .
	$my_db_name_list .
	"</SELECT>\n";

$my_db_name_list = "<TR>\n<TD COLSPAN='2'>\n" .
	"$my_db_name_list" .
	"</TD>\n</TR>\n";

print <<ENDOFTEXT;
<CENTER>
<HR WIDTH=580>
</CENTER>

<CENTER>
<TABLE WIDTH=580>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Welcome to the DATABASE section of the
<b>AgoraCart</b>
System Manager. <br>
<FONT FACE=COURIER SIZE=2 COLOR=RED>
WARNING: THESE FUNCTIONS CAN AND DO ALTER THE ENTIRE DATABASE!
MAKE SURE YOU HAVE A GOOD BACKUP OF YOUR DATA FIRST!!
</FONT><br>
These options are currently available:<br>
 --> Update IMG tags, helpful if the directory has moved or the
database has recently been imported with incomplete or incorrect tags.
&nbsp; This option also sets the pad length of the product id #'s
to whatever is set in the agora.setup.db file.<br>
 --> Import the database file data.file from a CSV, PIPE or TAB file.<br>
 --> Export the database file data.file into a CSV or PIPE file.<br>
$mc_database_extra_options
</TD>
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
<FONT FACE=COURIER SIZE=2 COLOR=RED>$db_update_message</FONT>
</TD>
</TR>
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

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<FORM METHOD="POST" ACTION="manager.cgi">
<CENTER>
<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
This feature updates the IMG tags the same way they would be if 
edited individually.  However, this button will update all of the 
tags to point to the URL listed on the "Program Settings" screen.
It is useful if you have recently imported the database and the
pictures are not showing up, or the directory structure has been
changed and you desired to place the %%URLofImages%% token in the
path.&nbsp; This option also sets the pad length of the product id #'s
to whatever is set in the agora.setup.db file, and sorts the
records if the databse is a "flat file" so they appear in 
ascending order of product id.<br>
<CENTER>
<INPUT NAME="UpdateTags" TYPE="SUBMIT" VALUE="Update IMG Tags and PAD LENGTH">
&nbsp;&nbsp;
</CENTER>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
Here you may import or export the PRODUCT database (or any
other defined database) in CSV/PIPE/TAB
format.&nbsp;&nbsp; (CSV is Comma
Separated Variables format.&nbsp;&nbsp;
It is often used by spreadsheet and database
programs as a way of importing/exporting data.)<br><br>
Enter the name of the CSV/PIPE/TAB file here.&nbsp;&nbsp;
If left blank, database.csv is
assumed to be the name for exports, however imports REQUIRE a name.
<br><br>For IMPORTS you may specify if the import adds records
to the current database or replaces the entire database.
<br><br>Note: Make sure you have permission to create or modify the 
file in question!  
&nbsp;&nbsp;
Files are created in and read from the data_files directory.
$mc_database_custom_import_instructions
</TD>
</TR>

<TR>
<TD COLSPAN="2">
<INPUT NAME="CSV_filename" TYPE="TEXT" 
VALUE="" SIZE="25">
</TD>
</TR>

$my_db_name_list

<TR>
<TD COLSPAN=2>
<LEFT>
IMPORTS:  <br>
&nbsp;<INPUT TYPE="CHECKBOX" NAME="INIT_DB">
Full-Import of Database (erases db before importing records) 
<br>
&nbsp;<INPUT TYPE="CHECKBOX" NAME="CSV_update_padding">
Update key padding with leading zeros (product db, others if so defined)
<br>
&nbsp;<INPUT TYPE="CHECKBOX" NAME="CSV_update_image_tag">
Update image tag field (product db only)
<br>
$mc_database_custom_import_options
<INPUT NAME="data_from_CSV" TYPE="SUBMIT"
 VALUE="Import records From CSV">
<br>
<INPUT NAME="data_from_PIPE" TYPE="SUBMIT"
 VALUE="Import records From PIPE-delimited file">
<br>
<INPUT NAME="data_from_TAB" TYPE="SUBMIT" 
VALUE="Import records From TAB-delimited file">
$mc_database_custom_import_actions
<BR><BR>EXPORTS:<br>
$mc_database_custom_export_options
<INPUT 
TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<BR>
<INPUT NAME="data_to_CSV" TYPE="SUBMIT" 
VALUE="Export entire database to CSV">
<BR>
<INPUT NAME="data_to_PIPE" TYPE="SUBMIT" 
VALUE="Export entire database to PIPE">
<BR>
<INPUT NAME="data_to_TAB" TYPE="SUBMIT" 
VALUE="Export entire database to TAB">
$mc_database_custom_export_actions
</LEFT>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<HR>
</TD>
</TR>

$mc_database_extra_options_html

</TABLE>

</CENTER>
</FORM>
ENDOFTEXT
print &$manager_page_footer;
}
#########################################################################
sub conv_to_CSV
{
 local ($in,$part) = @_;
 local ($part);
 local ($ans) = "";

 while ($in ne "") {
   ($part,$in) = split(/\|/,$in,2);
   $part =~ s/\"/\"\"/g;
   if ($part eq "") {
     $ans .= ",";
    } else {
     $ans .= "\"$part\",";
    }
  } 
 
 chop($ans);
 return $ans;
 
}
############################################################
sub conv_from_CSV
{
    local($data_line) = @_;
    local($output_line) = "";
    local($combine,$combine_trigger,$data,$temp_data,$data_length, 
          @split_data, @output);

    $combine_trigger = "off";


    $data_line =~ s/\n+$//;
    $data_line =~ s/\r+$//;


    @split_data = split (/\,/, $data_line);


    foreach $data (@split_data)
	{

	if ($data =~ /\"/ || $combine_trigger eq "on")
		{

		$temp_data = $data;
		$temp_data =~ s/\"{2}//g;
		if ( $temp_data =~ /^\"/ ) { $beginning_quotes = "odd" } else { $beginning_quotes = "even" }
		if ( $temp_data =~ /\"$/ ) { $ending_quotes = "odd" } else { $ending_quotes = "even" }

		$temp_data = $data;
		$temp_data =~ s/\"//g;
		if ($temp_data eq "") { $all_quotes = "true" } else { $all_quotes = "false" }

		$data_length = length($data);
		if ( $beginning_quotes eq "odd" && $ending_quotes eq "odd" && $all_quotes eq "false" )
			{
			$combine_trigger = "off";
			$data = substr($data,1,$length-1);
			$data =~ s/\"{2}/\"/g;
			$output_line .= "$data|";
			}
		elsif ( $beginning_quotes eq "odd" && $ending_quotes eq "even" && $all_quotes eq "false" )
			{
			$combine_trigger = "on";
			$data = substr($data,1);
			$data =~ s/\"{2}/\"/g;
			$combine_data = $data;
			}
		elsif ( $beginning_quotes eq "even" && $ending_quotes eq "even" && $all_quotes eq "false" )
			{
			$combine_trigger = "on";
			$data =~ s/\"{2}/\"/g;
			$combine_data .= ",$data";
			}
		elsif ( $beginning_quotes eq "even" && $ending_quotes eq "odd" && $all_quotes eq "false" )
			{
			$combine_trigger = "off";
			$data = substr($data,0,$length-1);
			$data =~ s/\"{2}/\"/g;
			$combine_data .= ",$data";
			$output_line .= "$combine_data|";
			$combine_data = "";
			}
		elsif ( $beginning_quotes eq "odd" && $ending_quotes eq "odd" && $all_quotes eq "true" )
			{
			$data =~ s/\"//;  
			$data =~ s/\"{2}/\"/g;
			if ( $combine_trigger eq "off" )
				{
				$combine_trigger = "on";
				$combine_data = "$data";
				}
			else
				{
				$combine_trigger = "off";
				$combine_data .= ",$data";
				$output_line .= "$combine_data|";
				}
			}
		elsif ( $beginning_quotes eq "even" && $ending_quotes eq "even" && $all_quotes eq "true" )
			{
			$data =~ s/\"{2}/\"/g;
			$combine_data .= ",$data";
			}
		else
			{
			$combine_trigger = "off";
			$combine_data .= "ERROR";
			}

		}
	else
		{
		# print "Regular Push<BR>\n";
		$output_line .= "$data|";
		}

	}

chop($output_line);
return $output_line;

} 
#######################################################################
sub get_file_lock 
{

local ($lock_file) = @_;
local ($endtime);
local ($exit_get_file_lock)="";
&codehook("get_file_lock");
if ($exit_get_file_lock ne "") {return;}

$endtime = 55; # was 20 originally
$endtime = time + $endtime;

while (-e $lock_file && time < $endtime) 
{
sleep(1);
}

open(LOCK_FILE, ">$lock_file") || 
    &CgiDie ("I could not open the lockfile - check your permission " .
	     "settings ($lock_file)");

# flock(LOCK_FILE, 2); # 2 exclusively locks the file

} 

#######################################################################
sub release_file_lock 
{
local ($lock_file) = @_;
local ($exit_release_file_lock)="";
&codehook("release_file_lock");
if ($exit_release_file_lock ne "") {return;}

# flock(LOCK_FILE, 8); # 8 unlocks the file
close(LOCK_FILE);
unlink($lock_file);
} 
############################################################
1; #We are a library
