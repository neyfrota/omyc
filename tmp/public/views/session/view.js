app.controller('session', function($scope,$routeParams,$http,$interval) {
    //
    $scope.session			    = {};
    $scope.session.active	    = false;
    $scope.session.busy	    	= false;
    $scope.session.goWelcome    = function() {
        //window.location="/welcome/";
    }
    $scope.session.check        = function(callbackTrue,callbackFalse) {
        if (!callbackTrue) { callbackTrue=function(){} }
        if (!callbackFalse) { callbackFalse=function(){} }
        if ($scope.session.busy) {return}
        $scope.session.busy     = true;
        $scope.session.active	= false;
        $http.get("/session/status/")
        .success(function(response) {
            $scope.session.busy 	= false;
            if (response) {
                if (response.ok==1) {
                    $scope.session.active = true;
                }
            }
            if ($scope.session.active) { callbackTrue() } else { callbackFalse() }
        })
        .error(function(response) {
            $scope.session.busy 	= false;
            if ($scope.session.active) { callbackTrue() } else { callbackFalse() }
        });
    }
    $scope.session.destroy      = function() {
        // New XMLHTTPRequest
        var request = new XMLHttpRequest();
        request.open("POST", "/session/destroy/", false);
        request.setRequestHeader("Authorization", "Basic "+btoa("fake:user" ));  
        request.send();
        $scope.session.check();
    }
    $scope.session.create       = function() {
        // New XMLHTTPRequest
        var request = new XMLHttpRequest();
        request.open("POST", "/session/create", false);
        request.send();
        $scope.session.check($scope.session.goWelcome);
    }
    //
    $scope.session.check();
    //
});














