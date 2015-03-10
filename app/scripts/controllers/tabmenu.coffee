'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:TabmenuCtrl
 # @description
 # # TabmenuCtrl
 # Controller of the webvisApp
###
angular.module('webvisApp').controller 'TabmenuCtrl', ($scope, Options) ->
    $scope.pages = Object.keys(Options.getOptions())
    $scope.currentPage = Options.getOptions()[$scope.pages[0]]
    
    $scope.changePage = (pageName) ->
        $scope.currentPage = Options.getOptions()[pageName]
        
    $scope.$on 'Options:pageAdded', (event, data) =>
        $scope.pages = Object.keys(Options.getOptions())