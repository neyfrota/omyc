# ============================================================
#
# command line tools
#
# ============================================================
#

package cmdLine;
use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw(run_command_and_return_array exit_with_error exit_ok print_error print_ok print_debug);
@EXPORT_OK   = qw(run_command_and_return_array exit_with_error exit_ok print_error print_ok print_debug);

sub exit_with_error {
	my ($code,$msg) = @_;
	chomp($msg);
	if ($msg) { &print_error($msg);}
	if (!$code) { $code = -1 }
	exit $code
}
sub exit_ok{
	my ($msg) = @_;
	chomp($msg);
	if ($msg) {print_ok($msg);}
	exit 0
}
sub print_error {
	my ($msg) = @_;
	chomp($msg);
	#print STDERR time."|".$msg."\n";
	print STDERR $msg."\n";
}
sub print_ok {
	my ($msg) = @_;
	chomp($msg);
	#print STDOUT time."|".$msg."\n";
	print STDOUT $msg."\n";
}
sub print_debug {
	my ($msg) = @_;
	chomp($msg);
	#print STDOUT $msg."\n";
}
sub run_command_and_return_array {
	my ($cmd) = @_;
	my @lines = ();
    my $ans = `$cmd`;
    chomp($ans);
    chomp($ans);
    my $find = "\r";
    my $replace = " ";
    $find = quotemeta $find; # escape regex metachars if present
    $ans =~ s/$find/$replace/g;
	foreach (split(/\n/,$ans)){
		my $l = $_;
		chomp($l);
		@lines = (@lines,$l);
	}
	return @lines;
}



1;


