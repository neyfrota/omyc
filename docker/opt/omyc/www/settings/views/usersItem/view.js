app.controller('usersItem', function($scope,$routeParams,$location,$http,$interval) {
	//
    activateSubMenu("users");
    //
	//
	// item
	$scope.isEdit	= false;
	$scope.isAdd	= false;
	$scope.user	    = {};
	//
	// define sessions list
	$scope.api				= {};
	$scope.api.url			= "/api/users/";
	$scope.api.error		= null;
	$scope.api.busy			= false;
	$scope.api.create		= function() {
		//
		if ($scope.api.busy) {return}
		//
		$scope.api.error= null;
		$scope.api.busy = true;
		//
		$http.post($scope.api.url,$scope.user)
		.success(function(response) {
			if (!response.error) {
				if (!response.user) {response.error = { code:"DATA_ERROR", message:"Incorrect api response"} ;}
			}
			if (response.error) {
				$scope.api.busy 	= false;
				$scope.api.error	= response.error;
			} else {
				$location.path('/users/');
			}
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.error	= { code:"NETWORK_ERROR", message:"network error" };
		});		
	}
	$scope.api.retrieve		= function(user) {
		//
		if ($scope.api.busy) {return}
		//
		$scope.api.error	= null;
		$scope.api.busy 	= true;
		$http.get($scope.api.url+user)
		.success(function(response) {
			if (!response.error) {
				if (!response.user) {response.error = { code:"DATA_ERROR", message:"Incorrect api response"} ;}
			}
			if (response.error) {
				$scope.api.busy = false;
				$scope.api.error= response.error;
			} else {
				$scope.api.busy = false;
				$scope.user		= response.user;
			}
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.error	= { code:"NETWORK_ERROR", message:"network error" };
		});
	}
	$scope.api.update		= function() {
		//
		if ($scope.api.busy) {return}
		//
		$scope.api.error= null;
		$scope.api.busy = true;
		//
		$http.post($scope.api.url+$scope.user.username ,$scope.user)
		.success(function(response) {
			if (!response.error) {
				if (!response.user) {response.error = { code:"DATA_ERROR", message:"Incorrect api response"} ;}
			}
			if (response.error) {
				$scope.api.busy 	= false;
				$scope.api.error	= response.error;
			} else {
				$location.path('/users/');
			}
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.error	= { code:"NETWORK_ERROR", message:"network error" };
		});
	}
	$scope.api.delete		= function() {
		//
		if ($scope.api.busy) {return}
		//
		if (!$scope.user.username) {
			$scope.api.error = { code:"ID_EMPTY", message:"No user to delete"};
			return
		}
		//
		$scope.api.error= null;
		$scope.api.busy = true;
        //
		$http.delete($scope.api.url+$scope.user.username)
		.success(function(response) {
			if (!response.error) {
				if (!response.user) {response.error = { code:"DATA_ERROR", message:"Incorrect api response"} ;}
			}
			if (response.error) {
				$scope.api.busy 	= false;
				$scope.api.error	= response.error;
			} else {
				$location.path('/users/');
			}
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.response = { error:{ code:"NETWORK_ERROR", message:"network error"} };
		});
		
	}
    //
    // main loop
	//
    $scope.isEdit	= false;
    $scope.isAdd	= true;
	$scope.user     = {};
	if ($routeParams.id){
        $scope.isEdit	= true;
        $scope.isAdd	= false;
        $scope.api.retrieve($routeParams.id);
    }
	//
});














