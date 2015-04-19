`//# sourceURL=Pharaoh.js
`
'use strict'

angular.module('webvisApp').provide.factory 'Pharaoh', (PluginBase, Renderer, Options) ->
    class Entity extends PluginBase.BaseEntity
        constructor: () ->
            @animations = []

        getAnimations: () -> @animations

    class Wall extends Entity
        constructor: (game, tile) ->
            super()
            @sprite = new Renderer.Sprite()
            @sprite.texture = "Wall"
            @sprite.frame = 1
            @type = 2
            @intervals = []

        @idleMake: (game, id, entities) =>
            (renderer, turn, progress) =>
                e = entities[id]

                south = game.getTileIdAt(e.sprite.position.x, e.sprite.position.y + 1)
                if entities[south]? and entities[south].type == 2
                    e.sprite.frame = 0

                for i in [0 ... e.intervals.length] by 2
                    e.type = e.typeOnTurn(turn)
                    if e.type == 2
                        renderer.drawSprite e.sprite
                        break

        typeOnTurn: (turn) ->
            for i in [0 ... @intervals.length] by 2
                if @intervals[i] <= turn <= @intervals[i+1]
                    return 2
            return 0

    class Unit extends Entity
        constructor: () ->
            super()
            @start = 0
            @end = 0
            @posIntervals = []
            @positions = []
            @sprite = new Renderer.Sprite()
            @clickable = false
            @states = {}
            @normalTex = ""

        @idleMake: (id, entities, gamedata) =>
            (renderer, turn, progress) =>
                e = entities[id]
                j = -1
                e.sprite.texture = e.normalTex

                for i in [0 ... e.posIntervals.length] by 2
                    j++
                    if e.posIntervals[i] <= turn < e.posIntervals[i+1]
                        e.sprite.position.x = e.positions[j].x
                        e.sprite.position.y = e.positions[j].y

                if e.start <= turn <= e.end
                    renderer.drawSprite e.sprite
                    e.clickable = true
                else
                    e.clickable = false

        @move: (id, entities, moves) =>
            (renderer, turn, progress) =>
                sprite = entities[id].sprite
                i = Math.floor(moves.length * progress)
                subt = (moves.length * progress) - i

                diffx = moves[i].toX - moves[i].fromX
                diffy = moves[i].toY - moves[i].fromY

                sprite.position.x = moves[i].fromX + (diffx * subt)
                sprite.position.y = moves[i].fromY + (diffy * subt)

                renderer.drawSprite sprite
                @clickable = true

    class Thief extends Unit
        constructor: () ->
            super()

        @die: (id, entities) =>
            (renderer, turn, progress) =>
                s = entities[id].sprite
                s.texture = "death"
                s.frame = Math.floor(16 * progress)
                renderer.drawSprite s
                @clickable = true

        @bomb: (id, entities, anim) =>
            (renderer, turn, progress) =>
                ts = entities[anim.target].sprite
                ts.texture = "explosion"
                ts.frame = Math.floor(16 * progress)
                renderer.drawSprite s
                @clickable = true


    class Trap extends Unit
        constructor: () ->
            super()

    class ArrowWall extends Trap
        constructor: (game, trap) ->
            super()
            if trap < 25
                @sprite.transform = game.pyramid1.transform
            else
                @sprite.transform = game.pyramid2.transform

            @sprite.width = 1
            @sprite.height = 1
            @sprite.frame = 0

            @north = game.getTileIdAt(trap.x, trap.y - 1)
            @south = game.getTileIdAt(trap.x, trap.y + 1)
            @east = game.getTileIdAt(trap.x - 1, trap.y)
            @west = game.getTileIdAt(trap.x + 1, trap.y)

        @idleMake: (id, entities, gamedata) =>
            (renderer, turn, progress) =>
                e = entities[id]
                e.sprite.frame = 0

                j = -1
                for i in [0 ... e.posIntervals.length] by 2
                    j++
                    if e.posIntervals[i] <= turn < e.posIntervals[i+1]
                        e.sprite.position.x = e.positions[j].x
                        e.sprite.position.y = e.positions[j].y

                if entities[e.north]? and entities[e.north].type == 2
                    e.sprite.texture = "ArrowDown"
                else if entities[e.south]? and entities[e.south].type == 2
                    e.sprite.texture = "ArrowUp"
                else
                    e.sprite.texture = "ArrowSide"

                if e.start <= turn < e.end
                    e.clickable = true
                    renderer.drawSprite e.sprite
                else
                    e.clickable = false

        @activate: (id, entities) =>
            (renderer, turn, progress) =>
                entities[id].sprite.frame = Math.floor(16 * progress)
                renderer.drawSprite entities[id].sprite

    class HeadWire extends Trap
        constructor: (game, trap) ->
            super()
            @sprite.width = 1
            @sprite.height = 1

            if trap.x < 25
                @sprite.transform = game.pyramid1.transform
            else
                @sprite.transform = game.pyramid2.transform

            @north = game.getTileIdAt(trap.x, trap.y - 1)
            @south = game.getTileIdAt(trap.x, trap.y + 1)
            @east = game.getTileIdAt(trap.x - 1, trap.y)
            @west = game.getTileIdAt(trap.x + 1, trap.y)

        @idleMake: (id, entities, gamedata) =>
            (renderer, turn, progress) =>
                e = entities[id]
                e.sprite.frame = 0

                j = -1
                for i in [0 ... e.posIntervals.length] by 2
                    j++
                    if e.posIntervals[i] <= turn < e.posIntervals[i+1]
                        e.sprite.position.x = e.positions[j].x
                        e.sprite.position.y = e.positions[j].y

                if entities[e.north]? and entities[e.north].type == 2
                    e.sprite.texture = "WireVert"
                    e.sprite.height = 2
                    e.sprite.position.y--
                else
                    e.sprite.texture = "WireHoriz"
                    e.sprite.height = 1

                if e.start <= turn < e.end
                    e.clickable = true
                    renderer.drawSprite e.sprite
                else
                    e.clickable = false

        @activate: (id, entities) =>
            (renderer, turn, progress) =>
                entities[id].sprite.frame = Math.floor(16 * progress)
                renderer.drawSprite entities[id].sprite

    class RotatingWall extends Trap
        constructor: (game, trap) ->
            super()
            @sprite.width = 1
            @sprite.height = 1

            if trap.x < 25
                @sprite.transform = game.pyramid1.transform
            else
                @sprite.transform = game.pyramid2.transform

            @sprite.texture = "WallTurn"
            @sprite.position.x = trap.x
            @sprite.position.y = trap.y
            @sprite.frame = 0

        @idleMake: (id, entities, gamedata) =>
            (renderer, turn, progress) =>
                e = entities[id]
                e.sprite.frame = 0

                j = -1
                for i in [0 ... e.posIntervals.length] by 2
                    j++
                    if e.posIntervals[i] <= turn < e.posIntervals[i+1]
                        e.sprite.position.x = e.positions[j].x
                        e.sprite.position.y = e.positions[j].y

                if e.start <= turn < e.end
                    e.clickable = true
                    renderer.drawSprite e.sprite
                else
                    e.clickable = false

        @activate: (id, entities) =>
            (renderer, turn, progress) =>
                entities[id].sprite.frame = Math.floor(8 * progress)
                renderer.drawSprite entities[id].sprite


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
            @tileLookup = {}

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

            @guiBarLeft = new Renderer.Sprite()
            @guiBarLeft.texture = "guiback"
            @guiBarLeft.position.x = 5
            @guiBarLeft.position.y = 80
            @guiBarLeft.width = 42
            @guiBarLeft.height = 15

            @guiPlayer1 = new Renderer.Text()
            @guiPlayer1.position.x = 7
            @guiPlayer1.position.y = 82
            @guiPlayer1.width = 38
            @guiPlayer1.size = 25

            @guiPlayer1Scarab = new Renderer.Sprite()
            @guiPlayer1Scarab.texture = "fullscrb"
            @guiPlayer1Scarab.width = 4
            @guiPlayer1Scarab.height = 8
            @guiPlayer1Scarab.position.x = 7
            @guiPlayer1Scarab.position.y = 93 - @guiPlayer1Scarab.height

            @guiPlayer1ScarabCount = new Renderer.Text()
            @guiPlayer1ScarabCount.position.x = 11
            @guiPlayer1ScarabCount.position.y = 93 - (@guiPlayer1Scarab.height/2) - 1
            @guiPlayer1ScarabCount.width = 10
            @guiPlayer1ScarabCount.size = 18

            @guiPlayer1RoundWin = new Renderer.Text()
            @guiPlayer1RoundWin.position.x = 42
            @guiPlayer1RoundWin.position.y = 85
            @guiPlayer1RoundWin.width = 5
            @guiPlayer1RoundWin.size = 35

            @guiBarRight = new Renderer.Sprite()
            @guiBarRight.texture = "guiback"
            @guiBarRight.position.x = 53
            @guiBarRight.position.y = 80
            @guiBarRight.width = 42
            @guiBarRight.height = 15

            @guiPlayer2 = new Renderer.Text()
            @guiPlayer2.position.x = 55
            @guiPlayer2.position.y = 82
            @guiPlayer2.alignment = "right"
            @guiPlayer2.width = 38
            @guiPlayer2.size = 25

            @guiPlayer2Scarab = new Renderer.Sprite()
            @guiPlayer2Scarab.texture = "fullscrb"
            @guiPlayer2Scarab.width = 4
            @guiPlayer2Scarab.height = 8
            @guiPlayer2Scarab.position.x = 90
            @guiPlayer2Scarab.position.y = 93 - (@guiPlayer2Scarab.height)

            @guiPlayer2ScarabCount = new Renderer.Text()
            @guiPlayer2ScarabCount.alignment = "right"
            @guiPlayer2ScarabCount.position.x = 80
            @guiPlayer2ScarabCount.position.y = 93 - (@guiPlayer2Scarab.height/2) - 1
            @guiPlayer2ScarabCount.width = 10
            @guiPlayer2ScarabCount.size = 18

            @guiPlayer2RoundWin = new Renderer.Text()
            @guiPlayer2RoundWin.position.x = 55
            @guiPlayer2RoundWin.position.y = 85
            @guiPlayer2RoundWin.width = 5
            @guiPlayer2RoundWin.size = 35

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

            @endScreen = new Renderer.Rect()
            @endScreen.fillColor.setColor(1.0, 1.0, 1.0, 0.4)
            @endScreen.position.x = 0
            @endScreen.position.y = 0
            @endScreen.width = 100
            @endScreen.height = 100

            @endText = new Renderer.Text()
            @endText.alignment = "center"
            @endText.position.x = 20
            @endText.position.y = 40
            @endText.width = 60
            @endText.size = 50

            @endReason = new Renderer.Text()
            @endReason.alignment = "center"
            @endReason.position.x = 20
            @endReason.position.y = 55
            @endReason.width = 60
            @endReason.size = 35

            @sarcosCapped = new Renderer.Sprite()
            @sarcosCapped.position.x = 20
            @sarcosCapped.position.y = 90
            @sarcosCapped.width = 3
            @sarcosCapped.height = 6

        selectEntities: (renderer, turn, x, y) ->
            selections = {}

            [sw, sh] = renderer.getScreenSize()

            scw = x/(sw-20) * 2 - 1
            sch = (y-60)/(sh) * 2 + 1

            pyra1 = @pyramid1.transform.invert()

            [p1x, p1y] = pyra1.mul(scw, sch)
            p1y = -p1y

            for id,e of @entities
                if e instanceof Thief or e instanceof Trap
                    if e.sprite.transform == @pyramid1.transform
                        if e.sprite.position.x <= p1x <= e.sprite.position.x +
                            e.sprite.width and
                            e.sprite.position.y <= p1y <= e.sprite.position.y +
                            e.sprite.height and
                            e.clickable
                                selections[id] = e.states[turn]

            pyra2 = @pyramid2.transform.invert()
            [p1x, p1y] = pyra2.mul(scw, sch)
            p1x -= 1.0
            p1y = -p1y

            for id,e of @entities
                if e instanceof Thief or e instanceof Trap
                    if e.sprite.transform == @pyramid2.transform
                        if e.sprite.position.x <= p1x <= e.sprite.position.x +
                            e.sprite.width and
                            e.sprite.position.y <= p1y <= e.sprite.position.y +
                            e.sprite.height and
                            e.clickable
                                selections[id] = e.states[turn]

            return selections

        verifyEntities: (renderer, turn, selection) ->
            newselection = {}
            for id, s of selection
                if @entities[id].states[turn]? and @entities[id].clickable
                    newselection[id] = @entities[id].states[turn]
            return newselection

        getName: () -> "Pharaoh"

        preDraw: (turn, dt, renderer) ->
            renderer.drawSprite(@background)
            renderer.drawSprite(@pyramid1)
            renderer.drawSprite(@pyramid2)

            renderer.drawSprite(@guiBarLeft)
            renderer.drawText(@guiPlayer1)
            renderer.drawSprite(@guiPlayer1Scarab)
            if @gamedata.turns[turn]?
                @guiPlayer1ScarabCount.text = "x "+ @gamedata.turns[turn].Player[0].scarabs
                @guiPlayer1RoundWin.text = @gamedata.turns[turn].Player[0].roundsWon + ""
            renderer.drawText(@guiPlayer1ScarabCount)
            renderer.drawText(@guiPlayer1RoundWin)

            renderer.drawSprite(@guiBarRight)
            renderer.drawText(@guiPlayer2)
            renderer.drawSprite(@guiPlayer2Scarab)
            if @gamedata.turns[turn]?
                @guiPlayer2ScarabCount.text = @gamedata.turns[turn].Player[1].scarabs + " x"
                @guiPlayer2RoundWin.text = @gamedata.turns[turn].Player[1].roundsWon + ""
            renderer.drawText(@guiPlayer2ScarabCount)
            renderer.drawText(@guiPlayer2RoundWin)

            @sarcosCapped.position.x = 20
            @sarcosCapped.texture = "sarcblue"
            if @gamedata.turns[turn]?
                for i in [0..@gamedata.turns[turn].Player[0].sarcophagiCaptured]
                    renderer.drawSprite @sarcosCapped
                    @sarcosCapped.position.x += 5

            @sarcosCapped.position = 60
            @sarcosCapped.texture = "sarcred"
            if @gamedata.turns[turn]?
                for i in [0..@gamedata.turns[turn].Player[1].sarcophagiCaptured]
                    renderer.drawSprite @sarcosCapped
                    @sarcosCapped.position.x += 5

            for l in @pyramid1Lines
                renderer.drawLine(l)

            for l in @pyramid2Lines
                renderer.drawLine(l)

        postDraw: (turn, dt, renderer) ->
            if turn == @maxTurn
                renderer.drawRect @endScreen
                renderer.drawText @endText
                renderer.drawText @endReason

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

        loadGame: (@gamedata, renderer) ->
            @entities = {}
            @tileLookup = {}

            @maxTurn = @gamedata.turns.length
            @mapWidth = @gamedata.turns[0].mapWidth
            @mapHeight = @gamedata.turns[0].mapHeight

            @resize(renderer)

            @guiPlayer1.text = @gamedata.turns[0].Player[0].playerName
            @guiPlayer2.text = @gamedata.turns[0].Player[1].playerName
            @endText.text = "Winner: " + @gamedata.gameWinner.team
            @endReason.text = @gamedata.gameWinner.reason

            i = -1
            for turn in @gamedata.turns
                i++
                if i+1 < @maxTurn and
                    turn.roundNumber != @gamedata.turns[i+1].roundNumber
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
                            @entities[id] = new Wall(tile)
                            sp = @entities[id].sprite
                            if tile.x < 25
                                sp.transform = @pyramid1.transform
                            else
                                sp.transform = @pyramid2.transform
                            sp.position.x = tile.x
                            sp.position.y = tile.y
                            sp.width = 1
                            sp.height = 1

                            @entities[id].idle = Wall.idleMake(this, id, @entities)

                        if @entities[id].intervals.length %2 == 0
                            @entities[id].intervals.push i

                    if tile.type == 0 and @entities[id]? and
                        @entities[id].intervals.length %2 == 1
                            @entities[id].intervals.push i

                    if !@tileLookup[""+tile.x+":"+tile.y]?
                        @tileLookup[""+tile.x+":"+tile.y] = id

                for id,thief of turn.Thief
                    if !@entities[id]?
                        @entities[id] = new Thief()
                        @entities[id].sprite.position.x = thief.x
                        @entities[id].sprite.position.y = thief.y
                        if thief.x < 25
                            @entities[id].sprite.transform = @pyramid1.transform
                        else
                            @entities[id].sprite.transform = @pyramid2.transform

                        switch thief.thiefType
                            when 0
                                @entities[id].sprite.texture = "bomber"
                                @entities[id].normalTex = "bomber"
                            when 1
                                @entities[id].sprite.texture = "digger"
                                @entities[id].normalTex = "digger"
                            when 2
                                @entities[id].sprite.texture = "ninja"
                                @entities[id].normalTex = "ninja"
                            when 3
                                @entities[id].sprite.texture = "guide"
                                @entities[id].normalTex = "guide"
                            when 4
                                @entities[id].sprite.texture = "slave"
                                @entities[id].normalTex = "slave"
                        @entities[id].sprite.width = 1
                        @entities[id].sprite.height = 1
                        @entities[id].start = i
                        @entities[id].end = @maxTurn
                        @entities[id].positions.push new Renderer.Point(thief.x, thief.y)
                        @entities[id].posIntervals.push i

                        @entities[id].idle = Thief.idleMake(id, @entities, @gamedata)

                    # does not exist, or dies next turn
                    if i+1 < @maxTurn and thief.alive == 1 and
                        @gamedata.turns[i+1].Thief[id]? and
                        @gamedata.turns[i+1].Thief[id].alive == 0

                            @entities[id].end = i+1
                            @entities[id].posIntervals.push i+1

                            e = @entities[id]
                            f = Thief.die(id, @entities)
                            a = new PluginBase.Animation(i+1, i+2, f)
                            @entities[id].animations.push a

                    if i+1 < @maxTurn and !@gamedata.turns[i+1].Thief[id]? and
                        @entities[id].end == @maxTurn
                            @entities[id].end = i
                            @entities[id].posIntervals.push i

                            e = @entities[id]
                            f = Thief.die(id, @entities)
                            a = new PluginBase.Animation(i, i+1, f)
                            @entities[id].animations.push a

                    @entities[id].states["#{i}"] = thief

                for id,trap of turn.Trap
                    if !@entities[id]?
                        switch trap.trapType
                            when 0, 1, 2, 3, 4, 5, 6, 9, 10
                                @entities[id] = new Trap()
                                @entities[id].sprite.position.x = trap.x
                                @entities[id].sprite.position.y = trap.y
                                if trap.x < 25
                                    @entities[id].sprite.transform = @pyramid1.transform
                                else
                                    @entities[id].sprite.transform = @pyramid2.transform

                                switch trap.trapType
                                    when 0 #sarc
                                        if trap.x < 25
                                            @entities[id].sprite.texture = "sarcred"
                                            @entities[id].normalTex = "sarcred"
                                        else
                                            @entities[id].sprite.texture = "sarcblu"
                                            @entities[id].normalTex = "sarcblu"
                                    when 1 #spike pit
                                        @entities[id].sprite.texture = "spike"
                                        @entities[id].normalTex = "spike"
                                    when 2 #swinging blade
                                        @entities[id].sprite.texture = "SwingingBlade"
                                        @entities[id].normalTex = "SwingingBlade"
                                    when 3 #boulder
                                        @entities[id].sprite.texture = "boulder"
                                        @entities[id].normalTex = "boulder"
                                    when 4 #spider web
                                        @entities[id].sprite.texture = "web"
                                        @entities[id].normalTex = "web"
                                    when 5 #quicksand
                                        @entities[id].sprite.texture = "Quicksand"
                                        @entities[id].normalTex = "Quicksand"
                                    when 6 #oil vases
                                        @entities[id].sprite.texture = "OilVase"
                                        @entities[id].normalTex = "OilVase"
                                    when 9 #mercury pit
                                        @entities[id].sprite.texture = "MercPit"
                                        @entities[id].normalTex = "MercPit"
                                    when 10 #mummy
                                        @entities[id].sprite.texture = "mummy"
                                        @entities[id].normalTex = "mummy"

                                @entities[id].sprite.width = 1
                                @entities[id].sprite.height = 1
                                @entities[id].start = i
                                @entities[id].end = @maxTurn
                                @entities[id].positions.push new Renderer.Point(trap.x, trap.y)
                                @entities[id].posIntervals.push i

                                @entities[id].idle = Trap.idleMake(id, @entities)

                            when 7 #arrow wall
                                e = new ArrowWall(this, trap)
                                e.start = i
                                e.end = @maxTurn
                                e.sprite.position.x = trap.x
                                e.sprite.position.y = trap.y
                                e.positions.push new Renderer.Point(trap.x, trap.y)
                                e.posIntervals.push i

                                e.idle = ArrowWall.idleMake(id, @entities)
                                @entities[id] = e

                            when 8 #head wire
                                e = new HeadWire(this, trap)
                                e.start = i
                                e.end = @maxTurn
                                e.sprite.position.x = trap.x
                                e.sprite.position.y = trap.y
                                e.positions.push new Renderer.Point(trap.x, trap.y)
                                e.posIntervals.push i

                                e.idle = HeadWire.idleMake(id, @entities)
                                @entities[id] = e
                            when 11
                                e = new RotatingWall(this, trap)
                                e.start = i
                                e.end = @maxTurn
                                e.sprite.position.x = trap.x
                                e.sprite.position.y = trap.y
                                e.positions.push new Renderer.Point(trap.x, trap.y)
                                e.posIntervals.push i

                                e.idle = RotatingWall.idleMake(id, @entities)
                                @entities[id] = e

                    if i+1 < @maxTurn and @gamedata.turns[i+1].Trap[id]?
                            ent = @gamedata.turns[i+1].Trap[id]
                            if @entities[id].sprite.position.x != ent.x or
                                @entities[id].sprite.position.y != ent.y
                                    @entities[id].posIntervals.push i+1
                                    @entities[id].posIntervals.push i+1
                                    @entities[id].positions.push new Renderer.Point(ent.x, ent.y)

                    # does not exist, or dies next turn
                    if i+1 < @maxTurn and
                        @gamedata.turns[i+1].Trap[id]? and
                        @gamedata.turns[i+1].Trap[id].active == 0 and
                        @gamedata.turns[i+1].Trap[id].activationsRemaining = 0
                            @entities[id].end = i
                            @entities[id].posIntervals.push i

                    if i+1 < @maxTurn and !@gamedata.turns[i+1].Trap[id]? and
                        @entities[id].end == @maxTurn
                            @entities[id].end = i
                            @entities[id].posIntervals.push i


                    @entities[id].states["#{i}"] = trap

                for id,animList of turn.animations
                    moves = []

                    for anim in animList
                        switch(anim.type)
                            when "move"
                                moves.push anim
                            when "activate"
                                e = @entities[id]
                                f = e.activate(id, @entities, anim)
                                a = new PluginBase.Animation(i, i+1, f)
                                e.animations.push a

                    if moves.length != 0
                        e = @entities[id]
                        f = Unit.move(id, @entities, moves)
                        a = new PluginBase.Animation(i, i+1, f)
                        @entities[id].animations.push a

                        lastMove = moves[moves.length - 1]
                        e.positions.push new Renderer.Point(lastMove.toX, lastMove.toY, 0)
                        e.posIntervals.push i
                        e.posIntervals.push i+1

        getTileIdAt: (x, y) -> @tileLookup[""+x+":"+y]

        getSexpScheme: () ->
            {
                gameName : ["gameName"],
                Player : ["id", "playerName", "time", "scarabs", "roundsWon",
                         "sarcophagiCaptured"],
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
                       "scarabsForThieves", "roundsToWin",
                       "roundTurnLimit", "numberOfSarcophagi"]
            }

    return new Pharaoh
