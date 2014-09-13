'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game', ($log, Parser) ->
    @minTurn = 0
    @maxTurn = 0
    @playing = false
    @currentTurn = 0
    @gameLog = null

    @fileLoaded = (logfile) ->
        @gameLog = Parser.SexpParser.parse logfile
        @maxTurn = @gameLog.turns.length

    return this
