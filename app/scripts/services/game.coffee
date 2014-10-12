'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game', ($rootScope, $log, Parser) ->
    @minTurn = 0
    @maxTurn = 0
    @playing = false
    @currentTurn = 0
    @playbackSpeed = 1
    @renderer = null

    @entities = null

    @plugin = null

    @getCurrentTurn = () -> @currentTurn

    @getPlaybackSpeed = () -> @playbackSpeed

    @getEntities = () -> @entities
    
    @isPlaying = () -> @playing

    @setPlugin = (plugin) ->
        @plugin = plugin

    @setTurn = (turnNum) ->
        @currentTurn = turnNum

    @start = () ->
        lastAnimate = new Date()
        @lastAnimateTime = lastAnimate.getTime
        requestAnimationFrame @animate
        
    @animate = () ->
        if Game.isPlaying()
            @updateTime
        entities = do @getEntities
        entities.each (entity) ->
            entity.draw @getCurrentTurn(), @turnProgress

        @turnProgress += @getPlaybackSpeed()
        requestAnimationFrame @animate
        
    @setRenderer = (element) ->
        @renderer = element
        
    @updateTime = () ->
        currentDate = new Date()
        currentTime = currentDate.getTime
        curTurn = @getCurrentTurn + @turnProgress
        dtSeconds = (currentTime - @lastAnimateTime)/1000
        curTurn += @getPlaybackSpeed * dtSeconds  
        Game.setTurn(window.parseInt(curTurn))
        turnProgress = curTurn - window.parseInt(curTurn)
        @lastAnimateTime = currentTime

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
