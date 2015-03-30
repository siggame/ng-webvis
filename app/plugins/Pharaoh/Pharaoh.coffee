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
            @background = new Renderer.Sprite();

        getName: () -> "Pharaoh"

        preDraw: (dt, renderer) ->
            @background.position.x += 1 * dt;
            @background.position.y += 1 * dt;
            renderer.drawSprite(@background)

        postDraw: (dt, renderer) ->

        loadGame: (gamedata) ->
            @maxTurn = gamedata.turns.length
            @mapWidth = gamedata.turns[0].mapWidth
            @mapHeight = gamedata.turns[0].mapHeight

            @background.texture = "background"
            @background.width = @mapWidth
            @background.height = @mapHeight
            @background.tiling = true
            @background.tileWidth = 24
            @background.tileHeight = 16


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
