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

        getAnimations: () ->
            throw new PluginError("getAnimations not implemented")

        draw: (turnNum, turnProgress) ->
            animations = _(@getAnimations())
            animations.each (anim) ->
                anim.animate turnNum, turnProgress


    class Animation
        constructor: () ->

        getStartTurn: () ->
            throw new PluginError("getStartTurn not implemented")

        getEndTurn: () ->
            throw new PluginError("getEndTurn not implemented")

        animate: (turn, progress) ->
            throw new PluginError("animate not implemented")


    class BasePlugin
        constructor: () ->

        getParserMethod: () ->
            throw new PluginError("getParsemethod not implemented")

        processLog: () ->
            throw new PluginError("processLog not implemented")

    return {
        BaseEntity: BaseEntity
        Animation: Animation
        BasePlugin: BasePlugin
    }
