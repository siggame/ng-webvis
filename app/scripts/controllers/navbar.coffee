'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.controller 'NavbarCtrl', (config) ->
    @version = config.version
    return this
