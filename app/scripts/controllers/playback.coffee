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
    @isFullscreen = false

    $scope.$on 'currentTurn:updated', (event, data) =>
        if !$scope.$$phase
            @currentTurn = data
            $scope.$apply()

    $scope.$on 'maxTurn:updated', (event, data) =>
        if !$scope.$$phase
            @maxTurn = data
            $scope.$apply()

    $scope.$watch 'playback.currentTurn', (newValue) =>
        if angular.isDefined(newValue) and newValue != Game.getCurrentTurn()
            Game.setCurrentTurn newValue

    @isPlaying = -> Game.isPlaying()

    @stepBack = ->
        if Game.getCurrentTurn() > Game.getMinTurn()
            Game.setCurrentTurn(Game.getCurrentTurn() - 1)
            @currentTurn--
        else
            Game.setCurrentTurn(Game.getMinTurn())

    @stepForward = ->
        if Game.getCurrentTurn() < Game.getMaxTurn()
            Game.setCurrentTurn(Game.getCurrentTurn() + 1)
            @currentTurn++
        else
            Game.setCurrentTurn(Game.getMaxTurn())

    @playPause = ->
        $log.info "Play/Pause Pressed"
        Game.playing = not Game.playing
        if(Game.isPlaying())
            Game.start()

    @fullscreen = ->
        elem = document.getElementById "fullscreen-container";
        if(document.fullscreenElement ||
            document.webkitFullscreenElement ||
            document.mozFullScreenElement ||
            document.msFullscreenElement)
                if document.exitFullscreen
                    document.exitFullscreen()
                else if document.webkitExitFullscreen
                    document.webkitExitFullscreen()
                else if document.mozCancelFullScreen
                    document.mozCancelFullScreen()
                else if document.msExitFullscreen
                    document.msExitFullscreen()
        else
            if elem.requestFullscreen
                elem.requestFullscreen()
            else if elem.msRequestFullscreen
                elem.msRequestFullscreen()
            else if elem.mozRequestFullscreen
                elem.mozRequestFullscreen()
            else if elem.webkitRequestFullscreen
                elem.webkitRequestFullscreen()







    return this
