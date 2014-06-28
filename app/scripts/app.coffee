'use strict'

###*
 # @ngdoc overview
 # @name webvisApp
 # @description
 # # webvisApp
 #
 # Main module of the application.
###
webvisApp = angular.module 'webvisApp', [
    'ngCookies'
    'ngResource'
    'ngSanitize'
    'ngRoute'
    'ui.bootstrap'
]

webvisApp.config ($routeProvider) ->
    $routeProvider.when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'

    $routeProvider.otherwise
        redirectTo: '/'
