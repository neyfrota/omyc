# ============================================================
#
# simple document storage
#
# ============================================================
#
# streamRecord saith unto him, I am the way, the truth, and the life: no man cometh unto the streamRecord data, but by me.
#
# normalize zenoradio record engine data.
# please do not toch data direct, use this library instead 
# all data stored using storage package
# we did not export functions so we need use streamRecord::function to make code clear
# we use entity as function prefix (entity_action, example recordEvent_create)
# we try to create full CRUD for each entity
# we have some search and list functions for each entity 
#
# Code example:
# 	after __DATA__
#
#
# ============================================================



# ------------------------------
# describe package and load what we need
# ------------------------------
package omyc::user;
use strict;
#use serialize;
use tools;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $error);
$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw();
@EXPORT_OK   = qw();
$error = "";
# ------------------------------


# ------------------------------
use vars qw($users_dir $settings_dir $file_users_web $file_users_sftp $file_groups_web $file_groups_sftp $fail_object);
$users_dir          = "/data/users/";
$settings_dir       = "/data/settings/";
$file_users_web     = $settings_dir."users.web";
$file_users_sftp    = $settings_dir."users.sftp";
$file_groups_web    = $settings_dir."groups.web";
$file_groups_sftp   = $settings_dir."groups.sftp";
$fail_object        = undef;
# ------------------------------


# ------------------------------
#
sub list(){
    &_setFail();
	my (@l,@users);
    opendir(DIR,$users_dir);
    @l = readdir(DIR);
    closedir(DIR);
    @users = ();
    foreach (@l){
        if (index($_,".") eq 0) { next }
        if (index($_,".") ne -1) { next }
        if ($_ eq "") { next }
        @users = (@users,$_);
    }
	return @users;
}
#
sub exists(){
    &_setFail();
    my($u) = @_;
    if (!$u) { return  }	
    if ($u  ne substr(&clean_string($u,"MINIMAL"),0,64)) { return  };
    if (-d "$users_dir$u") { return 1 }
    return ;
}
#
sub create(){
    &_setFail();
    my($user_plain,$data) = @_;
    #
    my $user = substr(&clean_string($user_plain,"MINIMAL"),0,255);
    if (!$user) { &_setFail("empty_user"); return }
    if ($user ne $user_plain) { &_setFail("invalid_user"); return }
    if (&exists($user)) { &_setFail("duplicate_user"); return }
    #
    # create/restore folder
    my $folder_user = $users_dir.$user;
    my $folder_bkp  = $users_dir.".deleted.".$user;
    unless (-d $folder_user) {
        if (-d $folder_bkp) {
            rename($folder_bkp,$folder_user);
		} else {
            mkdir($folder_user);
        }
    }
    unless (-d $folder_user) { &_setFail("fail_create_folder"); return }
    #
    # set data (admin, password, etc etc)
    unless(&update($user,$data)) {return}
    #
    return 1;    
}
sub retrieve(){
    &_setFail();
    my($u) = @_;
    #
    if (!&exists($u)) { &_setFail("not_found"); return }
    #
    my $info = {};
    $info->{username}   = $u;
    $info->{homedir}    = $users_dir.$u;
    $info->{isAdmin}    = 0;
    #
    # get isAdmin
    open (IN,$file_groups_web);
    my $line = <IN>;
    close(IN);
    chomp($line);
    my ($group,$users) = split(/\:/,$line);
    if (index(" $users "," $u ") ne -1) { $info->{isAdmin} = 1;}
    #
    return $info;    
}
sub update(){
    &_setFail();
    my($u,$data) = @_;
    #
    if (!&exists($u)) { &_setFail("not_found"); return }
    #
    # update isAdmin
    if (exists($data->{password})) {
        unless(&passwordChange($u,$data->{password})) {return}
    }
    #
    # update isAdmin
    if (exists($data->{isAdmin})) {
        #
		$data->{isAdmin} = ($data->{isAdmin}) ? 1 : 0;
        #
        open (IN,$file_groups_web);
        my $line = <IN>;
        close(IN);
        chomp($line);
        #
        my ($group,$users_plain) = split(/\:/,$line);
        my @users = split (/ /,$users_plain);
        #
        # im lazy so will use a hash to make users unique
        my %hash = ();
        foreach (@users) {$hash{$_}++;}
        #
        # add or delete user in hash
        if ($data->{isAdmin}) {
            $hash{$u}++;
		} else {
            delete($hash{$u});
        }
        #
        # boil down hash into array again, and then in plain
        @users = keys %hash;
        $users_plain = join(" ",@users);
        #
        # now save again
        open (OUT,">$file_groups_web");
        print OUT "admin: $users_plain\n";
        close(OUT);
        #		
    }
    #
    return 1;    
}
sub delete(){
    #
    &_setFail();
    my($user) = @_;
    #
    if (!&exists($user)) { &_setFail("not_found"); return }
    #
    # remove is admin
    my $data = {};
    $data->{isAdmin} = 0;
    &update($user,$data);
    #
    # remove password
    &passwordDestroy($user);
    #
    # remove folder
    my $folder_user     = $users_dir.$user;
    my $folder_bkp      = $users_dir.".deleted.".$user;
    my $folder_bkp_old  = $users_dir.".deleted.".$user.".".time;
    if (-d $folder_bkp) {
        rename($folder_bkp,$folder_bkp_old);
    }
    rename($folder_user,$folder_bkp);
	#
    `/omyc/bin/systemCommands/add updateBtsyncFiles 2>\&1 `;
    #
    return 1;
}
#
sub passwordCheck{
    &_setFail();   
    my($u,$p) = @_;
    #
    if (!&exists($u)) { &_setFail("not_found");  return }
    if (!$p) { &_setFail("no_password"); return }	
    #
    my $pwd_file = "";
    my $l;
    open (IN,$file_users_web);
    foreach $l (<IN>) {
        chomp($l);
        if (index($l,":") eq -1) {next}
        my($v1,$v2)=split(/\:/,$l);
        if ($v1 ne $u) { next }
        $pwd_file = $v2;
	}
    close(IN);
    if (!$pwd_file ) { return }
    if (index($pwd_file,"\$") eq -1) { &_setFail("INTERNAL_ERROR_404"); return }
    #
    my ($trash,$pwd_file_method,$pwd_file_salt) = split(/\$/,$pwd_file);
    if ($pwd_file_method ne "apr1") { &_setFail("INTERNAL_ERROR_405"); return }
    if (!$pwd_file_salt) { &_setFail("INTERNAL_ERROR_406"); return }
    #
    my $pwd_enc =`openssl passwd -apr1 -salt $pwd_file_salt $p`;
    chomp($pwd_enc);
    if (!$pwd_enc) { return }
    if ($pwd_enc eq $pwd_file) { return 1}
    return;
}
sub passwordChange{
    &_setFail();    
    my($u,$p) = @_;
    #
    if (!&exists($u)) { &_setFail("not_found"); return }
    if (!$p) { &_setFail("no_password"); return }	
    if ($p ne &clean_string($p,"PASSWORD")) { &_setFail("invalid_password");  return  };
    #    
    `/usr/bin/htpasswd -b $file_users_web "$u" "$p"  >/dev/null 2>/dev/null`;
    `/bin/echo "$p" | /usr/sbin/ftpasswd --file $file_users_sftp --passwd --name $u --home /data/users/$u --shell /bin/false --uid 33 --gid 33 --stdin   >/dev/null 2>/dev/null`;
    `/omyc/bin/systemCommands/add disconnectFtpUser $u 2>\&1 `;
    #`chmod -Rf a-rwx,u+rw $file_users_sftp >/dev/null 2>/dev/null`;
    return 1;
}
sub passwordDestroy{
    &_setFail();    
    my($u) = @_;
    #
    if (!&exists($u)) { &_setFail("not_found"); return }
    #    
    `/usr/bin/htpasswd -D $file_users_web "$u"  >/dev/null 2>/dev/null`;
    `/usr/sbin/ftpasswd --file $file_users_sftp --name $u --delete-user --passwd >/dev/null 2>/dev/null`;
    `/omyc/bin/systemCommands/add disconnectFtpUser $u 2>\&1 `;
    #`chmod -Rf a-rwx,u+rw $file_users_sftp >/dev/null 2>/dev/null`;
    return 1;
}
sub passwordLock{}
sub passwordUnlock{}
#
sub isFail{ return ($fail_object) ? 1 : 0 }
sub failCode{ return $fail_object }
#
sub _setFail{
    my($in) = @_;
	$fail_object = $in || undef;
};
#
# ------------------------------
	
1;
