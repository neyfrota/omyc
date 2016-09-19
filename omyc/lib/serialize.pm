# ============================================================
#
# simple freeze/thaw using json/base64
# I prefere use my own and take control of my data
# Intention here is just safe serialize/deserialize
# Intention is not protect data or obfuscate
# we reserve first char (as 0) as a version flag.
# in future, if we find other more modern ways to serialize, we can keep compatibility with old data
#
# ============================================================



# ------------------------------
# describe package and load what we need
# ------------------------------
package serialize;
use strict;
use tools;
use JSON;
use MIME::Base64;

use Data::Dumper;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $error);
$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw();
@EXPORT_OK   = qw();
#
#use vars qw($json_engine);
#$json_engine = JSON->new->allow_nonref;
#
# ------------------------------



sub freeze(){
	my($object) = @_;
    #
	my $json_text = JSON->new->encode($object);
    my $serial = encode_base64($json_text);
    chomp($serial);
	return "0".$serial;
}
sub thaw(){
	my($serial) = @_;
    #
    if (!$serial) { return }
    if (substr($serial,0,1) ne "0") { return }
    #
    my $json_text = decode_base64(substr($serial,1,4096));
	my $object = JSON->new->decode($json_text);
    return $object;    
}
	
1;
