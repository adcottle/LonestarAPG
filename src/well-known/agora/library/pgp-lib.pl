############################################################
#                       PGP-LIB.PL
#
# Summary: PGP stands for Pretty Good Privacy and it
#  is a utility on the internet that allows you to encrypt
#  and decrypt files.  This library interfaces with this
#  3rd party encryption program
#
# This script was written by Gunther Birznieks.
# Date Created: 11-5-96
# Modified: 1-25-2000 SPK -- for use with GPG
# Modified: 3-10-2000 SPK -- add update_error_log code

$versions{'pgp-lib.pl'} = "20000310"; # last modification date

#
# Copyright Info: This library was written by Gunther Birznieks    
#       (gunther@clark.net) having been inspired by countless
#       other Perl authors.  Feel free to copy, cite, reference, sample,
#       borrow, resell or plagiarize the contents.  However, if you don't
#       mind, please let me know where it goes so that I can at least     
#       watch and take part in the development of the memes. Information  
#       wants to be free, support public domain freware.  Donations are   
#       appreciated and will be spent on further upgrades and other public
#       domain scripts.
#
############################################################
$pgp_config_files = "./pgpfiles";
$pgp_public_key_user_id = $sc_pgp_order_email;

if ($sc_pgp_or_gpg eq "GPG") {
  $pgp_path = $sc_pgp_or_gpg_path;
  $pgp_options = "--home ./pgpfiles --always-trust --batch -q -a -e -r";
 } else {
  $pgp_path = $sc_pgp_or_gpg_path;
  $pgp_options = "-atz -f +batchmode=1 +nobatchinvalidkeys=off -r";
 }

############################################################
sub make_pgp_file 
{

local($output_text, $output_file) = @_;  
local($pgp_output,$pre_pgp_output) = "";

$ENV{"PGPPATH"} = $pgp_config_files;

$pgp_command  = "$pgp_path $pgp_options ";
$pgp_command .= "$pgp_public_key_user_id ";
$pgp_command .= "$pgp_second_options ";

local($old_path) = $ENV{"PATH"};
$ENV{"PATH"} = "";

open (SAVEERR, ">&STDERR") || die ("Could not capture STDERR");
open (SAVEOUT, ">&STDOUT") || die ("Could not capture STDOUT");
open (STDOUT, ">$output_file");
open (STDERR, ">&STDOUT");

$pid = open (PGPCOMMAND, "|$pgp_command");
 
$ENV{"PATH"} = $old_path;

if ($sc_pgp_change_newline eq '\r\n') {
  $output_text =~ s/\n/\r\n/g;
 }
elsif ($sc_pgp_change_newline eq '\n\r') {
  $output_text =~ s/\n/\n\r/g;
 }
elsif ($sc_pgp_change_newline eq '\r') {
  $output_text =~ s/\n/\r/g;
 }

print PGPCOMMAND $output_text;

close (PGPCOMMAND);

close (STDOUT) || die ("Error closing STDOUT");
close (STDERR) || die ("Error closing STDERR");
open(STDERR,">&SAVEERR") || die ("Could not reset STDERR");
open(STDOUT,">&SAVEOUT") || die ("Could not reset STDOUT");
close (SAVEERR) || die ("Error closing SAVEERR");
close (SAVEOUT) || die ("Error closing SAVEOUT");

open(PGPOUTPUT, $output_file);

my $insidepgp = 0;

while (<PGPOUTPUT>)
{

$insidepgp = 1 if (/BEGIN PGP/i);

	if ($insidepgp) {
	 $pgp_output .= $_;
	} else {
         $pre_pgp_output .= $_;
        }
} 

close (PGPOUTPUT);


if (!defined($pid))
{

$pgp_output .= "PGP Never Executed. Something went wrong.\n";

}

if (!$pgp_output)
{
$pgp_output = "No data was returned from PGP.\n";
&update_error_log("PGP problem: $pre_pgp_output",__FILE__,__LINE__);
}

unlink($output_file);

return($pgp_output);


}


1;
