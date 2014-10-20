'use strict'

###*
 # @ngdoc service
 # @name webvisApp.Parser
 # @description
 # # Parser
 # Factory in the webvisApp.
###
webvisApp = angular.module('webvisApp')

webvisApp.factory 'Parser', ->

    class Parser
        constructor: () ->

        loadFile: () ->
            throw message: "Not implemented"

        getGameID: () ->
            throw message: "Not implemented"

        getGameName: () ->
            throw message: "Not implemented"

        getTurns: () ->
            throw message: "Not implemented"

        getGameWinner: () ->
            throw message: "Not implemented"

        parse: (file_contents) ->
            log = @loadFile(file_contents)

            return {
                fileContents: file_contents
                gameID: @getGameID(log)
                gameName: @getGameName(log)
                turns: @getTurns(log)
                result: @getGameWinner(log)
            }


    class SexpParser extends Parser

        # Loads file contents by converting the S-Expression into readable
        # JSON data and loading that up.
        loadFile: (data) ->
            data = data.replace(/\s+/g, ' ')
            data = data.replace(/\)\(/g, ') (')
            data = data.replace(/\(/g, '[').replace(/\)/g, ']')

            inquote = false
            json = "["

            for c in data
                # TODO handle quotes in quotes...
                if c == '"'
                    inquote = not inquote

                if inquote
                    json += c
                    continue

                if c == " "
                    json += ', '
                else
                    json += c

            json += ']'

            return JSON.parse(json.replace(/,\s*\]/g, ']'))

        getGameID: (gameLog) -> _.last(gameLog)[1]

        getGameName: (gameLog) -> gameLog[0][1]

        getGameWinner: (gameLog) ->
            winner = _.last(gameLog)
            return team: winner[2], reason: winner[4]

        getTurns: (gameLog) ->
            turns = gameLog[1..gameLog.length-2]
            prepareObj = (statusList, animationList) =>
                status: @toObj(turns[i][1..(turns[i].length - 1)])
                animations: turns[i+1][1..(turns[i+1].length - 1)]

            for i in [0..(turns.length - 1)] by 2
                prepareObj(turns[i], turns[i+1])

        toObj: (sexp) ->
            game = _(sexp).find((x) -> x[0] == "game")
            statuses = _(sexp).filter((x) -> x[0] != "game")
            status = _.object(_(statuses).map((x) -> [x[0], x[1..]]))
            status['game'] = [game]
            return status



    # Public API here
    return {
        SexpParser: new SexpParser()
    }
