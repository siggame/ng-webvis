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

    @entities = _([])

    @getCurrentTurn = () -> @currentTurn

    @getPlaybackSpeed = () -> @playbackSpeed

    @getEntities = () -> @entities

    @isPlaying = () -> @playing

    @setTurn = (turnNum) ->
        @currentTurn = turnNum

    @start = () ->
        lastAnimate = new Date()
        @lastAnimateTime = lastAnimate.getTime
        requestAnimationFrame @animate

    @animate = () =>
        requestAnimationFrame @animate

        if @isPlaying()
            @updateTime
        entities = @getEntities()
        entities.each (entity) =>
            entity.draw @getCurrentTurn(), @turnProgress

        @turnProgress += @getPlaybackSpeed()

        if @stage then @renderer.render @stage

    @setRenderer = (element) ->
        @renderer = element

    @updateTime = () =>
        currentDate = new Date()
        currentTime = currentDate.getTime
        curTurn = @getCurrentTurn + @turnProgress
        dtSeconds = (currentTime - @lastAnimateTime)/1000
        curTurn += @getPlaybackSpeed * dtSeconds
        Game.setTurn(window.parseInt(curTurn))
        turnProgress = curTurn - window.parseInt(curTurn)
        @lastAnimateTime = currentTime

    @fileLoaded = (logfile) =>
        gameLog = Plugin.parse logfile
        @currentTurn = 0
        @playing = false

        @maxTurn = _(Plugin.getEntities gameLog)

        @stage = new PIXI.Stage(0x66FF99)
        @entities = _(Plugin.getEntities gameLog)
        @entities.each (entity) =>
            @stage.addChild entity.getSprite()

    return this
