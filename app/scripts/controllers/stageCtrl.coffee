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
            Game.clickEvent(event)

        $scope.mouseup = (event) ->
            Game.mouseupEvent(event)

        $scope.mousedown = (event) ->
            Game.mousedownEvent(event)

        $scope.mousemove = (event) ->
            x = event.pageX
            y = event.pageY
            offset = $(event.target).offset()
            Game.inputManager._currentX = x - offset.left
            Game.inputManager._currentY = y - offset.top
            Game.mousemoveEvent(event)



    StageCtrl.$inject = ['$scope', 'Game']
    return StageCtrl

