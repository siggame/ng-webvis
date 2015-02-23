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

        Droid: class Droid extends PluginBase.BaseEntity
            constructor: () ->
                @sprite = new Renderer.sprite
                @spawnTurn = -1
                @removeTurn = -1
                @variant = ""
                @animations = {}

            getAnimations: () -> @antimations

            idleFunc: (e, droid) => (renderer, turn, progress) =>
                entity = e[droid.id]
                if entity.spawnTurn - 1 <= turn <= entity.removeTurn
                    entity.sprite = entity.variant + ".png"
                    renderer.drawSprite entity.sprite

            repairFunc: (e, repairAnim) => (renderer, turn, progress) =>
                source = e[repairAnim.sourceID]
                target = e[repairAnim.targetID]

                p1 = source.sprite.position
                p2 = target.sprite.position

                l = new Renderer.Line p1.x, p1.y, p2.x, p2.y
                l.color.setColor(0.0, 1.0, 0.0, 1.0)
                renderer.drawLine l

            moveFunc: (e, moves) => (renderer, turn, progress) =>
                entity = e[moves[0].actingID]
                i = parseInt(moves.length * progress)
                subt = (moves.length * progress) - i

                diffX = moves[i].toX - moves[i].fromX
                diffY = moves[i].toY - moves[i].fromY

                posX = moves[i].fromX + diffX * subt
                posY = moves[i].fromY + diffY * subt

                entity.sp.position.x = posX
                entity.sp.position.y = posY

            hackFunc: (e, hackAnim) => (renderer, turn, progress) =>
                source = e[hackAnim.sourceID]
                target = e[hackAnim.targetID]

                p1 = source.sprite.position
                p2 = target.sprite.position

                l = new Renderer.Line p1.x, p1.y, p2.x, p2.y
                l.color.setColor 1.0, 0.0, 1.0, 1.0
                renderer.drawLine l

            dropFunc: (e, dropAnim) => (renderer, turn, progress) =>
                entity = e[dropAnim.sourceID]

                p = new Renderer.Point(entity.x - 3, entity.y - 20)

                entity.sprite.texture = "fireball.png"
                entity.sprite.position.x = p.x + (3 * progress)
                entity.sprite.position.y = p.y + (20 * progress)

            attackFunc: (e, attackAnim) => (renderer, turn, progress) =>
                source = e[attackAnim.actingID]
                target = e[attackAnim.sourceID]

                p1 = source.sprite.position
                p2 = target.sprite.position

                l = new Renderer.line p1.x, p1.y, p2.x, p2.y
                l.color.setColor 1.0, 0.0, 0.0, 1.0
                renderer.drawLine l

        constructor: () ->
            @entities = {}
            @maxTurn = 0
            @mapWidth = 0
            @mapHeight = 0
            @background = new Renderer.Sprite

        getName: () -> "Droids"

        getMaxTurn: () -> @maxTurn

        getMapWidth: () -> @mapWidth

        getMapHeight: () -> @mapHeight

        preDraw: (renderer) ->
            renderer.drawSprite @background

            for i in [1..@mapHeight - 1]
                l = new Renderer.Line 0, i, @mapWidth, i
                l.color.setColor 0.0, 0.0, 0.0, 1.0
                renderer.drawLine l

            for i in [1..@mapWidth - 1]
                l = new Renderer.Line i, 0, i, @mapHeight
                l.color.setColor 0.0, 0.0, 0.0, 1.0
                renderer.drawLine l

        getEntities: () -> @entities

        postDraw: (renderer) ->

        loadGame: (gamedata) ->
            @maxTurn = gamedata.turns.length

            @mapWidth = gamedata.turns[0].mapWidth
            @mapHeight = gamedata.turns[0].mapHeight

            @background.texture = "background"
            @background.frame = 0
            @background.position.x = 0
            @background.position.y = 0
            @background.width = @mapWidth
            @background.height = @mapHeight
            @background.tiling = true
            @background.tileWidth = 24
            @background.tileHeight = 14

            console.log @mapWidth + " " + @mapHeight


            ###
            #create all entities
            for turn in gamedata.turns
                for id, droid of turn.Droid
                    if !@entities[id]?
                        @entities[id] = new @Droid

                        a =  new PluginBase.Animation 0, @getMaxTurn(),
                            @Droid.idleFunc(@entities, droid)

                        @entities[id].animations.push a

                    moves = []
                    for anim in turn.animations[id]
                        # entity must have been initialized this turn or before
                        # to have an animation.
                        switch anim.type
                            when "add", "spawn"
                                @entities[id].spawnTurn = turn.turnNumber - 1
                            when "remove"
                                @entities[id].endTurn = turn.turnNumber
                            when "repair"
                                f = @Droid.repairFunc @entities, anim

                                a = new PluginBase.Animation turn.currentTurn,
                                    turn.currentTurn + 1, f

                                @entities[id].animations.push a

                            when "move"
                                moves.push anim

                            when "hack"
                                f = @Droid.hackFunc @entities, anim

                                a = new PluginBase.Animation turn.currentTurn,
                                    turn.currentTurn + 1, f

                                @entities[id].animations.push a

                            when "orbitalDrop"
                                f = @Droid.dropFunc @entities, anim

                                a = new PluginBase.Animation turn.currentTurn,
                                    turn.currentTurn + 1, f

                                @entities[id].animations.push a

                            when "attack"
                                f = @Droid.attackFunc @entities, anim

                                a = new PluginBase.Animation turn.currentTurn,
                                    turn.currentTurn + 1, f

                                @entities[id].animations.push a


                    if moves.length > 0
                        f = @Droid.moveFunc @entities, moves

                        a = new PluginBase.Animation turn.currentTurn,
                            turn.currentTurn + 1, f

                        @entities[id].animations.push a
            ###


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
