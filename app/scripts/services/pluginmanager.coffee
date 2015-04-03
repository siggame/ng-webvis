'use strict'

###*
 # @ngdoc service
 # @name webvisApp.PluginManager
 # @description
 # # PluginManager
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')

webvisApp.service 'PluginManager', ($rootScope, $injector) ->
    class PluginError
        constructor: (@msg) ->

    @currentPlugin = null

    @changePlugin = (plugin) ->
        if $injector.has plugin
            @currentPlugin = $injector.get plugin
            $rootScope.$broadcast('currentPlugin:updated')
        else
            @currentPlugin = null

    @getName = () ->
        if @currentPlugin != null
            @currentPlugin.getName()
        else
            return "WebVis"

    @getMaxTurn = () ->
        if @currentPlugin != null
            @currentPlugin.getMaxTurn()
        else
            throw PluginError("No plugin selected")

    @getMapWidth = () ->
        if @currentPlugin != null
            @currentPlugin.getMapWidth()
        else
            throw PluginError("No plugin selected")

    @getMapHeight = () ->
        if @currentPlugin != null
            @currentPlugin.getMapHeight()
        else
            throw PluginError("No plugin selected")

    @preDraw = (delta, renderer) ->
        if @currentPlugin != null
            @currentPlugin.preDraw(delta, renderer)
        else
            throw PluginError("No plugin selected")

    @getEntities = () ->
        if @currentPlugin != null
            @currentPlugin.getEntities()
        else
            throw PluginError("No plugin selected")

    @postDraw = (delta, renderer) ->
        if @currentPlugin != null
            @currentPlugin.postDraw(delta, renderer)
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
            return true;
        else
            false

    @getSexpScheme = () ->
        if @currentPlugin != null
            @currentPlugin.getSexpScheme()
        else
            throw PluginError("No plugin selected")

    return this
