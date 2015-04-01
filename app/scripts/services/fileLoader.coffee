'use strict'

###*
 # @ngdoc service
 # @name webvisApp.FileLoader
 # @description
 # # FileLoader
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')
webvisApp.service 'FileLoader', ($rootScope, $log, $injector, alert, Game, Parser, Options) ->
    # A helper function for showing errors
    acceptFileExtensions = ["gamelog", "glog", "json"]

    showError = (message) ->
        alert.error message
        if !$rootScope.$$phase
            $rootScope.$apply()
        $log.warn message

    verifyFileType = (filename) ->
        ext = ""
        for extension in acceptFileExtensions
            if filename.indexOf("." + extension) != -1
                ext = extension
                break
        return ext


    checkDroppedFiles = (files) ->
        if files.length != 1
            throw message: "Multiple files dropped"

        file = files[0]
        filename = escape file.name

        ext = verifyFileType filename
        if ext == ""
            throw message: "Bad file extension"

        return {
            extension : ext
            fileName : file
        }

    readFromLocal = (fileData, callback) ->
        reader = new FileReader()
        reader.onload = (event) =>
            file = {
                extension : fileData.extension
                data : event.target.result
            }
            callback(file)
        reader.readAsText(fileData.fileName)

    processFile = (file) ->
        # TODO Trigger progress bar
        parser = null
        switch file.extension
            when "gamelog" or "glog"
                parser = Parser.SexpParser
            when "json"
                parser = Parser.JsonParser
            else
                throw message: "No parser available for file type of file"

        parser.parse file.data


        gameObject = {}
        gameObject["gameName"] = parser.getGameName()
        gameObject["gameID"] = parser.getGameID()
        gameObject["gameWinner"] = parser.getGameWinner()


        if $injector.has parser.getGameName()
            plugin = $injector.get parser.getGameName()
            gameObject["turns"] = parser.getTurns(plugin.getSexpScheme())
            parser.clear()
            Game.fileLoaded gameObject
        else
            pluginUrl = "/plugins/" + parser.getGameName() + "/" + parser.getGameName() + ".js"
            $.ajax
                dataType: "script",
                url: pluginUrl,
                data: null,
                success: (jqxhr, textStatus) =>
                    $rootScope.$digest()
                    module = angular.module('webvisApp')
                    $injector.invoke([parser.getGameName(), (plugin) =>
                        console.log "loaded plugin"
                        gameObject["turns"] = parser.getTurns(plugin.getSexpScheme())
                        parser.clear()
                        Game.fileLoaded gameObject
                        ])
                error: (jqxhr, textStatus, errorThrown)->
                    alert.error "Plugin " + parser.getGameName() + " could not be loaded. " + errorThrown
                    $rootScope.$digest()
                    parser.clear()

    @loadFile = (files) ->
        try
            fileData = checkDroppedFiles files
            $log.info "Extension looks ok. Ready to read gamelog"
            readFromLocal(fileData, processFile)
        catch error
            showError error.message

    @loadFromUrl = (u) ->
        try
            checkExtension = (url) ->
                a = url.split('.')
                if a.length == 1 or (a[1] == "")
                    return ""
                return verifyFileType("." + a.pop())

            ext = checkExtension(u)

            if ext != ""
                $.ajax
                    type: "GET",
                    dataType: "text",
                    url: u,
                    data: null,
                    success: (d) =>
                        file = {
                            extension : ext
                            data : d
                        }
                        processFile(file)
                    error: (jqxhr, textStatus, errorThrown) ->
                        showError {message: "File could not be loaded from " + u}
            else
                throw message: "Bad File Extension"
        catch error
            showError error.message

    return this
