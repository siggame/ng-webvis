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
    
    @preDraw = (renderer) -> 
        if @currentPlugin != null
            @currentPlugin.preDraw(renderer)
        else
            throw PluginError("No plugin selected")
            
    @getEntities = () -> 
        if @currentPlugin != null
            @currentPlugin.getEntities()
        else
            throw PluginError("No plugin selected")
            
    @postDraw = (renderer) -> 
        if @currentPlugin != null
            @currentPlugin.postDraw(renderer)
        else
            throw PluginError("No plugin selected")
            
    @loadGame = (gamedata) -> 
        if @currentPlugin != null
            @currentPlugin.loadGame(gamedata)
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