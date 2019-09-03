#!/usr/local/bin/perl
#
#License Agreement for all Extropia Applications and Code
#
#NOTE: This contract is based upon the  "Artistic License" 
#and the "MIT License" as made available by Eric Raymond 
#at www.opensource.org.  The contract was written on 
#November 17, 1998.
#
#Preamble
#
#The intent of this document is to state the conditions
#under which a Package may be copied, such that the Copyright 
#Holder maintains some semblance of artistic control over the 
#development of the package, while giving the users of the 
#package the right to use and distribute the Package in a 
#more-or-less customary fashion, plus the right to make
#reasonable modifications.
#
#
#Definitions:
#
#
#    "Package" refers to the collection of files distributed 
#    by the Copyright Holder, and derivatives of that 
#    collection of files created through textual modification.
#
#    "Standard Version" refers to such a Package if it has 
#    not been modified, or has been modified in accordance 
#    with the wishes of the Copyright Holder.
#
#    "Copyright Holder" is whoever is named in the 
#    copyright or copyrights for the package.
#
#    "You" is you, if you're thinking about copying or 
#    distributing this Package.
#
#    "Reasonable copying fee" is whatever you can justify 
#    on the basis of media cost, duplication charges, time of 
#    people involved, and so on.  (You will not be required to 
#    justify it to the Copyright Holder, but only to the 
#    computing community at large as a market that must bear 
#    the fee.)
#
#    "Freely Available" means that no fee is charged for 
#    the item itself, though there may be fees involved in 
#    handling the item. It also means that recipients of the 
#    item may redistribute it under the same conditions they 
#    received it.
#
#1. You may make and give away verbatim copies of the source 
#form of the Standard Version of this Package without 
#restriction, provided that you duplicate all of the original 
#copyright notices and associated disclaimers.
#
#2. You may apply bug fixes, portability fixes and other 
#modifications derived from the Public Domain or from the 
#Copyright Holder.  A Package modified in such a way shall 
#still be considered the Standard Version.
#
#3. You may otherwise modify your copy of this Package in any 
#way, provided that you insert a prominent notice in each 
#changed file stating how and when you changed that file, and 
#provided that you do at least ONE of the following:
#
#    a) place your modifications in the Public Domain or otherwise 
#    make them Freely Available, such as by posting said 
#    modifications to Usenet or an equivalent medium, or placing 
#    the modifications on a major archive site such as ftp.uu.net, 
#    or by allowing the Copyright Holder to include your 
#    modifications in the Standard Version of the Package.
#
#    b) use the modified Package only within your corporation or 
#    organization.
#
#    c) rename any non-standard executables so the names do not 
#    conflict with standard executables, which must also be 
#    provided, and provide a separate manual page for each 
#    non-standard executable that clearly documents how it differs 
#    from the Standard Version.
#
#    d) make other distribution arrangements with the Copyright 
#    Holder.
#
#4. You may distribute the programs of this Package in object 
#code or executable form, provided that you do at least ONE of 
#the following:
#
#    a) distribute a Standard Version of the executables and 
#    library files, together with instructions (in the manual 
#    page or equivalent) on where to get the Standard Version.
#
#    b) accompany the distribution with the machine-readable 
#    source of the Package with your modifications.
#
#    c) accompany any non-standard executables with their 
#    corresponding Standard Version executables, giving the 
#    non-standard executables non-standard names, and clearly 
#    documenting the differences in manual pages (or equivalent), 
#    together with instructions on where to get the Standard 
#    Version.
#
#    d) make other distribution arrangements with the Copyright 
#    Holder.
#
#5. You may charge a reasonable copying fee for any 
#distribution of this Package.  You may charge any fee you 
#choose for support of this Package. You may not charge a fee 
#for this Package itself.  However, you may distribute this 
#Package in aggregate with other (possibly commercial) 
#programs as part of a larger (possibly commercial) software
#distribution provided that you do not advertise this Package 
#as a product of your own.
#
#6. The scripts and library files supplied as input to or 
#produced as output from the programs of this Package do not 
#automatically fall under the copyright of this Package, but 
#belong to whomever generated them, and may be sold 
#commercially, and may be aggregated with this Package.
#
#7. C or perl subroutines supplied by you and linked into this 
#Package shall not be considered part of this Package.
#
#8. The name of the Copyright Holder may not be used to endorse 
#or promote products derived from this software without 
#specific prior written permission.
#
#9. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY 
#KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
#WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
#PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS 
#OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
#OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
#OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
#SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#10. We encourage you to report any successful 
#implementations of Extropia applications or Extropia-based 
#applications.  To notify us, send email to 
#register@extropia.com.  By notifying us of your installation, 
#you ensure that you will be notified immediately in the
#case of bug fixes or security enhancements.
#
#11. Finally, if you have done some cool modifications to the scripts, 
#please consider submitting your code back to the public domain and getting
#some community recognition by submitting your modifications to the
#Extropia Cool Hacks page.  To do so, send email to hacks@extropia.com
#
############################################################
#                       HTTP_LIB.PL
#
# This script was written by Gunther Birznieks.
# Date Created: 5-15-96

$versions{'http-lib.pl'} = "19960515";

#
# Copyright:
#    
#     You may use this code according to the terms specified in
#     the "Artistic License" included with this distribution.  The license
#     can be found in the "Documentation" subdirectory as a file named
#     README.LICENSE. If for some reason the license is not included, you
#     may also find it at www.extropia.com.
# 
#     Though you are not obligated to do so, please let us know if you
#     have successfully installed this application.  Not only do we
#     appreciate seeing the wonderful things you've done with it, but we
#     will then be able to contact you in the case of bug reports or
#     security announcements.  To register yourself, simply send an
#     email to register@extropia.com.
#    
#    Finally, if you have done some cool modifications to the scripts,
#    please consider submitting your code back to the public domain and
#    getting some community recognition by submitting your modifications
#    to the Extropia Cool Hacks page.  To do so, send email to 
#    hacks@extropia.com
#
# Purpose: Provides a set of library routines to connect as
# a browser to another HTTP site and then return the results to
# the caller.
#
# Main Procedures:
#  HTTPGet - Gets a URL using the GET Method
#  HTTPPost - Gets a URL using the POST Method
#
# Set the $http_os variable equal to NT if you are on Windows NT perl
# Set it to UNIX for normal UNIX operations.
#
# If you do not have a version of PERL with the Socket.pm, you
# can manually define $AF_INET and $SOCK_STREAM to 2 and 1 respectively.
# On some systems, SOCK_STREAM may be 2.
#
############################################################

use Socket;
$http_os = "UNIX";

############################################################
sub HTTPGet {
    local($url, $hostname, $port, $in) = @_;
    local($form_vars, $x, $socket);
    local ($buf);
    $socket = &OpenSocket($hostname, $port);


    $form_vars = &FormatFormVars($in);

    $url .= "?" . $form_vars;

    print  $socket <<__END_OF_SOCKET__;
GET $url HTTP/1.0
Accept: text/html
Accept: text/plain
User-Agent: Mozilla/1.0


__END_OF_SOCKET__
   
    $buf = &RetrieveHTTP($socket);
    $buf;

} 

############################################################
sub HTTPPost {
    local($url, $hostname, $port, $in) = @_;
    local($form_vars, $x, $socket);
    local ($buf, $form_var_length);
    $socket = &OpenSocket($hostname, $port);

    $form_vars = &FormatFormVars($in);

    $form_var_length = length($form_vars);
    print $socket <<__END_OF_SOCKET__;
POST $url HTTP/1.0
Accept: text/html
Accept: text/plain
User-Agent: Mozilla/1.0
Content-type: application/x-www-form-urlencoded
Content-length: $form_var_length

$form_vars
__END_OF_SOCKET__

    $buf = &RetrieveHTTP($socket);
    $buf;

} 

############################################################
sub FormatFormVars {
    local ($in) = @_; 

    $in =~ s/ /%20/g;

    $in;
} 

############################################################

sub RetrieveHTTP {
    local ($socket) = @_;
    local ($buf,$x, $split_length);

    $buf = read_sock($socket, 6);

    if ($buf =~ /200/) {
        while(<$socket>) {
            $buf .= $_;
        }
    }

    $x = index($buf, "\r\n\r\n");
    $split_length = 4;

    if ($x == -1) {
        $x = index($buf, "\n\n");
        $split_length = 2;
    }

    if ($x > -1) {
        $buf = substr($buf,$x + $split_length);
    }

    close $socket;

$buf;
} 

############################################################
sub OpenSocket {
    local($hostname, $port) = @_;

    local($ipaddress, $fullipaddress, $packconnectip);
    local($packthishostip);
    local($AF_INET, $SOCK_STREAM, $SOCK_ADDR);
    local($PROTOCOL, $HTTP_PORT); 

    $AF_INET = AF_INET;
    $SOCK_STREAM = SOCK_STREAM;

    $SOCK_ADDR = "S n a4 x8";


    $PROTOCOL = (getprotobyname('tcp'))[2];

    $HTTP_PORT = $port;
    $HTTP_PORT = 80 unless ($HTTP_PORT =~ /^\d+$/);
    $PROTOCOL = 6 unless ($PROTOCOL =~ /^\d+$/);

    $ipaddress = (gethostbyname($hostname))[4];

    $fullipaddress = join (".", unpack("C4", $ipaddress));

    $packconnectip = pack($SOCK_ADDR, $AF_INET, 
		   $HTTP_PORT, $ipaddress);
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

S;
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
    if ($http_os ne "NT") {
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

