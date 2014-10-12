'use strict'

###*
 # @ngdoc service
 # @name webvisApp.droids
 # @description
 # # droids
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')
webvisApp.service 'Plugin', (PluginBase)->

    class Droids extends PluginBase.BasePlugin

        getName: () -> "Droids"

    return new Droids
