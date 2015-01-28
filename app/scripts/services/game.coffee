'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game', ($rootScope, $log, Parser, Plugin, Renderer) ->
    @minTurn = 0
    @maxTurn = 0
    @playing = false
    @currentTurn = 0
    @playbackSpeed = 1
    @renderer = null
    @gameLoaded = false
    @turnProgress = 0

    @getCurrentTurn = () -> @currentTurn

    @getMaxTurn = () -> @maxTurn

    @getMinTurn = () -> @minTurn

    @getPlaybackSpeed = () -> @playbackSpeed

    @getEntities = () -> Plugin.entities

    @setCurrentTurn = (t) ->
        if t != @currentTurn
            console.log "change " + t
            $rootScope.$broadcast('currentTurn:updated', t)

        @currentTurn = t

    @setMaxTurns = (maxTurn) ->
        if maxTurn != @maxTurn
            console.log "change max turn " + maxTurn
            $rootScope.$broadcast('maxTurn:updated', maxTurn)

        @maxTurn = maxTurn

    @setMinTurns = (minTurn) ->
        @minTurn = minTurn

    @createRenderer = (canvas) ->
        @renderer = new Renderer.CanvasRenderer(canvas, 20, 20)
        col = new Renderer.Color(1, 1, 1, 1)
        console.log "yo"
        @renderer.setClearColor(col)
        @renderer.begin()

    @canvasResized = (newWidth, newHeight) ->
        if @renderer?
            requestAnimationFrame @animate

    @isPlaying = () -> @playing

    @start = () ->
        lastAnimate = new Date()
        @lastAnimateTime = lastAnimate.getTime()
        requestAnimationFrame @animate

    @animate = () =>
        requestAnimationFrame @animate

        if @isPlaying()
            @updateTime()

        if @renderer != null
            @renderer.begin()

            if @gameLoaded
                entities = @getEntities()

                # console.log @getCurrentTurn() + " " + @turnProgress

                Plugin.preDraw(@renderer)
                for id, entity of entities
                    entity.draw @renderer, @getCurrentTurn(), @turnProgress
                Plugin.postDraw(@renderer)

    @updateTime = () =>
        currentDate = new Date()
        currentTime = currentDate.getTime()
        curTurn = @getCurrentTurn() + @turnProgress
        dtSeconds = (currentTime - @lastAnimateTime)/1000

        curTurn += @getPlaybackSpeed() * dtSeconds
        @setCurrentTurn(window.parseInt(curTurn))

        @turnProgress = curTurn - @getCurrentTurn()
        @lastAnimateTime = currentTime

    @fileLoaded = (gameData) =>
        data = Parser.SexpParser.parse gameData, Plugin.getSexpScheme()
        Plugin.loadGame data

        @renderer.resizeWorld Plugin.getMapWidth(), Plugin.getMapHeight()

        @currentTurn = 0
        @playing = false

        @setMaxTurns(Plugin.getMaxTurn())
        @gameLoaded = true

        requestAnimationFrame @animate

    return this
