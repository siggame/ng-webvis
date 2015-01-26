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

        parse: (file_contents, scheme) ->
            log = @loadFile(file_contents)

            return {
                fileContents: file_contents
                gameID: @getGameID(log)
                gameName: @getGameName(log)
                turns: @getTurns(log, scheme)
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

        getTurns: (gameLog, scheme) ->
            turns = []
            for i in [1..(gameLog.length - 2)] by 2
                state = {}
                for j in [1..(gameLog[i].length - 1)]
                    memberData = scheme[gameLog[i][j][0]]
                    model = null
                    if gameLog[i][j].length <= 1
                        if !state[gameLog[i][j][0]]?
                            state[gameLog[i][j][0]] = []
                    else if gameLog[i][j][1] instanceof Array
                        model = {}
                        for k in [1..(gameLog[i][j].length - 1)]
                            elem = {}
                            for l in [0..(gameLog[i][j][k].length - 1)]
                                elem[memberData[l]] = gameLog[i][j][k][l]
                            model[gameLog[i][j][k][0]] = elem

                        if !state[gameLog[i][j][0]]?
                            state[gameLog[i][j][0]] = []

                        state[gameLog[i][j][0]] = model
                    else
                        for k in [1..(gameLog[i][j].length - 1)]
                            state[memberData[k-1]] = gameLog[i][j][k]

                animations = {}
                for j in [1..(gameLog[i+1].length - 1)]
                    if gameLog[i+1].length <= 1
                        break

                    memberData = scheme[gameLog[i+1][j][0]]
                    anim = {}
                    for k in [0..(gameLog[i+1][j].length - 1)]
                        anim[memberData[k]] = gameLog[i+1][j][k]

                    if !animations[gameLog[i+1][j][1]]?
                        animations[gameLog[i+1][j][1]] = []
                    animations[gameLog[i+1][j][1]].push anim

                state.animaitons = animations
                turns.push state

            return turns

    # Public API here
    return {
        SexpParser: new SexpParser()
    }
