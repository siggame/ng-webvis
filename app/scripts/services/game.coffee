'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game', ($rootScope, $log, PluginManager, Renderer) ->
    @minTurn = 0
    @maxTurn = 0
    @playing = false
    @currentTurn = 0
    @playbackSpeed = 1
    @renderer = null
    @turnProgress = 0
    window.requestAnimFrame = (callback) =>
        return window.setTimeout(callback, 1000 / 60);

    @getCurrentTurn = () -> @currentTurn

    @getMaxTurn = () -> @maxTurn

    @getMinTurn = () -> @minTurn

    @getPlaybackSpeed = () -> @playbackSpeed

    @setCurrentTurn = (t) ->
        if t != @currentTurn
            $rootScope.$broadcast('currentTurn:updated', t)

        @currentTurn = t

    @setMaxTurns = (maxTurn) ->
        if maxTurn != @maxTurn
            $rootScope.$broadcast('maxTurn:updated', maxTurn)

        @maxTurn = maxTurn

    @setMinTurns = (minTurn) ->
        @minTurn = minTurn

    @setPlaybackSpeed = (pb) ->
        @playbackSpeed = pb

    @createRenderer = (canvas) ->
        if PluginManager.isLoaded()
            @renderer = new Renderer.CanvasRenderer(canvas, PluginManager.getMapWidth(), PluginManager.getMapHeight())
        else
            @renderer = new Renderer.CanvasRenderer(canvas, 20, 20)

    @canvasResized = (newWidth, newHeight) ->
        if @renderer?
            requestAnimationFrame @animate

    @isPlaying = () -> @playing

    @start = () ->
        if pluginManager.isLoaded()
            lastAnimate = new Date()
            @lastAnimateTime = lastAnimate.getTime()
            requestAnimationFrame @animate
            @playing = true

    @animate = () =>
        requestAnimationFrame @animate
        dt = @updateTime()

        if @renderer != null
            @renderer.begin()

            if PluginManager.isLoaded()
                entities = PluginManager.getEntities()

                PluginManager.preDraw(dt, @renderer)
                for id, entity of entities
                    console.info "drawing " + id
                    entity.draw @renderer, @getCurrentTurn(), @turnProgress
                PluginManager.postDraw(dt, @renderer)

    @updateTime = () =>
        currentDate = new Date()
        currentTime = currentDate.getTime()
        curTurn = @getCurrentTurn() + @turnProgress
        dtSeconds = (currentTime - @lastAnimateTime)/1000

        if @isPlaying()
            curTurn += @getPlaybackSpeed() * dtSeconds
            @setCurrentTurn(window.parseInt(curTurn))
            @turnProgress = curTurn - @getCurrentTurn()

        @lastAnimateTime = currentTime
        return dtSeconds

    @fileLoaded = (gameObject) =>
        PluginManager.clear()
        PluginManager.changePlugin gameObject.gameName
        PluginManager.loadGame gameObject

        @renderer.resizeWorld PluginManager.getMapWidth(), PluginManager.getMapHeight()
        @currentTurn = 0
        @playing = false
        @setMaxTurns(PluginManager.getMaxTurn())

        @renderer.assetManager.loadTextures gameObject.gameName, () =>
            currentDate = new Date()
            @lastAnimateTime = currentDate.getTime()
            requestAnimationFrame @animate

    return this
