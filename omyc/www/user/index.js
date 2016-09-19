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
		when('/home',					{templateUrl: 'views/home/view.html',		controller: 'home'			}).
		when('/password',				{templateUrl: 'views/password/view.html',	controller: 'password'		}).
		otherwise({redirectTo: '/home'});
	}
]);
// ============================================================================




app.filter('seconds2hhmmss', function() {
	return function(input) {
		var sec_num = parseInt(input, 10) || 0;
		var hours   = Math.floor(sec_num / 3600);
		var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
		var seconds = sec_num - (hours * 3600) - (minutes * 60);
		if (hours   < 10) {hours   = "0"+hours;}
		if (minutes < 10) {minutes = "0"+minutes;}
		if (seconds < 10) {seconds = "0"+seconds;}
		var time    = hours+':'+minutes+':'+seconds;
		return time;
	};
});
app.filter('seconds2mss', function() {
	return function(input) {
		var sec_num = parseInt(input, 10) || 0;
		var hours   = Math.floor(sec_num / 3600);
		var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
		var seconds = sec_num - (hours * 3600) - (minutes * 60);
		if (seconds < 10) {seconds = "0"+seconds;}
		var time    = minutes+':'+seconds;
		return time;
	};
});

