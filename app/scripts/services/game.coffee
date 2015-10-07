'use strict'

define ()->
    Game = ($rootScope, $log, PluginManager, Renderer, Options) ->
        @minTurn = 0
        @maxTurn = 0
        @playing = false
        @currentTurn = 0
        @playbackSpeed = 1
        @renderer = null
        @turnProgress = 0
        @lastRenderTime = new Date()
        @frames = 0
        @currentSelection = []

        @getCurrentTurn = () -> @currentTurn

        @getMaxTurn = () -> @maxTurn

        @getMinTurn = () -> @minTurn

        @getPlaybackSpeed = () -> @playbackSpeed

        @setCurrentTurn = (t) ->
            if t != @currentTurn
                @currentSelection = PluginManager.verifyEntities(@renderer,
                @getCurrentTurn(), @currentSelection)
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

        @updateSelection = (x, y) ->
            if PluginManager.isLoaded()
                @currentSelection = PluginManager.selectEntities(@renderer,
                @getCurrentTurn(), x, y)
                $rootScope.$broadcast('selection:updated')

        @getCurrentSelection = () -> @currentSelection

        @createRenderer = (canvas) ->
            #@renderer = new Renderer.CanvasRenderer(canvas, 100, 100)
            @renderer = Renderer.autoDetectRenderer(canvas, 100, 100)

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
                @frames = 0
                @lastRenderTime = now

            if @renderer != null
                @renderer.begin()

                if PluginManager.isLoaded() and @renderer.texturesLoaded()
                    entities = PluginManager.getEntities()

                    PluginManager.preDraw(@getCurrentTurn(), dt, @renderer)
                    for id, entity of entities
                        entity.draw @renderer, @getCurrentTurn(), @turnProgress
                    PluginManager.postDraw(@getCurrentTurn(), dt, @renderer)
                @renderer.end()
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
                    option = Options.get 'Webvis', 'Mode'
                    url = Options.get 'Webvis', 'Arena Url'
                    if option.currentValue == "arena"
                        setTimeout($rootScope.$broadcast, 3000,
                            'FileLoader:LoadFromUrl', url.text + "/api/next_game/")

            @lastAnimateTime = currentTime
            return dtSeconds

        @fileLoaded = (gameObject) =>
            PluginManager.loadGame gameObject, @renderer

            @currentTurn = 0
            @playing = false
            @setMaxTurns(PluginManager.getMaxTurn())

            @renderer.loadTextures gameObject.gameName, () =>
                currentDate = new Date()
                @lastAnimateTime = currentDate.getTime()

        window.requestAnimationFrame @animate
        return this

    Game.$inject =['$rootScope', '$log', 'PluginManager', 'Renderer', 'Options']
    return Game
