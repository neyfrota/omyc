app.controller('list', function($scope,$routeParams,$location,$http,$interval) {
    //
    $scope.list			= [];
    //
    $scope.api			= {};
    $scope.api.url		= "/api/sync/";
    $scope.api.response	= null;
    $scope.api.busy		= false;
    $scope.api.list	    = function() {
        //
        if ($scope.api.busy) {return}
        $scope.api.response	= null;
        //
        url = $scope.api.url;
        $scope.api.busy = true;
        $http.get(url)
        .success(function(response) {
            if (!response.error) {
                if (!response.shares)	{ response.error = { code:"DATA_ERROR", message:"Incorrect api response"};		}
            }
            $scope.api.busy 	= false;
            $scope.api.response = response;
            $scope.list			= response.shares;
        })
        .error(function(response) {
            $scope.api.busy 	= false;
            $scope.api.response = { error:{ code:"NETWORK_ERROR", message:"network error"} };
        });
    }
    //
    $scope.clickItem    = function(item) {$location.path('/view/'+item._id);}
    $scope.clickAdd     = function() {$location.path('/add');}
    //
    $scope.api.list();

});














