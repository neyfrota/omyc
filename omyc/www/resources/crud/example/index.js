// ============================================================================
// start app
// ============================================================================
//
// create app
var app = angular.module('app', ['ngRoute']);
//
// define routes->controlers
app.config(['$routeProvider',
	function($routeProvider) {
		$routeProvider.
		when('/',		{templateUrl: 'view.list.html',	controller: 'list'	}).
		when('/add',	{templateUrl: 'view.crud.html',	controller: 'crud'	}).
		when('/:id', 	{templateUrl: 'view.crud.html',	controller: 'crud'	}).
		otherwise({redirectTo: '/'});
	}
]);
// ============================================================================


