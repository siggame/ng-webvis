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

        getSprite: () ->
            throw new PluginError("getSprite not implemented")

        getAnimations: () ->
            throw new PluginError("getAnimations not implemented")

        draw: (turnNum, turnProgress) ->
            animations = _(@getAnimations())
            animations.each (anim) ->
                if anim.getStartTurn() < turnNum + turnProgress and 
                    anim.getEndTurn() > turnNum + turnProgress
                        $log.info "anim being called"
                        anim.animate turnNum, turnProgress


    class Animation
        constructor: (@startTurn, @endTurn, @animate) ->

        getStartTurn: () -> @startTurn

        getEndTurn: () -> @endTurn

        animate: (turn, progress) ->
            throw new PluginError("animate not implemented")

    class Sprite extends PIXI.Sprite
        constructor: (texture) ->
            super(texture)
            @zOrder = 0
            
    class TilingSprite extends PIXI.TilingSprite
        constructor: (texture) ->
            super(texture)
            @zOrder = 0

    class BasePlugin
        constructor: () ->

        getName: () ->
            throw new PluginError("getName not implemented")

        getMaxTurn: () ->
            throw new PluginError("getMaxTurns not implemented")

        getEntities: (gameLog) ->
            throw new PluginError("getEntities not implemented")
            
        getZOrder: () ->
            throw new PluginError("getZOrder not implemented")

        parse: (logFile) ->
            throw new PluginError("parse not implemented")


    return {
        BaseEntity: BaseEntity
        Animation: Animation
        Sprite: Sprite
        TilingSprite: TilingSprite
        BasePlugin: BasePlugin
    }
