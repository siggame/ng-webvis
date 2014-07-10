'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.directive 'dropzone', ($log, alert, GameLog) ->
    restrict: 'A'
    link: (scope, element) ->

        element.bind 'dragover', (event) ->
            event.stopPropagation()
            event.preventDefault()

        element.bind 'drop', (event) ->
            event.stopPropagation()
            event.preventDefault()

            GameLog.loadFile event.originalEvent.dataTransfer.files
