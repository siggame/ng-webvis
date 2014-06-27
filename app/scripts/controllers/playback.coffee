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

    @isPlaying = -> @playing

    @stepBack = ->
        $scope.currentTurn -= 1
        $log.debug "Stepping back to #{$scope.currentTurn}"

    @stepForward = ->
        $scope.currentTurn += 1
        $log.debug "Stepping forward to #{$scope.currentTurn}"

    @playPause = ->
        if @playing
            $log.debug "Pausing"
        else
            $log.debug "Playing"
        @playing = not @playing

    return this
