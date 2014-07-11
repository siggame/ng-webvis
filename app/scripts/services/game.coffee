'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game',() ->
    @minTurn = 0
    @maxTurn = 150
    @playing = false
    @currentTurn = 0

    @getTurn = () -> @currentTurn
    @setTurn = (val) -> @currentTurn = val

    @isPlaying = () -> @playing

    return this
