'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:StagectrlCtrl
 # @description
 # # StagectrlCtrl
 # Controller of the webvisApp
###

define ()->
    StageCtrl = ($scope, Game) ->
        $scope.click = (event) ->
            x = event.pageX
            y = event.pageY
            offset = $(event.target).offset()
            Game.updateSelection(x - offset.left, y - offset.top)
    StageCtrl.$inject = ['$scope', 'Game']
    return StageCtrl

