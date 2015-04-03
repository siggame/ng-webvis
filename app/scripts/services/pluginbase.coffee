'use strict'

###*
 # @ngdoc service
 # @name webvisApp.PluginBase
 # @description
 # # PluginBase
 # Factory in the webvisApp.
###
webvisApp = angular.module('webvisApp')

webvisApp.factory 'PluginBase', ($log) ->

    class PluginError
        constructor: (@msg) ->

    class BaseEntity
        constructor: () ->

        getAnimations: () ->
            throw new PluginError("getAnimations not implemented")

        draw: (renderer, turnNum, turnProgress) ->
            animations = _(@getAnimations())
            animations.each (anim) ->
                if anim.getStartTurn() < turnNum + turnProgress and
                    anim.getEndTurn() > turnNum + turnProgress
                        $log.info "anim being called"
                        anim.animate renderer, turnNum, turnProgress


    class Animation
        constructor: (@startTurn, @endTurn, @animate) ->

        getStartTurn: () -> @startTurn

        getEndTurn: () -> @endTurn

        animate: (renderer, turn, progress) ->
            throw new PluginError("animate not implemented")

    class BasePlugin
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

        getName: () ->
            throw new PluginError("getName not implemented")

        preDraw: (delta, renderer) ->
            throw new PluginError("preDraw not implemented")

        postDraw: (delta, renderer) ->
            throw new PluginError("postDraw not implemented")

        resize: (renderer) ->
            throw new PluginError("resize not implemented")

        loadGame: (gamedata, renderer) ->
            throw new PluginError("loadGame not implemented")

        getSexpScheme: () ->
            throw new PluginError("getSexpScheme not implemented")

    return {
        BaseEntity: BaseEntity
        Animation: Animation
        BasePlugin: BasePlugin
    }
