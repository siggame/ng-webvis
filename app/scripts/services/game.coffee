'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.service 'Game', ($rootScope, $log, Plugin) ->
    class GameStage extends PIXI.Stage
        constructor: (backgroundColor) ->
            super(backgroundColor)
        
        addChild: (child) =>
            if child.parent
                child.parent.removeChild child
                
            child.parent = this
            
            if this.stage
                child.setStageReference this.Stage
        
            if(@children.length == 0)
                @children.push child
            else
                index = 0
                while index < @children.length and 
                    child.zOrder < @children[index].zOrder
                        index++
                @children.splice(index, 0, child)
                    
        addChildAt: (child) ->
            throw {Error: "Not aloud to add a child without z ordering"}

        swapChildren: (child, child2) ->
            throw {Error: "Children must be sorted by z order"}
            
        _renderWebGL: (renderSession) ->
            super(renderSession)
            
        _renderCanvas: (renderSession) ->
            super(renderSession)
            

    @minTurn = 0
    @maxTurn = 0
    @playing = false
    @currentTurn = 0
    @playbackSpeed = 1
    @renderer = null
    @stage = null
    @turnProgress = 0

    @getCurrentTurn = () -> @currentTurn

    @getPlaybackSpeed = () -> @playbackSpeed

    @getEntities = () -> Plugin.entities
    
    @getWidth = () -> @renderer.width

    @getHeight = () -> @renderer.height

    @rendererResized = () =>
        if @renderer != null
            worldMat = new PIXI.Matrix
            worldMat.a = @renderer.width/Plugin.getWorldWidth()
            worldMat.b = 0;
            worldMat.c = 0;
            worldMat.d = @renderer.height/Plugin.getWorldHeight()
            worldMat.tx = 0;
            worldMat.ty = 0;
            @stage.worldTransform = worldMat;

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
        for id, entity of entities
            entity.draw @getCurrentTurn(), @turnProgress
            
        if @stage then @renderer.render @stage

    @setRenderer = (element) ->
        @renderer = element


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
        
        @stage = new GameStage(0x66FF99)
        
        @rendererResized()
        
        @entities = _(Plugin.getEntities gameLog)
        
        @entities.each (entity) =>
            @stage.addChild entity.getSprite()

    return this
