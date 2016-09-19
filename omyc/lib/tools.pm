# ============================================================
#
# some system wide tools.
#
# this is the only module we export functions in global context
#
# ============================================================
#
#	$s = "   2312312kijoij \" ()***&&¨ oijo ij123123  ";
#	print "-|".$s."|-\n";
#	print "-|".&trim($s)."|-\n";
#	print "-|".&clean_digits($s)."|-\n";
#	print "-|".&clean_string($s)."|-\n";
#	print "-|".&clean_string($s,"MINIMAL")."|-\n";
#	print "-|".&clean_string($s,"() ")."|-\n";
#	
#	-|   2312312kijoij " ()***&&¨ oijo ij123123  |-
#	-|2312312kijoij " ()***&&¨ oijo ij123123|-
#	-|2312312123123|-
#	-|   2312312kijoij  ()&& oijo ij123123  |-
#	-|2312312kijoijoijoij123123|-
#	-|   2312312kijoij  () oijo ij123123  |-
#
#
# 	format_E164_number is NOT perfect 
#	We need something powerfull (with per country format database) like:
#	https://github.com/googlei18n/libphonenumber or
#	http://search.cpan.org/~cfaerber/Number-Phone-Normalize-0.220/lib/Number/Phone/Normalize.pm
#	...but for now, what we have is better then nothing
#
#	@a = qw(5521994249388 16461234567);
#	foreach(@a){
#		print $_."\n";
#		print &format_E164_number($_)."\n";
#		print &format_E164_number($_,"USA")."\n";
#		print "\n";
#	}
#	
#	5521994249388
#	+55 (219) 9424-9388
#	011 55 (219) 9424-9388
#	
#	16461234567
#	+1 (646) 123-4567
#	(646) 123-4567
#
# ============================================================


package tools;
use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw(trim clean_digits clean_string clean_string_sql delta_seconds_in_human_format);
@EXPORT_OK   = qw(trim clean_digits clean_string clean_string_sql delta_seconds_in_human_format);


sub trim {
     my @out = @_;
     for (@out) {
         s/^\s+//;
         s/\s+$//;
     }
     return wantarray ? @out : $out[0];
}
sub clean_digits {
	#limpa tudo que nao for letras e numeros
	my ($old)=@_;
	my ($new,$i,$caracterok);
	$old=$old."";
	$new="";
	$caracterok="1234567890";
	for ($i=0;$i<length($old);$i++) {if (index($caracterok,substr($old,$i,1))>-1) {$new=$new.substr($old,$i,1);} }
	return $new;	
}
sub clean_string {
	my ($old,$extra)=@_;
	my ($new,$i,$caracterok);
	$old=$old."";
	$new="";
	$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\% ";
	if 		("\U$extra" eq "MINIMAL")	{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";}
	elsif 	("\U$extra" eq "URL") 		{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\%";}
	elsif 	("\U$extra" eq "SQL") 		{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\% ";}
	elsif 	("\U$extra" eq "PASSWORD")	{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\%";}
	elsif 	("\U$extra" eq "EMAIL")		{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\%";}
	elsif 	("\U$extra" eq "HEX") 		{$caracterok="abcdefghABCDEFGH1234567890";}
	elsif 	($extra ne "")				{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".$extra}
	for ($i=0;$i<length($old);$i++) {if (index($caracterok,substr($old,$i,1))>-1) {$new=$new.substr($old,$i,1);} }
	if ("\U$extra" eq "SQL") { $new= &clean_string_sql($new) }
	return $new;
}
sub clean_string_sql {
	my ($string) = @_;
	$string =~ s/\\/\\\\/g ; # first escape all backslashes or they disappear
	$string =~ s/\n/\\n/g ; # escape new line chars
	$string =~ s/\r//g ; # escape carriage returns
	$string =~ s/\'/\\\'/g; # escape single quotes
	$string =~ s/\"/\\\"/g; # escape double quotes
	return $string ;
}
sub delta_seconds_in_human_format{
    my ($delta) = @_;
    $delta++; $delta--;
    #
    if ($delta < 60) { return "$delta second".(($delta>1) ? "s" : ""); }
    #
    $delta = int($delta/60);
    if ($delta < 60) { return "$delta minute".(($delta>1) ? "s" : ""); }
    #
    $delta = int($delta/60);
    if ($delta < 24) { return "$delta hour".(($delta>1) ? "s" : ""); }
    #
    $delta = int($delta/24);
    if ($delta < 7) { return "$delta day".(($delta>1) ? "s" : ""); }
    #
    $delta = int($delta/7);
    return "$delta week".(($delta>1) ? "s" : ""); 
}

1;


