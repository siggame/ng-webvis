'use strict'

###*
 # @ngdoc service
 # @name webvisApp.droids
 # @description
 # # droids
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')
webvisApp.service 'Plugin', (PluginBase, Renderer)->

    class Droids extends PluginBase.BasePlugin
        constructor: () ->
            @entities = {}
            @Droid = class Droid extends PluginBase.BaseEntity
                constructor: () ->
                    @sprite = new Renderer.Sprite

        getName: () -> "Droids"

        getMaxTurn: () ->

        getEntities: () ->

        loadGame: (gamedata) ->
            #create all entities
            for turn in gamedata.turns
                for id, droid of turn.Droid
                    if !@entities[id]?
                        @entities[id] = new @Droid


        getSexpScheme: () ->
            scheme = {
                gameName: ["gameName"],
                Player: ["id", "playerName", "time", "spores"],
                Mappable: ["id", "x", "y"],
                Droid: ["id", "x", "y", "owner", "variant", "attacksLeft",
                        "maxAttacks", "healthLeft", "maxHealth", "movementLeft",
                        "maxMovement", "range", "attack", "armor", "maxArmor",
                        "scrapWorth", "turnsToBeHacked", "hackedTurnsLeft",
                        "hackets", "hacketsMax"],
                Tile: ["id", "x", "y", "owner", "turnsUntilAssembled",
                       "variantToAssemble"],
                ModelVariant: ["id", "name", "variant", "cost", "maxAttacks",
                               "maxHealth", "maxMovement", "range", "attack", "maxArmor",
                               "scrapWorth", "turnsToBeHacked", "hacketsMax"],
                add: ["type", "sourceID"],
                remove: ["type", "sourceID"],
                spawn: ["type", "sourceID", "unitID"],
                repair: ["type", "actingID", "targetID"],
                move: ["type", "actingID", "fromX", "fromY", "toX", "toY"],
                hack: ["type", "actingID", "targetID"],
                orbitalDrop: ["type", "sourceID"],
                attack: ["type", "actingID", "targetID"],
                game: ["mapWidth", "mapHeight", "turnNumber", "maxDroids",
                    "playerID", "gameNumber", "scrapRate", "maxScrap",
                    "dropTime"]
            }

            return scheme

    return new Droids
