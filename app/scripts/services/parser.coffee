'use strict'

###*
 # @ngdoc service
 # @name webvisApp.Parser
 # @description
 # # Parser
 # Factory in the webvisApp.
###


define ()->
    Parser = () ->
        class Parser
            constructor: () ->
                @log = null

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

            clear: () ->
                @log = null

            parse: (file_contents) ->
                if @log != null then @log = null
                @log = @loadFile(file_contents)

        class JsonParser extends Parser
            loadFile: (data) -> JSON.parse(data)

            getGameID: () -> @log.gameSession;

            getGameName: () -> @log.gameName;

            getGameWinner: () -> @log.winners[0];

            getTurns:() -> @log.deltas;


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

            getGameID: () ->
                if @log != null
                    _.last(@log)[1]
                else
                    return -1

            getGameName: () ->
                if @log != null
                    @log[0][1]
                else
                    return ""

            getGameWinner: () ->
                if @log != null
                    winner = _.last(@log)
                    return team: winner[2], reason: winner[4]
                else
                    return null

            getTurns: (scheme) ->
                if @log != null
                    turns = []
                    for i in [1..(@log.length - 2)] by 2
                        state = {}
                        for j in [1..(@log[i].length - 1)]
                            memberData = scheme[@log[i][j][0]]
                            model = null
                            if @log[i][j].length <= 1
                                if !state[@log[i][j][0]]?
                                    state[@log[i][j][0]] = []
                            else if @log[i][j][1] instanceof Array
                                model = {}
                                for k in [1..(@log[i][j].length - 1)]
                                    elem = {}
                                    for l in [0..(@log[i][j][k].length - 1)]
                                        elem[memberData[l]] = @log[i][j][k][l]
                                    model[@log[i][j][k][0]] = elem

                                if !state[@log[i][j][0]]?
                                    state[@log[i][j][0]] = []

                                state[@log[i][j][0]] = model
                            else
                                for k in [1..(@log[i][j].length - 1)]
                                    state[memberData[k-1]] = @log[i][j][k]

                        animations = {}
                        for j in [1..(@log[i+1].length - 1)]
                            if @log[i+1].length <= 1
                                break

                            memberData = scheme[@log[i+1][j][0]]
                            anim = {}
                            for k in [0..(@log[i+1][j].length - 1)]
                                anim[memberData[k]] = @log[i+1][j][k]

                            if !animations[@log[i+1][j][1]]?
                                animations[@log[i+1][j][1]] = []
                            animations[@log[i+1][j][1]].push anim

                        state.animations = animations
                        turns.push state

                    return turns
                else
                    return null

        # Public API here
        return {
            SexpParser: new SexpParser()
            JsonParser: new JsonParser()
        }
