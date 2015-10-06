'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:StagectrlCtrl
 # @description
 # # StagectrlCtrl
 # Controller of the webvisApp
###

define [
    'scripts/services/game'
], ()->
    webvisApp = angular.module 'webvisApp'
    webvisApp.controller 'StageCtrl', ($scope, Game) ->
        $scope.click = (event) ->
            x = event.pageX
            y = event.pageY
            offset = $(event.target).offset()
            Game.updateSelection(x - offset.left, y - offset.top)
