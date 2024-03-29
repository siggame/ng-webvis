'use strict'

###*
 # @ngdoc service
 # @name webvisApp.FileLoader
 # @description
 # # FileLoader
 # Service in the webvisApp.
###

FileLoader = ($rootScope, $log, $injector, alert, Game,
    Parser, Options, PluginManager) ->
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
            file : file
        }

    readCompressed = (fileData, callback) ->
        prepareFile = (event) ->
            file = {
                extension : fileData.extension
                data : event.target.result
            }
            callback(file)

        decompress = (file) ->
            buffer = new Uint8Array(file.target.result)
            decompressed = compressjs.Bzip2.decompressFile(buffer)

            textReader = new FileReader()
            textReader.onload = prepareFile
            textReader.readAsText(new Blob([decompressed]))

        reader = new FileReader()
        reader.onload = decompress

        $log.debug "Reading compressed file"
        reader.readAsArrayBuffer(fileData.file)

    readDecompressed = (fileData, callback) ->
        reader = new FileReader()
        reader.onload = (event) ->
            file = {
                extension : fileData.extension
                data : event.target.result
            }
            callback(file)

        $log.debug "Reading decompressed file"
        reader.readAsText(fileData.file)

    preProcessFile = (file) ->
        if file.extension == "glog"
            readCompressed(file, processFile)
        else
            readDecompressed(file, processFile)

    processFile = (file) ->
        # TODO Trigger progress bar
        parser = null
        switch file.extension
            when "gamelog"
                parser = Parser.SexpParser
            when "glog"
                parser = Parser.SexpParser
            when "json"
                parser = Parser.JsonParser
            else
                parser = Parser.JsonParser

        parser.parse file.data


        gameObject = {}
        gameObject["gameName"] = parser.getGameName()
        gameObject["gameID"] = parser.getGameID()
        gameObject["gameWinner"] = parser.getGameWinner()

        PluginManager.changePlugin parser.getGameName(), ()=>
            sexpScheme = PluginManager.getSexpScheme()
            gameObject["turns"] = parser.getTurns(sexpScheme)
            parser.clear()
            Game.fileLoaded gameObject


        ###
        if $injector.has parser.getGameName()
            plugin = $injector.get parser.getGameName()
            gameObject["turns"] = parser.getTurns(plugin.getSexpScheme())
            parser.clear()
            Game.fileLoaded gameObject
        else
            pluginUrl = ("/plugins/" + parser.getGameName() +
            "/" + parser.getGameName() + ".js")

            $.ajax
                dataType: "script",
                url: pluginUrl,
                data: null,
                success: (jqxhr, textStatus) ->
                    $rootScope.$digest()
                    module = angular.module('webvisApp')
                    $injector.invoke([parser.getGameName(), (plugin) ->
                        console.log "loaded plugin"
                        sexpScheme = plugin.getSexpScheme()
                        gameObject["turns"] = parser.getTurns(sexpScheme)
                        parser.clear()
                        Game.fileLoaded gameObject
                        ])
                error: (jqxhr, textStatus, errorThrown) ->
                    alert.error("Plugin " + parser.getGameName() +
                    " could not be loaded. " + errorThrown)
                    $rootScope.$digest()
                    parser.clear()
        ###

    @loadFile = (files) ->
        try
            fileData = checkDroppedFiles files
            $log.info "Extension looks ok. Ready to read gamelog"
            preProcessFile(fileData)
        catch error
            showError error.message

    @loadFromUrl = (u) ->
        urlsplit = u.split(".")

        if urlsplit[urlsplit.length - 1] == "gz"
            u = ""
            for i in [0..urlsplit.length - 3]
                u += urlsplit[i] + "."
            u += urlsplit[urlsplit.length - 2]

        checkExtension = (url) ->
            a = url.split('.')
            if a.length == 1 or (a[1] == "")
                return ""
            return verifyFileType("." + a.pop())

        error = (jqxhr, textStatus, errorThrown) ->
            showError "File could not be loaded from #{u}"

        success = (data) ->
            file =
                extension : ext
                file : new Blob([data])
            preProcessFile(file)

        fetchText = () ->
            $.ajax
                type: "GET"
                dataType: "text"
                url: u
                data: null
                success: success
                error: error

        fetchBinary = () ->
            req = new XMLHttpRequest()
            req.open("GET", u, true)
            req.responseType = "blob"
            req.onload = (event) ->
                if req.status == 200
                    success(req.response)
                else
                    error()
            req.onerror = error
            req.send()

        try
            ext = checkExtension(u)

            switch ext
                when "glog" then fetchBinary()
                when "gamelog" then fetchText()
                when "json" then fetchText()
                else
                    fetchBinary()
        catch error
            showError error.message

    $rootScope.$on 'FileLoader:LoadFromUrl', (event, data) =>
        @loadFromFile(data)

    $rootScope.$on 'FileLoader:GetArenaGame', (event, data) =>
        url = Options.get 'Webvis', 'Arena Url'
        $.ajax
            dataType: "text",
            url: url.text + "/api/next_game/",
            data: null,
            success: (data) =>
                @loadFromUrl decodeURIComponent(data)

    return this

FileLoader.$inject = [
    '$rootScope',
    '$log',
    '$injector',
    'alert',
    'Game',
    'Parser',
    'Options',
    'PluginManager'
]
webvisApp = angular.module 'webvisApp'
webvisApp.service 'FileLoader', FileLoader
