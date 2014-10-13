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
            newWidth = element.parent().width()
            playbackHeight = $('.playback-container').outerHeight(true)
            newHeight = angular.element($window).height() - playbackHeight

            # Set the new width and height
            renderer.view.style.width = "#{newWidth}px"
            renderer.view.style.height = "#{newHeight}px"

        do resizeRendererView

        Game.setRenderer renderer
        Game.start()

        angular.element($window).on 'resize', () ->
            do resizeRendererView
