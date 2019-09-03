#!/usr/local/bin/perl
# Simple Library  -- can use the "lynx" command line program to 
# use as a replacement for using SOCKETS in perl with small changes.
#
# Parts stolen from Business:UPS CPAN  module and included here
# because that module if often not installed at Web hosting companies
# 
# written by Steve Kneizys Jan 9, 2000
#
# Modified 1/21/2000 to use http-lib.pl as some folks do not 
# have LWP or lynx installed at their web hosting company
# UPDATE: lynx is being phased out, APIs tend to require POST now
#
# Modified 01/27/2000 to search for lynx and use perl taint mode 
# Modified 02/06/2000 for error-recovery if libraries/modules not found
# Modified 04/21/2000 to allow for custom logic outside this library
# Modified 06/30/2000 USPS code added (not finished yet!)
# Modified 07/02/2000 FedEx code added, added sub LWP_post
# Modified 08/08/2000 New UPS Interface installed
# Modified 08/17/2000 UPS Interface w LWP fixed
# Modified 05/06/2001 UPS Interface fixed, uses 'old' code again 
# Modified 05/11/2001 Includes 'value of items' in 'shipping thing' string
#

$versions{'shipping_lib.pl'} = "20021020";

# Do we need sockets part of this library ?
if (($sc_use_SBW =~ /yes/i) || ($sc_need_sockets =~ /yes/i)) { 
 if ($sc_use_socket eq "") { # should be set but if not ...
   $sc_use_socket = "http-lib";   # set our preferred default
  }

 if ($sc_use_socket =~ /lwp/i) { #helpful (but not required) error check
    $test_result = eval("use LWP::Simple; 1;");
    if ($test_result ne "1") {
      print "Content-type: text/html\n\n";
      print "LWP library not installed -- choose another library type\n";
      print "in \"Program Settings\".\n";
      if ($main_program_running =~ /yes/i) {
        &call_exit;
       }
     }
  }
 if ($sc_use_socket =~ /http-lib/i) {
    local($wtd)="";
    if ($main_program_running =~ /yes/i) {
      $wtd .= "warn exit";
      }
    &request_supporting_libraries($wtd, __FILE__, __LINE__, 
		"./library/http-lib.pl");
    $http_lib_loaded = "yes";
  }
 if ($sc_use_socket =~ /lynx/i) {
    $path_to_lynx_software = &get_lynx_path("1");
  }
}
#********************************************************************

sub agora_http_get {
 local ($site,$path,$workString) = @_;
 local ($answer,$doworkString);

 if ($sc_use_socket =~ /lwp/i) { # use LWP library GET
  # By calling this way, no error generated if library is missing
  # when the library is first loaded up or at runtime of this routine
   $doworkString = "http://$site$path\?${workString}";
   $answer = eval("use LWP::Simple; get\(\"$doworkString\"\);");
  }
 if ($sc_use_socket =~ /http-lib/i) { # use http-lib.pl library GET
   $answer = &HTTPGet($path,$site,80,$workString);
  }
 if ($sc_use_socket =~ /lynx/i) { # use lynx to get the answer
   $doworkString = "http://$site$path\?${workString}";
   $answer = &special_get($doworkString);
  }
 return $answer;
}
#********************************************************************
# This routine should take the string of weights and descriptions,
# and decide what goes in what box.  It also returns a string of
# shipping instructions so the people packing know what to put in
# each box to get the weight correct.
#
# It is not very efficient, nor is it very smart!
#

sub ship_put_in_boxes {
 local($weight_data,$names_data, $Origin_ZIP,$max_per_box) = @_;
 local($instructions, $special_instructions, $items_in_box, $weight_of_box,
       $new_wt_data, $inx1, $inx2, $junk, $items_this_round, $value_of_box);
 local($continue)="yes";

 $instructions="";
 $special_instructions="";
 &codehook("shippinglib-put-in-boxes-top");
 if (!($continue =~ /yes/i)) { return;}

 $instructions  = "Ship By Weight cost was based on the suggested ";
 $instructions .= "configuration below.  It might not be the best way!\n";
 $instructions .= "ORIGIN: $Origin_ZIP\n\n";
 $instructions .= "Box 1:\n";
 $items_in_box = 0;
 $weight_of_box = 0;
 $value_of_box = 0;
 $new_wt_data = "";

    ($junk,$weight_data) = split(/\|/,$weight_data,2);
    @ship_list = split(/\|/,$weight_data);
    ($junk,$names_data) = split(/\|/,$names_data,2);
    @name_list = split(/\|/,$names_data);
    for ($inx1=0; $inx1 <= $#ship_list; $inx1++) {
      ($item_qty,$item_wt,$item_val,$junk) = split(/\*/,$ship_list[$inx1],4);
      $ztitle = $name_list[$inx1];
      $items_this_round = 0;
      for ($inx2=$item_qty; $inx2 > 0; $inx2--) {
        if ($items_in_box == 0) {
           $items_in_box = 1;
           $weight_of_box = $item_wt;
           $value_of_box = $item_val;
           $items_this_round++;
          } else { # add to or close/start box
            if (($weight_of_box + $item_wt) < $max_per_box) { #add
              $items_in_box++;
              $weight_of_box = $weight_of_box + $item_wt;
              $value_of_box = $value_of_box + $item_val;
              $items_this_round++;
             } else { # close, then start a new box
              if ($items_this_round > 0) {
                  $instructions .="  $items_this_round $ztitle [$item_wt]\n";
                }
              $instructions .= " Total Weight: $weight_of_box\n\n";
              $new_wt_data .= "|1*${weight_of_box}*${value_of_box}";
              $instructions .= "Next Box:\n";
              $items_in_box = 1;
              $weight_of_box = $item_wt;
              $value_of_box = $item_val;
              $items_this_round = 1;
             }
          }
       }
        if ($items_this_round > 0) {
            $instructions .="  $items_this_round $ztitle [$item_wt]\n";
          }
     }
    $instructions .= " Total Weight: $weight_of_box\n\n";
    $new_wt_data .= "|1*${weight_of_box}*${value_of_box}";

 if ($max_per_box == 0) {
   $instructions = "Put one item in each box.";
  }

 $final_instructions =  $special_instructions . $instructions;
 &codehook("shippinglib-put-in-boxes-bot");
 return ($new_wt_data,$final_instructions);
}

sub calc_SBW {
  my ($method, $dest, $weight_data) = @_;
  my ($via,$junk);

  ($via,$junk) = split(/\ /,$method,2);
 
  &codehook("SBW_top");

  if (($via eq "UPS") && ($sc_use_UPS =~ /yes/i)) {
    $sc_verify_Origin_ZIP = $sc_UPS_Origin_ZIP;
    return &calc_ups($method, $sc_verify_Origin_ZIP, $dest, $weight_data);
   }

  if (($via eq "USPS") && ($sc_use_USPS =~ /yes/i)) {
    $sc_verify_Origin_ZIP = $sc_USPS_Origin_ZIP;
    return &calc_usps($method, $sc_verify_Origin_ZIP, $dest, $weight_data);
   }

  if (($via =~ /FEDEX/i) && ($sc_use_FEDEX =~ /yes/i)) {
    $sc_verify_Origin_ZIP = $sc_FEDEX_Origin_ZIP;
    return &calc_fedex($method, $sc_verify_Origin_ZIP, $dest, $weight_data);
   }

  &codehook("SBW_bot");

# got here, this is bad, return zero value
  return 0;

}

sub calc_ups {
    my ($method, $origin, $dest, $weight_data) = @_;
    my ($err_printed) = "";
    my ($product, $weight, $ship_cost, $total_weight, $junk,
        $thezone, $errmsg, $foundit,
        $item_info, $item_wt, $item_qty, $item_cost, @ship_list);

    $ship_cost = 0; # handling charge added in define_shipping_logic
#
# Split the order out into boxes using logic of ship_put_in_boxes
    ($weight_data,$ship_ins) =  
      &ship_put_in_boxes($weight_data, $weight_data, $origin, $sc_UPS_max_wt);
    $sc_shipping_thing = $weight_data;
    $sc_verify_boxes_max_wt = $sc_UPS_max_wt;

#  Now setup the proper UPS PRODUCT code based on web page selection
    $product = "GNDRES"; #default
    $foundit = "no";

    if ($method eq "UPS 2nd Day") {
       $product = "2DA";
       $foundit = "yes";
      }
    if ($method eq "UPS Next Day") {
       $product = "1DA";
       $foundit = "yes";
      }
    if ($foundit eq "no") { #Look for code: value ="UPS xyz (PRODUCT)"
       ($junk,$stuff) = split(/\(/,$method,2);
       ($stuff,$junk) = split(/\)/,$stuff,2);
       if ($stuff ne "") { #assume we have a valid product code
          $product = $stuff;
          $foundit = "yes";
         }
      }
# Split off the total weight calculated
    ($total_weight,$weight_data) = split(/\|/, $weight_data, 2);
#
# calculate the shipping for each box  individually. 
    @ship_list = split(/\|/,$weight_data);
    foreach $item_info (@ship_list) {
      ($item_qty,$item_wt,$junk) = split(/\*/,$item_info,3);
      if ($item_wt <= 1) { # set min value
        $item_wt = 1;
       }

      ($item_cost,$thezone,$errmsg) = 
        &getUPS_simple($product, $origin, $dest, $item_wt);
      if ($errmsg ne "") {
        #sleep(4);
        ($item_cost,$thezone,$errmsg) = 
          &getUPS_simple($product, $origin, $dest, $item_wt);
       }
      if ($errmsg ne "") {
        #sleep(4);
        ($item_cost,$thezone,$errmsg) = 
          &getUPS_simple($product, $origin, $dest, $item_wt);
       }
      if ($item_cost == 0 && $err_printed eq "") {
        $err_printed = "yes";
        $order_error_do_not_finish = "yes";
        print "UPS module error: shipping cost not determined!<br>",
		"Please use your 'Make Changes' button and correct ",
		"<br>any fields as required and try again.<br>",
		"$errmsg<br>\n";
       }

      $ship_cost = $ship_cost + $item_qty*$item_cost;

     }

    return $ship_cost;
}

######################################################################
sub calc_usps {
    my ($method, $origin, $dest, $weight_data) = @_;
    my ($err_printed,$err) = "";
    my ($product, $weight, $ship_cost, $total_weight, $junk,
        $thezone, $errmsg, $foundit,
        $item_info, $item_wt, $item_qty, $item_cost, @ship_list);

    $ship_cost = 0; 

  ($weight_data,$ship_ins) =  
	&ship_put_in_boxes($weight_data, $weight_data, $origin, $sc_USPS_max_wt);
  $sc_shipping_thing = $weight_data;

  $sc_verify_boxes_max_wt = $sc_USPS_max_wt;

  # Look for code: value ="USPS xyz (PRODUCT)"
  ($junk,$stuff) = split(/\(/,$method,2);
  ($stuff,$junk) = split(/\)/,$stuff,2);
  if ($stuff ne "") { 
     $product = $stuff;
     $foundit = "yes";
    }
  
    ($total_weight,$weight_data) = split(/\|/, $weight_data, 2);

    @ship_list = split(/\|/,$weight_data);
    foreach $item_info (@ship_list) {
      ($item_qty,$item_wt,$junk) = split(/\*/,$item_info,3);
      if ($item_wt <= 1) { # min
        $item_wt = 1;
       }

      ($item_cost,$err) = &getUSPS_simple($product, $origin, $dest, $item_wt);

      if ($item_cost == 0 && $err_printed eq "") {
        $err_printed = "yes";
        $order_error_do_not_finish = "yes";
        print "USPS module error: shipping cost not determined!<br>",
              "Please use your browser's back button and correct ",
              "<br>any fields as required and try again.<br><br>$err<br>\n";
       }

      $ship_cost = $ship_cost + $item_qty*$item_cost;

     }

    return $ship_cost;
}
######################################################################

sub calc_fedex {
#Federal Express interface module
# very very similar to UPS,USPS routines
    my ($method, $origin, $dest, $weight_data) = @_;
    my ($err_printed,$err) = "";
    my ($product, $weight, $ship_cost, $total_weight, $junk,
        $thezone, $errmsg, $foundit, $iter,
        $item_info, $item_wt, $item_qty, $item_cost, @ship_list);

    $ship_cost = 0; # handling charge added in define_shipping_logic
#
# Split the order out into boxes using logic of ship_put_in_boxes
    ($weight_data,$ship_ins) =  
      &ship_put_in_boxes($weight_data, $weight_data, $origin, $sc_FEDEX_max_wt);

  $sc_shipping_thing = $weight_data;
  $sc_verify_boxes_max_wt = $sc_FEDEX_max_wt;

  # Look for product code: value ="FEDEX xyz (PRODUCT)"
  ($junk,$stuff) = split(/\(/,$method,2);
  ($stuff,$junk) = split(/\)/,$stuff,2);
  if ($stuff ne "") { #assume we have a valid product code
     $product = $stuff;
     $foundit = "yes";
    }
  
# Split off the total weight calculated
    ($total_weight,$weight_data) = split(/\|/, $weight_data, 2);
#
# calculate the shipping for each box  individually. 
    @ship_list = split(/\|/,$weight_data);
    foreach $item_info (@ship_list) {
      ($item_qty,$item_wt,$junk) = split(/\*/,$item_info,3);
      if ($item_wt <= 1) { # min value
        $item_wt = 1;
       }

       $item_cost="";
       $iter = 0;
       while ((!($item_cost > 0)) && ($iter < 10)) {
         $iter++;
         ($item_cost,$err)=&getFEDEX_simple($product,$origin,$dest,$item_wt);
        } 

      if ($item_cost == 0 && $err_printed eq "") {
        $err_printed = "yes";
        $order_error_do_not_finish = "yes";
        print "FEDEX module error: shipping cost not determined!<br>",
              "Please use your browser's back button and correct ",
              "<br>any fields as required and try again.<br><br>$err<br>\n";
       }

      $ship_cost = $ship_cost + $item_qty*$item_cost;

     }

    return $ship_cost;
}

################################################################
#can try to use this if LWP not available andhttp-lib broken ... 
#maybe lynx is avail for UPS/USPS

sub special_get {
    local ($spk, $answer, $oldpath, $my_lynx);
    local ($workString) = @_;

    $spk = $workString;
    $spk =~ s/\&/\\\&/g;         # need to change & to \& for the shell
    $oldpath = $ENV{"PATH"};
    $ENV{"PATH"} = "/bin:/usr/bin";
    $ENV{"TERM"} = "vt100"; # fool it! 
    $answer = `$path_to_lynx_software -dump $spk`;#have lynx dump answer
    $ENV{"PATH"} = $oldpath;
    $answer =~ s/\n//;          # get rid of first newline char
    return $answer;
}

#####################################################################

sub get_lynx_path {
 local($switch) = @_;
 local($lynx_program,$lynx0,$lynx1,$lynx2,$lynx3,$lynx4,$lynx5);
 
 $lynx0 = './lynx';
 $lynx1 = '/usr/bin/lynx';
 $lynx2 = '/bin/lynx';
 $lynx3 = '/usr/local/bin/lynx';
 $lynx4 = '/usr/sbin/lynx';
 $lynx5 = '/usr/local/lynx/lynx';

 if ( -f $lynx0) {
    $lynx_program = $lynx0;
 } elsif( -f $lynx1){
    $lynx_program = $lynx1;
 } elsif( -f $lynx2){
    $lynx_program = $lynx2;
 } elsif( -f $lynx3){
    $lynx_program = $lynx3;
 } elsif( -f $lynx4){
    $lynx_program = $lynx4;
 } elsif( -f $lynx5){
    $lynx_program = $lynx5;
 } else {
    if ($switch eq "1") {
      print "Content-type: text/html\n\n";
      print "I can't find lynx, shutting down...<br>";
      print "If you find the path to lynx change it in shipping_lib.pl ";
      &call_exit;
     } else {
      $lynx_program = "";
     }
 }

 return $lynx_program;

}

#####################################################################

sub getFEDEX_simple {
  my ($product, $origin, $dest, $weight) = @_;
  my ($pounds,$ounces,$prot,$site,$path,$junk,$answer);
  my ($err,$resp,$resp1,@resp);
  my ($country , $service, $length, $width, $height, $oversized, $cod);
#  $country ||= 'US';
    
#Taint mode stuff ...
  $weight=$weight + 0.9999999999; # round up!
  $weight =~ /(\w+)/;
  $weight = $1; 
  $dest =~ /(\w+)/;
  $dest = $1;
#    $product =~ /(\w+)/;
  $product =~ /([\w\ \,]+)/;
  $product = $1;
  $origin =~ /(\w+)/; 
  $origin = $1;
  $pounds = $weight;
  $ounces = "0";
   
  $site="rate.dmz.fedex.com";
  $path="/servlet/RateFinderServlet";
  $workString="";
  ($ztype,$zsubtype) = split(/\,/,$product,2);

  $workString .= "jsp_name=index";
  $workString .= "&orig_country=US";
  $workString .= "&language=english&account=";
  $workString .= "&portal=xx&heavy_weight=NO";
  $workString .= "&packet_zip=&hold_packaging=";
  $workString .= "&orig_zip=$origin&dest_zip=$dest";
  $workString .= "&dest_country_val=U.S.A.";
  $workString .= "&company_type=$ztype&packaging=1";
  $workString .= "&weight=$pounds&weight_units=lbs";
  $workString .= "&dropoff_type=1";
  $workString .= "&submit_button=Get+Rate";

  $doworkString = 'http://' . $site . $path . '?' . $workString;

if ($sc_use_socket =~ /lwp/i) { # use LWP library POST
 # By calling this way, no error generated if library is missing
 # when the library is first loaded up or at runtime of this routine
  $answer = eval("use LWP::UserAgent;  LWP_post\(\"$doworkString\"\);");
 }
if ($sc_use_socket =~ /http-lib/i) { # use http-lib.pl library POST
  $answer = &HTTPPost($path,$site,80,$workString);
 }

#print "**workString=$workString**<br>\n";
  $resp = $answer;
  ($junk,$resp)=split(/class\=\'resultstable\'/,$resp,2);
  ($resp,$junk)=split(/\<\/table\>/i,$resp,2);
  ($junk,$resp)=split(/\>/,$resp,2);
  while ($resp =~ /\>/) { # reponse is mixed with tags, eliminate them
    ($part1,$resp) = split(/\</,$resp,2);
    ($junk,$resp) = split(/\>/,$resp,2);
    $resp = $part1 . "|" . $resp;
   }
  while ($resp =~ /\&/) { # eliminate things like &nbsp;
    ($part1,$resp) = split(/\&/,$resp,2);
    ($junk,$resp) = split(/\;/,$resp,2);
    $resp = $part1 . "|" . $resp;
   }
  $resp = "|" . $resp . "|";
  $resp =~ s/\n//g;
  $resp =~ s/\r//g;
  while ($resp =~ /\|\|/) { # get rid of "null" answers
    $resp =~ s/\|\|/\|/g;
   }
  chomp($resp);
# now check the subtype
  ($junk,$resp) = split(/$zsubtype/i,$resp,2);
  $resp = "|FedEx $zsubtype" . $resp;
  @resp = split(/\|/,$resp);
#  print $resp,"\n","**$resp[5]**\n";
  return $resp[5],$err;
}

#####################################################################

sub getUSPS_simple {
  my ($product, $origin, $dest, $weight) = @_;

#  if ($sc_USPS_use_API =~ /yes/i) {
    return &getUSPS_simple_API($product, $origin, $dest, $weight);
#   } else {
#    return &getUSPS_simple_free($product, $origin, $dest, $weight);
#   }  
}

#####################################################################
sub getUSPS_simple_API {
    my ($product, $origin, $dest, $weight) = @_;
    my ($pounds,$ounces,$usps_prot,$usps_site,$usps_cgi,$junk,$answer);
    my ($error,$orig_ans);
    my ($country , $service, $length, $width, $height, $oversized, $cod);
    $country ||= 'US';
    
#Taint mode stuff ...
    $weight=$weight + 0.9999999999; # round up!
    $weight =~ /(\w+)/;
    $weight = $1; 
    $dest =~ /(\w+)/;
    $dest = $1;
    $product =~ /(\w+)/;
    $product = $1;
    $origin =~ /(\w+)/; 
    $origin = $1;

    $service = $product; # variable
    $pounds = $weight;
    $ounces = "0";

# ($pounds,$ounces) = split(/\./, $weight);
# $ounces = ("." . $ounces)*16;
   
    ($usps_prot,$junk,$usps_site,$usps_cgi) = 
       split(/\//,$sc_USPS_host_URL,4);
    $usps_prot .= '//';
    $usps_cgi = '/' . $usps_cgi;

#   $usps_site = 'testing.shippingapis.com';
#ShippingAPITest.dll';
   
    $workString .= "API=Rate&XML=<RateRequest";
    $workString .= " USERID=\"$sc_USPS_userid\"";
    $workString .= " PASSWORD=\"$sc_USPS_password\">";
    $workString .= '<Package ID="0">';
    $workString .= "<Service>$service</Service>";
    $workString .= "<ZipOrigination>$origin</ZipOrigination>";
    $workString .= "<ZipDestination>$dest</ZipDestination>";
    $workString .= "<Pounds>$pounds</Pounds>";
    $workString .= "<Ounces>$ounces</Ounces>";
    $workString .= '<Container>None</Container>';
    $workString .= '<Size>REGULAR</Size>';
    $workString .= '<Machinable>False</Machinable></Package></RateRequest>';

 if ($product =~ /Parcel/i) {
    $workString =~ s/False/True/;
}
   
    $doworkString = "$usps_prot$usps_site$usps_cgi\?${workString}";

if ($sc_use_socket =~ /lwp/i) { # use LWP library POST
 # By calling this way, no error generated if library is missing
 # when the library is first loaded up or at runtime of this routine
  $answer = eval("use LWP::UserAgent;");
  if ($@ eq "" ) {
    $answer = LWP_post($doworkString);
   } else {
    print "<br><left>$@</left><br>\n";
    $answer = "";
   }
 }
if ($sc_use_socket =~ /http-lib/i) { # use http-lib.pl library GET
  $answer = &HTTPGet($usps_cgi,$usps_site,80,$workString);
 }
if ($sc_use_socket =~ /lynx/i) { # use lynx to get the answer
  $answer = &special_get($doworkString);  
 }
    $orig_ans = $answer;
    ($junk,$answer) = split(/<Postage>/,$answer,2);
    ($answer,$junk) = split(/<\/Postage>/,$answer,2);
    if ($answer eq "") {
      $error=$orig_ans;
     }

    return ($answer,$error);

}
##########################################################################
#-- START OF CODE STOLEN/MODIFIED FROM UPS.pm, heavily modified for new API

sub getUPS_simple {
    my ($product, $origin, $dest, $weight) = @_;
    my ($country , $rate_chart, $length, $width, $height, $oversized, $cod);
    my ($RateChart) = $sc_UPS_RateChart;
    my ($is_residential)='0';
    $country ||= 'US';

    if (substr($product,0,3) eq 'GND') { 
      if ($product eq 'GNDRES') {$is_residential = 1;}
      $product = 'GND';
     }
    if ($RateChart eq "") { 
      $RateChart = "Regular+Daily+Pickup";
     }
    $RateChart =~ s/\ /\+/g;
    
    $weight=$weight + 0.9999999999; 
    $weight =~ /(\w+)/;
    $weight = $1; 
    $dest =~ /(\w+)/;
    $dest = $1;
    $product =~ /(\w+)/;
    $product = $1;
    $origin =~ /(\w+)/; 
    $origin = $1;

    my $ups_prot = 'http://';
    my $ups_site = 'www.ups.com';
    my $ups_cgi = '/using/services/rave/qcost_dss.cgi';

    my $workString = "";
    my ($spk, $answer);
    
    $workString .= "AppVersion=1.2&";
    $workString .= "AcceptUPSLicenseAgreement=YES&";
    $workString .= "ResponseType=application/x-ups-rss&";
    $workString .= "ActionCode=3&";
    $workString .= "ServiceLevelCode=" . $product . "&";
#    $workString .= "RateChart=Regular+Daily+Pickup&";
    $workString .= "RateChart=$RateChart&";
    $workString .= "ShipperPostalCode=" . $origin . "&";
    $workString .= "ConsigneePostalCode=" . $dest . "&";
    $workString .= "ConsigneeCountry=US&";
    $workString .= "PackageActualWeight=" . $weight . "&";
    $workString .= "ResidentialInd=$is_residential&";
    $workString .= "PackagingType=00";
    $doworkString = "${ups_prot}${ups_site}${ups_cgi}\?${workString}";

if ($sc_use_socket =~ /lwp/i) { 
  $answer = eval("use LWP::UserAgent;  LWP_post\(\"$doworkString\"\);");
 }
if ($sc_use_socket =~ /http-lib/i) { 
  $answer = &HTTPPost($ups_cgi,$ups_site,80,$workString);
 }
if ($sc_use_socket =~ /lynx/i) { 
  $answer = &special_get($doworkString);  
 }

    my @ret = split( '%', $answer );
    
#    if (! $ret[14]) {
#	# Error
#	return (undef,undef,$ret[1]);
#    }
#    else {
	# Good results
	my $total_shipping = $ret[14];
	my $ups_zone = $ret[10];
	return ($total_shipping,$ups_zone,"");
#    }
}

sub getUPS_simple_old {
    my ($product, $origin, $dest, $weight) = @_;
    my ($country , $rate_chart, $length, $width, $height, $oversized, $cod);
    my ($RateChart) = $sc_UPS_RateChart;
    $country ||= 'US';

    if ($RateChart eq "") { 
      $RateChart = "Regular+Daily+Pickup";
     }
    $RateChart =~ s/\ /\+/g;

    $weight=$weight + 0.9999999999; 
    $weight =~ /(\w+)/;
    $weight = $1; 
    $dest =~ /(\w+)/;
    $dest = $1;
    $product =~ /(\w+)/;
    $product = $1;
    $origin =~ /(\w+)/; 
    $origin = $1;

    my $ups_prot = 'http://';
    my $ups_site = 'www.ups.com';
    my $ups_cgi = '/using/services/rave/qcostcgi.cgi';

    my $workString = "";
    my ($spk, $answer);
    
    $workString .= "accept_UPS_license_agreement=yes";
    $workString .= "&10_action=3";
    $workString .= "&13_product=" . $product ;
    $workString .= "&15_origPostal=" . $origin ;
    $workString .= "&19_destPostal=" . $dest ;
    $workString .= "&23_weight=" . $weight ;
    $workString .= "&22_destCountry=" . $country if $country;
    $workString .= "&25_length=" . $length if $length;
    $workString .= "&26_width=" . $width if $width;
    $workString .= "&27_height=" . $height if $height;
    $workString .= "&30_cod=" . $cod if $cod;
    $workString .= "&29_oversized=1" if $oversized;
    $workString .= "&47_rate_chart=" . $rate_chart if $rate_chart;
    $doworkString = "${ups_prot}${ups_site}${ups_cgi}\?${workString}";
    
#    my @ret = split( '%', get($workString) );

if ($sc_use_socket =~ /lwp/i) { # use LWP library POST

  $answer = eval("use LWP::UserAgent;  LWP_post\(\"$doworkString\"\);");
 }
if ($sc_use_socket =~ /http-lib/i) { 
  $answer = &HTTPPost($ups_cgi,$ups_site,80,$workString);
 }
if ($sc_use_socket =~ /lynx/i) { 
  $answer = &special_get($doworkString);  
 }

    my @ret = split( '%', $answer );
    
    if (! $ret[5]) {
	return ("","",$ret[1]);
    }
    else {
	my $total_shipping = $ret[10];
	my $ups_zone = $ret[6];
	return ($total_shipping,$ups_zone,undef);
    }
}

sub getUPS {

    my ($product, $origin, $dest, $weight, $country , $rate_chart, $length,
	$width, $height, $oversized, $cod) = @_;

	$country ||= 'US';
    
    my $ups_cgi = 'http://www.ups.com/using/services/rave/qcostcgi.cgi';
    my $workString = "?";
    $workString .= "accept_UPS_license_agreement=yes&";
    $workString .= "10_action=3&";
    $workString .= "13_product=" . $product . "&";
    $workString .= "15_origPostal=" . $origin . "&";
    $workString .= "19_destPostal=" . $dest . "&";
    $workString .= "23_weight=" . $weight;
    $workString .= "&22_destCountry=" . $country if $country;
    $workString .= "&25_length=" . $length if $length;
    $workString .= "&26_width=" . $width if $width;
    $workString .= "&27_height=" . $height if $height;
    $workString .= "&30_cod=" . $cod if $cod;
    $workString .= "&29_oversized=1" if $oversized;
	$workString .= "&47_rate_chart=" . $rate_chart if $rate_chart;
    $workString .= "&30_cod=1" if $cod;
    $workString = "${ups_cgi}${workString}";
    
#    my @ret = split( '%', get($workString) );
    
    if (! $ret[5]) {
	return (undef,undef,$ret[1]);
    }
    else {
	my $total_shipping = $ret[10];
	my $ups_zone = $ret[6];
	return ($total_shipping,$ups_zone,undef);
    }
}

#
#	UPStrack sub added 2/27/1998
#

sub UPStrack {
    my ($tracking_number) = shift;
    my %retValue = ();		
    $tracking_number || Error("No number to track in UPStrack()");

#    my $raw_data = get("http://wwwapps.ups.com/tracking/tracking.cgi?tracknum=$tracking_number") || Error("Cannot get data from UPS");
    $raw_data =~ tr/\r//d;

    my @raw_data = split "\n", $raw_data;

    # These are the splitting keys
    my $scan_sep = 'Scanning Information';
    my $notice_sep = 'Notice';
    my $error_key = 'Unable to track';
    my $section;
    my @scanning;
    for (@raw_data) {
	s/<.*?>/ /gi;	# Remove html tags
	s/(?:&nbsp;|[\n\t])//gi;	# Remove '&nbsp' separators
	s/^\s+//g;

	next if /^$/;
	last if /^Top\sof\sPage/;

	if (/^Tracking\sResult/) {
	    $section = 'RESULT';
	}
	elsif (/^$scan_sep/) {
	    $section = 'SCANNING';
	}
	elsif (/^$notice_sep/) {
	    $section = 'NOTICE';
	}
	elsif (/^($error_key\s.*?)\s{4}/) {
	    my $error = $1;
	    $error =~ s/\s+$/ /g;
	    $retValue{error} = $error;
	    return %retValue;
	}
	elsif ($section eq 'NOTICE') {
	    $retValue{Notice} .= $_;
	}
	elsif ($section eq 'RESULT') {
	    my ($key,$value) = /(.*?):(.*)/;
	    $value =~ s/^\s+//g;
	    $value =~ s/\s+$//g;
	    $retValue{$key} = $value;
	}
	elsif ($section eq 'SCANNING') {
	    if (/^\d/) {
		push @scanning, $_;
	    }
	    else {
		$scanning[-1] .= " = $_";
	    }
	}
    }

    $retValue{Scanning} = join "\n", @scanning;

    return %retValue;
}

sub Error {
    my $error = shift;
    print STDERR "$error\n";
    exit(1);
}

#-- End of code stolen from UPS.pm

# ==========================================================================

sub define_shipping_logic {
 local($shipping_total, $stevo_shipping_thing) = @_;
 local($orig_zip, $dest_zip, $ship_method, $mylogic);
 local($shipping_price)=0;
 local($ship_logic_run,$ship_logic_done)="no";
 local($continue)="yes";
 local($use_vform)="no";

 &codehook("shippinglib-define-shipping-logic");
 if (!($continue =~ /yes/i)) { return;}

 $ship_method = $form_data{'Ecom_ShipTo_Method'};
 if ($ship_method eq "") { #
   $use_vform = "yes";
   $ship_method = $vform{'Ecom_ShipTo_Method'};
  }
 ($sc_ship_method_shortname,$junk) = split(/\(/,$ship_method,2);

 if ($sc_use_custom_shipping_logic =~ /yes/i) {
   $mylogic = "$sc_custom_shipping_logic";
   eval($mylogic);
   $err_code = $@;
   if ($err_code ne "") { 
     &update_error_log("custom-shipping-logic $err_code ","","");
    }
   $ship_logic_run="yes";
   if (($ship_logic_done =~ /yes/i) || ($shipping_logic_done =~ /yes/i)) 
    { 
     return $shipping_price;
    }
  } 

 if ($sc_use_SBW =~ /yes/i) {
   $stevo_shipping_thing = "$shipping_total$stevo_shipping_thing";
   $dest_zip = $form_data{'Ecom_ShipTo_Postal_PostalCode'};
   if ($dest_zip eq "") { # try vform, perhaps there is a value there
     $use_vform = "yes";
     $dest_zip = $vform{'Ecom_ShipTo_Postal_PostalCode'};
    }
   $shipping_price = $shipping_price +
		&calc_SBW($ship_method,$dest_zip,$stevo_shipping_thing);   
   $ship_logic_run="yes";
  }

 if (!($ship_logic_run =~ /yes/i)) {
   $shipping_price = $shipping_total;
  }

 if (($shipping_price > 0 ) ||
     ($sc_add_handling_cost_if_shipping_is_zero =~ /yes/i)) {
   $shipping_price = $shipping_price + $sc_handling_charge;
  }

 return ($shipping_price);

}

# ==========================================================================
sub LWP_post {

local ($ua);
local ($stuff) = @_;
local ($site_url,$info_to_post);
($site_url,$info_to_post) = split(/\?/,$stuff,2);

  $ua = new LWP::UserAgent;
  $ua->agent("AgentName/0.1 " . $ua->agent);

  my $req = new HTTP::Request POST => $site_url;
  $req->content_type('application/x-www-form-urlencoded');
  $req->content($info_to_post);

  my $res = $ua->request($req);

  if ($res->is_success) {
      return $res->content;
  } else {
      return "ERROR";
  }
}

# ==========================================================================

$shipping_lib_loaded_ok = "yes";

1;
