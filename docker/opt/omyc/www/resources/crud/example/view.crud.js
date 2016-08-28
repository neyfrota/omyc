app.controller('crud', function($scope,$location,$routeParams,$http,$interval) {
	//
	// global
	//
	// form
	$scope.form						= {};
	$scope.form.id					= null;
	$scope.form.title				= null;
	//
	// define sessions list
	$scope.api				= {};
	$scope.api.url			= "api.cgi";
	$scope.api.response		= null;
	$scope.api.busy			= false;
	$scope.api.create		= function() {
		//
		if ($scope.api.busy) {return}
		//
		$scope.api.response	= null;
		if (!$scope.form.title) {
			$scope.api.response = { error:{ code:"TITLE_EMPTY", message:"Title cannot be empty"} };
			return
		}
		//
		$scope.api.busy = true;
		$http.post($scope.api.url,$scope.form)
		.success(function(response) {
			if (!response.error) {
				if (!response.ok) 	{response.error = { code:"INTERNAL_ERROR", message:"Incorrect api response"};	}
				if (!response.item) {response.error = { code:"DATA_ERROR", message:"Incorrect api response"};		}
			}
			if (!response.error) {
				$location.path('/');
			} else {
				$scope.api.response = response;
				$scope.api.busy 	= false;
			}
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.response = { error:{ code:"NETWORK_ERROR", message:"network error"} };
		});
		
	}
	$scope.api.retrieve		= function(id) {
		//
		if ($scope.api.busy) {return}
		//
		$scope.api.response	= null;
		$scope.api.busy 	= true;
		$http.get($scope.api.url+"?id="+id,$scope.form)
		.success(function(response) {
			if (!response.error) {
				if (!response.ok) 	{response.error = { code:"INTERNAL_ERROR", message:"Incorrect api response"};	}
				if (!response.item) {response.error = { code:"DATA_ERROR", message:"Incorrect api response"};		}
			}
			$scope.api.busy 	= false;
			$scope.api.response = response;
			if (response.item) { $scope.form=response.item }
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.response = { error:{ code:"NETWORK_ERROR", message:"network error"} };
		});
	}
	$scope.api.update		= function() {
		//
		if ($scope.api.busy) {return}
		//
		$scope.api.response	= null;
		if (!$scope.form.id) {
			$scope.api.response = { error:{ code:"ID_EMPTY", message:"Id is empty"} };
			return
		}
		if (!$scope.form.title) {
			$scope.api.response = { error:{ code:"TITLE_EMPTY", message:"Title cannot be empty"} };
			return
		}
		//
		$scope.api.busy 	= true;
		$http.post($scope.api.url+"?id="+$scope.form.id,$scope.form)
		.success(function(response) {
			if (!response.error) {
				if (!response.ok) 	{response.error = { code:"INTERNAL_ERROR", message:"Incorrect api response"};	}
				if (!response.item) {response.error = { code:"DATA_ERROR", message:"Incorrect api response"};		}
			}
			if (!response.error) {
				$location.path('/');
			} else {
				$scope.api.response = response;
				$scope.api.busy 	= false;
			}
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.response = { error:{ code:"NETWORK_ERROR", message:"network error"} };
		});
	}
	$scope.api.delete		= function() {
		//
		if ($scope.api.busy) {return}
		//
		$scope.api.response	= null;
		if (!$scope.form.id) {
			$scope.api.response = { error:{ code:"ID_EMPTY", message:"Id is empty"} };
			return
		}
		//
		$scope.api.busy 	= true;
		$http.delete($scope.api.url+"?id="+$scope.form.id)
		.success(function(response) {
			if (!response.error) {
				if (!response.ok) 	{response.error = { code:"INTERNAL_ERROR", message:"Incorrect api response"};	}
				if (!response.id)	{response.error = { code:"DATA_ERROR", message:"Incorrect api response"};		}
			}
			if (!response.error) {
				$location.path('/');
			} else {
				$scope.api.response = response;
				$scope.api.busy 	= false;
			}
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.response = { error:{ code:"NETWORK_ERROR", message:"network error"} };
		});
		
	}
	//
	//
	if ($routeParams.id){
		$scope.form.id		= $routeParams.id;
		$scope.form.title	= null;
		$scope.api.retrieve($routeParams.id);
	} else {
		$scope.form.id		= null;
		$scope.form.title	= null;
	}
	//
});














