'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game', ($rootScope, $log, Plugin) ->
    @minTurn = 0
    @maxTurn = 0
    @playing = false
    @currentTurn = 0
    @playbackSpeed = 1
    @renderer = null
    @stage = null
    @turnProgress = 0

    @entities = _([])

    @getCurrentTurn = () -> @currentTurn

    @getPlaybackSpeed = () -> @playbackSpeed

    @getEntities = () -> @entities

    @getWidth = () -> @stage.width

    @getHeight = () -> @stage.height

    @isPlaying = () -> @playing

    @setTurn = (turnNum) ->
        @currentTurn = turnNum

    @setMaxTurns = (maxTurn) ->
        @maxTurn = maxTurn

    @start = () ->
        lastAnimate = new Date()
        @lastAnimateTime = lastAnimate.getTime()
        requestAnimationFrame @animate

    @animate = () =>
        requestAnimationFrame @animate

        if @isPlaying()
            @updateTime()

        entities = @getEntities()
        entities.each (entity) =>
            entity.draw @getCurrentTurn(), @turnProgress

        if @stage then @renderer.render @stage

    @setRenderer = (element) ->
        @renderer = element

    @updateTime = () =>
        currentDate = new Date()
        currentTime = currentDate.getTime()
        curTurn = @getCurrentTurn() + @turnProgress
        $log.info "#{@getCurrentTurn()} and #{@turnProgress}"
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

        @stage = new PIXI.Stage(0x66FF99)
        Plugin.setDimensions @stage.width, @stage.height
        @entities = _(Plugin.getEntities gameLog)

        @entities.each (entity) =>
            @stage.addChild entity.getSprite()

    return this
