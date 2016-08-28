# ============================================================
#
# simple CACHE abstraction (only get/set/delete)
# 
# TODO: add real memcache instead that nasty/prototype fake storage
#
# ============================================================
#
# --------------------------
# example 1 (scalar)
# --------------------------
#
#	$remember = &app::cache::get("MY_UID");
#	if ($remember) {print "I remember ($remember)\n"} else { print "I do not remember anything\n"}
#	if (&app::cache::set("MY_UID",5,"SOMETHING")) {print "Set to remember SOMETHING for 5 seconds\n";}
#	$remember = &app::cache::get("MY_UID");
#	if ($remember) {print "We remember ($remember)\n"} else { print " i do not remember anything\n"}
#	sleep(6);
#	$remember = &app::cache::get("MY_UID");
#	if ($remember) {print "We remember ($remember)\n"} else { print " i do not remember anything\n"}
#
#	I do not remember anything
#	Set to remember SOMETHING for 5 seconds
#	I remember (SOMETHING)
#	I do not remember anything
#
# --------------------------
#
#
# --------------------------
# example 2 (hash)
# --------------------------
#
#	$id = "MY_UID";
#	%song = ();
#	$song{type} = "WEIRDO";
#	$song{title} = "The Out Sound from Way In";
#	#
#	$remember_raw = &app::cache::get($id);
#	if ($remember_raw) {
#		%remember_song = %$remember_raw;
#		print "I remember $remember_song{type} song $remember_song{title} \n";
#	} else {
#		print "I do not remember any song\n"
#	}
#	#
#	if (&app::cache::set($id,5,\%song)) {print "Set to remember SONG for 5 seconds\n";}
#	#
#	$remember_raw = &app::cache::get($id);
#	if ($remember_raw) {
#		%remember_song = %$remember_raw;
#		print "I remember $remember_song{type} song $remember_song{title} \n";
#	} else {
#		print "I do not remember any song\n"
#	}
#	#
#	$song{type} = "NORMAL";
#	$song{title} = "Let it be";
#	$remember_raw = &app::cache::get($id);
#	if ($remember_raw) {
#		%remember_song = %$remember_raw;
#		print "I still remember $remember_song{type} song $remember_song{title} \n";
#	}
#	#
#	sleep(6);
#	$remember_raw = &app::cache::get($id);
#	if ($remember_raw) {
#		%remember_song = %$remember_raw;
#		print "I remember $remember_song{type} song $remember_song{title} \n";
#	} else {
#		print "I do not remember any song\n"
#	}
#	
#	I do not remember any song
#	Set to remember SONG for 5 seconds
#	I remember WEIRDO song The Out Sound from Way In 
#	I still remember WEIRDO song The Out Sound from Way In 
#	I do not remember any song
#
# --------------------------
#
#
# ============================================================




package cache;
use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw(cache_get cache_set cache_del);
@EXPORT_OK   = qw(cache_get cache_set cache_del);

# ------------------------------
# our fake data storage
# ------------------------------
use vars qw(%fake_data %fake_timer);
%fake_data = ();
%fake_timer = ();
# ------------------------------


sub cache_get(){
	my ($id) = @_;
	#
	unless ($id) { return }
	unless(exists($fake_data{$id})) { return }
	#
	my $die_at = $fake_timer{$id} || 0;
	if (time>$die_at) { &cache_del($id); return}
	#
	return $fake_data{$id};
}
sub cache_set(){
	my ($id,$data,$ttl) = @_;
	unless ($id) { return }
	#
	$ttl = $ttl || 60;
	# We need de-reference, to store the data, not the pointer
	if (ref($data) eq "HASH") {
		my %deref_hash = %$data;
		$fake_data{$id} = \%deref_hash;
	} elsif (ref($data) eq "ARRAY") {
		my @deref_array =@$data;
		$fake_data{$id} = \@deref_array;
    } unless (ref($data)) {
		$fake_data{$id}=$data;
    }
	$fake_timer{$id} = time+$ttl;
	return 1
}
sub cache_del(){
	my ($id,$ttl,$data) = @_;
	unless ($id) { return }
	delete($fake_data{$id});
	delete($fake_timer{$id});
}

1;


