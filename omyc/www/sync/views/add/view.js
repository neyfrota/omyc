app.controller('add', function($scope,$routeParams,$location,$http,$interval) {
    //
    $scope.isNew		= 1;
    $scope.item			= {};
    //
    $scope.api			= {};
    $scope.api.url		= "/api/sync/";
    $scope.api.response	= {};
    $scope.api.busy		= false;
    $scope.api.create		= function() {
        //
        if ($scope.api.busy) {return}
        //
        $scope.api.response	= null;
        //
        if (!$scope.item.folder) {
            $scope.api.response = { error:{ code:"FOLDER_EMPTY", message:"Folder cannot be empty"} };
            return
        }
        if ($scope.isNew) {
            $scope.item.secret_ext = "";
        } else {
            if (!$scope.item.secret_ext ) {
                $scope.api.response = { error:{ code:"SECRET_EMPTY", message:"Secret key cannot be empty"} };
                return
			}
        }
        //
        $scope.api.busy = true;
        $http.post($scope.api.url,$scope.item)
        .success(function(response) {
            if (!response.error) {
                if (!response.share) 	{response.error = { code:"DATA_ERROR", message:"Incorrect api response"};		}
            }
            if (!response.error) {
                $scope.api.response = response;
                $scope.api.busy 	= false;
                $scope.item         = response.share
                $location.path('/list/'); 
                //$location.path('/view/'+$scope.item._id);
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
    $scope.tree					= {};
    $scope.tree.data			= [{ id:"", label:"Personal folder", localLabel:"Personal folder", children:[] }];
    $scope.tree.opts 			= { isSelectable: function(node){return true}, isLeaf: function(node) {return false;} };
    $scope.tree.expandedNodes 	= [$scope.tree.data[0]];
    $scope.tree.showSelected 	= function(node, selected, $parentNode, $index, $first, $middle, $last, $odd, $even) {
        $scope.item.folder = node.id;
        $scope.tree.expandedNodes.push(node);
        $scope.tree.showToggle(node);
    };	
    $scope.tree.showToggle 		= function(node) {
        node.children=[];
        var postData = {};
        postData.folder = node.id;
        $http.post("/api/user/browseFolder/",postData)
        .success(function(response) {
            var folder = response.folder || "";
            var subFolders = response.subFolders || [];
            var newChildren = [];
            for	(index = 0; index < subFolders.length; index++) {
                var f = folder+ ( (folder=="/")?"":"/") +subFolders[index];
                newChildren.push( { id:f, label:f, localLabel:subFolders[index], children:[] } );
            }
            node.children = newChildren;
        })
        .error(function(response) {
        });
    };
    //
    //
    $scope.clickAddConfirm  = function() { $scope.api.create(); }
    $scope.clickCancel  = function() { $location.path('/list/'); }             
    //
    //
    $scope.api.response	= null;
    $scope.item = {};
    $scope.tree.showToggle($scope.tree.data[0]);
	//
    //
});














