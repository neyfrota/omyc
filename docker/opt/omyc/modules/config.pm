

# ------------------------------
# describe package and load what we need
# ------------------------------
package config;
use lib '/opt/omyc/modules';# ask perl to look modules in this folder 
use tools;
use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw();
@EXPORT_OK   = qw();
# ------------------------------




# ==================================================
# tools
# ==================================================
sub write(){
	my($f,%d) = @_;
	my($buf,$tmp,$tmp1,$tmp2,$l,$n,$v);
	#
	# decide file to read (if we have new, read from new)
	if ($f eq "") { return }
    #
    # create file buffer
    $buf = "";
    foreach(sort keys %d){
		$n = &trim(&clean_string($_,"=_."));
		$v = &clean_string(&trim($d{$_}));
		$buf .= "$n=$v\n";
    }
    #
    open(OUT,">$f");
    print OUT $buf;
    close(OUT);
    #
}
sub read(){
	my($f) = @_;
	my(%out,$tmp,$tmp1,$tmp2,$l,$n,$v);
	%out = ();
	#
	# decide file to read (if we have new, read from new)
	if ($f eq "") { return %out}
	unless (-e $f) { return %out}
	unless (-r $f) { return %out}
	#
	# read 
	open(IN,"$f");
	while (<IN>){
		chomp($_);
		$l = &trim($_);
		if (substr($l,0,1) eq "#") {next}
		if (index($l,"=") eq -1) {next}
		$n = substr($l,0,index($l,"="));
		$v = substr($l,index($l,"=")+1,4096);
		$n = &trim(&clean_string($n,"=_."));
		$v = &clean_string(&trim($v));
		$out{$n} = $v;
	}
	close(IN);
	#
	# return 
	return %out;
}
# ==================================================




1;


