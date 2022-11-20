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
		when('/session',		    	{templateUrl: '/public/views/session/view.html',	    controller: 'session'	    }).
		otherwise({redirectTo: '/session/'});
	}
]);
// ============================================================================
