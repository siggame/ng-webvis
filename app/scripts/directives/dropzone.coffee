'use strict'

webvisApp = angular.module('webvisApp')

goodLogName = (filename) ->
    /\.gamelog$/.test(filename)

webvisApp.directive 'dropzone', () ->
    restrict: 'A'
    link: (scope, element) ->
        element.bind 'dragover', (event) ->
            event.stopPropagation()
            event.preventDefault()

        element.bind 'drop', (event) ->
            event.stopPropagation()
            event.preventDefault()

            files = event.originalEvent.dataTransfer.files
            if files.length != 1
                # TODO Handle error
                err = "Multiple files dropped"
                console.log err
                return

            file = files[0]
            filename = escape file.name

            console.log "Dropped #{filename} with type '#{file.type}'"

            if not goodLogName filename
                err = "Bad file extension"
                console.log err
                return

            console.log("Extension looks ok. Ready to read gamelog")

            # TODO Trigger progress bar

            reader = new FileReader()

            # Set up a callback that will be called when reader finishes
            reader.onload = (event) ->
                file_contents = event.target.result
                element.text file_contents

            # Start reading!
            reader.readAsText(file)
