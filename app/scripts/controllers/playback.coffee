'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:PlaybackCtrl
 # @description
 # # PlaybackCtrl
 # Controller of the webvisApp
###
webvisApp = angular.module('webvisApp')

webvisApp.controller 'PlaybackCtrl', ($scope, $log) ->
    @minTurn = 0
    @maxTurn = 150

    @playing = false
    @currentTurn = 0

    @isPlaying = -> @playing

    @stepBack = ->
        if @currentTurn > @minTurn
            @currentTurn -= 1
            $log.debug "Stepping back to turn #{@currentTurn}"
        else
            @currentTurn = @minTurn
            $log.debug "Remaining at turn #{@currentTurn}"

    @stepForward = ->
        if @currentTurn < @maxTurn
            @currentTurn += 1
            $log.debug "Stepping forward to turn #{@currentTurn}"
        else
            @currentTurn = @maxTurn
            $log.debug "Remaining at turn #{@currentTurn}"


    @playPause = ->
        @playing = not @playing

    return this
