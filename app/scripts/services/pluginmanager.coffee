'use strict'

###*
 # @ngdoc service
 # @name webvisApp.PluginManager
 # @description
 # # PluginManager
 # Service in the webvisApp.
###

define ()->
    webvisApp = angular.module('webvisApp')
    webvisApp.service 'PluginManager', ($rootScope) ->
        class PluginError
            constructor: (@msg) ->

        @pluginConstructors = {};
        @currentPlugin = null

        @changePlugin = (plugin, success) ->
            if @pluginConstructors[plugin]?
                @currentPlugin = new @pluginConstructors[plugin]
                success()
            else
                require([
                    'plugins/' + plugin + '/' + plugin
                    ]
                    (newplugin) =>
                        @pluginConstructors[plugin] = newplugin
                        @currentPlugin = new newplugin()
                        success()
                    (err) =>
                        throw PluginError("The plugin '"+plugin +"' could not be found")
                )

        @selectEntities = (renderer, turn, x, y) ->
            if @currentPlugin != null
                return @currentPlugin.selectEntities(renderer, turn, x, y)
            else
                throw PluginError("No plugin selected")

        @verifyEntities = (renderer, turn, selection) ->
            if @currentPlugin != null
                return @currentPlugin.verifyEntities(renderer, turn, selection)
            else
                throw PluginError("No plugin selected")

        @getName = () ->
            if @currentPlugin != null
                return @currentPlugin.getName()
            else
                return "WebVis"

        @getMaxTurn = () ->
            if @currentPlugin != null
                return @currentPlugin.getMaxTurn()
            else
                throw PluginError("No plugin selected")

        @getMapWidth = () ->
            if @currentPlugin != null
                return @currentPlugin.getMapWidth()
            else
                throw PluginError("No plugin selected")

        @getMapHeight = () ->
            if @currentPlugin != null
                return @currentPlugin.getMapHeight()
            else
                throw PluginError("No plugin selected")

        @preDraw = (turn, delta, renderer) ->
            if @currentPlugin != null
                @currentPlugin.preDraw(turn, delta, renderer)
            else
                throw PluginError("No plugin selected")

        @getEntities = () ->
            if @currentPlugin != null
                e = @currentPlugin.getEntities()
                return e
            else
                throw PluginError("No plugin selected")

        @postDraw = (turn, delta, renderer) ->
            if @currentPlugin != null
                @currentPlugin.postDraw(turn, delta, renderer)
            else
                throw PluginError("No plugin selected")

        @resize = (renderer) ->
            if @currentPlugin != null
                @currentPlugin.resize(renderer)
            else
                throw PluginError("No plugin selected")

        @loadGame = (gamedata, renderer) ->
            if @currentPlugin != null
                @currentPlugin.loadGame(gamedata, renderer)
            else
                throw PluginError("No plugin selected")

        @clear = () ->
            if @currentPlugin != null
                @currentPlugin.clear()

        @isLoaded = () ->
            if @currentPlugin != null
                return true
            else
                false

        @getSexpScheme = () ->
            if @currentPlugin != null
                @currentPlugin.getSexpScheme()
            else
                throw PluginError("No plugin selected")

        return this
