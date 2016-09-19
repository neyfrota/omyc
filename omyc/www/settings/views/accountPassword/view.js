app.controller('accountPassword', function($scope,$routeParams,$http,$interval) {
	//
    activateSubMenu("account");
    //
	// form
	$scope.form						= {};
	$scope.form.passwordNow		= null;
	$scope.form.passwordNew			= null;
	$scope.form.passwordNewRetype	= null;	
	//
	// define sessions list
	$scope.api					= {};
	$scope.api.response			= null;
	$scope.api.busy				= false;
	$scope.api.changePassword	= function() {
		//
		if ($scope.api.busy) {return}
		//
		$scope.api.response	= null;
		//
		if (!$scope.form.passwordNow) {
			$scope.api.response = { error:{ code:-20, message:"No actual password"} };
			return
		}
		if (!$scope.form.passwordNew) {
			$scope.api.response = { error:{ code:-30, message:"No new password"} };
			return
		}
		if ($scope.form.passwordNew != $scope.form.passwordNewRetype) {
			$scope.api.response = { error:{ code:-90, message:"New passwords mismatch. Please trype new password twice"} };
			return
		}
		//
		$scope.api.busy 	= true;
		$http.post('/api/user/passwordChange',$scope.form)
		.success(function(response) {
			$scope.api.busy 	= false;
			$scope.api.response = response;
		})
		.error(function(response) {
			$scope.api.busy 	= false;
			$scope.api.response = { error:{ code:-999, message:"network error"} };
		});
	}
	//
});














