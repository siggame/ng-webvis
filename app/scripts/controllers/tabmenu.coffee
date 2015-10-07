'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:TabmenuCtrl
 # @description
 # # TabmenuCtrl
 # Controller of the webvisApp
###

define ()->
    TabmenuCtrl = ($scope, Game, FileLoader, Options) ->
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

        $scope.$on 'Webvis:Mode:updated', (event, data) ->
            url = Options.get 'Webvis', 'Arena Url'
            FileLoader.loadFromUrl(url.text + "/api/next_game")

        $scope.$on 'selection:updated', (event, data) ->
            $scope.currentSelection = Game.getCurrentSelection()

        $scope.$on 'currentTurn:updated', (event, data) ->
            $scope.currentSelection = Game.getCurrentSelection()
            if !$scope.currentSelection[$scope.focusData.id]?
                $scope.focusData = {}
            else
                $scope.focusData = $scope.currentSelection[$scope.focusData.id]

    TabmenuCtrl.$inject = ['$scope', 'Game', 'FileLoader', 'Options']
    return TabmenuCtrl