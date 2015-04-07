`//# sourceURL=Pharaoh.js
`
'use strict'

angular.module('webvisApp').provide.factory 'Pharaoh', (PluginBase, Renderer, Options) ->
    class Entity extends PluginBase.BaseEntity
        constructor: () ->
            @animations = []

        getAnimations: () -> @animations

    class Thief extends Entity
        constructor: () ->
            super()
            @start = 0
            @end = 0
            @sprite = new Renderer.Rect()

        @idle: (id, entities) =>
            (renderer, turn, progress) =>
                if entities[id].start < turn and turn < entities[id].end
                    console.log "blah blah blah"
                    renderer.drawRect entities[id].sprite

        @move: (id, entities, moves) =>
            (renderer, turn, progress) =>
                sprite = entities[id].sprite
                i = Math.floor(moves.length * progress)
                subt = (moves.length * progress) - i

                diffx = moves[i].toX - moves[i].fromX
                diffy = moves[i].toY - moves[i].fromY

                sprite.position.x = moves[i].fromX + (diffx * subt)
                sprite.position.y = moves[i].fromY + (diffy * subt)
                console.log moves[i].fromX + " " + moves[i].toX + " " +  moves[i].fromY + " " + moves[i].toY + " " + subt + " " + diffx + " " + diffy + " "

    class Wall extends Entity
        constructor: () ->
            super()
            @sprite = new Renderer.Rect()
            @intervals = []

        @idle: (id, entities) =>
            (renderer, turn, progress) =>
                intervals = entities[id].intervals
                for i in [0 ... intervals.length] by 2
                    if intervals[i] <= turn and turn <= intervals[i+1]
                        renderer.drawRect entities[id].sprite

    class Pharaoh extends PluginBase.BasePlugin
        constructor: () ->
            super()
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

            @guiBarLeft = new Renderer.Rect()
            @guiBarLeft.position.x = 5
            @guiBarLeft.position.y = 80
            @guiBarLeft.width = 42
            @guiBarLeft.height = 15
            @guiBarLeft.fillColor.setColor(1.0, 0.0, 0.0, 1.0)

            @guiBarRight = new Renderer.Rect()
            @guiBarRight.position.x = 53
            @guiBarRight.position.y = 80
            @guiBarRight.width = 42
            @guiBarRight.height = 15
            @guiBarRight.fillColor.setColor(0.0, 1.0, 0.0, 1.0)

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
            renderer.drawRect(@guiBarLeft)
            renderer.drawRect(@guiBarRight)

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

            console.log "blah"

            i = -1
            for turn in gamedata.turns
                i++
                if i+1 < @maxTurn and
                    turn.roundNumber != gamedata.turns[i+1].roundNumber
                        for id,ent of @entities
                            if ent instanceof Wall and
                                ent.intervals.length %2 == 1
                                    ent.intervals.push i

                if i+1 == @maxTurn
                    for id, ent of @entities
                        if ent instanceof Wall and
                            ent.intervals.length %2 == 1
                                ent.intervals.push i

                for id,tile of turn.Tile
                    if tile.type == 2
                        if !@entities[id]?
                            @entities[id] = new Wall()
                            sp = @entities[id].sprite
                            if tile.x < 25
                                sp.transform = @pyramid1.transform
                            else
                                sp.transform = @pyramid2.transform
                            sp.position.x = tile.x
                            sp.position.y = tile.y
                            sp.width = 1
                            sp.height = 1
                            sp.fillColor.setColor(0.0, 0.0, 0.0, 1.0)
                            f = Wall.idle(id, @entities)
                            a = new PluginBase.Animation(0, @maxTurn, f)
                            @entities[id].animations.push a

                        if @entities[id].intervals.length %2 == 0
                            @entities[id].intervals.push i

                    if tile.type == 0 and @entities[id]? and
                        @entities[id].intervals.length %2 == 1
                            @entities[id].intervals.push i

                for id,thief of turn.Thief
                    if !@entities[id]?
                        @entities[id] = new Thief()
                        @entities[id].sprite.position.x = thief.x
                        @entities[id].sprite.position.y = thief.y
                        if thief.x < 25
                            @entities[id].sprite.transform = @pyramid1.transform
                        else
                            @entities[id].sprite.transform = @pyramid2.transform
                        @entities[id].sprite.fillColor.setColor(1.0, 1.0, 1.0, 1.0)
                        switch thief.thiefType
                            when 0
                                @entities[id].sprite.fillColor.setColor(1.0, 0.0, 0.0, 1.0)
                            when 1
                                @entities[id].sprite.fillColor.setColor(1.0, 1.0, 0.0, 1.0)
                            when 2
                                @entities[id].sprite.fillColor.setColor(0.0, 1.0, 1.0, 1.0)
                            when 3
                                @entities[id].sprite.fillColor.setColor(1.0, 0.0, 1.0, 1.0)
                            when 4
                                @entities[id].sprite.fillColor.setColor(0.0, 0.0, 1.0, 1.0)
                        @entities[id].sprite.width = 1
                        @entities[id].sprite.height = 1
                        @entities[id].start = i

                        f = Thief.idle(id, @entities)
                        a = new PluginBase.Animation(0, @maxTurn, f)
                        @entities[id].animations.push a

                    # does not exist, or dies next turn
                    if i+1 < @maxTurn and !gamedata.turns[i+1].Thief[id]?
                        @entities[id].end = i

                for id,animList of turn.animations
                    moves = []
                    for anim in animList
                        switch(anim.type)
                            when "move"
                                moves.push anim

                    if moves.length != 0
                        e = @entities[id]
                        f = Thief.move(id, @entities, moves)
                        a = new PluginBase.Animation(i, i+1, f)
                        @entities[id].animations.push a

        getSexpScheme: () ->
            {
                gameName : ["gameName"],
                Player : ["id", "playerName", "time", "scarabs", "roundsWon"],
                Mappable : ["id", "x", "y"],
                Tile : ["id", "x", "y", "type"],
                Trap : ["id", "x", "y", "owner", "trapType", "visible",
                       "active", "bodyCount", "activationsRemaining",
                       "turnsTillActive"],
                Thief : ["id", "x", "y", "owner", "thiefType", "alive",
                        "specialsLeft", "maxSpecials", "movementLeft",
                        "maxMovement", "frozenTurnsLeft"],
                ThiefType : ["id", "name", "type", "cost", "maxMovement",
                            "maxSpecials", "maxInstances"],
                TrapType : ["id", "name", "type", "cost", "maxInstances",
                          "startsVisible", "hasAction", "deactivatable",
                          "maxActivations", "activatesOnWalkedThrough",
                          "turnsToActivateOnTile", "canPlaceOnWalls",
                          "canPlaceOnOpenTiles", "freezesForTurns",
                          "killsOnActivate", "cooldown", "explosive",
                          "unpassable"],
                add : ["type", "sourceID"],
                spawn : ["type", "sourceID", "x", "y"],
                move : ["type", "sourceID", "fromX", "fromY", "toX", "toY"],
                kill : ["type", "sourceID", "targetID"],
                pharaohTalk : ["type", "playerID", "message"],
                theifTalk : ["type", "sourceID", "message"],
                activate : ["type", "sourceID"],
                bomb : ["type", "sourceID", "targetid"],
                dig : ["type", "sourceid", "targetid", "x", "y"],
                roll : ["type", "sourceid", "x", "y"],
                remove : ["type", "sourceID"],
                game : ["mapWidth", "mapHeight", "turnNumber",
                       "roundTurnNumber", "maxThieves", "maxTraps", "playerID",
                       "gameNumber", "roundNumber", "scarabsForTraps",
                       "scarabsForThieves", "maxStack", "roundsToWin",
                       "roundTurnLimit"]
            }

    return new Pharaoh
