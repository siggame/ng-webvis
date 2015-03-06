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

webvisApp.config ($routeProvider, $provide, $compileProvider, $controllerProvider) ->
    webvisApp.provide = $provide
    webvisApp.compileProvider = $compileProvider
    webvisApp.controllerProvider = $controllerProvider
    
    $routeProvider.when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
        controllerAs: 'main'

    $routeProvider.otherwise
        redirectTo: '/'
