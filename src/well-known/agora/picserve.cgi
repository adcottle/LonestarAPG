#!/usr/bin/perl -T
#
# helper program that speeds up pic serving
# includes contents of cgi-lib.pl for increased speed
# be sure to ste the paths correctly in the next few lines

$versions{'picserve.cgi'} = "20021020";

&ReadParse(*form_data);

if ($form_data{'picserve'} ne "") {
  &serve_picture($form_data{'picserve'},"./html/images");
  exit;
 }
if ($form_data{'secpicserve'} ne "") {
  &serve_picture($form_data{'secpicserve'},"./protected/images/");
  exit;
 }
exit;
########################################################################
sub serve_picture
{

 local ($qstr,$sc_path_of_images_directory) = @_;
 local ($test, $test2, $my_path_to_image);

 $qstr =~ /([\w\-\=\+\/\.\:]+)/;
 $qstr = "$1";

 $my_path_to_image = $sc_path_of_images_directory . $qstr ;
 $test = substr($my_path_to_image,0,6);
 $test2 = substr($my_path_to_image,(length($my_path_to_image)-3),3);

 if ($test2=~ /jpg/i || $test2 =~ /gif/i || $test2 =~ /png/i) {
  if ($test2=~ /jpg/i) {# .jpg is jpeg file
    $test2 = "jpeg";
   }
  if ($test=~ /http:\//i || $test =~ /https:/i) {
#    use LWP::Simple;
#    print "Content-type: image/$test2\n\n";
#    print get($my_path_to_image);
   } else { 
    print "Content-type: image/$test2\n\n";
    if (!(-f $my_path_to_image)) {
      $my_path_to_image = $sc_path_of_images_directory ."/" . $qstr ;
     }
    { 
     open (MYPIC,$my_path_to_image);
     binmode(MYPIC);
     local $/=undef;
     $the_picture=<MYPIC>;
     print $the_picture;
     close(MYPIC);
    }
   }
 }
}
#
#*********************************************************************
# MODIFIED FOR AGORA.CGI -- an open source, FREE shopping cart 
# http://www.agoracart.com  4/30/2000 SPK
# Fixes a problem with MSIE 5.01
#*********************************************************************
# Perl Routines to Manipulate CGI input
# cgi-lib@pobox.com
#
# Copyright (c) 1993-1999 Steven E. Brenner  
# Unpublished work.
# Permission granted to use and modify this library so long as the
# copyright above is maintained, modifications are documented, and
# credit is given for any use of the library.
#
# For more information, see:
#     http://cgi-lib.stanford.edu/cgi-lib/

$cgi_lib'version = sprintf("%d.%02d", q$Revision: 2.18 $ =~ /(\d+)\.(\d+)/);
$versions{'cgi-lib'}= "$cgi_lib'version with Agora MSIE Patch";

$cgi_lib'maxdata    = 131072;    
$cgi_lib'writefiles =      0;    
                                 
$cgi_lib'filepre    = "cgi-lib"; 

# Do not change the following parameters unless you have special reasons
$cgi_lib'bufsize  =  8192;    
$cgi_lib'maxbound =   100;    
$cgi_lib'headerout =    0;    

sub ReadParse {

  local ($perlwarn);
  $perlwarn = $^W;
  $^W = 0;

  local (*in) = shift if @_;    # CGI input
  local (*incfn,                # Client's filename (may not be provided)
         *inct,                 # Client's content-type (may not be provided)
         *insfn) = @_;          # Server's filename (for spooled files)

# SPK added $first_type and $junk below:
  local ($len, $type, $first_type, $meth, $errflag, $cmdflag, $got, $name, $junk);
        
  binmode(STDIN);   # we need these for DOS-based systems
  binmode(STDOUT);  # and they shouldn't hurt anything else 
  binmode(STDERR);
        
  # Get several useful env variables
  $type = $ENV{'CONTENT_TYPE'};
  $len  = $ENV{'CONTENT_LENGTH'};
  $meth = $ENV{'REQUEST_METHOD'};
  
  if ($len > $cgi_lib'maxdata) { #'
      &CgiDie("cgi-lib.pl: Request to receive too much data: $len bytes\n");
  }

# SPK look at only the first if there is a comma-delimited CONTENT-TYPE list
  ($first_type,$junk) = split(/\,/,$type,2);

  if (!defined $meth || $meth eq '' || $meth eq 'GET' ||
      $meth eq 'HEAD' ||
      $first_type eq 'application/x-www-form-urlencoded') {
    local ($key, $val, $i);
        
    # Read in text
    if (!defined $meth || $meth eq '') {
      $in = $ENV{'QUERY_STRING'};
      $cmdflag = 1;  # also use command-line options
    } elsif($meth eq 'GET' || $meth eq 'HEAD') {
      $in = $ENV{'QUERY_STRING'};
    } elsif ($meth eq 'POST') {
        if (($got = read(STDIN, $in, $len) != $len))
          {$errflag="Short Read: wanted $len, got $got\n";};
    } else {
      &CgiDie("cgi-lib.pl: Unknown request method: $meth\n");
    }

    @in = split(/[&;]/,$in); 
    push(@in, @ARGV) if $cmdflag; 

    foreach $i (0 .. $#in) {
      $in[$i] =~ s/\+/ /g;

      ($key, $val) = split(/=/,$in[$i],2); # splits on the first =.

      $key =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
      $val =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;

      $in{$key} .= "\0" if (defined($in{$key}));
      $in{$key} .= $val;
    }

  } elsif ($ENV{'CONTENT_TYPE'} =~ m#^multipart/form-data#) {
$errflag = !(eval <<'END_MULTIPART');

    local ($buf, $boundary, $head, @heads, $cd, $ct, $fname, $ctype, $blen);
    local ($bpos, $lpos, $left, $amt, $fn, $ser);
    local ($bufsize, $maxbound, $writefiles) = 
      ($cgi_lib'bufsize, $cgi_lib'maxbound, $cgi_lib'writefiles);


    $buf = ''; 

    ($boundary) = $type =~ /boundary="([^"]+)"/; #";   
    ($boundary) = $type =~ /boundary=(\S+)/ unless $boundary;
    &CgiDie ("Boundary not provided: probably a bug in your server") 
      unless $boundary;
    $boundary =  "--" . $boundary;
    $blen = length ($boundary);

    if ($ENV{'REQUEST_METHOD'} ne 'POST') {
      &CgiDie("Invalid request method for  multipart/form-data: $meth\n");
    }

    if ($writefiles) {
      local($me);
      stat ($writefiles);
      $writefiles = "/tmp" unless  -d _ && -w _;
      # ($me) = $0 =~ m#([^/]*)$#;
      $writefiles .= "/$cgi_lib'filepre"; 
    }

    $left = $len;
   PART: 
    while (1) {
      die $@ if $errflag;

      $amt = ($left > $bufsize+$maxbound-length($buf) 
              ?  $bufsize+$maxbound-length($buf): $left);
      $errflag = (($got = read(STDIN, $buf, $amt, length($buf))) != $amt);
      die "Short Read: wanted $amt, got $got\n" if $errflag;
      $left -= $amt;

      $in{$name} .= "\0" if defined $in{$name}; 
      $in{$name} .= $fn if $fn;

      $name=~/([-\w]+)/;  # This allows $insfn{$name} to be untainted
      if (defined $1) {
        $insfn{$1} .= "\0" if defined $insfn{$1}; 
        $insfn{$1} .= $fn if $fn;
      }
 
     BODY: 
      while (($bpos = index($buf, $boundary)) == -1) {
        if ($left == 0 && $buf eq '') {
          foreach $value (values %insfn) {
            unlink(split("\0",$value));
          }
          &CgiDie("cgi-lib.pl: reached end of input while seeking boundary " .
                  "of multipart. Format of CGI input is wrong.\n");
        }
        die $@ if $errflag;
        if ($name) {  # if no $name, then it's the prologue -- discard
          if ($fn) { print FILE substr($buf, 0, $bufsize); }
          else     { $in{$name} .= substr($buf, 0, $bufsize); }
        }
        $buf = substr($buf, $bufsize);
        $amt = ($left > $bufsize ? $bufsize : $left); #$maxbound==length($buf);
        $errflag = (($got = read(STDIN, $buf, $amt, length($buf))) != $amt);
        die "Short Read: wanted $amt, got $got\n" if $errflag;
        $left -= $amt;
      }
      if (defined $name) {  # if no $name, then it's the prologue -- discard
        if ($fn) { print FILE substr($buf, 0, $bpos-2); }
        else     { $in {$name} .= substr($buf, 0, $bpos-2); } # kill last \r\n
      }
      close (FILE);
      last PART if substr($buf, $bpos + $blen, 2) eq "--";
      substr($buf, 0, $bpos+$blen+2) = '';
      $amt = ($left > $bufsize+$maxbound-length($buf) 
              ? $bufsize+$maxbound-length($buf) : $left);
      $errflag = (($got = read(STDIN, $buf, $amt, length($buf))) != $amt);
      die "Short Read: wanted $amt, got $got\n" if $errflag;
      $left -= $amt;


      undef $head;  undef $fn;
     HEAD:
      while (($lpos = index($buf, "\r\n\r\n")) == -1) { 
        if ($left == 0  && $buf eq '') {
          foreach $value (values %insfn) {
            unlink(split("\0",$value));
          }
          &CgiDie("cgi-lib: reached end of input while seeking end of " .
                  "headers. Format of CGI input is wrong.\n$buf");
        }
        die $@ if $errflag;
        $head .= substr($buf, 0, $bufsize);
        $buf = substr($buf, $bufsize);
        $amt = ($left > $bufsize ? $bufsize : $left); #$maxbound==length($buf);
        $errflag = (($got = read(STDIN, $buf, $amt, length($buf))) != $amt);
        die "Short Read: wanted $amt, got $got\n" if $errflag;
        $left -= $amt;
      }
      $head .= substr($buf, 0, $lpos+2);
      push (@in, $head);
      @heads = split("\r\n", $head);
      ($cd) = grep (/^\s*Content-Disposition:/i, @heads);
      ($ct) = grep (/^\s*Content-Type:/i, @heads);

      ($name) = $cd =~ /\bname="([^"]+)"/i; #"; 
      ($name) = $cd =~ /\bname=([^\s:;]+)/i unless defined $name;  

      ($fname) = $cd =~ /\bfilename="([^"]*)"/i; #"; # filename can be null-str
      ($fname) = $cd =~ /\bfilename=([^\s:;]+)/i unless defined $fname;
      $incfn{$name} .= (defined $in{$name} ? "\0" : "") . 
        (defined $fname ? $fname : "");

      ($ctype) = $ct =~ /^\s*Content-type:\s*"([^"]+)"/i;  #";
      ($ctype) = $ct =~ /^\s*Content-Type:\s*([^\s:;]+)/i unless defined $ctype;
      $inct{$name} .= (defined $in{$name} ? "\0" : "") . $ctype;

      if ($writefiles && defined $fname) {
        $ser++;
        $fn = $writefiles . ".$$.$ser";
        open (FILE, ">$fn") || &CgiDie("Couldn't open $fn\n");
        binmode (FILE);  # write files accurately
      }
      substr($buf, 0, $lpos+4) = '';
      undef $fname;
      undef $ctype;
    }

1;
END_MULTIPART
    if ($errflag) {
      local ($errmsg, $value);
      $errmsg = $@ || $errflag;
      foreach $value (values %insfn) {
        unlink(split("\0",$value));
      }
      &CgiDie($errmsg);
    } else {
      # everything's ok.
    }
  } else {
    &CgiDie("cgi-lib.pl: Unknown Content-type: $ENV{'CONTENT_TYPE'}\n");
  }

  # no-ops to avoid warnings
  $insfn = $insfn;
  $incfn = $incfn;
  $inct  = $inct;

  $^W = $perlwarn;

  return ($errflag ? undef :  scalar(@in)); 
}

sub PrintHeader {
  return "Content-type: text/html\n\n";
}

sub HtmlTop
{
  local ($title) = @_;

  return <<END_OF_TEXT;
<html>
<head>
<title>$title</title>
</head>
<body>
<h1>$title</h1>
END_OF_TEXT
}


sub HtmlBot
{
  return "</body>\n</html>\n";
}

sub SplitParam
{
  local ($param) = @_;
  local (@params) = split ("\0", $param);
  return (wantarray ? @params : $params[0]);
}


sub MethGet {
  return (defined $ENV{'REQUEST_METHOD'} && $ENV{'REQUEST_METHOD'} eq "GET");
}

sub MethPost {
  return (defined $ENV{'REQUEST_METHOD'} && $ENV{'REQUEST_METHOD'} eq "POST");
}

sub MyBaseUrl {
  local ($ret, $perlwarn);
  $perlwarn = $^W; $^W = 0;
  $ret = 'http://' . $ENV{'SERVER_NAME'} .  
         ($ENV{'SERVER_PORT'} != 80 ? ":$ENV{'SERVER_PORT'}" : '') .
         $ENV{'SCRIPT_NAME'};
  $^W = $perlwarn;
  return $ret;
}

sub MyFullUrl {
  local ($ret, $perlwarn);
  $perlwarn = $^W; $^W = 0;
  $ret = 'http://' . $ENV{'SERVER_NAME'} .  
         ($ENV{'SERVER_PORT'} != 80 ? ":$ENV{'SERVER_PORT'}" : '') .
         $ENV{'SCRIPT_NAME'} . $ENV{'PATH_INFO'} .
         (length ($ENV{'QUERY_STRING'}) ? "?$ENV{'QUERY_STRING'}" : '');
  $^W = $perlwarn;
  return $ret;
}

sub MyURL  {
  return &MyBaseUrl;
}

sub CgiError {
  local (@msg) = @_;
  local ($i,$name);

  if (!@msg) {
    $name = &MyFullUrl;
    @msg = ("Error: script $name encountered fatal error\n");
  };

  if (!$cgi_lib'headerout) { #')
    print &PrintHeader; 
    print "<html>\n<head>\n<title>$msg[0]</title>\n</head>\n<body>\n";
  }
  print "<h1>$msg[0]</h1>\n";
  foreach $i (1 .. $#msg) {
    print "<p>$msg[$i]</p>\n";
  }

  $cgi_lib'headerout++;
}

sub CgiDie {
  local (@msg) = @_;
  &CgiError (@msg);
  die @msg;
}

sub PrintVariables {
  local (*in) = @_ if @_ == 1;
  local (%in) = @_ if @_ > 1;
  local ($out, $key, $output);

  $output =  "\n<dl compact>\n";
  foreach $key (sort keys(%in)) {
    foreach (split("\0", $in{$key})) {
      ($out = $_) =~ s/\n/<br>\n/g;
      $output .=  "<dt><b>$key</b>\n <dd>:<i>$out</i>:<br>\n";
    }
  }
  $output .=  "</dl>\n";

  return $output;
}

sub PrintEnv {
  &PrintVariables(*ENV);
}


$cgi_lib'writefiles =  $cgi_lib'writefiles;
$cgi_lib'bufsize    =  $cgi_lib'bufsize ;
$cgi_lib'maxbound   =  $cgi_lib'maxbound;
$cgi_lib'version    =  $cgi_lib'version;
$cgi_lib'filepre    =  $cgi_lib'filepre;

1; 
