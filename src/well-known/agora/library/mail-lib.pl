############################################################
#                       SENDMAIL_LIB.PL
#
# This script was written by Gunther Birznieks. 
# Date Created: 2-22-96
# Date Last Modified: 5-5-96

$versions{'mail-lib.pl'} = "19960505+";

#
#   You may copy this under the terms of the GNU General Public
#   License or the Artistic License which is distributed with
#   copies of Perl v5.x for UNIX.
#
############################################################
$flags = "-t";

$mailer0 = '/usr/lib/sendmail';
$mailer1 = '/usr/bin/sendmail';
$mailer2 = '/usr/sbin/sendmail';
$mailer3 = '/bin/sendmail';
$mailer4 = '/sbin/sendmail';
if ( -e $mailer0) {
    $mail_program=$mailer0;
} elsif( -e $mailer1){
    $mail_program=$mailer1;
} elsif( -e $mailer2){
    $mail_program=$mailer2;
} elsif( -e $mailer3){
    $mail_program=$mailer3;
} elsif( -e $mailer4){
    $mail_program=$mailer4;
} else {
    print "Content-type: text/html\n\n";
    print "I can't find sendmail, shutting down...<br>\n";
    print "Whoever set this machine up put it someplace weird.<br>\n";
    print "(Edit library/mail-lib.pl to set the path manually.)<br>\n";
    exit;
}

$mail_program = "$mail_program $flags ";

############################################################
sub real_send_mail {
    local($fromuser, $fromsmtp, $touser, $tosmtp, 
      $subject, $messagebody) = @_;

    local($old_path) = $ENV{"PATH"};

    $ENV{"PATH"} = "";
$ENV{ENV} = "";

open (MAIL, "|$mail_program") || &web_error("Could Not Open Mail Program");

    $ENV{"PATH"} = $old_path;

    print MAIL <<__END_OF_MAIL__;
To: $touser
From: $fromuser
Subject: $subject

$messagebody

__END_OF_MAIL__

    close (MAIL);

} 
############################################################
sub send_mail {
    local($from, $to, $subject, $messagebody) = @_;

    local($fromuser, $fromsmtp, $touser, $tosmtp);

    $fromuser = $from;
    $touser = $to;


    $fromsmtp = (split(/\@/,$from))[1];
    $tosmtp = (split(/\@/,$to))[1];

    &real_send_mail($fromuser, $fromsmtp, $touser, 
           $tosmtp, $subject, $messagebody);

} 
############################################################
sub web_error {
    local ($error) = @_;
    $error = "Error Occured: $error";
    print "$error<p>\n";

    die $error;

} 

1;

