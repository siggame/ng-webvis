'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:TabmenuCtrl
 # @description
 # # TabmenuCtrl
 # Controller of the webvisApp
###
angular.module('webvisApp').controller 'TabmenuCtrl', ($scope, FileLoader, Options) ->
    $scope.pages = Object.keys(Options.getOptions())
    $scope.currentPageName = $scope.pages[0]
    $scope.currentPage = Options.getOptions()[$scope.pages[0]]

    $scope.changePage = (pageName) ->
        $scope.currentPageName = pageName
        $scope.currentPage = Options.getOptions()[pageName]

    $scope.$on 'Options:pageAdded', (event, data) =>
        $scope.pages = Object.keys(Options.getOptions())

    $scope.$on 'Webvis:Mode:updated', (event, data) =>
        url = Options.get 'Webvis', 'Arena Url'
        FileLoader.loadFromUrl(url.text + "/api/next_game")
