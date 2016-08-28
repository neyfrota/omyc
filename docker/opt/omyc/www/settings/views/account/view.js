app.controller('account', function($scope,$routeParams,$http,$interval) {
	//
    activateSubMenu("account");
    //
    $scope.user = null;
    //
    $scope.api			= {};
    $scope.api.response	= null;
    $scope.api.busy		= false;
    $scope.api.getUser  = function() {
        //
        if ($scope.api.busy) {return}
        setIsAdminSubMenu();
        $scope.api.response	= null;
        $scope.user = null;
        //
        $scope.api.busy = true;
        $http.get("/api/user/")
        .success(function(response) {
            if (!response.error) {
                if (!response.user)	{ response.error = { code:"DATA_ERROR", message:"Incorrect api response"};		}
            }
            $scope.api.busy 	= false;
            $scope.api.response = response;
            if (!response.error) {
                $scope.user = response.user;
                setIsAdminSubMenu($scope.user.isAdmin);
            }
        })
        .error(function(response) {
            $scope.api.busy 	= false;
            $scope.api.response = { error:{ code:"NETWORK_ERROR", message:"network error"} };
        });
    }
    //
    $scope.api.getUser();
    //
});














