app.controller('system', function($scope,$routeParams,$http,$interval) {
	//
    activateSubMenu("system");
	//
	$scope.noip			= {};
	$scope.letsEncrypt	= {};
	//
	$scope.noip.config			= {};
	$scope.noip.config.data		= null;
	$scope.noip.config.error   	= null;
	$scope.noip.config.busy		= false;
	$scope.noip.config.load		= function() {
		//
		if ($scope.noip.config.busy) {return}
    	$scope.noip.config.busy		= true;
    	$scope.noip.config.error   	= null;
    	$scope.noip.config.data		= null;
		$http.get('/api/noip/config')
		.success(function(response) {
            if (!response.config) {
                if (!response.error) {
        			response.error= { code:"invalid_response", message:"Invalid api response"};
                }
			}
			$scope.noip.config.busy 	= false;
            if (response.error) {
            	$scope.noip.config.error = response.error;                
            } else {
            	$scope.noip.config.data = response.config;
            }
		})
		.error(function(response) {
			$scope.noip.config.busy 	= false;
			$scope.noip.config.error= { code:"network_error", message:"network error"};
		});
	}
	$scope.noip.config.save		= function() {
		//
		if ($scope.noip.config.busy) {return}
    	$scope.noip.config.busy		= true;
    	$scope.noip.config.error   	= null;
    	$http.post('/api/noip/config',$scope.noip.config.data)
		.success(function(response) {
            if (!response.config) {
                if (!response.error) {
        			response.error= { code:"invalid_response", message:"Invalid api response"};
                }
			}
			$scope.noip.config.busy 	= false;
            if (response.error) {
            	$scope.noip.config.error = response.error;                
            } else {
            	$scope.noip.config.data = null;
                $scope.noip.status.update();
            }
		})
		.error(function(response) {
			$scope.noip.config.busy 	= false;
			$scope.noip.config.error= { code:"network_error", message:"network error"};
		});
	}
	$scope.noip.config.cancel	= function() {
		if ($scope.noip.config.busy) {return}
    	$scope.noip.config.error   	= null;
    	$scope.noip.config.data		= null;
		$scope.noip.status.update();		
	}
	//
	$scope.noip.status		    = {};
	$scope.noip.status.now		= {};
	$scope.noip.status.busy		= false;
	$scope.noip.status.update	= function() {
		if ($scope.noip.status.busy) {return}
    	$scope.noip.status.busy		= true;
		$http.get('/api/noip/status')
		.success(function(response) {
			$scope.noip.status.busy 	= false;
            if (response.status) {$scope.noip.status.now = response.status; }
		})
		.error(function(response) {
			$scope.noip.status.busy 	= false;
		});
	}
    //
	//
	$scope.letsEncrypt.status		    = {};
	$scope.letsEncrypt.status.now		= {};
	$scope.letsEncrypt.status.busy		= false;
	$scope.letsEncrypt.status.update	= function() {
		if ($scope.letsEncrypt.status.busy) {return}
    	$scope.letsEncrypt.status.busy		= true;
		$http.get('/api/letsEncrypt/status')
		.success(function(response) {
			$scope.letsEncrypt.status.busy 	= false;
            if (response.status) {$scope.letsEncrypt.status.now = response.status; }
		})
		.error(function(response) {
			$scope.letsEncrypt.status.busy 	= false;
		});
	}
    //
	$scope.letsEncrypt.config			= {};
	$scope.letsEncrypt.config.data		= null;
	$scope.letsEncrypt.config.error   	= null;
	$scope.letsEncrypt.config.busy		= false;
	$scope.letsEncrypt.config.load		= function() {
		//
		if ($scope.letsEncrypt.config.busy) {return}
    	$scope.letsEncrypt.config.busy		= true;
    	$scope.letsEncrypt.config.error   	= null;
    	$scope.letsEncrypt.config.data		= null;
		$http.get('/api/letsEncrypt/config')
		.success(function(response) {
            if (!response.config) {
                if (!response.error) {
        			response.error= { code:"invalid_response", message:"Invalid api response"};
                }
			}
			$scope.letsEncrypt.config.busy 	= false;
            if (response.error) {
            	$scope.letsEncrypt.config.error = response.error;                
            } else {
            	$scope.letsEncrypt.config.data = response.config;
            }
		})
		.error(function(response) {
			$scope.letsEncrypt.config.busy 	= false;
			$scope.letsEncrypt.config.error= { code:"network_error", message:"network error"};
		});
        
    }
	$scope.letsEncrypt.config.save		= function() {
		//
		if ($scope.letsEncrypt.config.busy) {return}
    	$scope.letsEncrypt.config.busy		= true;
    	$scope.letsEncrypt.config.error   	= null;
    	$http.post('/api/letsEncrypt/config',$scope.letsEncrypt.config.data)
		.success(function(response) {
            if (!response.config) {
                if (!response.error) {
        			response.error= { code:"invalid_response", message:"Invalid api response"};
                }
			}
			$scope.letsEncrypt.config.busy 	= false;
            if (response.error) {
            	$scope.letsEncrypt.config.error = response.error;                
            } else {
            	$scope.letsEncrypt.config.data = null;
                $scope.letsEncrypt.status.update();
            }
		})
		.error(function(response) {
			$scope.letsEncrypt.config.busy 	= false;
			$scope.letsEncrypt.config.error= { code:"network_error", message:"network error"};
		});
    }
	$scope.letsEncrypt.config.cancel	= function() {
		if ($scope.letsEncrypt.config.busy) {return}
    	$scope.letsEncrypt.config.error   	= null;
    	$scope.letsEncrypt.config.data		= null;
		$scope.letsEncrypt.status.update();		
        
    }
	//
    // main loop
    $scope.noip.status.update();
    $scope.letsEncrypt.status.update();
    //
});














