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
		when('/account',		    {templateUrl: 'views/account/view.html',	    controller: 'account'		    }).
		when('/accountPassword',    {templateUrl: 'views/accountPassword/view.html',controller: 'accountPassword'   }).
		when('/users',			    {templateUrl: 'views/usersList/view.html',	    controller: 'usersList'		    }).
		when('/users/add',			{templateUrl: 'views/usersItem/view.html',	    controller: 'usersItem'		    }).
		when('/users/:id',			{templateUrl: 'views/usersItem/view.html',	    controller: 'usersItem'		    }).
		otherwise({redirectTo: '/account/'});
	}
]);
// ============================================================================
