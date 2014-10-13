'use strict'

###*
 # @ngdoc service
 # @name webvisApp.PluginBase
 # @description
 # # PluginBase
 # Factory in the webvisApp.
###
webvisApp = angular.module('webvisApp')

webvisApp.factory 'PluginBase', ->

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
                anim.animate turnNum, turnProgress


    class Animation
        constructor: (@startTurn, @endTurn, @animate) ->

        getStartTurn: () -> @startTurn

        getEndTurn: () -> @endTurn

        animate: (turn, progress) ->
            throw new PluginError("animate not implemented")


    class BasePlugin
        constructor: () ->

        getName: () ->
            throw new PluginError("getName not implemented")

        getMaxTurn: () ->
            throw new PluginError("getMaxTurns not implemented")

        getEntities: (gameLog) ->
            throw new PluginError("getEntities not implemented")

        parse: (logFile) ->
            throw new PluginError("parse not implemented")


    return {
        BaseEntity: BaseEntity
        Animation: Animation
        BasePlugin: BasePlugin
    }
