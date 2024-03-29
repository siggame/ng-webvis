'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:TabmenuCtrl
 # @description
 # # TabmenuCtrl
 # Controller of the webvisApp
###

TabmenuCtrl = ($rootScope, $scope, Game, FileLoader, Options) ->
    $scope.pages = Object.keys(Options.getOptions())
    $scope.currentPageName = $scope.pages[0]
    $scope.currentPage = Options.getOptions()[$scope.pages[0]]
    $scope.currentSelection = {}
    $scope.focusData = {}

    $scope.changePage = (pageName) ->
        $scope.currentPageName = pageName
        $scope.currentPage = Options.getOptions()[pageName]

    $scope.focus = (id) ->
        $scope.focusData = $scope.currentSelection[id]


    $scope.$watch(
        () =>
            return Object.keys(Options.getOptions())
        (newval, oldval) ->
            $scope.pages = Object.keys(Options.getOptions())
        true
    )

    $scope.$on 'Webvis:Mode:updated', (event, data) =>
        $rootScope.$broadcast 'FileLoader:GetArenaGame'

    $scope.$watch(
        () =>
            if Game.getCurrentSelection()?
                return Object.keys(Game.getCurrentSelection())
            else
                return {}
        (newval, oldval) ->
            if Game.getCurrentSelection()?
                $scope.currentSelection = Game.getCurrentSelection()
                if Object.keys(Game.getCurrentSelection()).length > 0
                    firstid = Object.keys(Game.getCurrentSelection())[0]
                    $scope.focusData = $scope.currentSelection[firstid]
            else
                $scope.currentSelection = {}
        true
    )

TabmenuCtrl.$inject = ['$rootScope', '$scope', 'Game', 'FileLoader', 'Options']
webvisApp = angular.module 'webvisApp'
webvisApp.controller 'TabmenuCtrl', TabmenuCtrl