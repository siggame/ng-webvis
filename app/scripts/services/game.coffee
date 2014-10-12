'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game', ($rootScope, $log, Parser, Plugin) ->
    @minTurn = 0
    @maxTurn = 0
    @playing = false
    @currentTurn = 0
    @playbackSpeed = 1

    @entities = null

    @getCurrentTurn = () -> @currentTurn

    @getPlaybackSpeed = () -> @playbackSpeed

    @getEntities = () -> @entities

    @setTurn = (turnNum) ->
        @currentTurn = turnNum

    @fileLoaded = (logfile) ->
        if not @plugin?
            $log.error "Game doesn't have a plugin!"
            return

        parser = Parser[@plugin.getParserMethod()]
        if not parser?
            $log.error "Parser not provided"
            return

        gameLog = parser.parse logfile
        @currentTurn = 0
        @maxTurn = gameLog.turns.length
        @playing = false

        entities = _(@plugin.processLog gamelog)

    return this
