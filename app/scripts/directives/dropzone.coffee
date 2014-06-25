'use strict'

webvisApp = angular.module('webvisApp')

goodLogName = (filename) ->
    /\.gamelog$/.test(filename)

webvisApp.directive 'dropzone', ($log, alert) ->
    restrict: 'A'
    link: (scope, element) ->

        # A helper function for showing errors
        showError = (message) ->
            scope.$apply ->
                alert.error message
            $log.warn message

        element.bind 'dragover', (event) ->
            event.stopPropagation()
            event.preventDefault()

        element.bind 'drop', (event) ->
            event.stopPropagation()
            event.preventDefault()

            files = event.originalEvent.dataTransfer.files
            if files.length != 1
                showError "Multiple files dropped"
                return

            file = files[0]
            filename = escape file.name

            $log.info "Dropped #{filename} with type '#{file.type}'"

            if not goodLogName filename
                showError "Bad file extension"
                return

            $log.info "Extension looks ok. Ready to read gamelog"

            # TODO Trigger progress bar

            reader = new FileReader()

            # Set up a callback that will be called when reader finishes
            reader.onload = (event) ->
                file_contents = event.target.result
                $log.debug file_contents

            # Start reading!
            reader.readAsText(file)
