// ============================================================================
// start app
// ============================================================================
//
// create app
var app = angular.module('app', ['ngRoute','treeControl']);
//
// define routes->controlers
app.config(['$routeProvider',
	function($routeProvider) {
		$routeProvider.
		when('/list',	    {templateUrl: 'views/list/view.html',	controller: 'list'  }).
		when('/view/:id',   {templateUrl: 'views/view/view.html',   controller: 'view'  }).
		when('/add',	    {templateUrl: 'views/add/view.html',	controller: 'add'   }).
		otherwise({redirectTo: '/list/'});
	}
]);
// ============================================================================




