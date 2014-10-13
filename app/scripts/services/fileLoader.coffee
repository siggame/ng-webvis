'use strict'

###*
 # @ngdoc service
 # @name webvisApp.FileLoader
 # @description
 # # FileLoader
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')
webvisApp.service 'FileLoader', ($rootScope, $log, alert, Game) ->
    # A helper function for showing errors
    showError = (message) ->
        $rootScope.$apply ->
            alert.error message
        $log.warn message

    goodLogName = (filename) ->
        /\.gamelog$/.test(filename)

    checkFiles = (files) ->
        if files.length != 1
            throw message: "Multiple files dropped"

        file = files[0]
        filename = escape file.name

        $log.info "Dropped #{filename} with type '#{file.type}'"

        if not goodLogName filename
            throw message: "Bad file extension"

        return file

    processFile = (file) ->
        # TODO Trigger progress bar

        reader = new FileReader()

        # Set up a callback that will be called when reader finishes
        reader.onload = (event) ->
            $log.debug "File read"
            Game.fileLoaded event.target.result

        # Start reading!
        reader.readAsText(file)

    @loadFile = (files) ->
        try
            file = checkFiles files
            $log.info "Extension looks ok. Ready to read gamelog"
            processFile file
        catch error
            showError error.message

    return this