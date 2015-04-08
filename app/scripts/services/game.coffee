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
            @animate()

        if PluginManager.isLoaded()
            PluginManager.resize(@renderer)

    @isPlaying = () -> @playing

    @start = () ->
        if PluginManager.isLoaded()
            lastAnimate = new Date()
            @lastAnimateTime = lastAnimate.getTime()
            @animate()
            @playing = true

    @stop = () ->
        @playing = false

    @animate = () =>
        dt = @updateTime()

        if @renderer != null
            console.log "start"
            @renderer.begin()

            if PluginManager.isLoaded() and @renderer.assetManager.isLoaded()
                entities = PluginManager.getEntities()
                queue = []

                PluginManager.preDraw(dt, @renderer)
                for id, entity of entities
                    queue.push [entity.draw, entity]
                @animRegulator(this, queue, dt)

    @animRegulator = (t, queue, dt) ->
        start = +new Date()
        loop
            end = +new Date()

            a = queue.shift()
            f = a[0]
            ent = a[1]
            f.call(ent, t.renderer, t.getCurrentTurn(), t.turnProgress)

            if queue.length > 0  and end - start < 10 then continue
            if queue.length > 0
                setTimeout(t.animRegulator, 2, t, queue, dt);
            else
                PluginManager.postDraw(dt, t.renderer)
                setTimeout(t.animate(), 10)
                console.log "end"
            break;

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
            @animate()

    return this
