`//# sourceMappingURL=Anarchy.map.js
`
'use strict'

# define block lists out the modules you'll need
# in this case it is the basePlugin class to extend
define [
    'scripts/inherits/basePlugin'
], (BasePlugin) ->
    # The explicit block lists the angular services/factories you need
    # all game logic/entity classes go inside this block
    explicit = (Options, Renderer) ->
        class Building extends BasePlugin.Entity
            constructor: () ->
                super()
                @classType = "Building"
                @type = "Building"

                @animations = []
                @startTurn = 0
                @endTurn = 0
                @clickable = true

                @id = -1
                @owner = -1
                @fire = []
                @health = []
                @exposure = null
                @maxHealth = 100
                @maxFire = 0

                @sprite = new Renderer.Sprite()
                @sprite.texture = "building"
                @sprite.width = 1
                @sprite.height = 1

                @team = new Renderer.Sprite()
                @team.texture = "graffiti1"
                @team.width = 1
                @team.height = 1
                @team.color.a = 0.5

                @fireSprite = new Renderer.Sprite()
                @fireSprite.texture = "fire"
                @fireSprite.width = 1
                @fireSprite.height = 1

                @ignite = new Renderer.Sprite()
                @ignite.texture = "explosion"
                @ignite.width = 1
                @ignite.height = 1

                @healthBar = new Renderer.Rect()
                @healthBar.fillColor = new Renderer.Color(0.0, 1.0, 0.0, 1.0)
                @healthBar.height = 0.1



            getAnimations: () -> @animations

            setx: (x) ->
                @sprite.position.x = x
                @team.position.x = x
                @fireSprite.position.x = x
                @ignite.position.x = x
                @healthBar.position.x = x

                if @hqnorth?
                    @hqnorth.x1 = x
                    @hqnorth.x2 = x + 1

                if @hqwest?
                    @hqwest.x1 = x
                    @hqwest.x2 = x

                if @hqeast?
                    @hqeast.x1 = x + 1
                    @hqeast.x2 = x + 1

                if @hqsouth?
                    @hqsouth.x1 = x
                    @hqsouth.x2 = x + 1

            sety: (y) ->
                @sprite.position.y = y
                @team.position.y = y
                @fireSprite.position.y = y
                @ignite.position.y = y
                @healthBar.position.y = y

                if @hqnorth?
                    @hqnorth.y1 = y
                    @hqnorth.y2 = y

                if @hqwest?
                    @hqwest.y1 = y
                    @hqwest.y2 = y + 1

                if @hqeast?
                    @hqeast.y1 = y
                    @hqeast.y2 = y + 1

                if @hqsouth?
                    @hqsouth.y1 = y + 1
                    @hqsouth.y2 = y + 1

            setTransform: (transform) ->
                @sprite.transform = transform
                @team.transform = transform
                @fireSprite.transform = transform
                @ignite.transform = transform
                @healthBar.transform = transform

                if @hqnorth? then @hqnorth.transform = transform
                if @hqwest? then @hqwest.transform = transform
                if @hqeast? then @hqeast.transform = transform
                if @hqsouth? then @hqsouth.transform = transform

            makeHeadquarters: () ->
                @hqnorth = new Renderer.Line(0, 0, 0, 0)
                @hqnorth.color = new Renderer.Color(0.0, 1.0, 0.0, 1.0)

                @hqwest = new Renderer.Line(0, 0, 0, 0)
                @hqwest.color = new Renderer.Color(0.0, 1.0, 0.0, 1.0)

                @hqeast = new Renderer.Line(0, 0, 0, 0)
                @hqeast.color = new Renderer.Color(0.0, 1.0, 0.0, 1.0)

                @hqsouth = new Renderer.Line(0, 0, 0, 0)
                @hqsouth.color = new Renderer.Color(0.0, 1.0, 0.0, 1.0)

            idle: (renderer, turnNum, turnProgress) ->
                spriteChanged = false
                if @health[turnNum] <= 0
                    if @sprite.texture != "rubble" then @sprite.update = true
                    @sprite.texture = "rubble"
                else
                    if @sprite.texture == "rubble" then @sprite.update = true
                    switch @type
                        when "Warehouse"
                            @sprite.texture = "building"
                        when "WeatherStation"
                            @sprite.texture = "weatherstation"
                        when "PoliceDepartment"
                            @sprite.texture = "policestation"
                        when "FireDepartment"
                            @sprite.texture = "firehouse"


                renderer.drawSprite(@sprite)

                if @fire[turnNum] > 0
                    if 0 < @fire[turnNum] < 0.25 * @maxFire
                        if @fireSprite.frame != 0 then @fireSprite.update = true
                        @fireSprite.frame = 0
                    else if 0.25 * @maxFire < @fire[turnNum] < 0.5 * @maxFire
                        if @fireSprite.frame != 1 then @fireSprite.update = true
                        @fireSprite.frame = 1
                    else if 0.5 * @maxFire < @fire[turnNum] < 0.75 * @maxFire
                        if @fireSprite.frame != 2 then @fireSprite.update = true
                        @fireSprite.frame = 2
                    else if 0.75 * @maxFire < @fire[turnNum] < @maxFire
                        if @fireSprite.frame != 3 then @fireSprite.update = true
                        @fireSprite.frame = 3
                    else if @fire[turnNum] >= @maxFire
                        if @fireSprite.frame != 4 then @fireSprite.update = true
                        @fireSprite.frame = 4

                    renderer.drawSprite(@fireSprite, 2)

                if @health[turnNum] < @maxHealth
                    if @healthBar.width != @health[turnNum]/@maxHealth
                        @healthBar.update = true
                    @healthBar.width = @health[turnNum]/@maxHealth

                    renderer.drawRect(@healthBar, 2)

                if @hqnorth?
                    renderer.drawLine(@hqnorth)
                    renderer.drawLine(@hqeast)
                    renderer.drawLine(@hqwest)
                    renderer.drawLine(@hqsouth)

                renderer.drawSprite(@team)

            @setFire: (entity, anim) =>
                (renderer, turnNum, turnProgress) =>
                    renderer.drawSprite(entity.sprite)
                    renderer.drawSprite(entity.team)
                    entity.ignite.frame = Math.floor(turnProgress * 8)
                    renderer.drawSprite(entity.ignite)

        class Road extends BasePlugin.Entity
            constructor: () ->
                super()
                @type = "Road"
                @id = -1
                @animations = []
                @startTurn = 0
                @endTurn = 0
                @sideWalkN = false
                @sideWalkS = false
                @sideWalkE = false
                @sideWalkW = false

                @sprite = new Renderer.Sprite()
                @sprite.width = 1
                @sprite.height = 1

                @sideWalkSpriteN = new Renderer.Sprite()
                @sideWalkSpriteN.texture = "sidewalkn"
                @sideWalkSpriteN.width = 1
                @sideWalkSpriteN.height = 1

                @sideWalkSpriteS = new Renderer.Sprite()
                @sideWalkSpriteS.texture = "sidewalks"
                @sideWalkSpriteS.width = 1
                @sideWalkSpriteS.height = 1

                @sideWalkSpriteE = new Renderer.Sprite()
                @sideWalkSpriteE.texture = "sidewalke"
                @sideWalkSpriteE.width = 1
                @sideWalkSpriteE.height = 1

                @sideWalkSpriteW = new Renderer.Sprite()
                @sideWalkSpriteW.texture = "sidewalkw"
                @sideWalkSpriteW.width = 1
                @sideWalkSpriteW.height = 1

            setx: (x) ->
                @sprite.position.x = x
                @sideWalkSpriteN.position.x = x
                @sideWalkSpriteS.position.x = x
                @sideWalkSpriteE.position.x = x
                @sideWalkSpriteW.position.x = x

            sety: (y) ->
                @sprite.position.y = y
                @sideWalkSpriteN.position.y = y
                @sideWalkSpriteS.position.y = y
                @sideWalkSpriteE.position.y = y
                @sideWalkSpriteW.position.y = y

            setTransform: (transform) ->
                @sprite.transform = transform
                @sideWalkSpriteN.transform = transform
                @sideWalkSpriteS.transform = transform
                @sideWalkSpriteE.transform = transform
                @sideWalkSpriteW.transform = transform

            getAnimations: () -> @animations

            idle: (renderer, turnNum, turnProgress) ->
                renderer.drawSprite(@sprite)
                if @sprite.texture == "road"
                    #@TODO, change sprite or rotate based on which sidewalk needs to be drawn
                    if @sideWalkN == true
                        renderer.drawSprite(@sideWalkSpriteN)
                    if @sideWalkS == true
                        renderer.drawSprite(@sideWalkSpriteS)
                    if @sideWalkE == true
                        renderer.drawSprite(@sideWalkSpriteE)
                    if @sideWalkW == true
                        renderer.drawSprite(@sideWalkSpriteW)

        class Anarchy extends BasePlugin.Plugin
            constructor: () ->
                super()
                @gamestates = []
                @centerCamera = new Renderer.Camera()
                @player1BuildingsLeft = []
                @player2BuildingsLeft = []
                @forecasts = {}
                @player1HQid = -1
                @player2HQid = -1

                @guiMat = new Renderer.Matrix3x3()
                @guiMat.scale(1/100, 1/100)

                @bottomRect = new Renderer.Rect()
                @bottomRect.transform = @guiMat
                @bottomRect.position.x = 0
                @bottomRect.position.y = 80
                @bottomRect.width = 100
                @bottomRect.height = 20
                @bottomRect.fillColor = new Renderer.Color(1.0, 1.0, 1.0, 1.0)

                @guiPlayer1 = new Renderer.Text()
                @guiPlayer1.transform = @guiMat
                @guiPlayer1.position.x = 5
                @guiPlayer1.position.y = 82
                @guiPlayer1.width = 38
                @guiPlayer1.size = 25

                @guiPlayer2 = new Renderer.Text()
                @guiPlayer2.transform = @guiMat
                @guiPlayer2.position.x = 55
                @guiPlayer2.position.y = 82
                @guiPlayer2.alignment = "left"
                @guiPlayer2.width = 38
                @guiPlayer2.size = 25

                @guiPlayer1BuildingText = new Renderer.Text()
                @guiPlayer1BuildingText.transform = @guiMat
                @guiPlayer1BuildingText.position.x = 5
                @guiPlayer1BuildingText.position.y = 95
                @guiPlayer1BuildingText.width = 20
                @guiPlayer1BuildingText.size = 20

                @guiPlayer2BuildingText = new Renderer.Text()
                @guiPlayer2BuildingText.transform = @guiMat
                @guiPlayer2BuildingText.position.x = 55
                @guiPlayer2BuildingText.position.y = 95
                @guiPlayer2BuildingText.alignment = "right"
                @guiPlayer2BuildingText.width = 20
                @guiPlayer2BuildingText.size = 20

                @guiPlayer1HQHealthText = new Renderer.Text()
                @guiPlayer1HQHealthText.transform = @guiMat
                @guiPlayer1HQHealthText.position.x = 5
                @guiPlayer1HQHealthText.position.y = 86
                @guiPlayer1HQHealthText.width = 12
                @guiPlayer1HQHealthText.size = 20
                @guiPlayer1HQHealthText.text = "HQ Health"

                @guiPlayer1HQHealthBar = new Renderer.Rect()
                @guiPlayer1HQHealthBar.transform = @guiMat
                @guiPlayer1HQHealthBar.position.x = 5
                @guiPlayer1HQHealthBar.position.y = 90
                @guiPlayer1HQHealthBar.width = 38
                @guiPlayer1HQHealthBar.height = 3
                @guiPlayer1HQHealthBar.fillColor = new Renderer.Color(0.0, 1.0, 0.0, 1.0)

                @guiPlayer1HQHealthBarBack = new Renderer.Rect()
                @guiPlayer1HQHealthBarBack.transform = @guiMat
                @guiPlayer1HQHealthBarBack.position.x = 5
                @guiPlayer1HQHealthBarBack.position.y = 90
                @guiPlayer1HQHealthBarBack.width = 38
                @guiPlayer1HQHealthBarBack.height = 3
                @guiPlayer1HQHealthBarBack.fillColor = new Renderer.Color(1.0, 0.0, 0.0, 1.0)

                @guiPlayer2HQHealthText = new Renderer.Text()
                @guiPlayer2HQHealthText.transform = @guiMat
                @guiPlayer2HQHealthText.position.x = 55
                @guiPlayer2HQHealthText.position.y = 86
                @guiPlayer2HQHealthText.width = 12
                @guiPlayer2HQHealthText.size = 20
                @guiPlayer2HQHealthText.text = "HQ Health"

                @guiPlayer2HQHealthBar = new Renderer.Rect()
                @guiPlayer2HQHealthBar.transform = @guiMat
                @guiPlayer2HQHealthBar.position.x = 55
                @guiPlayer2HQHealthBar.position.y = 90
                @guiPlayer2HQHealthBar.width = 38
                @guiPlayer2HQHealthBar.height = 3
                @guiPlayer2HQHealthBar.fillColor = new Renderer.Color(0.0, 1.0, 0.0, 1.0)

                @guiPlayer2HQHealthBarBack = new Renderer.Rect()
                @guiPlayer2HQHealthBarBack.transform = @guiMat
                @guiPlayer2HQHealthBarBack.position.x = 55
                @guiPlayer2HQHealthBarBack.position.y = 90
                @guiPlayer2HQHealthBarBack.width = 38
                @guiPlayer2HQHealthBarBack.height = 3
                @guiPlayer2HQHealthBarBack.fillColor = new Renderer.Color(1.0, 0.0, 0.0, 1.0)

                @endScreen = new Renderer.Rect()
                @endScreen.transform = @guiMat
                @endScreen.fillColor.setColor(1.0, 1.0, 1.0, 0.4)
                @endScreen.position.x = 0
                @endScreen.position.y = 0
                @endScreen.width = 100
                @endScreen.height = 100

                @endText = new Renderer.Text()
                @endText.transform = @guiMat
                @endText.alignment = "center"
                @endText.position.x = 20
                @endText.position.y = 40
                @endText.width = 60
                @endText.size = 50

                @endReason = new Renderer.Text()
                @endReason.transform = @guiMat
                @endReason.alignment = "center"
                @endReason.position.x = 20
                @endReason.position.y = 55
                @endReason.width = 60
                @endReason.size = 35

            selectEntities: (renderer, turn, x, y) ->
                selections = {}
                [canvasWidth, canvasHeight] = renderer.getScreenSize()

                canvasToScreen = new Renderer.Matrix3x3()
                canvasToScreen.set(0, 0, 2/canvasWidth)
                canvasToScreen.set(1, 1, -2/canvasHeight)
                canvasToScreen.set(2, 0, -1)
                canvasToScreen.set(2, 1, 1)

                [sw, sh] = canvasToScreen.mul(x, y)
                sw = ((1/@centerCamera.getZoomFactor()) * sw) + @centerCamera.getTransX()
                sh = ((1/@centerCamera.getZoomFactor()) * sh) + @centerCamera.getTransY()

                screenToWorld = new Renderer.Matrix3x3()
                screenToWorld.set(0, 0, @mapWidth/2)
                screenToWorld.set(1, 1, -(@mapHeight + ((1/5) * @mapHeight) + 1)/2)
                screenToWorld.set(2, 0, @mapWidth/2)
                screenToWorld.set(2, 1, (@mapHeight + ((1/5) * @mapHeight) + 1)/2)

                [newx, newy] = screenToWorld.mul(sw, sh)
                console.log newx + " " + newy

                for id, e of @entities
                    if e.classType == "Building"

                        if e.sprite.position.x <= newx <= e.sprite.position.x + e.sprite.width and
                            e.sprite.position.y <= newy <= e.sprite.position.y + e.sprite.height and
                            e.clickable
                                newSelection = {}
                                newSelection.id = id
                                newSelection.x = e.sprite.position.x
                                newSelection.y = e.sprite.position.y
                                newSelection.fire = e.fire[turn]
                                newSelection.owner = e.owner
                                newSelection.type = e.type
                                if e.exposure != null
                                    newSelection.exposure = e.exposure[turn]
                                newSelection.health = e.health[turn]
                                selections[id] = newSelection

                return selections


            verifyEntities:(renderer, turn, selection) ->
                for s in selection
                    s.fire = e.fire[turn]
                    if e.exposure != null
                        s.exposure = e.exposure[turn]
                    s.health = e.health[turn]
                    selections[id] = newSelection

                return selection

            getName: () -> 'Anarchy'

            preDraw: (turn, dt, renderer) ->
                renderer.setCamera(@centerCamera)

            postDraw: (turn, dt, renderer) ->
                renderer.resetCamera()
                renderer.drawRect(@bottomRect, 1)
                @bottomRect.update = true
                renderer.drawText(@guiPlayer1, 1)
                renderer.drawText(@guiPlayer2, 1)

                renderer.drawText(@guiPlayer1HQHealthText, 1)
                renderer.drawText(@guiPlayer2HQHealthText, 1)

                renderer.drawRect(@guiPlayer1HQHealthBarBack, 1)
                renderer.drawRect(@guiPlayer2HQHealthBarBack, 1)

                hq1 = @entities[@player1HQid]
                @guiPlayer1HQHealthBar.width = (hq1.health[turn]  / 1000) * 38
                renderer.drawRect(@guiPlayer1HQHealthBar, 1)

                hq2 = @entities[@player2HQid]
                @guiPlayer2HQHealthBar.width = (hq2.health[turn] / 1000) * 38
                renderer.drawRect(@guiPlayer2HQHealthBar, 1)

                @guiPlayer1BuildingText.text = "Buildings Left: " + @player1BuildingsLeft[turn]
                renderer.drawText(@guiPlayer1BuildingText, 1)

                @guiPlayer2BuildingText.text = "Buildings Left: " + @player2BuildingsLeft[turn]
                renderer.drawText(@guiPlayer2BuildingText, 1)

                if turn == @maxTurn
                    renderer.drawRect(@endScreen, 1)
                    renderer.drawText(@endText, 1)
                    renderer.drawText(@endReason, 1)

            resize: (renderer) ->

            loadGame: (@gamedata, renderer, inputManager) ->
                animations = []
                turnNum = 0

                renderer.setCamera(@centerCamera)

                zoominAction = @_zoomIn(renderer, inputManager)
                inputManager.setMouseAction("wheelUp", "zoomin", zoominAction)
                inputManager.setMouseAction("wheelDown", "zoomout", @_zoomOut())

                pressed = false
                lastx = 0
                lasty = 0
                inputManager.setMouseAction("press", "grab", (e) =>
                    pressed = true
                    lastx = e.pageX
                    lasty = e.pageY
                )
                inputManager.setMouseAction("release", "release", (e) =>
                    pressed = false
                )
                inputManager.setMouseAction("move", "translate", (e) =>
                    if pressed
                        [canvasWidth, canvasHeight] = renderer.getScreenSize()
                        deltax = (e.pageX - lastx) / canvasWidth
                        deltay = (e.pageY - lasty) / canvasHeight
                        lastx = e.pageX
                        lasty = e.pageY

                        @centerCamera.setTransX( @centerCamera.getTransX() - deltax)
                        @centerCamera.setTransY( @centerCamera.getTransY() + deltay)
                )

                player1id = -1
                player2id = -1

                for turn in @gamedata.turns
                    if turn.type == "start"
                        animations.push []
                        @mapWidth = turn.game.mapWidth
                        @mapHeight = turn.game.mapHeight

                        @worldMat = new Renderer.Matrix3x3()
                        @worldMat.scale(1/@mapWidth, 1/(@mapHeight + ((1/5) * @mapHeight) + 1))

                        @guiPlayer1.text = turn.game.gameObjects[turn.game.players[0].id].name
                        @guiPlayer2.text = turn.game.gameObjects[turn.game.players[1].id].name

                        player1id = turn.game.players[0].id
                        player2id = turn.game.players[1].id
                        @player1HQid = turn.game.gameObjects[player1id].headquarters.id
                        @player2HQid = turn.game.gameObjects[player2id].headquarters.id

                        # initialize 2d array of entities to null
                        map = []
                        for i in [0..@mapWidth-1]
                            temp = []
                            for j in [0..@mapHeight-1]
                                temp.push null
                            map.push temp

                        @_initBuildings(turn, map)
                        @_initRoads(map)

                        for id, obj of turn.game.gameObjects
                            if obj.gameObjectName == "Forecast"
                                @forecasts[id] = obj

                        # insert all entities into the entity pool
                        for row in map
                            for ent in row
                                type = ent.type
                                if ent != null
                                    @entities[ent.id] = ent


                    else if turn.type == "ran"
                        animations[animations.length - 1].push turn

                    else if turn.type == "finished"
                        console.log "current turn " + turnNum
                        turnNum++
                        @gamestates.push(turn.game)

                        if turn.game.gameObjects[player1id]?
                            player1 = turn.game.gameObjects[player1id]
                            if player1.won?
                                if player1.won
                                    @endText.text = "Winner: " + @guiPlayer1.text
                                    @endReason.text = player1.reasonWon

                        if turn.game.gameObjects[player2id]?
                            player2 = turn.game.gameObjects[player2id]
                            if player2.won?
                                if player2.won
                                    @endText.text = "Winner: " + @guiPlayer2.text
                                    @endReason.text = player2.reasonWon


                        for own eid, eobj of @entities
                            if eobj.classType == "Building"
                                if turn.game.gameObjects[eid]?
                                    state = turn.game.gameObjects[eid]
                                    #setting fire array state for building entity
                                    if state.fire?
                                        eobj.fire.push state.fire
                                    else
                                        eobj.fire.push eobj.fire[eobj.fire.length - 1]
                                    #setting health array state for building entity
                                    if state.health?
                                        eobj.health.push state.health
                                    else
                                        eobj.health.push eobj.health[eobj.health.length - 1]

                                    if eobj.exposure == null then continue
                                    #setting exposure array state for building entity
                                    if state.exposure?
                                        eobj.exposure.push state.exposure
                                    else
                                        eobj.exposure.push eobj.exposure[eobj.exposure.length - 1]
                                else
                                    eobj.fire.push eobj.fire[eobj.fire.length - 1]
                                    eobj.health.push eobj.health[eobj.health.length - 1]
                                    if eobj.exposure != null
                                        eobj.exposure.push eobj.exposure[eobj.exposure.length - 1]

                        animations.push []



                @maxTurn = animations.length - 1

                for i in [0..@maxTurn]
                    p1 = 0
                    p2 = 0
                    for id, obj of @entities
                        if obj.classType == "Building"
                            if obj.owner == "0" and obj.health[i] > 0
                                p1++
                            if obj.owner == "1" and obj.health[i] > 0
                                p2++

                    @player1BuildingsLeft.push p1
                    @player2BuildingsLeft.push p2

                meh = 6
                meh = 7




            getSexpScheme: () -> null

            _initBuildings: (turn, map) ->
                for id, obj of turn.game.gameObjects
                    type = obj.gameObjectName

                    if type != "Warehouse" and type != "WeatherStation" and type != "PoliceDepartment" and type != "FireDepartment"
                        continue

                    map[obj.x][obj.y] = newBldg = new Building

                    if obj.owner.id == "0"
                        newBldg.team.texture = "graffiti1"
                    else
                        newBldg.team.texture = "graffiti2"

                    #newBldg.team.texture = if obj.owner == 0 then "graffiti1" else "graffiti2"
                    switch type
                        when "Warehouse"
                            newBldg.type = "Warehouse"
                            newBldg.sprite.texture = "building"
                        when "WeatherStation"
                            newBldg.type = "WeatherStation"
                            newBldg.sprite.texture = "weatherstation"
                        when "PoliceDepartment"
                            newBldg.type = "PoliceDepartment"
                            newBldg.sprite.texture = "policestation"
                        when "FireDepartment"
                            newBldg.type = "FireDepartment"
                            newBldg.sprite.texture = "firehouse"
                    newBldg.id = obj.id
                    newBldg.owner = obj.owner.id
                    if obj.isHeadquarters
                        newBldg.makeHeadquarters()

                    newBldg.setTransform(@worldMat)
                    newBldg.setx(obj.x)
                    newBldg.sety(obj.y)
                    newBldg.maxFire = turn.game.maxFire



                    #initialize start states
                    newBldg.fire.push obj.fire
                    newBldg.health.push obj.health
                    if obj.exposure?
                        newBldg.exposure = []
                        newBldg.exposure.push obj.exposure

            _initRoads: (map) ->
                # logic for tiles
                isRoad = false
                north3 = 0
                south3 = 0
                east3 = 0
                west3 = 0
                for i in [0..@mapWidth-1]
                    for j in [0..@mapHeight-1]
                        if map[i][j] == null
                            map[i][j] = newRoad = new Road
                            newRoad.setTransform(@worldMat)
                            newRoad.id = "road" + i + " " + j
                            newRoad.setx(i)
                            newRoad.sety(j)
                            if i > 0
                                # West
                                if map[i-1][j] != null and map[i-1][j].type != "Road"
                                    newRoad.sideWalkW = true
                                    isRoad = true
                                else
                                    west3 += 1

                                #North West
                                if j > 0
                                    if map[i-1][j-1] != null and map[i-1][j-1].type != "Road"
                                        isRoad = true
                                    else
                                        north3 += 1
                                        west3 += 1

                                #South West
                                if j < @mapHeight - 1
                                    if map[i-1][j+1] != null and map[i-1][j+1].type != "Road"
                                        isRoad = true
                                    else
                                        south3 += 1
                                        west3 += 1
                            else
                                newRoad.sideWalkW = true
                                isRoad = true

                            if i < @mapWidth-1
                                #East
                                if map[i+1][j] != null and map[i+1][j].type != "Road"
                                    newRoad.sideWalkE = true
                                    isRoad = true
                                else
                                    east3 += 1

                                #North East
                                if j > 0
                                    if map[i+1][j-1] != null and map[i+1][j-1].type != "Road"
                                        isRoad = true
                                    else
                                        north3 += 1
                                        east3 += 1

                                #South East
                                if j < @mapHeight - 1
                                    if map[i+1][j+1] != null and map[i+1][j+1].type != "Road"
                                        isRoad = true
                                    else
                                        south3 += 1
                                        east3 += 1

                            else
                                newRoad.sideWalkE = true
                                isRoad = true

                            if j > 0
                                #North
                                if map[i][j-1] != null and map[i][j-1].type != "Road"
                                    newRoad.sideWalkN = true
                                    isRoad = true
                                else
                                    north3 += 1
                            else
                                newRoad.sideWalkN = true
                                isRoad = true

                            if j < @mapHeight-1
                                #South
                                if map[i][j+1] != null and map[i][j+1].type != "Road"
                                    newRoad.sideWalkS = true
                                    isRoad = true
                                else
                                    south3 += 1
                            else
                                newRoad.sideWalkS = true
                                isRoad = true


                            #replacing the road with building
                            if isRoad == false
                                newRoad.sprite.texture = "drab"
                            #if adjacent/diagonal building, keeping it road
                            else
                                newRoad.sprite.texture = "road"
                                isbuildingNorth = newRoad.sideWalkN
                                isbuildingSouth = newRoad.sideWalkS
                                isbuildingEast = newRoad.sideWalkE
                                isbuildingWest = newRoad.sideWalkW
                                if isbuildingEast != true and isbuildingWest != true
                                    if north3 == 3
                                        newRoad.sideWalkN = true
                                    if south3 == 3
                                        newRoad.sideWalkS = true
                                if isbuildingNorth != true and isbuildingSouth != true
                                    if east3 == 3
                                        newRoad.sideWalkE = true
                                    if west3 == 3
                                        newRoad.sideWalkW = true

                        isRoad = false
                        north3 = 0
                        south3 = 0
                        east3 = 0
                        west3 = 0

            _zoomIn: (renderer, inputManager) -> () =>
                zoomFactor = @centerCamera.getZoomFactor()
                zoomFactor = zoomFactor + Math.pow(0.05, 1/ zoomFactor)
                @centerCamera.setZoomFactor(zoomFactor)

                [x, y] = inputManager.getMousePosition()
                [canvasWidth, canvasHeight] = renderer.getScreenSize()

                canvasToScreen = new Renderer.Matrix3x3()
                canvasToScreen.set(0, 0, 2/canvasWidth)
                canvasToScreen.set(1, 1, -2/canvasHeight)
                canvasToScreen.set(2, 0, -1)
                canvasToScreen.set(2, 1, 1)
                [screenX, screenY] = canvasToScreen.mul(x, y)

                screenX *= 1/zoomFactor
                screenY *= 1/zoomFactor

                realx = @centerCamera.getTransX() + screenX
                realy = @centerCamera.getTransY() + screenY

                vecx = realx - @centerCamera.getTransX()
                vecy = realy - @centerCamera.getTransY()

                newx = @centerCamera.getTransX() + ((1/10) * vecx)
                newy = @centerCamera.getTransY() + ((1/10) * vecy)

                @centerCamera.setTransX(newx)
                @centerCamera.setTransY(newy)

            _zoomOut: () -> () =>
                zoomFactor = @centerCamera.getZoomFactor()
                zoomFactor = zoomFactor - Math.pow(0.05, 1/ zoomFactor)
                if zoomFactor < 1
                    @centerCamera.setZoomFactor(1)
                    zoomFactor = 1
                else
                    @centerCamera.setZoomFactor(zoomFactor)

        return Anarchy

    # the dependencies are manually specified
    explicit.$inject = ['Options', 'Renderer']

    # the constructor function for the main checkers object is returned here
    return angular.module('webvisApp').injector.invoke(explicit)
