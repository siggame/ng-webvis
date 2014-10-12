'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:Stage
 # @description
 # # Stage
###
webvisApp = angular.module('webvisApp')

webvisApp.directive 'stage', ($log, Renderer) ->
    template: ''
    restrict: 'E'
    link: (scope, element, attrs) ->
        $log.info attrs
        width = attrs['width']
        height = attrs['height']

        renderer = PIXI.autoDetectRenderer(width, height)
        element.append renderer.view

        Renderer.setRenderer renderer
