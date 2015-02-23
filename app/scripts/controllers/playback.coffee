'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:PlaybackCtrl
 # @description
 # # PlaybackCtrl
 # Controller of the webvisApp
###
webvisApp = angular.module('webvisApp')

webvisApp.controller 'PlaybackCtrl', ($scope, $log, Game) ->
    @currentTurn = Game.getCurrentTurn()
    @maxTurn = Game.getMaxTurn()
    @minTurn = Game.getMinTurn()


    $scope.$on 'currentTurn:updated', (event, data) =>
        console.log "recieved " + data
        if !$scope.$$phase
            @currentTurn = data
            $scope.$apply()

    $scope.$on 'maxTurn:updated', (event, data) =>
        console.log "recieved maxTurn = " + data
        if !$scope.$$phase
            @maxTurn = data
            $scope.$apply()

    $scope.$watch 'playback.currentTurn', (newValue) =>
        if angular.isDefined(newValue) and newValue != Game.getCurrentTurn()
            console.log "changed " + newValue
            Game.setCurrentTurn newValue

    @stepBack = ->
        if Game.getCurrentTurn() > Game.getMinTurn()
            Game.setCurrentTurn(Game.getCurrentTurn() - 1)
        else
            Game.setCurrentTurn(Game.getMinTurn())

    @stepForward = ->
        if Game.getCurrentTurn() < Game.getMaxTurn()
            Game.setCurrentTurn(Game.getCurrentTurn() + 1)
        else
            Game.setCurrentTurn(Game.getMaxTurn())

    @playPause = ->
        $log.info "Play/Pause Pressed"
        Game.playing = not Game.playing
        if(Game.isPlaying())
            lastAnimate = new Date()
            Game.lastAnimateTime = lastAnimate.getTime()

    @fullscreen = ->

    return this
