'use strict'

webvisApp = angular.module('webvisApp', [
        'ngCookies',
        'ngResource',
        'ngSanitize',
        'ngRoute',
        'ui.bootstrap'
    ])

webvisApp.config ($routeProvider) ->
    $routeProvider
        .when '/',
            templateUrl: 'views/main.html'
            controller: 'MainCtrl'
        .otherwise redirectTo: '/'
