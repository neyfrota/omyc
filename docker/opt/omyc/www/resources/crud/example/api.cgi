#!/usr/bin/perl
require "api.include.cgi"; 


# ---------------------------
# main loop 
# ---------------------------
#
# check authentication
#$auth = ("\L$ENV{AUTH_TYPE}" eq "basic") ? 1 : 0;
#$user = &clean_str($ENV{REMOTE_USER},"USERNAME");
#if (!$user) { &api_print_error_end_exit("AUTH_FAIL","No authentication user");}
#if ($user ne $ENV{REMOTE_USER}) { &api_print_error_end_exit("AUTH_FAIL","Invalid authentication user");}
#if ("\L$ENV{AUTH_TYPE}" ne "basic") { &api_print_error_end_exit("AUTH_FAIL","Invalid authentication");}
#
# simple crud+list routing
$method  = "\L$ENV{REQUEST_METHOD}";
$id = &trim(&clean_str($form{id}));
if ($id) {
	if ($method eq "delete") {
		&action_delete($id);
	} elsif ($method eq "post") {
		&action_update($id,%json);
	} else {
		&action_retrieve($id);
	}
} else {
	if ($method eq "post") {
		&action_create(%json);
	} else {
		&action_list();
	}
}
#
# ---------------------------


# ---------------------------
# crud action
# ---------------------------
sub action_list {
	my %data = &data_read();
	my @list = ();
	foreach (sort keys %data) {
		my %item = %{$data{$_}};
		push @list, \%item;
	}
    my %response			= ();
    $response{ok}{code}		= "0";
    $response{ok}{message}	= "OK";
    $response{list}			= [@list];
	&api_print_json_response(%response);
}
sub action_create {
	my (%data) = @_;
	my $id = time;	
	my $title = &trim(&clean_str($data{title}));
	if (!$title) {api_print_error_end_exit("TITLE_EMPTY","Cannot allow empty title")}
	my %data = &data_read();
	$data{$id}{id}		= $id;
	$data{$id}{title}	= $title;
	&data_write(%data);
	&action_retrieve($id);
}
sub action_retrieve {
	my($id) = @_;
	if (!$id) {api_print_error_end_exit("ID_EMPTY","No id to retrieve")}
	my %data = &data_read();
	unless(exists($data{$id})) {api_print_error_end_exit("ID_UNKNOWN","Unknown id")}
    my %response			= ();
    $response{ok}{code}		= "0";
    $response{ok}{message}	= "OK";
    %{$response{item}}		= %{$data{$id}};
	&api_print_json_response(%response);
}
sub action_update {
	my($id,%data) = @_;
	if (!$id) {api_print_error_end_exit("ID_EMPTY","No id to retrieve")}
	my $title = &trim(&clean_str($data{title}));
	if (!$title) {api_print_error_end_exit("TITLE_EMPTY","Cannot allow empty title")}
	my %data = &data_read();
	unless(exists($data{$id})) {api_print_error_end_exit("ID_UNKNOWN","Unknown id")}
	$data{$id}{id}		= $id;
	$data{$id}{title}	= $title;
	&data_write(%data);
	&action_retrieve($id);
}
sub action_delete {
	my($id) = @_;
	if (!$id) {api_print_error_end_exit("ID_EMPTY","No id to retrieve")}
	my %data = &data_read();
	unless(exists($data{$id})) {api_print_error_end_exit("ID_UNKNOWN","Unknown id")}
	delete($data{$id});
	&data_write(%data);
    my %response			= ();
    $response{ok}{code}		= "0";
    $response{ok}{message}	= "OK";
    $response{id}			= $id;
	&api_print_json_response(%response);
}
# ---------------------------


# ---------------------------
# data 
# ---------------------------
sub data_read {
	local(%d,$v1,$v2);
	%d = ();
	open(IN,"/tmp/crud-example.txt");
	while (<IN>) {
		chomp($_);
		if (index($_,"|") eq -1) { next }		
		($v1,$v2) = split(/\|/,$_);
		$d{$v1}{id} = $v1;
		$d{$v1}{title} = $v2;
	}
	close(IN);
	return %d;
}
sub data_write {
	local (%d) = @_;
	local ($buf);
	foreach (sort keys %d){
		$buf .= "$_|$d{$_}{title}\n";
	}
	open(OUT,">/tmp/crud-example.txt");
	print OUT $buf;
	close(OUT);
}
# ---------------------------

