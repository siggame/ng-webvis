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

        getName: () ->
            throw new PluginError("getName not implemented")

        getMaxTurn: () ->
            throw new PluginError("getMaxTurns not implemented")

        getMapWidth: () ->
            throw new PluginError("getMapWidth not implemented")

        getMapHeight: () ->
            throw new PluginError("getMapHeight not implemented")

        preDraw: (renderer) ->
            throw new PluginError("preDraw not implemented")

        getEntities: () ->
            throw new PluginError("getEntities not implemented")

        postDraw: (renderer) ->
            throw new PluginError("postDraw not implemented")

        loadGame: (gamedata) ->
            throw new PluginError("loadGame not implemented")

        isLoaded: ->
            throw new PluginError("isLoaded not implemented")

        getSexpScheme: () ->
            throw new PluginError("getSexpScheme not implemented")

    return {
        BaseEntity: BaseEntity
        Animation: Animation
        BasePlugin: BasePlugin
    }
