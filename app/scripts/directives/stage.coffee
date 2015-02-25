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

        canvas = document.createElement 'canvas'
        canvas.width = attrs['width']
        canvas.height = attrs['height']
        element.append canvas

        Game.createRenderer canvas

        resizeRendererView = () ->
            # Calculate new width and height
            # TODO: Don't hard-code height of playback controls
            window = $($window)

            newWidth = $(element).parent().width()

            oH = window.outerHeight(true)
            h = window.height()
            pH = 120
            newHeight = 2 * h - oH - pH

            canvas.width = newWidth
            canvas.height = newHeight

            console.info newWidth + "  " + newHeight

            Game.canvasResized(newWidth, newHeight)

        do resizeRendererView

        angular.element($window).on 'resize', () ->
            do resizeRendererView
