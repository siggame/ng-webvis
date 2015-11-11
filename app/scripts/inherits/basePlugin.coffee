'use strict'

###*
 # @ngdoc service
 # @name webvisApp.PluginBase
 # @description
 # # PluginBase
###

define () ->
    class PluginError
        constructor: (@msg) ->

    class Entity
        constructor: () ->

        getAnimations: () ->
            throw new PluginError("getAnimations not implemented")

        draw: (renderer, turnNum, turnProgress) =>
            @animPlayed = false
            for anim in @getAnimations()
                if anim.getStartTurn() <= turnNum + turnProgress and
                    anim.getEndTurn() > turnNum + turnProgress
                        @animPlayed = true
                        anim.animate renderer, turnNum, turnProgress
            if @animPlayed == false
                @idle(renderer, turnNum, turnProgress)

        idle: (renderer, turnNum, turnProgress) ->
            throw new PluginError("idle not implemented")


    class Animation
        constructor: (@startTurn, @endTurn, @animate) ->

        getStartTurn: () -> @startTurn

        getEndTurn: () -> @endTurn

        animate: (renderer, turn, progress) ->
            throw new PluginError("animate not implemented")

    class Plugin
        constructor: () ->
            @entities = {}
            @maxTurn = 0
            @mapWidth = 0
            @mapHeight = 0

        getMaxTurn: () -> @maxTurn

        getMapWidth: () -> @mapWidth

        getMapHeight: () -> @mapHeight

        getEntities: () -> @entities

        clear: () ->
            @entities = {}
            @maxTurn = 0
            @mapWidth = 0
            @mapheight = 0

        selectEntities: (renderer, turn, x, y) ->
            throw new PluginError("selectEntities not implemented")

        verifyEntities: (renderer, turn, selection) ->
            throw new PluginError("verifyEntities not implemented")

        getName: () ->
            throw new PluginError("getName not implemented")

        preDraw: (turn, delta, renderer) ->
            throw new PluginError("preDraw not implemented")

        postDraw: (turn, delta, renderer) ->
            throw new PluginError("postDraw not implemented")

        resize: (renderer) ->
            throw new PluginError("resize not implemented")

        loadGame: (gamedata, renderer, inputManager) ->
            throw new PluginError("loadGame not implemented")

        getSexpScheme: () ->
            throw new PluginError("getSexpScheme not implemented")

    return {
        Entity: Entity
        Animation: Animation
        Plugin: Plugin
    }
