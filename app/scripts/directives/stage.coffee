'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:Stage
 # @description
 # # Stage
###
webvisApp = angular.module('webvisApp')

webvisApp.directive 'stage', ($log, Game) ->
    template: ''
    restrict: 'E'
    link: (scope, element, attrs) ->
        width = attrs['width']
        height = attrs['height']

        renderer = PIXI.autoDetectRenderer(width, height)
        element.append renderer.view

        Game.setRenderer renderer
        Game.start()
