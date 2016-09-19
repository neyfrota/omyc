#!/usr/bin/perl
# ==============================================
#
#------------------
# disable buffer
#------------------
$|=1;$!=1; 
#
#------------------
# laod modules
#------------------
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use JSON; # sudo cpan JSON
use URI::Escape qw(uri_escape);
#
#------------------
# init cgi
#------------------
$CGI::POST_MAX = 1024; # Limit to small posts.
$cgi = new CGI;
#
#------------------
# get parameters at %form
#------------------
%form	= (); 
foreach $form_name ($cgi->param) {
	@form_values = $cgi->param($form_name);
	$form_values_count = @form_values;
	$form{$form_name} = ($form_values_count>1) ? join(",",@form_values) : $form_values[0];
}
#
#------------------
# read cookies at %cookie
#------------------
%cookies = &cgi_cookie_read();
#
# read json post and save at %json
$json_engine	= JSON->new->allow_nonref;
%json 			= &api_Json2Hash($form{POSTDATA});
#
#------------------
# hack for post form with query string.
#------------------
# by default, in post forms, cgi module ignore query string.
# but becuase we use post form with json, we lost query string data
# to solve this situation, we process query string manual in post forms.
# the result is %form with data from post AND query string at same time
# remember this manual decode is dumb, so play safe in your url
if ( ($ENV{REQUEST_METHOD} ne "GET") && ($ENV{QUERY_STRING} ne "") ) {
	foreach $tmp_block (split(/\&/,$ENV{QUERY_STRING})){
		($tmp_name,$tmp_value) = split(/\=/,$tmp_block);
		unless (exists($form{$tmp_name})) {$form{$tmp_name}=$tmp_value}
	}
}
#
#------------------
# all done, return ok
#------------------
return 1;
#
# ==============================================








# ==============================================
# api lib
# ==============================================
sub api_print_error_end_exit(){
	local($code,$message) = @_;
	local %response = ();
	$response{error}{code}		= ($code) ? $code : -1;
	$response{error}{message}	= ($message) ? $message : "Error code $response{error}{code}";
	&api_print_json_response(%response);
	exit;
}
sub api_print_ok_end_exit(){
	local($code,$message) = @_;
	local %response = ();
	$response{ok}{code}		= ($code) ? $code : 0;
	$response{ok}{message}	= ($message) ? $message : "ok code $response{ok}{code}";
	&api_print_json_response(%response);
	exit;
}
sub api_print_json_response(){
	local(%data) = @_;
	&cgi_hearder_jason();
	#if ($form{callback} ne "") { print "$form{callback} (";}
	print &api_Hash2Json(%data);
	if ($form{callback} ne "") { print ");";}
}
sub api_Json2Hash(){
	local($json_plain) = @_;
	my %json_data = ();
	if ($json_plain ne "") {
		my $json_data_reference	= $json_engine->decode($json_plain);
		%json_data			= %{$json_data_reference};
	}
	return %json_data;
}
sub api_Hash2Json(){
	local(%jason_data) = @_;
	# hack: error.code need be a numeric if value is 0
	# if ( exists($jason_data{error}) ){
	#	if ($jason_data{error}{code} == "0"){
	#		$jason_data{error}{code} = 0;
	#	}
	# }
	my $json_data_reference = \%jason_data;
	#my $json_data_text		= $json_engine->encode($json_data_reference);
	my $json_data_text		= $json_engine->pretty->encode($json_data_reference);
	return $json_data_text;
}
# ==============================================






# ==============================================
# cgi lib
# ==============================================
sub cgi_cookie_save($$) {
	local($name,$value)=@_;
	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,@months,$monstr,@week,$wdaystr);
	@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
	@week = qw(Sun Mon Tue Wed Thu Fri Sat);
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =	localtime(time+(60*60*24*365*2));
	if ($year < 1000) {$year+=1900}
	$monstr = $months[$mon];
	$wdaystr = $week[$wday];
	$mon++;
	print "Set-Cookie: ".$name."=".$value."; path=/; expires=".$wdaystr.", ".$mday."-".$monstr."-".$year." 00:00:00 GMT; \n";
}
sub cgi_cookie_read(){
	local(@rawCookies) = split (/; /,$ENV{'HTTP_COOKIE'});
	local(%r);
	foreach(@rawCookies){
		($key, $val) = split (/=/,$_);
		$r{$key} = $val;
	}
	return %r;
}
sub cgi_hearder_html() {
	local($status)=@_;
	$status = &clean_int($status);
	$status = ($status eq "") ? 200 : $status;
	print "Content-type: text/html\n";
	print "Cache-Control: no-cache, must-revalidate\n";
	print "Pragma: no-cache\n";
	print "status: $status\n";
	print "\n";
}
sub cgi_hearder_jason() {
	local($status)=@_;
	#$status = &clean_int($status);
	$status = &clean_int($form{status});
	$status = ($status eq "") ? 200 : $status;
	print "Content-type: application/json\n";
	print "Cache-Control: no-cache, must-revalidate\n";
	print "Pragma: no-cache\n";
	print "status: $status\n";
	#print "status: 500\n";
	print "\n";
}
sub cgi_redirect {
  local($url) = @_;
  print "Content-type: text/html\n";
  print "Cache-Control: no-cache, must-revalidate\n";
  print "Pragma: no-cache\n";
  print "status: 302\n";
  # we should use 303 http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
  print "location: $url\n";
  print "\n";
  #print "<meta http-equiv='refresh' content='0;URL=$url'>";
  #print "<script>window.location='$url'</script>";
  print "\n";
}
sub cgi_url_encode {
    defined(local $_ = shift) or return "";
    s/([" %&+<=>"])/sprintf '%%%.2X' => ord $1/eg;
    $_
}
sub cgi_url_decode {
  local($trab)=@_;
  $trab=~ tr/+/ /;
  $trab=~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  return $trab;
}
# ==============================================






# ==============================================
# base lib
# ==============================================
sub clean_str() {
  #limpa tudo que nao for letras e numeros
  local ($old,$extra1,$extra2)=@_;
  local ($new,$caracterok,$i);
  $old=$old."";
  $new="";
  $caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.".$extra1; 		# new default
  $caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_. @".$extra1; 	# using old default to be compatible with old cgi
  if ($extra1 eq "MINIMAL") {$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".$extra2;}
  if ($extra2 eq "MINIMAL") {$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".$extra1;}
  if ($extra1 eq "USERNAME"){$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".$extra2;}
  if ($extra2 eq "USERNAME"){$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".$extra1;}
  if ($extra1 eq "URL") 	{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\%".$extra2;}
  if ($extra2 eq "URL") 	{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\%".$extra1;}
  if ($extra1 eq "SQLSAFE") {$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\% ".$extra2;}
  if ($extra2 eq "SQLSAFE") {$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\% ".$extra1;}
  if ($extra1 eq "TEXT") 	{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\% ".$extra2;}
  if ($extra2 eq "TEXT") 	{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\% ".$extra1;}
  if ($extra1 eq "PASSWORD"){$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\%".$extra2;}
  if ($extra2 eq "PASSWORD"){$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\%".$extra1;}
  if ($extra1 eq "EMAIL")	{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\%".$extra2;}
  if ($extra2 eq "EMAIL")	{$caracterok="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890/\&\$\@#?!=:;-_+.(),'{}^~[]<>\%".$extra1;}
  for ($i=0;$i<length($old);$i++) {if (index($caracterok,substr($old,$i,1))>-1) {$new=$new.substr($old,$i,1);} }
  if ($extra1 eq "SQLSAFE") { $new= &clean_str_helper($new) }
  if ($extra2 eq "SQLSAFE") { $new= &clean_str_helper($new) }
  return $new;
}
sub clean_str_helper{
	my ($string) = @_;
	$string =~ s/\\/\\\\/g ; # first escape all backslashes or they disappear
	$string =~ s/\n/\\n/g ; # escape new line chars
	$string =~ s/\r//g ; # escape carriage returns
	$string =~ s/\'/\\\'/g; # escape single quotes
	$string =~ s/\"/\\\"/g; # escape double quotes
	return $string ;
}
sub clean_int() {
  #limpa tudo que nao for letras e numeros
  local ($old)=@_;
  local ($new,$pre,$i);
  $pre="";
  $old=$old."";
  if (substr($old,0,1) eq "+") {$pre="+";$old=substr($old,1,1000);}
  if (substr($old,0,1) eq "-") {$pre="-";$old=substr($old,1,1000);}
  $new="";
  $caracterok="1234567890";
  for ($i=0;$i<length($old);$i++) {if (index($caracterok,substr($old,$i,1))>-1) {$new=$new.substr($old,$i,1);} }
  return $pre.$new;
}
sub trim {
     my @out = @_;
     for (@out) {
         s/^\s+//;
         s/\s+$//;
     }
     return wantarray ? @out : $out[0];
}
# ==============================================



