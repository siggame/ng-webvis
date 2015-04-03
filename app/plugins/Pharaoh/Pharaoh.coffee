`// # sourceURL=Pharaoh.js
`
'use strict'

angular.module('webvisApp').provide.factory 'Pharaoh', (PluginBase, Renderer, Options) ->
    class Theif extends PluginBase.BaseEntity
        constructor: () ->

    class Pharaoh extends PluginBase.BasePlugin
        constructor: () ->
            @pharaohOptions = [
                [
                    "checkbox",
                    "Animate Background",
                    false
                ]
            ]
            Options.addPage "Pharaoh", @pharaohOptions
            @gameLoaded = false
            @background = new Renderer.Sprite()
            @background.texture = "background"
            @background.width = 100
            @background.height = 100
            @background.tiling = true
            @background.tileWidth = 60
            @background.tileHeight = 70
            @background.tileOffsetX = 0.5
            @background.tileOffsetY = 0.5

            @pyramid1 = new Renderer.Sprite()
            @pyramid1.transform = new Renderer.Matrix3x3()
            @pyramid1.texture = "floor"
            @pyramid1.width = 25
            @pyramid1.height = 25
            @pyramid1.tiling = true
            @pyramid1.tileWidth = 15
            @pyramid1.tileHeight = 15

            @pyramid2 = new Renderer.Sprite()
            @pyramid2.transform = new Renderer.Matrix3x3()
            @pyramid2.texture = "floor"
            @pyramid2.position.x = 25
            @pyramid2.position.y = 0
            @pyramid2.width = 25
            @pyramid2.height = 25
            @pyramid2.tiling = true
            @pyramid2.tileWidth = 15
            @pyramid2.tileHeight = 15

            @pyramid1Lines = []
            @pyramid2Lines = []
            for i in [0..@pyramid1.width]
                l = new Renderer.Line(i+@pyramid1.position.x,
                                      @pyramid1.position.y,
                                      i+@pyramid1.position.x,
                                      @pyramid1.position.y + @pyramid1.height)
                l.transform = @pyramid1.transform
                l.color.setColor(0.0, 0.0, 0.0, 1.0)
                @pyramid1Lines.push l

            for i in [0..@pyramid1.height]
                l = new Renderer.Line(@pyramid1.position.x,
                                      i+@pyramid1.position.y,
                                      @pyramid1.position.x + @pyramid1.width,
                                      i+@pyramid1.position.y)
                l.transform = @pyramid1.transform
                l.color.setColor(0.0, 0.0, 0.0, 1.0)
                @pyramid1Lines.push l

            for i in [0..@pyramid2.width]
                l = new Renderer.Line(i+@pyramid2.position.x,
                                      @pyramid2.position.y,
                                      i+@pyramid2.position.x,
                                      @pyramid2.position.y + @pyramid2.height)
                l.transform = @pyramid2.transform
                l.color.setColor(0.0, 0.0, 0.0, 1.0)
                @pyramid2Lines.push l

            for i in [0..@pyramid2.height]
                l = new Renderer.Line(@pyramid2.position.x,
                                      i+@pyramid2.position.y,
                                      @pyramid2.position.x + @pyramid2.width,
                                      i)
                l.transform = @pyramid2.transform
                l.color.setColor(0.0, 0.0, 0.0, 1.0)
                @pyramid2Lines.push l



        getName: () -> "Pharaoh"

        preDraw: (dt, renderer) ->
            renderer.drawSprite(@background)
            renderer.drawSprite(@pyramid1)
            renderer.drawSprite(@pyramid2)

            for l in @pyramid1Lines
                renderer.drawLine(l)

            for l in @pyramid2Lines
                renderer.drawLine(l)

        postDraw: (dt, renderer) ->

        resize: (renderer) ->
            proj = renderer.getProjection()
            @pyramid1.transform.copy(proj)
            @pyramid2.transform.copy(proj)

            # (0, 0) at top left of pyramid 1
            # appears at (5, 5) of global coords
            @pyramid1.transform.translate(5, 5)

            # (25, 25) now appears at (45,75) of global coords
            @pyramid1.transform.scale(42/(@mapWidth/ 2), 70/@mapHeight)

            # (0, 0) at top left or pyramid 2
            # appears at (55, 5) of global coords
            @pyramid2.transform.translate(53, 5)

            # (25, 25) now appears at (95, 75)
            @pyramid2.transform.scale(42/(@mapWidth/2), 70/@mapHeight)

            # (26, 0) appears at top left of pyramid 2 so that thieves in
            # pyramid 2 can use the coordinates provided by the game log
            @pyramid2.transform.translate(-(@mapWidth/2), 0);

        loadGame: (gamedata, renderer) ->
            @maxTurn = gamedata.turns.length
            @mapWidth = gamedata.turns[0].mapWidth
            @mapHeight = gamedata.turns[0].mapHeight

            @resize(renderer)

            console.log @pyramid1Lines


        getSexpScheme: () ->
            {
                gameName : ["gameName"],
                Player : ["id", "playerName", "time", "scarabs", "roundsWon"],
                Mappable : ["id", "x", "y"],
                Tile : ["id", "x", "y", "type"],
                Trap : ["id", "x", "y", "owner", "trapType", "visible",
                       "active", "bodyCount", "activationsRemaining",
                       "turnsTillActive"],
                Thief : ["id", "x", "y", "owner", "theifType", "alive",
                        "ninjaReflexesLeft", "maxNinjaReflexes",
                        "movementLeft", "maxMovement", "frozenTurnsLeft"],
                ThiefType : ["id", "name", "type", "cost", "maxMovement",
                            "maxMovement", "maxNinjaReflexes", "maxInstances"],
                TrapType : ["id", "name", "type", "cost", "maxInstances",
                          "startsVisible", "hasAction", "deactivatable",
                          "maxActivations", "activatesOnWalkedThrough",
                          "turnsToActivateOnTile", "canPlaceOnWalls",
                          "canPlaceOnOpenTiles", "freezesForTurns",
                          "killsOnActivate", "cooldown", "explosive",
                          "upassable"],
                add : ["type", "sourceID"],
                spawn : ["type", "actingID", "x", "y"],
                Move : ["type", "actingID", "fromX", "fromY", "toX", "toY"],
                kill : ["type", "actingID", "targetID"],
                pharaohTalk : ["type", "actingID", "message"],
                theifTalk : ["type", "actingID", "message"],
                activate : ["type", "actingID"],
                bomb : ["type", "actingID", "x", "y"],
                AnimOwner : ["type", "owner"],
                game : ["mapWidth", "mapHeight", "turnNumber",
                       "roundTurnNumber", "maxThieves", "maxTraps", "playerID",
                       "gameNumber", "roundNumber", "scarabsForTraps",
                       "scarabsForThieves", "maxStack", "roundsToWin",
                       "roundTurnLimit"]
            }

    return new Pharaoh
