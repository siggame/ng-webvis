'use strict'

###*
 # @ngdoc service
 # @name webvisApp.FileLoader
 # @description
 # # FileLoader
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')
webvisApp.service 'FileLoader', ($rootScope, $log, $injector, alert, Game, Parser) ->
    # A helper function for showing errors
    acceptFileExtensions = ["gamelog", "glog", "json"]
    
    showError = (message) ->
        $rootScope.$apply ->
            alert.error message
        $log.warn message

    verifyFileType = (filename) ->
        ext = ""
        for extension in acceptFileExtensions
            if filename.indexOf("." + extension) != -1
                ext = extension
                break
        return ext
        

    checkFiles = (files) ->
        if files.length != 1
            throw message: "Multiple files dropped"

        file = files[0]
        filename = escape file.name

        $log.info "Dropped #{filename} with type '#{file.type}'"

        ext = verifyFileType filename
        if ext == ""
            throw message: "Bad file extension"

        return {
            extension : ext
            data : file
        }

    processFile = (file) ->
        # TODO Trigger progress bar

        reader = new FileReader()

        # Set up a callback that will be called when reader finishes
        reader.onload = (event) =>
            $log.debug "File read"
            parser = null 
            switch file.extension
                when "gamelog" or "glog"
                    parser = Parser.SexpParser
                when "json"
                    parser = Parser.JsonParser
                else
                    throw message: "No parser available for file type of file"
            
            parser.parse event.target.result
            
            gameObject = {}
            gameObject["gameName"] = parser.getGameName()
            gameObject["gameID"] = parser.getGameID()
            gameObject["gameWinner"] = parser.getGameWinner()
            
            console.log parser.getGameName()
            console.log parser.getGameID()
            console.log parser.getGameWinner()
            
            if $injector.has parser.getGameName()
                console.log "plugin exists"
                plugin = $injector.get parser.getGameName()
                gameObject["turns"] = parser.getTurns(plugin.getSexpScheme())
                parser.clear()
                Game.fileLoaded gameObject
            else
                console.log "plugin didn't exist"
                baseUrl = window.location.href.replace("/#/", "/")
                pluginUrl = baseUrl + "plugins/" + parser.getGameName() + ".js"
                console.log parser.getGameName()
                $.ajax
                    dataType: "script",
                    url: pluginUrl,
                    data: null,
                    success: (jqxhr, textStatus) =>
                        $rootScope.$digest()
                        module = angular.module('webvisApp')
                        console.log webvisApp._invokeQueue
                        console.log $injector.has parser.getGameName()
                        $injector.invoke([parser.getGameName(), (plugin) =>
                            console.log "loaded plugin"
                            gameObject["turns"] = parser.getTurns(plugin.getSexpScheme())
                            parser.clear()
                            Game.fileLoaded gameObject
                            ])
                    error: (jqxhr, textStatus, errorThrown)->
                        console.log textStatus + " " + errorThrown
                        alert.error "Plugin " + parser.getGameName() + " could not be found"
                        parser.clear()

        # Start reading!
        reader.readAsText(file.data)

    @loadFile = (files) ->
        try
            file = checkFiles files
            $log.info "Extension looks ok. Ready to read gamelog"
            processFile file
        catch error
            showError error.message

    return this
