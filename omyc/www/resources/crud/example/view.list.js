app.controller('list', function($scope,$location,$routeParams,$http) {
	//
	//
	$scope.api				= {};
	$scope.api.url			= "api.cgi";
	$scope.api.response		= null;
	$scope.api.busy			= false;
	$scope.api.getList	= function() {
		//
		if ($scope.api.busy) {return}
		$scope.api.response	= null;
		//
		url = $scope.api.url;
		$scope.api.busy = true;
		$http.get(url)
		.success(function(response) {
			$scope.api.busy 	= false;
			$scope.api.response = response;
			if (!response.ok) 	{$scope.api.response = { error:{ code:"INTERNAL_ERROR", message:"Incorrect api response"} };}
			if (!response.list) {$scope.api.response = { error:{ code:"DATA_ERROR", message:"Incorrect api response"} };}
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.response = { error:{ code:"NETWORK_ERROR", message:"network error"} };
		});
	}
	//
	$scope.clickReload	= function() {$scope.api.getList();}
	$scope.clickItem	= function(id) {$location.path('/'+id);}
	//
	$scope.api.getList();
	//
});














