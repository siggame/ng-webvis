'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:Stage
 # @description
 # # Stage
###

define [
    'scripts/services/game'
], ()->
    webvisApp = angular.module('webvisApp')
    webvisApp.directive 'stage', ($log, $window, Game) ->
        template: ''
        restrict: 'E'
        link: (scope, element, attrs) ->
            console.log "called"

            canvas = document.createElement 'canvas'
            canvas.width = attrs['width']
            canvas.height = attrs['height']
            canvas.onclick = attrs['click']
            $(canvas).css {'width': '100%', 'height': '100%'}
            element.append canvas


            Game.createRenderer canvas

            resizeRendererView = () ->
                # Calculate new width and height
                # TODO: Don't hard-code height of playback controls
                window = $($window)

                oH = window.outerHeight(true)
                h = window.height()
                pH = 120
                newHeight = 2 * h - oH - pH

                canvas.height = newHeight

                Game.canvasResized(canvas.width, newHeight)

            do resizeRendererView

            angular.element($window).on 'resize', () ->
                do resizeRendererView
