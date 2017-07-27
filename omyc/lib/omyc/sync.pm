

# ------------------------------
# describe package and load what we need
# ------------------------------
package omyc::sync;
use strict;
use tools;
use Exporter;
use omyc::user;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $error);
$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw();
@EXPORT_OK   = qw();
$error = "";
# ------------------------------


# ------------------------------
use vars qw($shares_file $config_file);
$shares_file    = "/data/settings/sync.conf";
$config_file    = "/etc/btsync.conf";
#$config_file    = "/data/settings/btsync.conf";
# ------------------------------



# ------------------------------
# global
# ------------------------------
sub updateSystem() {
    #
    # update /etc/btsync.conf with sync::databaseRead()
    # do not restart btsync.
    # We probably have no permission to kill/hup btsync
    # we have a cron script (run as root) that check changes at /etc/btsync.conf and kill/hup
    #
    # get shares
	my %shares = &omyc::sync::databaseRead();
    #
    # pre-process template for each share
    my @shares_list = ();
    my %homedirs = ();
    foreach (sort keys %shares) {
        #
        # get secret.
        my $secret = $shares{$_}{secret_rw} || $shares{$_}{secret_ext};
        if (!$secret) {next}
        #
        # get user homedir
        my $user = $shares{$_}{user};
        my $homedir = "";
        if ($homedirs{$user}) {
            $homedir = $homedirs{$user}
        } else {
            my $userInfo = &omyc::user::retrieve($user);
            $homedirs{$user} = $userInfo->{homedir} || "";
            $homedir = $homedirs{$user};
		}
        if (!$homedir) { next }
        #
        # calula folder
        my $folder = $shares{$_}{folder};
        if (!$folder) { next }
        if (substr($folder,0,1) eq "/") { $folder = substr($folder,1,1000);}
        if (substr($homedir,-1,1) eq "/") { $homedir = substr($homedir,0,-1);}
        my $sync_folder = "$homedir/$folder";
        #
        my $i = "";
        $i .= "\t\t{ \n";
        $i .= "\t\t\t\"secret\" : \"$secret\",  \n";
        $i .= "\t\t\t\"dir\" : \"$sync_folder\",  \n";
        $i .= "\t\t\t\"selective_sync\" : false,  \n";
        $i .= "\t\t\t\"use_sync_trash\" : false  \n";
        $i .= "\t\t}";
        push @shares_list,$i;
    };
    #
    # prepare template
    my $buf = "";
    $buf .= "{\n";
    $buf .= "\t\"device_name\": \"OMYC\",\n";
    $buf .= "\t\"listening_port\" : 55555,\n";
    $buf .= "\t\"send_statistics\" : false,\n";
    $buf .= "\t\"storage_path\": \"/data/settings/btsync\",\n";
    $buf .= "\t\"pid_file\": \"/data/settings/btsync/btsync.pid\",\n";
    $buf .= "\t\"check_for_updates\" : false,\n";
    $buf .= "\t\"use_upnp\" : true,\n";
    $buf .= "\t\"download_limit\" : 0,\n";
    $buf .= "\t\"upload_limit\" : 0,\n";
    $buf .= "\t\"use_gui\" : false,\n";
    $buf .= "\t\"shared_folders\" : [\n";
    $buf .= join("," , @shares_list);
    $buf .= "\n";
    $buf .= "\t]\n";
    $buf .= "}\n";
    #
    # save new config file
    open(OUT,">$config_file");
    print OUT $buf;
    close(OUT);
    `chown -f omyc.omyc $config_file  >/dev/null 2>/dev/null`;
    `chown -f omyc.omyc $shares_file  >/dev/null 2>/dev/null`;
    `chmod -f a-rwx,u+rwX $config_file  >/dev/null 2>/dev/null`;
    `chown -f a-rwx,u+rwX $shares_file  >/dev/null 2>/dev/null`;
    #
    # schedule a btsync restart
	`/omyc/bin/systemCommands/add restartBtsync 2>\&1 `;
    #
}
# ------------------------------



# ------------------------------
# database
# ------------------------------
sub databaseRead {
	my (%data,$v1,$v2,$v3,$v4,$v5,$id);
	%data = ();
	open(IN,"$shares_file");
	while (<IN>) {
		chomp($_);
		if (index($_,"|") eq -1) { next }		
		($id,$v1,$v2,$v3,$v4,$v5) = split(/\|/,$_);
		$data{$id}{_id}			= $id;
		$data{$id}{secret_ext}	= $v1;
		$data{$id}{secret_rw}	= $v2;
		$data{$id}{secret_ro}	= $v3;
		$data{$id}{user}		= $v4;
		$data{$id}{folder}		= $v5;
	}
	close(IN);
	return %data;
}
sub databaseWrite {
	my  (%data) = @_;
	my ($buf);
	foreach (sort keys %data){
		$buf .= "$_|";
		$buf .= &clean_string($data{$_}{secret_ext})."|";
		$buf .= &clean_string($data{$_}{secret_rw})."|";
		$buf .= &clean_string($data{$_}{secret_ro})."|";
		$buf .= &clean_string($data{$_}{user})."|";
		$buf .= &clean_string($data{$_}{folder});
		$buf .= "\n";
	}
	open(OUT,">$shares_file");
	print OUT $buf;
	print OUT "\n";
	close(OUT);
}
sub databaseNewUid {
	return time;
}
# ------------------------------



# ---------------------------
# btsync
# ---------------------------
sub btsyncSecretCheck { return 1 }
sub btsyncSecretNew {
	#   0.........1.........2.........3..
	#   0.........1.........2.........3..
	#	AA5525XRVDRIKHLOXNTKDEKSS2IVOC4GV
	#  "ANCAFEJUP6MYMF5Q66UVFUAVV76RRFANI : 33"
	my $cmd = "/omyc/bin/rslsync --generate-secret";
	my $ans = &clean_string(`$cmd`);
	my $out = "";
	if ($ans) {
		if (length($ans) > 28) {
			$out = $ans;
		}
	}	
	return $out;
}
sub btsyncSecretToReadOnly{
	my($id) = @_;
	$id = &clean_string($id);
	#
	my $out = "";
	if ($id) {
		if (length($id) >28) {
			my $cmd = "/omyc/bin/rslsync --get-ro-secret $id";
			my $ans = &clean_string(`$cmd`);
			if ($ans) {
				if (length($ans) > 28) {
					$out = $ans;
				}
			}	
		}
	}	
	return $out;
}
# ---------------------------



	
1;
