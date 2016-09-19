app.controller('usersList', function($scope,$routeParams,$location,$http,$interval) {
	//
    activateSubMenu("users");
    //
    $scope.list			= [];
    //
    $scope.api			= {};
    $scope.api.response	= null;
    $scope.api.busy		= false;
    $scope.api.list	    = function() {
        //
        if ($scope.api.busy) {return}
        $scope.api.response	= null;
        //
        $scope.api.busy = true;
        $http.get("/api/users")
        .success(function(response) {
            if (!response.error) {
                if (!response.users)	{ response.error = { code:"DATA_ERROR", message:"Incorrect api response"};		}
            }
            $scope.api.busy 	= false;
            $scope.api.response = response;
            if (!response.error) {
                $scope.list	= response.users;
            }
        })
        .error(function(response) {
            $scope.api.busy 	= false;
            $scope.api.response = { error:{ code:"NETWORK_ERROR", message:"network error"} };
        });
    }
    //
    $scope.clickItem    = function(item) {$location.path('/users/'+item);}
    $scope.clickAdd     = function(item) {$location.path('/users/add');}
    //
    $scope.api.list();

});














