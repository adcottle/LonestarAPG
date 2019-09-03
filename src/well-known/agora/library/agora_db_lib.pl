###########################################################
# AGORA_DB_LIB.PL

$versions{'agora_db_lib.pl'} = "20011226";
$sc_db_engine='flatfile';

# Written by Steve Kneizys for AGORA.CGI
#
# Some of this comes from the original WEB_STORE_DB_LIB.PL
# (written by Gunther Birznieks  -- "Feel free to copy, 
#  cite, reference, sample, borrow, resell or plagiarize the 
#  contents..." :) 
#
# Purpose: This library contains the routines that the
# store uses to interface with a flatfile (plain
# ASCII text file) database file.
##############################################################################
#
# The hash %db_file_defs must have something defined for each 
# database a database implementation has defined, such as:
#   $db_file_defs{"PRODUCT"} = '1';
# You can use the variable for anything, in this library it 
# holds the full path to the file, but it must be defined!
# 
##############################################################################
sub get_prod_db_category_list {
  local (%db_ele,%category_list);
  &get_prod_db_element($db{"product"},*db_ele);
  foreach $sku (keys %db_ele) {
    $category = $db_ele{$sku};
    $category_list{$category}=1;
   }
  return (sort(keys %category_list));
 }
############################################################
sub check_db_with_product_id {
  local($product_id, *db_row) = @_;
  local($result,$db_raw_line,$result);
  $result = &get_prod_db_row($product_id, *db_row, *db_raw_line, "yes");
  return $result;

}

############################################################
sub get_prod_db_row {
  local($product_id, *db_row, *db_raw_line, $cacheok) = @_;
  local($db_product_id,$save_the_line,$filename);
  $db_product_id = "";

  if (!($sc_db_flatfile_caching_ok =~ /yes/i)) {$cacheok = "no";}
  $db_raw_line = "";#init it
  if (($cacheok =~ /yes/i) && ($db_cache{$product_id} ne "")) {
    $line = $db_cache{$product_id};
    @db_row = split(/\|/,$line);
    $db_raw_line = $line;
    return 1;
  }

  $filename = $db_file_defs{"PRODUCT"};

  open(DATAFILE, "$filename") ||
    &file_open_error("$filename",
      "Read Database",__FILE__,__LINE__);

  while (($line = <DATAFILE>) &&
         ($product_id ne $db_product_id)) {
    chop($line);
    @db_row = split(/\|/,$line);
    $save_the_line = $line;
    $db_product_id = $db_row[0];
    if ($cacheok =~ /yes/i) {
      $db_cache{$db_product_id}=$save_the_line;
     }
  }

  if ($product_id eq $db_product_id) { 
    $db_raw_line = $save_the_line;
  }

  close (DATAFILE);

  return ($product_id eq $db_product_id);

} 

sub get_db_row {
  local($dbname, $product_id, *db_row, *db_raw_line, $cacheok) = @_;
  local($db_product_id,$save_the_line,$filename);
  $db_product_id = "";

  $db_raw_line = "";

  $filename = $db_file_defs{$dbname};

  open(DATAFILE, "$filename") ||
    &file_open_error("$filename",
      "Read Database",__FILE__,__LINE__);

  while (($line = <DATAFILE>) &&
         ($product_id ne $db_product_id)) {
    chop($line);
    @db_row = split(/\|/,$line);
    $save_the_line = $line;
    $db_product_id = $db_row[0];
  }
  if ($product_id eq $db_product_id) { 
    $db_raw_line = $save_the_line;
  }

  close (DATAFILE);

  return ($product_id eq $db_product_id);

} 


#################################################################
sub get_prod_db_element {
  local($element_id,*db_ele) = @_;
  &get_db_element("PRODUCT",0,$element_id,"last",*db_ele);
} 
#################################################################
sub get_prod_db_keys {
  local($element_id,%db_ele);
  $element_id = 0; #redundant, but works
  &get_db_element("PRODUCT",0,$element_id,"last",*db_ele);
  return (keys %db_ele);
} 
#################################################################
sub get_db_keys {
  local($dbname)=@_;
  local($element_id,%db_ele);
  $element_id = 0; #redundant, but works
  &get_db_element($dbname,0,$element_id,"last",*db_ele);
  return (keys %db_ele);
} # End of sub get_db_keys 
#################################################################
sub get_db_element {
  local($data_file,$id_inx,$element_id,$dups,*db_ele) = @_;
  local($db_id,$save_the_line,@db_row,$db_raw_line,$data_file_path);

  $data_file_path = $db_file_defs{"$data_file"};

  open(DATAFILE, $data_file_path) ||
    &file_open_error($data_file_path, " Read Database ",__FILE__,__LINE__);

  while (($line = <DATAFILE>)) {
    @db_row = split(/\|/,$line);
    $db_id = $db_row[$id_inx];
    if (($db_ele{$db_id} ne "") && ($dups =~ /all/i)) {
      $db_ele{$db_id} .= "|" . $db_row[$element_id];
     } else {
      $db_ele{$db_id} = $db_row[$element_id];
     }
  }
  close (DATAFILE);

  return;
} 
############################################################ 
sub get_next_prod_key {
  local($element_id,%db_ele,$highest,$next_key,$mykey); 
  local($padlength) = $sc_prod_db_pad_length;
  $element_id = $db{"product"};
  &get_prod_db_element($element_id,*db_ele);
  $highest=0;
  foreach $mykey (%db_ele){
    if ($mykey > $highest) {
      $highest = $mykey;
     }
   }
  $next_key = &pad_key(($highest + 1),$padlength);
  return $next_key;
} 
############################################################
sub pad_key {
  local($next_key,$padlength) = @_;
  while(length($next_key) < $padlength) {
    $next_key = "0$next_key";
   }
  return $next_key;
} 
############################################################
sub put_prod_db_raw_line {
  local($product_id, $db_raw_line, $cacheok) = @_;
  local($result,$db_product_id,$ProductEditSku)=0;
  local ($sku, $category, $price, $short_description, $image, 
         $long_description, $shipping_price, $userDefinedOne, 
         $userDefinedTwo, $userDefinedThree, $userDefinedFour, 
         $userDefinedFive, $options, $junk, $line, @lines);

($ProductEditSku,$junk) = split(/\|/,$db_raw_line,2);
 
$filename = $db_file_defs{"PRODUCT"};
&get_file_lock("${filename}.lock");
open(OLDFILE, "$filename") || &my_die("Can't Open $filename");
@lines = <OLDFILE>;
close (OLDFILE);
open(NEWFILE,">$filename") || &my_die("Can't Open $filename");

foreach $line (@lines){
  ($sku, $category, $price, $short_description, $image, 
  $long_description, $shipping_price, $userDefinedOne, 
  $userDefinedTwo, $userDefinedThree, $userDefinedFour, 
  $userDefinedFive, $options) = split(/\|/,$line);

  if ($sku eq $product_id) {
   print NEWFILE $db_raw_line . "\n";
   $result=1;
  } else {
   print NEWFILE $line;
  }
 }

close (NEWFILE);
&release_file_lock("${filename}.lock");

if ($result ne 1 ) {
  $result = &add_new_record_to_prod_db($db_raw_line);
 }

if ($db_cache{$ProductEditSku} ne "") {
  $db_cache{$ProductEditSku} = "";
 }
# if written ok and caching, don't need to read again!
if (($cacheok =~ /yes/i) && ($result)) {
  $db_cache{$ProductEditSku} = $db_raw_line;
 }
return $result;

} 
############################################################
sub put_db_raw_line {
  local($dbname,$product_id, $db_raw_line, $cacheok) = @_;
  local($result,$db_product_id,$ProductEditSku)=0;
  local ($sku, $category, $price, $short_description, $image, 
         $long_description, $shipping_price, $userDefinedOne, 
         $userDefinedTwo, $userDefinedThree, $userDefinedFour, 
         $userDefinedFive, $options, $junk, $line, @lines);

($ProductEditSku,$junk) = split(/\|/,$db_raw_line,2);
 
$filename = $db_file_defs{$dbname};
&get_file_lock("${filename}.lock");
open(OLDFILE, "$filename") || &my_die("Can't Open $filename");
@lines = <OLDFILE>;
close (OLDFILE);
open(NEWFILE,">$filename") || &my_die("Can't Open $filename");

foreach $line (@lines){
  ($sku, $junk) = split(/\|/,$line,2);

  if ($sku eq $product_id) {
   if ($db_raw_line ne '') {print NEWFILE $db_raw_line . "\n";}
   $result=1;
  } else {
   print NEWFILE $line;
  }
 }

if ($result ne 1 ) {
   if ($db_raw_line ne '') {print NEWFILE $db_raw_line . "\n";}
   $result = 1;
 }

close (NEWFILE);
&release_file_lock("${filename}.lock");

return $result;

} 
############################################################
sub del_prod_from_db {
  local($product_id) = @_;
  local($db_raw_line, $cacheok) = @_;
  local($result,$db_product_id,$ProductEditSku)=0;
  local ($sku, $category, $price, $short_description, $image, 
         $long_description, $shipping_price, $userDefinedOne, 
         $userDefinedTwo, $userDefinedThree, $userDefinedFour, 
         $userDefinedFive, $options, $junk, $line, @lines);

($ProductEditSku,$junk) = split(/\|/,$db_raw_line,2);
 
$filename = $db_file_defs{"PRODUCT"};
&get_file_lock("${filename}.lock");
open(OLDFILE, "$filename") || &my_die("Can't Open $filename");
@lines = <OLDFILE>;
$result=0;
close (OLDFILE);
open(NEWFILE,">$filename") || &my_die("Can't Open $filename");

foreach $line (@lines){
  ($sku, $category, $price, $short_description, $image, 
  $long_description, $shipping_price, $userDefinedOne, 
  $userDefinedTwo, $userDefinedThree, $userDefinedFour, 
  $userDefinedFive, $options) = split(/\|/,$line);

  if ($sku eq $product_id) {
   $result=1;
  } else {
   print NEWFILE $line;
  }
 }

close (NEWFILE);
&release_file_lock("${filename}.lock");

if ($db_cache{$ProductEditSku} ne "") {
  $db_cache{$ProductEditSku} = "";
 }

return $result;

} 
#######################################################################
sub add_new_record_to_prod_db {
 
 local ($my_new_rec) = @_;
 local ($filename);

 $filename = $db_file_defs{"PRODUCT"};
 &get_file_lock("${filename}.lock");
 open (NEW, "+>> $filename") || &my_die("Can't Open $filename");
 print (NEW "$my_new_rec\n");
 close(NEW);
 &release_file_lock("${filename}.lock");

 return 1;

}
############################################################
sub submit_query {
  local (*database_rows) = @_;
  local ($status,$rowcount);
  ($status,$row_count) = &submit_a_query("PRODUCT", $sc_db_max_rows_returned,
	*form_data, *sc_db_query_criteria, *database_rows);
  if (($row_count == 0) && ($main_program_running =~ /yes/i)) {
    &PrintNoHitsBodyHTML;
    &call_exit;
   } 
  return($status,$row_count);
}
############################################################
sub submit_a_query {
  local($dbname, $sc_db_max_rows_returned, *form_data, *sc_db_query_criteria, 
	*database_rows) = @_;
  local($status);
  local(@fields);
  local($row_count);
  local(@not_found_criteria);
  local($line); 
  local($exact_match) = $form_data{'exact_match'};
  local($case_sensitive) = $form_data{'case_sensitive'};
  $row_count = 0;
  $filename = $db_file_defs{$dbname};

  open(DATAFILE, "$filename") ||
    &file_open_error("$filename",
      "Read Database",__FILE__,__LINE__);

  while(($line = <DATAFILE> ))# &&
        #($row_count < $sc_db_max_rows_returned + 1))
  {
    chop($line); 

    @fields = split(/\|/, $line);

    $not_found = 0;
    foreach $criteria (@sc_db_query_criteria)
    {  
      $not_found += &flatfile_apply_criteria(
	$exact_match,
	$case_sensitive,
	*fields,
	$criteria);
    }

    if (($not_found == 0))# && 
        #($row_count <= $sc_db_max_rows_returned))
    {
#      push(@database_rows, join("\|", @fields));
      push(@database_rows, $fields[0]);
    }

    if ($not_found == 0) {
      $row_count++;
    }
  } 

  close (DATAFILE);

if ($row_count > $sc_db_max_rows_returned) {
    $status = "max_rows_exceeded";
} 

  @database_rows = sort(@database_rows);

  return($status,$row_count);

} 
############################################################
sub flatfile_apply_criteria {
  local($exact_match, $case_sensitive,
      *fields, $criteria) = @_;
  local($c_name, $c_fields, $c_op, $c_type);
  local(@criteria_fields);
  local($not_found);
  local($form_value);
  local($db_value);
  local($month, $year, $day);
  local($db_date, $form_date);
  local($db_index);
  local(@word_list);

  ($c_name, $c_fields, $c_op, $c_type) = 
     split(/\|/, $criteria);

  @criteria_fields = split(/,/,$c_fields);

  $form_value = $form_data{$c_name};

  $form_value =~ s/\0/ /g; 
  $form_value =~ s/(\s+)/ /g; 
  $form_value =~ s/(^\s)//g;  

  if ($form_value eq "")
  {
    return 0;
  }


  if (($c_type =~ /date/i) ||
     ($c_type =~ /number/i) ||
     ($c_op ne "="))
  {

    $not_found = "yes";

    foreach $db_index (@criteria_fields)
    {

      $db_value = $fields[$db_index];

      if ($c_type =~ /date/i) 
      {
        ($month, $day, $year) =
          split(/\//, $db_value);
        $month = "0" . $month
          if (length($month) < 2);
        $day = "0" . $day
          if (length($day) < 2);
        if ($year > 50 && $year < 1900) {
          $year += 1900;
        }
        if ($year < 1900) {
          $year += 2000;
        }
        $db_date = $year . $month . $day;

        ($month, $day, $year) =
          split(/\//, $form_value);
        $month = "0" . $month
          if (length($month) < 2);
        $day = "0" . $day
          if (length($day) < 2);
        if ($year > 50 && $year < 1900) {
          $year += 1900;
        }
        if ($year < 1900) {
          $year += 2000;
        }
        $form_date = $year . $month . $day;

        if ($c_op eq ">") {
          return 0 if ($form_date > $db_date); }
        if ($c_op eq "<") {
          return 0 if ($form_date < $db_date); }
        if ($c_op eq ">=") {
          return 0 if ($form_date >= $db_date); }
        if ($c_op eq "<=") {
          return 0 if ($form_date <= $db_date); }
        if ($c_op eq "!=") {
          return 0 if ($form_date != $db_date); }
        if ($c_op eq "=") {
          return 0 if ($form_date == $db_date); }

      } elsif ($c_type =~ /number/i) {
        if ($c_op eq ">") {
          return 0 if ($form_value > $db_value); }
        if ($c_op eq "<") {
          return 0 if ($form_value < $db_value); }
        if ($c_op eq ">=") {
          return 0 if ($form_value >= $db_value); }
        if ($c_op eq "<=") {
          return 0 if ($form_value <= $db_value); }
        if ($c_op eq "!=") {
          return 0 if ($form_value != $db_value); }
        if ($c_op eq "=") {
          return 0 if ($form_value == $db_value); }

      } else { 
        if ($c_op eq ">") {
          return 0 if ($form_value gt $db_value); }
        if ($c_op eq "<") {
          return 0 if ($form_value lt $db_value); }
        if ($c_op eq ">=") {
          return 0 if ($form_value ge $db_value); }
        if ($c_op eq "<=") {
          return 0 if ($form_value le $db_value); }
        if ($c_op eq "!=") {
          return 0 if ($form_value ne $db_value); }
      }    
    } 
    
  } else { 

    @word_list = split(/\s+/,$form_value);


    foreach $db_index (@criteria_fields)
    {
 

      $db_value = $fields[$db_index];
      $not_found = "yes";
 
      local($match_word) = "";
      local($x) = "";

      if ($case_sensitive eq "on") {
          if ($exact_match eq "on") {
              for ($x = @word_list; $x > 0; $x--) {
            # \b matches on word boundary
                  $match_word = $word_list[$x - 1];
                  if ($db_value =~ /\b$match_word\b/) {
                      splice(@word_list,$x - 1, 1);
                  } 
              } 
          } else {
              for ($x = @word_list; $x > 0; $x--) {
                  $match_word = $word_list[$x - 1];
                  if ($db_value =~ /$match_word/) {
                      splice(@word_list,$x - 1, 1);
                  } 
              } 
          } 
      } else {
          if ($exact_match eq "on") {
              for ($x = @word_list; $x > 0; $x--) {
      # \b matches on word boundary
                  $match_word = $word_list[$x - 1];
                  if ($db_value =~ /\b$match_word\b/i) {
                      splice(@word_list,$x - 1, 1);
                  }  
              } 
          } else {
              for ($x = @word_list; $x > 0; $x--) {
                  $match_word = $word_list[$x - 1];
                  if ($db_value =~ /$match_word/i) {
                      splice(@word_list,$x - 1, 1);
                  } 
              } 
          } 
      }

  

    } 

    if (@word_list < 1) 
    {
      $not_found = "no";
    }

  } 

  if ($not_found eq "yes")
  {
    return 1;
  } else {
    return 0;
  }
} 
#######################################################################
sub init_agora_database_library {
 $db_file_defs{"PRODUCT"} = "$sc_data_file_path";
 }
#######################################################################
sub open_product_database {
 # is a no-op, database is opened on demand in flatfile routines
 }
#######################################################################
sub init_product_database {
 # used in new manager routines for CSV 10/10/00
 $filename = $db_file_defs{"PRODUCT"};
 open(NEWFILE,">$filename") || &my_die("Can't Open $filename");
 close(NEWFILE);
 }
#######################################################################
sub open_a_database {
  local ($name,$path) = @_;
   if ($path eq '') { $ path = "$sc_data_file_dir";}
  $db_file_defs{"$name"} = "$path/$name";
  return;
 }
#######################################################################
sub init_a_database {
  local (
   $name,
   $path,
   $fields_to_index_by_keyword,	
   $fields_to_index_as_is,	
   @fieldnames			# optional ?
  ) = @_;
  &codehook("init_a_database_top");
  if ($db_file_defs{"$name"} ne '') {
    $zpath = $db_file_defs{"$name"}
   } else {
    if ($path eq '') { $ path = "$sc_data_file_dir";}
    $zpath = "$path/$name";
   }
  $zpath =~ /([^\xFF]*)/;
  $zpath = $1;
#print "Content-type: text/html;\n\n$zpath<br>\n";
  open(NEWFILE,">$zpath") || &my_die("Can't Open $zpath");
  close(NEWFILE);
  return;
 }
#######################################################################
sub close_all_databases {
 # is a no-op, databases opened/closed on demand in flatfile routines
 }
#######################################################################
sub match_pattern_in_database {
 local ($db_name,$db_field,$pattern,$case_sens_bool,*keylist) = @_;
 return;
 }
#######################################################################
if ($sc_db_lib_was_loaded ne "yes") {
  $sc_db_lib_was_loaded = "yes";
  &init_agora_database_library;
  &open_product_database;
  &add_codehook("cleanup_before_exit","close_all_databases");
 }
#############################################################################
1;

