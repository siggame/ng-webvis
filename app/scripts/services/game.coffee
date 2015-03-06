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
        console.log "creating a renderer"
        if PluginManager.isLoaded()
            @renderer = new Renderer.CanvasRenderer(canvas, PluginManager.getMapWidth(), PluginManager.getMapHeight())
        else
            @renderer = new Renderer.CanvasRenderer(canvas, 20, 20)
        col = new Renderer.Color(1, 1, 1, 1)
        @renderer.assetManager.loadTextures ()=>
            requestAnimationFrame @animate
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
        @playing = true

    @animate = () =>
        if @isPlaying()
            console.log "yo"
            requestAnimationFrame @animate
            @updateTime()

        if @renderer != null
            @renderer.begin()

            if PluginManager.isLoaded()
                entities = PluginManager.getEntities()

                # console.log @getCurrentTurn() + " " + @turnProgress

                PluginManager.preDraw(@renderer)
                for id, entity of entities
                    console.info "drawing " + id
                    entity.draw @renderer, @getCurrentTurn(), @turnProgress
                PluginManager.postDraw(@renderer)

    @updateTime = () =>
        currentDate = new Date()
        currentTime = currentDate.getTime()
        curTurn = @getCurrentTurn() + @turnProgress
        dtSeconds = (currentTime - @lastAnimateTime)/1000

        curTurn += @getPlaybackSpeed() * dtSeconds
        @setCurrentTurn(window.parseInt(curTurn))

        @turnProgress = curTurn - @getCurrentTurn()
        @lastAnimateTime = currentTime

    @fileLoaded = (gameObject) =>
        PluginManager.changePlugin gameObject.gameName
        PluginManager.loadGame gameObject

        @renderer.resizeWorld PluginManager.getMapWidth(), PluginManager.getMapHeight()

        @currentTurn = 0
        @playing = false

        @setMaxTurns(PluginManager.getMaxTurn())

        requestAnimationFrame @animate

    return this
