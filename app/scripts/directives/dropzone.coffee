'use strict'

define ()->
    dropzone = ($log, alert, FileLoader) ->
        restrict: 'A'
        link: (scope, element) ->

            element.bind 'dragover', (event) ->
                event.stopPropagation()
                event.preventDefault()

            element.bind 'drop', (event) ->
                event.stopPropagation()
                event.preventDefault()

                FileLoader.loadFile event.originalEvent.dataTransfer.files
    dropzone.$inject = ['$log', 'alert', 'FileLoader']
    return dropzone