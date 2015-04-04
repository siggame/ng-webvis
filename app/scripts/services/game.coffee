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
        console.log "meh"
        return window.setTimeout(callback, 1000 / 30);

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
        if @renderer?
            requestAnimationFrame @animate

        if PluginManager.isLoaded()
            PluginManager.resize(@renderer)

    @isPlaying = () -> @playing

    @start = () ->
        if PluginManager.isLoaded()
            lastAnimate = new Date()
            @lastAnimateTime = lastAnimate.getTime()
            requestAnimationFrame @animate
            @playing = true

    @stop = () ->
        @playing = false

    @animate = () =>
        dt = @updateTime()

        if @renderer != null
            currentDate = new Date()
            currentTime = currentDate.getTime()
            @renderer.begin()

            if PluginManager.isLoaded()
                entities = PluginManager.getEntities()

                PluginManager.preDraw(dt, @renderer)
                for id, entity of entities
                    #console.info "drawing " + id
                    entity.draw @renderer, @getCurrentTurn(), @turnProgress
                PluginManager.postDraw(dt, @renderer)
            currentDate = new Date()
            #console.log dt
            #console.log currentDate.getTime() - currentTime
        requestAnimationFrame @animate

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
            requestAnimationFrame @animate

    return this
