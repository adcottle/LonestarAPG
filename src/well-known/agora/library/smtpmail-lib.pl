############################################################
#                       SMTPMAIL_LIB.PL
#
# This script was written by Gunther Birznieks.
# Date Created: 2-22-96
# Date Last Modified: 5-5-96
$versions{'smtpmail-lib.pl'} = "19960505";
#
#   You may copy this under the terms of the GNU General Public
#   License or the Artistic License which is distributed with
#   copies of Perl v5.x for UNIX.
#
# Purpose: Provides a set of library routines to send email
# over the internet.  It communicates using TCP/IP Sockets directly
# to SMTP (Simple Mail Transfer Protocol)
#  
# Modified by Gunther Birznieks 3-19-96 to run on PERL 5 for Windows NT
# as well as the Solaris system it was originally written under
#
# NOTE: This program does not support MX DNS records which is
# an important part of the internet mail standard.  Use sendmail_lib.pl
# if you can since the sendmail daemon on unix supports MX records.
############################################################
use Socket;
$mail_os = "UNIX";
############################################################
sub real_send_mail {
    local($fromuser, $fromsmtp, $touser, $tosmtp, 
	  $subject, $messagebody) = @_;
    local($ipaddress, $fullipaddress, $packconnectip);
    local($packthishostip);
    local($AF_INET, $SOCK_STREAM, $SOCK_ADDR);
    local($PROTOCOL, $SMTP_PORT);
    local($buf);
    $messagebody = "Subject: $subject\n\n" . $messagebody;

    $AF_INET = AF_INET;
    $SOCK_STREAM = SOCK_STREAM;

    $SOCK_ADDR = "S n a4 x8";

    $PROTOCOL = (getprotobyname('tcp'))[2];
    $SMTP_PORT = (getservbyname('smtp','tcp'))[2];

    $SMTP_PORT = 25 unless ($SMTP_PORT =~ /^\d+$/);
    $PROTOCOL = 6 unless ($PROTOCOL =~ /^\d+$/);
    $ipaddress = (gethostbyname($tosmtp))[4];

    $fullipaddress = join (".", unpack("C4", $ipaddress));

    $packconnectip = pack($SOCK_ADDR, $AF_INET, 
		   $SMTP_PORT, $ipaddress);
    $packthishostip = pack($SOCK_ADDR, 
			 $AF_INET, 0, "\0\0\0\0");

    socket (S, $AF_INET, $SOCK_STREAM, $PROTOCOL) || 
	&web_error( "Can't make socket:$!\n");

    bind (S,$packthishostip) || 
	&web_error( "Can't bind:$!\n");
    connect(S, $packconnectip) || 
	&web_error( "Can't connect socket:$!\n");

    select(S);
    $| = 1;
    select (STDOUT);

    $buf = read_sock(S, 6);

    print S "HELO $fromsmtp\n";

    $buf = read_sock(S, 6);

    print S "MAIL From:<$fromuser>\n";
    $buf = read_sock(S, 6);

    print S "RCPT To:<$touser>\n";
    $buf = read_sock(S, 6);

    print S "DATA\n";
    $buf = read_sock(S, 6);

    print S $messagebody . "\n";

    print S ".\n";
    $buf = read_sock(S, 6);

    print S "QUIT\n";

    close S;

} 
############################################################
sub send_mail
{
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
sub read_sock {
    local($handle, $endtime) = @_;
    local($localbuf,$buf);
    local($rin,$rout,$nfound);

    $endtime += time;

    $buf = "";

    $rin = '';
    vec($rin, fileno($handle), 1) = 1;

    $nfound = 0;

read_socket: 
while (($endtime > time) && ($nfound <= 0)) {
    $length = 1024;
    $localbuf = " " x 1025;
    $nfound = 1;
    if ($mail_os ne "NT") {
	$nfound = select($rout=$rin, undef, undef,.2);
	    }
}

    if ($nfound > 0) {
	$length = sysread($handle, $localbuf, 1024);
	if ($length > 0) {
	    $buf .= $localbuf;
	    }
    }

$buf;
}
############################################################
sub web_error
{
local ($error) = @_;
$error = "Error Occured: $error";
print "$error<p>\n";

die $error;

} 

1;

