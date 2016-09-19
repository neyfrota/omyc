app.controller('view', function($scope,$routeParams,$location,$http,$interval) {
    //
    $scope.item			= null;
    //
    $scope.secretToShow = "";
    //
    //
    $scope.api			= {};
    $scope.api.url		= "/api/sync/";
    $scope.api.response	= null;
    $scope.api.busy		= false;
    $scope.api.retrieve	= function(id) {
        //
        if ($scope.api.busy) {return}
        $scope.api.response	= null;
        $scope.item = null;
        //
        $scope.api.busy = true;
        $http.get($scope.api.url)
        .success(function(response) {
            if (response.shares) {
                for(i=0; i<response.shares.length; i++){
                    if (response.shares[i]._id == id) {
                        $scope.item = response.shares[i];
                        break;
					}
                }
            }
            if (!$scope.item) {
                response.error = { code:"NOT_FOUND", message:"Cannot find this share"};
            }
            $scope.api.busy 	= false;
            $scope.api.response = response;
            //
            // call qrcode to draw code
            if ($scope.item) {
                if ($scope.item.secret_ext) { $scope.secretToShow="ext"; jQuery('#qrcode_ext').qrcode("btsync://"+$scope.item.secret_ext+"?n=syncnow"); }
                if ($scope.item.secret_ro)  { $scope.secretToShow="ro"; jQuery('#qrcode_ro').qrcode("btsync://"+$scope.item.secret_ro+"?n=syncnow"); }
                if ($scope.item.secret_rw)  { $scope.secretToShow="rw"; jQuery('#qrcode_rw').qrcode("btsync://"+$scope.item.secret_rw+"?n=syncnow"); }
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
        if (!$scope.item) {
            $scope.api.response = { error:{ code:"NOT_FOUND", message:"Cannot find this share"} };
            return
        }
        if (!$scope.item._id) {
            $scope.api.response = { error:{ code:"ID_EMPTY", message:"Id is empty"} };
            return
        }
        //
        $scope.api.busy 	= true;
        $http.delete($scope.api.url+$scope.item._id)
        .success(function(response) {
            if (!response.error) {
                if (!response._id)	{response.error = { code:"DATA_ERROR", message:"Incorrect api response"};		}
            }
            if (!response.error) {
                $location.path('/list/'); 
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
    $scope.clickAddConfirm  = function() { $scope.api.delete(); }
    $scope.clickCancel  = function() { $location.path('/list/'); }             
    //
    $scope.api.retrieve($routeParams.id)
    //

});














