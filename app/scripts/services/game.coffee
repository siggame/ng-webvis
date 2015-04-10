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
    @lastRenderTime = new Date()
    @frames = 0

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
        @renderer = new Renderer.CanvasRenderer(canvas, 100, 100)

    @canvasResized = (newWidth, newHeight) ->
        if PluginManager.isLoaded()
            PluginManager.resize(@renderer)

    @isPlaying = () -> @playing

    @start = () ->
        if PluginManager.isLoaded()
            lastAnimate = new Date()
            @lastAnimateTime = lastAnimate.getTime()
            @playing = true

    @stop = () ->
        @playing = false

    @animate = () =>
        window.requestAnimationFrame(@animate)
        
        dt = @updateTime()
        now = new Date()
        if now - @lastRenderTime > 1000
            console.log "fps: " +  @frames
            @frames = 0
            @lastRenderTime = now

        if @renderer != null
            @renderer.begin()

            if PluginManager.isLoaded() and @renderer.assetManager.isLoaded()
                entities = PluginManager.getEntities()

                PluginManager.preDraw(dt, @renderer)
                for id, entity of entities
                    entity.draw @renderer, @getCurrentTurn(), @turnProgress
                PluginManager.postDraw(dt, @renderer)
        end = new Date()

        @frames++

    @updateTime = () =>
        currentDate = new Date()
        currentTime = currentDate.getTime()
        curTurn = @getCurrentTurn() + @turnProgress
        dtSeconds = (currentTime - @lastAnimateTime)/1000

        if @isPlaying()
            curTurn += @getPlaybackSpeed() * dtSeconds
            @setCurrentTurn(window.parseInt(curTurn))
            @turnProgress = curTurn - @getCurrentTurn()
            if curTurn >= PluginManager.getMaxTurn()
                @turnProgress = 0
                @stop()

        @lastAnimateTime = currentTime
        return dtSeconds

    @fileLoaded = (gameObject) =>
        PluginManager.clear()
        PluginManager.changePlugin gameObject.gameName
        PluginManager.loadGame gameObject, @renderer

        @currentTurn = 0
        @playing = false
        @setMaxTurns(PluginManager.getMaxTurn())

        @renderer.assetManager.loadTextures gameObject.gameName, () =>
            currentDate = new Date()
            @lastAnimateTime = currentDate.getTime()

    window.requestAnimationFrame @animate
    return this
