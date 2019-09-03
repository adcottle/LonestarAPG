############################################################
#                       SEND-MAIL-LIB.PL
#
# This script was written by Steve Kneizys for agora.cgi
$versions{'send-mail-lib.pl'} = "200211020";
#
#   You may copy this under the terms of the GNU General Public
#   License or the Artistic License which is distributed with
#   copies of Perl v5.x for UNIX.
#
############################################################

use MIME::QuotedPrint;
use Mail::Sendmail 0.75;

############################################################
sub send_mail {
local($smtp_from, $smtp_to, $smtp_subject, $smtp_text) = @_;
local($smtp_host,%mail,$boundary,$plain);

$smtp_host = 'localhost' if (!($smtp_host));
$boundary = "====" . time() . "====";
%mail = (
         SMTP => $smtp_host,
         from => $smtp_from,
         to => $smtp_to,
         subject => $smtp_subject,
         'content-type' => "multipart/alternative; boundary=\"$boundary\""
        );
$plain = encode_qp $smtp_text;
$boundary = '--'.$boundary;

$mail{body} = <<END_OF_BODY;
$boundary
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

$plain

$boundary--
END_OF_BODY

sendmail(%mail) || &send_mail_lib_error("Error: $Mail::Sendmail::error",
	__FILE__,__LINE__);

}
##########
sub send_mail_lib_error {
  local ($text,$file,$line) = @_;
  $text =~ s/\n/\|/g;
  &update_error_log($text,$file,$line);
 }
##########
1; # Library
