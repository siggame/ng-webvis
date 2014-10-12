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
    @currentTurn = Game.currentTurn
    @maxTurn = Game.maxTurn

    @isPlaying = -> Game.playing
    @getCurrentTurn = -> Game.currentTurn
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
        Game.playing = not Game.playing
        

    return this
