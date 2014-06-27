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
    @playing = false
    @currentTurn = 20

    @isPlaying = -> @playing

    @stepBack = ->
        @currentTurn -= 1
        $log.debug "Stepping back to turn #{@currentTurn}"

    @stepForward = ->
        @currentTurn += 1
        $log.debug "Stepping forward to turn #{@currentTurn}"

    @playPause = ->
        @playing = not @playing

    return this
