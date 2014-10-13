'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.controller 'NavbarCtrl', (config, Plugin) ->
    @version = config.version
    @gameName = Plugin.getName()
    return this
