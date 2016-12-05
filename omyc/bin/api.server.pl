# ===============================================
#
# load all we need
#
# ===============================================
# 
use Mojolicious::Lite;					# because we like the easy way : ) cpanmin.pl Mojolicious::Lite
use Mojo::JSON;
use Data::Dumper;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use lib '/omyc/lib';# ask perl to look modules in this folder 
use tools; 			# give us trim, clean strings and other tools. Nice to have it
use config;
use omyc::user;
use omyc::sync;
#
# set app ip and port. Apache its in front between internet and us.;
# TODO: This is development mode (with change detection and recompile on the fly). We need get production-safe mode (no push logs to chrome and better server thread), read development=1/0 config field and start correct way
app->config(hypnotoad => {listen => ['http://127.0.0.1:3000'], workers=>2});
#
# ===============================================


# ===============================================
#
# helpers
#
# ===============================================
helper activeUserIsAdmin => sub {
    #return 1; 
    my $self  = shift;
	my $user = &clean_string($self->req->headers->header('REMOTE_USER')."");
    if (!$user) {return 0}
    my $info = &omyc::user::retrieve($user);
    if (!$info) {return 0}
    if ($info->{isAdmin}) {return 1}
    return 0
};
#under sub {
#    my $self  = shift;
#    #my $user = $c->activeUser;
#	# disable authentication, if set above
#	return 1;
#};
# ===============================================




# ===============================================
#
# /users/ endpoints
#
# ===============================================
get '/users/' => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"no_permission", message => "No permission"} }); }
    #
    # get list
    my @list = &omyc::user::list();
    #
    # output data
	my $data ;
	$data->{users}	= \@list;
	return $self->render(json => $data);
};
post '/users/' => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"no_permission", message => "No permission"} }); }
    #
	# get data from json
	my $json_data	    = $self->req->json || {};
    my $info            = {};
    $info->{username}   = substr(&clean_string($json_data->{username},"MINIMAL"),0,128);
    $info->{password}   = substr(&clean_string($json_data->{password},"PASSWORD"),0,129);
    $info->{isAdmin}    = ($json_data->{isAdmin}) ? 1 : 0;
    #
    # cheap checks
	if (!$info->{username})			                { return $self->render(json => {error => { code=>"username_empty", 	    message => "empty username" 	} });}
	if ($info->{username} ne $json_data->{username}){ return $self->render(json => {error => { code=>"username_invalid", 	message => "invalid username" 	} });}
	if (length($info->{username}) < 3)			    { return $self->render(json => {error => { code=>"username_too_small",  message => "username too small" } });}
	if (length($info->{username}) > 64)			    { return $self->render(json => {error => { code=>"username_too_big",    message => "username too big" 	} });}
    #
	if (!$info->{password})			                { return $self->render(json => {error => { code=>"password_empty", 	    message => "empty password" 	} });}
	if ($info->{password} ne $json_data->{password}){ return $self->render(json => {error => { code=>"password_invalid", 	message => "invalid password" 	} });}
	if (length($info->{password}) < 8)			    { return $self->render(json => {error => { code=>"password_too_small",  message => "password too small" } });}
	if (length($info->{password}) > 128)			{ return $self->render(json => {error => { code=>"password_too_big",    message => "password too big" 	} });}
    #
    $info->{isAdmin} = ($json_data->{isAdmin}) ? 1 : 0;
    #
    # expensive checks
    if (&omyc::user::exists($info->{username}))     { return $self->render(json => {error => { code=>"username_duplicated", message => "duplicated username" } });}
    #
    # create
    if (! &omyc::user::create($info->{username},$info)) {
        return $self->render(json => {error => { code=>"fail",    message => "Fail create user (".&omyc::user::failCode().")" 	} });
    }
    #
    # output data
	my $data = {};
	$data->{user}	= &omyc::user::retrieve($info->{username}) || {};
	return $self->render(json => $data);
};
get '/users/:username' => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"NO_PERMISSION", message => "No permission"} }); }
    #
    # get username
	my $username = substr(&clean_string($self->stash('username'),"MINIMAL"),0,64);
	if (!$username)			                    { return $self->render(json => {error => { code=>"username_empty", 	    message => "empty username" 	} });}
	if ($username ne $self->stash('username'))  { return $self->render(json => {error => { code=>"username_invalid", 	message => "invalid username" 	} });}
	if (length($username) < 3)			        { return $self->render(json => {error => { code=>"username_too_small",  message => "username too small" } });}
	if (length($username) > 64)			        { return $self->render(json => {error => { code=>"username_too_big",    message => "username too big" 	} });}
    #
    # get user info
    my $user = &omyc::user::retrieve($username);
    if (!$user) {return $self->render(json => {error => { code=>"username_not_found", message => "username not found"} }); }
    #
    # output data
	my $data ;
	$data->{user}	= $user;
	return $self->render(json => $data);
};
post '/users/:username' => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"no_permission", message => "No permission"} }); }
    #
    # get user
	my $username = substr(&clean_string($self->stash('username'),"MINIMAL"),0,64);
	if (!$username)			                    { return $self->render(json => {error => { code=>"username_empty", 	    message => "empty username" 	} });}
	if ($username ne $self->stash('username'))  { return $self->render(json => {error => { code=>"username_invalid", 	message => "invalid username" 	} });}
	if (length($username) < 3)			        { return $self->render(json => {error => { code=>"username_too_small",  message => "username too small" } });}
	if (length($username) > 64)			        { return $self->render(json => {error => { code=>"username_too_big",    message => "username too big" 	} });}
    if (! &omyc::user::exists($username))        { return $self->render(json => {error => { code=>"username_not_found",  message => "username not found" } });}
    #
	# get data from json
	my $json_data	    = $self->req->json || {};
    my $info            = {};
    my $info_need_update= 0;
    #
    # isAdmin
    if (exists($json_data->{isAdmin})) {
        $info_need_update= 1;
        $info->{isAdmin} = ($json_data->{isAdmin}) ? 1 : 0;
    }    
	if ($username eq &clean_string($self->req->headers->header('REMOTE_USER')."") ) {
        if (!$info->{isAdmin}) {
            return $self->render(json => {error => { code=>"remove_own_permission",    message => "Cannot remove your own permission" 	} });
        }
    }
    #
    # password
    if (exists($json_data->{password})) {
        $info_need_update= 1;
        $info->{password}   = substr(&clean_string($json_data->{password},"PASSWORD"),0,129);
        if (!$info->{password})			                { return $self->render(json => {error => { code=>"password_empty", 	    message => "empty password" 	} });}
        if ($info->{password} ne $json_data->{password}){ return $self->render(json => {error => { code=>"password_invalid", 	message => "invalid password" 	} });}
        if (length($info->{password}) < 8)			    { return $self->render(json => {error => { code=>"password_too_small",  message => "password too small" } });}
        if (length($info->{password}) > 128)			{ return $self->render(json => {error => { code=>"password_too_big",    message => "password too big" 	} });}
    }
    #
    # update if need
    if ($info_need_update) {
        if (! &omyc::user::update($username,$info)) {
            return $self->render(json => {error => { code=>"fail",    message => "Fail update user (".&omyc::user::failCode().")" 	} });
        }
    }
    #
    # output data
	my $data = {};
	$data->{user}	= &omyc::user::retrieve($username) || {};
	return $self->render(json => $data);
};
del '/users/:username' => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"no_permission", message => "No permission"} }); }
    #
    # get user
	my $username = substr(&clean_string($self->stash('username'),"MINIMAL"),0,64);
	if (!$username)			                    { return $self->render(json => {error => { code=>"username_empty", 	    message => "empty username" 	} });}
	if ($username ne $self->stash('username'))  { return $self->render(json => {error => { code=>"username_invalid", 	message => "invalid username" 	} });}
	if (length($username) < 3)			        { return $self->render(json => {error => { code=>"username_too_small",  message => "username too small" } });}
	if (length($username) > 64)			        { return $self->render(json => {error => { code=>"username_too_big",    message => "username too big" 	} });}
	if ($username eq &clean_string($self->req->headers->header('REMOTE_USER')."") ) {
       return $self->render(json => {error => { code=>"remove_your_self",    message => "Cannot remove yourself" 	} });
    }
    if (!&omyc::user::exists($username))        { return $self->render(json => {error => { code=>"username_not_found",  message => "username not found" } });}
    #
    # get data before delete
	my $data = {};
	$data->{user}	= &omyc::user::retrieve($username) || {};
    #
    # delete syncs
	my %syncs = &omyc::sync::databaseRead();
    my @syncs_ids = keys %syncs;
    foreach (@syncs_ids){
        if ($syncs{$_}{user} eq $username) {delete($syncs{$_});}
    }
	&omyc::sync::databaseWrite(%syncs);
    &omyc::sync::updateSystem();
    #
    # delete
    if (!&omyc::user::delete($username)) {
        return $self->render(json => {error => { code=>"fail",    message => "Fail delete user x(".&omyc::user::failCode().")" 	} });
    }
    #
    # output data
	return $self->render(json => $data);
};
# ===============================================




# ===============================================
#
# /noip/ endpoints
#
# ===============================================
get '/noip/config' => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"NO_PERMISSION", message => "No permission"} }); }
    #
    # get config
    my %config = &config::read("/data/settings/noip.conf");
    #
    # output data
	my $data ;
	$data->{hostname}	= $config{hostname} || "";
	$data->{username}	= $config{username} || "";
	$data->{password}	= $config{password} || "";
	return $self->render(json => {config=>$data});
};
post '/noip/config' => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"no_permission", message => "No permission"} }); }
    #
    # get config
    my %config = &config::read("/data/settings/noip.conf");
    my $need_save = 0;
    my $tmp = "";
    #
	# get data from json
	my $json_data	    = $self->req->json || {};
    #
    # hostname
    if (exists($json_data->{hostname})) {
        $tmp = substr(&clean_string($json_data->{hostname},"PASSWORD"),0,1024);
        #if (!$tmp)			                { return $self->render(json => {error => { code=>"hostname_empty", 	    message => "empty hostname" 	} });}
        if ($tmp ne $json_data->{hostname}) { return $self->render(json => {error => { code=>"hostname_invalid", 	message => "invalid hostname" 	} });}
        $config{hostname} = $tmp;
        $config{lastUpdateMessage}		= "Update in queue. Please wait.";
        $config{lastUpdateNoipResponse}	= "";
        $config{lastUpdateOk}			= 1;
        $need_save = 1;
    }
    #
    # username
    if (exists($json_data->{username})) {
        $tmp = substr(&clean_string($json_data->{username},"PASSWORD"),0,1024);
        #if (!$tmp)			                { return $self->render(json => {error => { code=>"username_empty", 	    message => "empty username" 	} });}
        if ($tmp ne $json_data->{username}) { return $self->render(json => {error => { code=>"username_invalid", 	message => "invalid username" 	} });}
        $config{username} = $tmp;
        $config{lastUpdateMessage}		= "Update in queue. Please wait.";
        $config{lastUpdateNoipResponse}	= "";
        $config{lastUpdateOk}			= 1;
        $need_save = 1;
    }
    #
    # password
    if (exists($json_data->{password})) {
        $tmp = substr(&clean_string($json_data->{password},"PASSWORD"),0,1024);
        #if (!$tmp)			                { return $self->render(json => {error => { code=>"password_empty", 	    message => "empty password" 	} });}
        if ($tmp ne $json_data->{password}) { return $self->render(json => {error => { code=>"password_invalid", 	message => "invalid password" 	} });}
        $config{password} = $tmp;
        $config{lastUpdateMessage}		= "Update in queue. Please wait.";
        $config{lastUpdateNoipResponse}	= "";
        $config{lastUpdateOk}			= 1;
        $need_save = 1;
    }
    #
    # save if need
    if ($need_save) {
        &config::write("/data/settings/noip.conf",%config);
        my $ans = `/omyc/bin/systemCommands/add updateNoip 2>\&1 `;
    }
    #
    # output data
    %config = &config::read("/data/settings/noip.conf");
	my $data ;
	$data->{hostname}	= $config{hostname} || "";
	$data->{username}	= $config{username} || "";
	$data->{password}	= $config{password} || "";
	return $self->render(json => {config=>$data});
};
get '/noip/status' => sub {
    my $self  = shift;
	my $status ;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"NO_PERMISSION", message => "No permission"} }); }
    #
    # get config
    my %config = &config::read("/data/settings/noip.conf");
    #
    $status->{message}               = $config{lastUpdateMessage} || "Unknown status";
    $status->{ok}                    = ($config{lastUpdateOk}) ? 1 : 0;
    $status->{timestamp}{lastCheck}  = $config{lastUpdateTS} || 0;
    $status->{timestamp}{now}        = time || 0;
    $status->{timestamp}{seconds}    = $status->{timestamp}{now}-$status->{timestamp}{lastCheck};
    $status->{time}                  = ( ($status->{timestamp}{seconds}>0) && ($config{lastUpdateTS}>0) ) ? &delta_seconds_in_human_format($status->{timestamp}{seconds}) : "(unknown)";
    #if    (!$config{hostname})  { $status->{ok}=0; $status->{message} = "Config incomplete. Hostname not set" }	
    #elsif (!$config{username})  { $status->{ok}=0; $status->{message} = "Config incomplete. Username not set" }	
    #elsif (!$config{password})  { $status->{ok}=0; $status->{message} = "Config incomplete. Password not set" }
    #
    # output data
	return $self->render(json => {status=>$status});
};
# ===============================================




# ===============================================
#
# /certificate/ endpoints
#
# ===============================================
get  '/certificate'             => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"NO_PERMISSION", message => "No permission"} }); }
    #
    # start response
	my $response ;
    #
    my %data= &config::read("/data/settings/cert/custom.conf");
	#
	# we always update this expensive check and save at conf so other systems can cheap read
	$data{active} = 0;
	if (-e "/data/settings/cert/custom.crt") {
		if (-e "/data/settings/cert/active.crt") {
			my $sig1 = `md5sum /data/settings/cert/active.crt`;
			my $sig2 = `md5sum /data/settings/cert/custom.crt`;
			chomp($sig1);
			chomp($sig2);
			$sig1 = substr($sig1,0,32);
			$sig2 = substr($sig2,0,32);
			if ( (length($sig1) eq 32) && ($sig1 eq $sig2) ) {
				$data{active} = 1;
			}
		}
	}
    &config::write("/data/settings/cert/custom.conf",%data);
	#
	$response->{active}		= ($data{active}) ? \1 : \0;
	$response->{hostname}	= $data{hostname} || "";
	$response->{email}		= $data{email} || "";
	#
	$response->{resources}->{key}	= (-e "/data/settings/cert/custom.key") ? \1 : \0;
	$response->{resources}->{csr}	= (-e "/data/settings/cert/custom.csr") ? \1 : \0;
	$response->{resources}->{crt}	= (-e "/data/settings/cert/custom.crt") ? \1 : \0;
	$response->{resources}->{ca}	= (-e "/data/settings/cert/custom.ca") ? \1 : \0;
	#
	return $self->render(json => {certificate=>$response});
	
};
post '/certificate/activate'    => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
post '/certificate/deactivate'  => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
get  '/certificate/key'         => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"NO_PERMISSION", message => "No permission"} }); }
    #
    # start response
	my $response ;
	$response->{key}	= (-e "/data/settings/cert/custom.key") ? \1 : \0;
	#
	return $self->render(json => {certificate=>$response});
};
post '/certificate/key'         => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"NO_PERMISSION", message => "No permission"} }); }
    if (-e "/data/settings/cert/custom.key") {return $self->render(json => {error => { code=>"KEY_EXISTS", message => "Cannot create key over actual key"} }); }
    if (-e "/data/settings/cert/custom.csr") {return $self->render(json => {error => { code=>"CSR_EXISTS", message => "Cannot create key with valid CSR"} }); }
    if (-e "/data/settings/cert/custom.crt") {return $self->render(json => {error => { code=>"CRT_EXISTS", message => "Cannot create key with valid certificate"} }); }
	#
    #
    # start response
	my $response ;
	$response->{key} = \0;
	return $self->render(json => {certificate=>$response});
};
del  '/certificate/key'         => sub {
    my $self  = shift;
    #
    # check permission
    if (!$self->activeUserIsAdmin) {return $self->render(json => {error => { code=>"NO_PERMISSION", message => "No permission"} }); }
    if (-e "/data/settings/cert/custom.csr") {return $self->render(json => {error => { code=>"CSR_EXISTS", message => "Cannot delete key with valid CSR"} }); }
    if (-e "/data/settings/cert/custom.crt") {return $self->render(json => {error => { code=>"CRT_EXISTS", message => "Cannot delete key with valid certificate"} }); }
	#
	unlink("/data/settings/cert/custom.key");
    #
    # start response
	my $response ;
	$response->{key} = \0;
	return $self->render(json => {certificate=>$response});
};
get  '/certificate/csr'         => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
post '/certificate/csr'         => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
del  '/certificate/csr'         => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
get  '/certificate/crt'         => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
post '/certificate/crt'         => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
del  '/certificate/crt'         => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
get  '/certificate/ca'          => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
post '/certificate/ca'          => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
del  '/certificate/ca'          => sub { my $self  = shift;return $self->render(json => {error => { code=>"NOT_IMPLEMENTED", message => "Not implemented"} }); };
# ===============================================




# ===============================================
#
# /account/ endpoints
#
# ===============================================
get '/user/' => sub { 
    my $self  = shift;
    #
    # check user
	my $user = &clean_string($self->req->headers->header('REMOTE_USER')."");
    if (!$user) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION", message => "No active authentication"} }); }
    if (!&omyc::user::exists($user)) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION_USER", message => "No active authentication user"} }); }
    #
    my $info = &omyc::user::retrieve($user);
    if (!$info) {return $self->render(json => {error => { code=>"NO_USER_INFO", message => "No user info"} }); }
    #
	my $data ;
	$data->{user}	= $info;
    delete($data->{user}->{homedir}); # hide some info we do not want public
	return $self->render(json => $data);
};
post '/user/passwordChange' 	=> sub {	
    my $self  = shift;
    #
    # TODO. Brute force fuse by ip/user/whatever. Return same fail_change error message to obfuscate fuse
    #
    # check user
	my $user = &clean_string($self->req->headers->header('REMOTE_USER')."");
    if (!$user) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION", message => "No active authentication"} }); }
    if (!&omyc::user::exists($user)) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION_USER", message => "No active authentication user"} }); }
    #
	# get data from json
	my $json_data	= $self->req->json || {};
    my $passwordNow = substr(&clean_string($json_data->{passwordNow}),0,255);
    my $passwordNew = substr(&clean_string($json_data->{passwordNew}),0,255);
    #
    # check json data
    if (!$passwordNow) {return $self->render(json => {error => { code=>"missing_passwordNow", message => "Missing now password"} }); }
    if (!$passwordNew) {return $self->render(json => {error => { code=>"missing_passwordNew", message => "Missing new password"} }); }
    if ($passwordNow ne $json_data->{passwordNow})  { return $self->render(json => {error => { code=>"incorrect_passwordNow", message => "Incorrect now password"} }); }
    if ($passwordNew ne $json_data->{passwordNew})  { return $self->render(json => {error => { code=>"incorrect_passwordNew", message => "Incorrect new password"} }); }
	if (!$passwordNew)			                    { return $self->render(json => {error => { code=>"password_empty", 	    message => "empty new password" 	} });}
	if (length($passwordNew) < 8)			        { return $self->render(json => {error => { code=>"password_too_small",  message => "new password too small" } });}
	if (length($passwordNew) > 128)			        { return $self->render(json => {error => { code=>"password_too_big",    message => "new password too big" 	} });}
	#
    if (!&omyc::user::passwordCheck($user,$passwordNow)) { return $self->render(json => {error => { code=>"fail_change", message => "Fail change password"} }); }
    if (!&omyc::user::passwordChange($user,$passwordNew)) { return $self->render(json => {error => { code=>"fail_change", message => "Fail change password"} }); }
    #
    return $self->render(json => {ok => { code=>"ok", message => "password changed"} });
};
post '/user/browseFolder/'	=> sub {
    my $self  = shift;
    #
    # check user
	my $user = &clean_string($self->req->headers->header('REMOTE_USER')."");
    if (!$user) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION", message => "No active authentication"} }); }
    if (!&omyc::user::exists($user)) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION_USER", message => "No active authentication user"} }); }
    my $userInfo = &omyc::user::retrieve($user);
    my $userHomedir = $userInfo->{homedir} || "";
    if (!$userHomedir) {return $self->render(json => {error => { code=>"INVALID_USER", message => "This user is invalid"} }); }
    #
    # get folder value
	my $json_data	= $self->req->json || {};
    my $folder  = substr(&clean_string($json_data->{folder}),0,1024);
    if ($folder ne $json_data->{folder}) {return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder (1)"} }); }
	if (substr($folder,0,1) eq "/") { $folder = substr($folder,1,1000);}
	if (substr($folder,-1,1) eq "/") { $folder = substr($folder,0,-1);}
	my $folderClean = "";
	foreach (split(/\//,$folder)){
		my $subfolder = &clean_string($_,"TEXT");
		if ($subfolder ne $_)   { return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder (2:$subfolder)"} }); }
		if ($subfolder eq ".")  { return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder (3:$subfolder)"} }); }
		if ($subfolder eq "..") { return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder (4:$subfolder)"} }); }
		$folderClean .= "/$subfolder";
	}
	$folder = $folderClean ;
    #
    # check if folder exists
	if (substr($userHomedir,0,1) eq "/") { $userHomedir = substr($userHomedir,1,1000);}
	if (substr($userHomedir,-1,1) eq "/") { $userHomedir = substr($userHomedir,0,-1);}
	$userHomedir = "/".$userHomedir;
	unless(-d $userHomedir.$folder) {return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder"} }); }
    #
    # get subfolders
    my @subfolders = ();
    opendir(DIR,$userHomedir.$folder);
    while(readdir DIR) {
        if ($_ eq ".") { next }
        if ($_ eq "..") { next }
        if (substr($_,0,1) eq ".") { next }	
        if (-d "$userHomedir$folder/$_") { @subfolders = (@subfolders,$_); }
    }
    closedir(DIR);
    #
    # output 
	my $data ;
	$data->{folder}	= $folder || "/";
	$data->{subFolders}	= \@subfolders;
	return $self->render(json => $data);
};
# ===============================================




# ===============================================
#
# /sync/ endpoints
#
# ===============================================
get  '/sync/' 	=> sub {	
	my $self  = shift;
    #
    # check user
	my $user = &clean_string($self->req->headers->header('REMOTE_USER')."");
    if (!$user) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION", message => "No active authentication"} }); }
	#
    # get list
	my @list = ();
	my %data = &omyc::sync::databaseRead();
	foreach (sort keys %data) {
		if (!$data{$_}{user}) { next }
		if ($user ne $data{$_}{user}) { next }
		my %item = %{$data{$_}};
		push @list, \%item;
	}
	#
    # return response
	my $data ;
	$data->{shares} 	= [@list];
	return $self->render(json => $data);
    #
};
post '/sync/'		=> sub {
    my $self  = shift;
    #
    # check user
	my $user = &clean_string($self->req->headers->header('REMOTE_USER')."");
    if (!$user) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION", message => "No active authentication"} }); }
    if (!&omyc::user::exists($user)) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION_USER", message => "No active authentication user"} }); }
    my $userInfo = &omyc::user::retrieve($user);
    my $userHomedir = $userInfo->{homedir} || "";
    if (!$userHomedir) {return $self->render(json => {error => { code=>"INVALID_USER", message => "This user is invalid"} }); }
    #
	# get data from json
	my $json_data	= $self->req->json || {};
    #
    # prepare new share to add
    my %share = ();
	my %shares = &omyc::sync::databaseRead();
	my $shareId = &omyc::sync::databaseNewUid();
	if (!$shareId) 	                {return $self->render(json => {error => { code=>"fail_generate_uid", message => "Fail generate new UID"} });  }
	if (exists($shares{$shareId})) 	{return $self->render(json => {error => { code=>"duplicate_uid", message => "Duplicate UID"} });  }
    $share{_id} = $shareId;
    #
    # check/decide secret
    if ($json_data->{secret_ext}) {
        $share{secret_ext} = substr(&clean_string($json_data->{secret_ext}),0,255);
        if (!$share{secret_ext}) {return $self->render(json => {error => { code=>"empty_secret", message => "Empty secret"} }); }
        if ($share{secret_ext} ne $json_data->{secret_ext}) {return $self->render(json => {error => { code=>"incorrect_secret", message => "Incorrect secret"} }); }
        if (!&omyc::sync::btsyncSecretCheck($share{secret_ext})) {return $self->render(json => {error => { code=>"invalid_secret", message => "Invalid secret"} }); }
 	} else {
        $share{secret_rw} = &omyc::sync::btsyncSecretNew();
        if (!$share{secret_rw}) {return $self->render(json => {error => { code=>"fail_create_rw_secret", message => "Fail creating read write secret"} }); }
        $share{secret_ro} = &omyc::sync::btsyncSecretToReadOnly($share{secret_rw});
        if (!$share{secret_ro}) {return $self->render(json => {error => { code=>"fail_create_ro_secret", message => "Fail creating read only secret"} }); }
    }
    #
    # get folder value
    my $folder  = substr(&clean_string($json_data->{folder},"SQL"),0,1024);
    if ($folder ne $json_data->{folder}) {return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder ($folder ne $json_data->{folder})"} }); }
	if (substr($folder,0,1) eq "/") { $folder = substr($folder,1,1000);}
	if (substr($folder,-1,1) eq "/") { $folder = substr($folder,0,-1);}
	my $folderClean = "";
	foreach (split(/\//,$folder)){
		my $subfolder = &clean_string($_,"SQL");
		if ($subfolder ne $_)   { return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder (2:$subfolder)"} }); }
		if ($subfolder eq ".")  { return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder (3:$subfolder)"} }); }
		if ($subfolder eq "..") { return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder (4:$subfolder)"} }); }
		$folderClean .= "/$subfolder";
	}
	$folder = $folderClean;
    #
    # check if folder exists
	if (substr($userHomedir,0,1) eq "/") { $userHomedir = substr($userHomedir,1,1000);}
	if (substr($userHomedir,-1,1) eq "/") { $userHomedir = substr($userHomedir,0,-1);}
	$userHomedir = "/".$userHomedir;
	unless(-d $userHomedir.$folder) {return $self->render(json => {error => { code=>"incorrect_folder", message => "Incorrect folder"} }); }
    #
    # folder is ok for this user
    $share{folder} = $folder;
    $share{user} = $user;
	#
	# check double sharing
	foreach (sort keys %shares) {
		if (!$shares{$_}{user}) { next }
		if ($user ne $shares{$_}{user}) { next }
		if ($folder eq $shares{$_}{folder}) 	        { return $self->render(json => {error => { code=>"folder_duplicate", message => "Folder Already shared"} }); }
		if (index($shares{$_}{folder},$folder) eq 0) 	{ return $self->render(json => {error => { code=>"folder_child_shared", message => "Folder has shared folders inside"} }); }
		if (index($folder,$shares{$_}{folder}) eq 0) 	{ return $self->render(json => {error => { code=>"folder_parent_shared", message => "This sub folder is already shared"} }); }
	}
	#
	# add new entry
    %{$shares{$shareId}} = %share;
	&omyc::sync::databaseWrite(%shares);
    &omyc::sync::updateSystem();
    #
    # ok. return share
	my $data ;
	$data->{share}	= \%share;
	return $self->render(json => $data);
    #
};
del  '/sync/:id'	=> sub {
    my $self  = shift;
    #
    # check user
	my $user = &clean_string($self->req->headers->header('REMOTE_USER')."");
    if (!$user) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION", message => "No active authentication"} }); }
    if (!&omyc::user::exists($user)) {return $self->render(json => {error => { code=>"NO_AUTHENTICATION_USER", message => "No active authentication user"} }); }
	#
	# fail if not exists
	my $id = substr(&clean_string($self->stash('id'),"MINIMAL"),0,64);
	if 		($id ne $self->stash('id'))			{ return $self->render(json => {error => { code=>"INVALID", 	message => "Invalid" 	} });}
	if		($id eq "")							{ return $self->render(json => {error => { code=>"EMPTY", 		message => "empty" 		} });}
    #
    # delete
	my %shares = &omyc::sync::databaseRead();
    delete($shares{$id});
	&omyc::sync::databaseWrite(%shares);
    &omyc::sync::updateSystem();
	#
	# return id we just take action
	return $self->render(json => { _id=>$id });
};
# ===============================================





# ===============================================
#
# /tools/ endpoints
#
# ===============================================
# ===============================================



# ===============================================
#
# /test/ endpoints
#
# A sandbox for developers test get/post/delete
# its a indicator that we cross apache frontend (encryption, authentication)
# This endpoint do not test other parts of systems (db, cache, etc)
#
# ===============================================
under sub {
	# disable authentication, if set above
	return 1;
};
get  '/test' 	=> sub {	
	my $self  = shift;
	#
	my $test_counter = $self->session->{test_counter} || 0;
	$test_counter++;
	$self->session->{test_counter} = $test_counter;
	#
	my $data ;
	$data->{method} 	= "GET";
	$data->{time} 		= time;
	$data->{counter}	= $test_counter;
	#$data->{headers}	= $self->req->headers->to_string;
	$data->{origin}		= $self->req->headers->origin;

	#
	return $self->render(json => $data);
};
post '/test' 	=> sub {	
    my $self  = shift;
	#
	# get data from json
	my $json_data	= $self->req->json || {};
	#
	my $test_counter = $self->session->{test_counter} || 0;
	$test_counter++;
	$self->session->{test_counter} = $test_counter;
	#
	my $data ;
	$data->{method} 	= "POST";
	$data->{time} 		= time;
	$data->{counter}	= $test_counter;
	$data->{echo} 		= $json_data;
	$data->{origin}		= $self->req->headers->origin;
	#
	return $self->render(json => $data);
};
del  '/test' 	=> sub {	
	my $self  = shift;
	#
	# get data from json
	my $json_data	= $self->req->json || {};
	#
	my $test_counter = $self->session->{test_counter} || 0;
	$test_counter++;
	$self->session->{test_counter} = $test_counter;
	#
	my $data ;
	$data->{method} 	= "DELETE";
	$data->{time} 		= time;
	$data->{counter}	= $test_counter;
	$data->{echo} 		= $json_data;
	$data->{origin}		= $self->req->headers->origin;
	#
	return $self->render(json => $data);
};
#
# ===============================================








# ===============================================
#
# cross domain tricks / catch all routes / main loop
#
# ===============================================
under sub {
	# disable authentication, if set above
	return 1;
};
options '*' => sub {
	#
	# cross domain trick #1
	# browsers pre-fly before a post, by going a "options" to server
	# we need answer this option with correct CORS headers
	# ps: headers are injected at app->hook->after_dispatch bellow
	#
    my $self = shift;
	$self->respond_to(any => { data => '', status => 200 });
};
any '/' => sub {
	# anything else, i guess its some of our apps hit a wrong place.
	# we can return a nice json response 
	my $self = shift;
	$self->res->code(200);
	#$self->res->message('Not Found');
	# if we return 404, api will keep try multiple times to hit a good server in load balance
	# if we reach this point, server is ok. so we need return a json response with ok http response
	return $self->render(json => {error => { code=>"NOT_FOUND", message => "not found"} });
	#
	#	# blank for first page to get script kidies curious.
	#	# i hope my geek response make he understand we are the same,
	#	# in same boat, and he become my friend, not enemy
	#	my $self = shift;
	#	$self->res->code(404);
	#	return $self->render(template => 'home');
	#
};
any '/*' => sub {
	# anything else, i guess its some of our apps hit a wrong place.
	# we can return a nice json response 
	my $self = shift;
	$self->res->code(200);
	#$self->res->message('Not Found');
	# if we return 404, api will keep try multiple times to hit a good server in load balance
	# if we reach this point, server is ok. so we need return a json response with ok http response
	return $self->render(json => {error => { code=>"NOT_FOUND", message => "not found"} });
};
app->hook(after_dispatch => sub {
	#
	# cross domain trick #2
	# for each answer we return to client, we need add correct CORS headers
	# Allow-Origin allow client javascript cross domain to us
	# Allow-Credentials allow client javascript save cookies on us
	#
    my $self = shift;
	#
	# Access-Control-Allow-Origin need be ONE domain.
	# we cannot use '*' because some browsers block cookies with wildcard
	# we decide to dynamic reurn origin we capture from request
	# later one, we can validate (proto code bellow) if this origin its acceptable or not
	#
	# TODO: decide if we will disallow all and allow only few... or .. allow all (like now)
	my $origin = $self->req->headers->origin;
	my $origin_approved = 0;
	#
	# send correct headers to allow cross domain ajax requests
	if ($origin_approved) {
		$self->res->headers->header('Access-Control-Allow-Origin' => $origin );
		$self->res->headers->header('Access-Control-Allow-Credentials' => 'true');
		$self->res->headers->header('Access-Control-Allow-Methods' => 'GET, OPTIONS, POST, DELETE, PUT');
		$self->res->headers->header('Access-Control-Allow-Headers' =>  'Set_Cookie, Set-Cookie, Cookie, Content-Type, Content_Type ');
	}
	#
});
# ===============================================




# ===============================================
#
# main loop
#
# ===============================================
#
app->start;
#
# ===============================================





# ===============================================
#
# if something goes wrong, say nothing
#
# ===============================================
# this server is not intent to humans, no need explain any fail
# TODO: After figureout production/development mode, we can reopen human errors at development at least
__DATA__
@@ exception.html.ep
<!-- bad server, bad server :( -->