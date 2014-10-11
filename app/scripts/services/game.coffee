'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game', ($rootScope, $log, Parser) ->
    @minTurn = 0
    @maxTurn = 0
    @playing = false
    @currentTurn = 0
    @playbackSpeed = 1

    @entities = null

    @plugin = null

    @getCurrentTurn = () -> @currentTurn

    @getPlaybackSpeed = () -> @playbackSpeed

    @getEntities = () -> @entities

    @setPlugin = (plugin) ->
        @plugin = plugin

    @setTurn = (turnNum) ->
        @currentTurn = turnNum

    @fileLoaded = (logfile) ->
        if not @plugin?
            $log.error "Game doesn't have a plugin!"
            return

        gameLog = Parser.SexpParser.parse logfile
        @maxTurn = gameLog.turns.length

        entities = _(@plugin.processLog gamelog)

    return this
