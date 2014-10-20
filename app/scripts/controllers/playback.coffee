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
    @maxTurn = Game.maxTurn

    @isPlaying = -> Game.isPlaying()
    @getCurrentTurn = -> Game.getCurrentTurn()
    @getMaxTurn = -> Game.maxTurn

    @stepBack = ->
        if @currentTurn > Game.minTurn
            @currentTurn -= 1
            $log.debug "Stepping back to turn #{@currentTurn}"
        else
            @currentTurn = Game.minTurn
            $log.debug "Remaining at turn #{@currentTurn}"

    @stepForward = ->
        if @currentTurn < Game.maxTurn
            @currentTurn += 1
            $log.debug "Stepping forward to turn #{@currentTurn}"
        else
            @currentTurn = Game.maxTurn
            $log.debug "Remaining at turn #{@currentTurn}"


    @playPause = ->
        $log.info "Play/Pause Pressed"
        Game.playing = not Game.playing
        if(Game.isPlaying())
            lastAnimate = new Date()
            Game.lastAnimateTime = lastAnimate.getTime()
        

    return this
