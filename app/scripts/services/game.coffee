'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game', ($rootScope, $log, Plugin, Renderer) ->      
    @minTurn = 0
    @maxTurn = 0
    @playing = false
    @currentTurn = 0
    @playbackSpeed = 1
    @renderer = null
    @gameLoaded = false
    @turnProgress = 0

    @getCurrentTurn = () -> @currentTurn
    
    @setCurrentTurn = (t) -> 
        @turnProgress = 0
        @currentTurn = t

    @getMaxTurn = () -> @maxTurn
    
    @getMinTurn = () -> @minTurn

    @getPlaybackSpeed = () -> @playbackSpeed

    @getEntities = () -> Plugin.entities

    @setTurn = (turnNum) ->
        @currentTurn = turnNum
        
    @setMaxTurns = (maxTurn) ->
        @maxTurn = maxTurn

    @setMinTurns = (minTurn) ->
        @minTurn = minTurn

    @createRenderer = (canvas) ->
        @renderer = new Renderer.CanvasRenderer(canvas, 20, 20)
        
    @isPlaying = () -> @playing

    @start = () ->
        lastAnimate = new Date()
        @lastAnimateTime = lastAnimate.getTime()
        requestAnimationFrame @animate

    @animate = () =>
        requestAnimationFrame @animate

        if @isPlaying() and @gameLoaded
            @updateTime()

        entities = @getEntities()
        for id, entity of entities
            entity.draw @getCurrentTurn(), @turnProgress

        if @gameLoaded and @renderer != null
            @renderer.draw()

    @updateTime = () =>
        currentDate = new Date()
        currentTime = currentDate.getTime()
        curTurn = @getCurrentTurn() + @turnProgress
        dtSeconds = (currentTime - @lastAnimateTime)/1000
        
        curTurn += @getPlaybackSpeed() * dtSeconds
        @setTurn(window.parseInt(curTurn))
        
        @turnProgress = curTurn - @getCurrentTurn()
        @lastAnimateTime = currentTime

    @fileLoaded = (logfile) =>
        gameLog = Plugin.parse logfile
        
        @currentTurn = 0
        @playing = false
        
        @setMaxTurns(gameLog.states.length)
        @gameLoaded = true

    return this
