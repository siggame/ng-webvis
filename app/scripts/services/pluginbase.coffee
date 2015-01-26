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

    class BasePlugin
        constructor: () ->

        getName: () ->
            throw new PluginError("getName not implemented")

        getMaxTurn: () ->
            throw new PluginError("getMaxTurns not implemented")

        getEntities: () ->
            throw new PluginError("getEntities not implemented")

        loadGame: (gamedata) ->
            throw new PluginError("parse not implemented")

        getSexpScheme: () ->
            throw new PluginError("getSexpScheme not implemented")

    return {
        BaseEntity: BaseEntity
        Animation: Animation
        BasePlugin: BasePlugin
    }
