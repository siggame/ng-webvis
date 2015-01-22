'use strict'

###*
 # @ngdoc service
 # @name webvisApp.droids
 # @description
 # # droids
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')
webvisApp.service 'Plugin', (PluginBase, Renderer)->

    class Droids extends PluginBase.BasePlugin

        getName: () -> "Droids"

        getEntities: () ->

        parse: (logFile) ->
            throw new P

    return new Droids
