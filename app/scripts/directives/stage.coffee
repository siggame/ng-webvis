'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:Stage
 # @description
 # # Stage
###
webvisApp = angular.module('webvisApp')

webvisApp.directive 'stage', ($log, $window, Game) ->
    template: ''
    restrict: 'E'
    link: (scope, element, attrs) ->

        width = attrs['width']
        height = attrs['height']

        renderer = PIXI.autoDetectRenderer(width, height)
        element.append renderer.view

        resizeRendererView = () ->
            # Calculate new width and height
            # TODO: Don't hard-code height of playback controls
            window = $($window)

            newWidth = $(element).parent().width()

            oH = window.outerHeight(true)
            h = window.height()
            pH = 88
            newHeight = 2 * h - oH - pH

            # Set the new width and height
            renderer.resize(newWidth, newHeight);
            
            Game.rendererResized()

        do resizeRendererView

        Game.setRenderer renderer
        Game.start()

        angular.element($window).on 'resize', () ->
            do resizeRendererView
