'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:PlaybackCtrl
 # @description
 # # PlaybackCtrl
 # Controller of the webvisApp
###

define [
    'scripts/services/game'
], ()->
    PlaybackCtrl = ($scope, $log, Game) ->
        $scope.currentTurn = Game.getCurrentTurn()
        $scope.maxTurn = Game.getMaxTurn()
        $scope.minTurn = Game.getMinTurn()
        $scope.isFullscreen = false
        $scope.timeDt = Game.getPlaybackSpeed() * 4

        $scope.$on 'currentTurn:updated', (event, data) =>
            if !$scope.$$phase
                $scope.currentTurn = data
                $scope.$apply()

        $scope.$on 'maxTurn:updated', (event, data) =>
            if !$scope.$$phase
                $scope.maxTurn = data
                $scope.$apply()

        $scope.$watch(
            ()=>
                return Game.getMaxTurn()
            (newval, oldval)->

                $scope.maxTurn = Game.getMaxTurn()
                console.log "updating max turn in playback bar." + $scope.maxTurn
        )

        $scope.$watch 'currentTurn', (newValue) ->
            console.log "current time changed"
            if angular.isDefined(newValue) and newValue != Game.getCurrentTurn()
                Game.setCurrentTurn newValue

        $scope.$watch 'playback.timeDt', (newValue) ->
            if angular.isDefined(newValue) and newValue/4 != Game.getPlaybackSpeed()
                Game.setPlaybackSpeed newValue/4

        $scope.isPlaying = -> Game.isPlaying()

        $scope.stepBack = ->
            if Game.getCurrentTurn() > Game.getMinTurn()
                Game.setCurrentTurn(Game.getCurrentTurn() - 1)
                $scope.currentTurn--
            else
                Game.setCurrentTurn(Game.getMinTurn())

        $scope.stepForward = ->
            console.log "forward pressed"
            if Game.getCurrentTurn() < Game.getMaxTurn()
                Game.setCurrentTurn(Game.getCurrentTurn() + 1)
                $scope.currentTurn++
            else
                Game.setCurrentTurn(Game.getMaxTurn())

        $scope.playPause = ->
            $log.info "Play/Pause Pressed"
            if(!Game.isPlaying())
                Game.start()
            else
                Game.stop()

        $scope.fullscreen = ->
            elem = document.getElementById "fullscreen-container"
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

    PlaybackCtrl.$inject = ['$scope', '$log', 'Game']
    return PlaybackCtrl
