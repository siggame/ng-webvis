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
    @maxTurn = Game.getMaxTurn()
    @minTurn = Game.getMinTurn()

    @isPlaying = -> Game.isPlaying()
    @getCurrentTurn = -> Game.getCurrentTurn()
    @getMaxTurn = -> Game.getMaxTurn()

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
        

    return this
