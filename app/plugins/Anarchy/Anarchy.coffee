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
                @fire = []
                @health = []
                @exposure = null
                @maxHealth = 100

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


            getAnimations: () -> @animations

            setx: (x) ->
                @sprite.position.x = x
                @team.position.x = x
                @fireSprite.position.x = x
                @ignite.position.x = x

            sety: (y) ->
                @sprite.position.y = y
                @team.position.y = y
                @fireSprite.position.y = y
                @ignite.position.y = y

            setTransform: (transform) ->
                @sprite.transform = transform
                @team.transform = transform
                @fireSprite.transform = transform
                @ignite.transform = transform

            idle: (renderer, turnNum, turnProgress) ->
                if @sprite.texture != null
                    renderer.drawSprite(@sprite)
                    renderer.drawSprite(@team)

            @setFire: (entity) =>
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
                screenToWorld.set(1, 1, -@mapHeight/2)
                screenToWorld.set(2, 0, @mapWidth/2)
                screenToWorld.set(2, 1, @mapHeight/2)

                [newx, newy] = screenToWorld.mul(sw, sh)

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
                                if e.exposure != null
                                    newSelection.exposure = e.exposure[turn]
                                newSelection.health = e.health[turn]
                                selections[id] = newSelection

                return selections


            verifyEntities:(renderer, turn, selection) ->
                return selections

            getName: () -> 'Anarchy'

            preDraw: (turn, dt, renderer) ->

            postDraw: (turn, dt, renderer) ->

            resize: (renderer) ->

            loadGame: (@gamedata, renderer, inputManager) ->
                animations = []
                turnNum = 0

                @centerCamera = new Renderer.Camera()

                inputManager.setMouseAction("wheelUp", "zoomin", ()=>
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
                )
                inputManager.setMouseAction("wheelDown", "zoomout", ()=>
                    zoomFactor = @centerCamera.getZoomFactor()
                    zoomFactor = zoomFactor - Math.pow(0.05, 1/ zoomFactor)
                    if zoomFactor < 1
                        @centerCamera.setZoomFactor(1)
                        zoomFactor = 1
                    else
                        @centerCamera.setZoomFactor(zoomFactor)
                )
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

                renderer.setCamera(@centerCamera)

                console.log "starting the loadgame function"
                for turn in @gamedata.turns
                    if turn.type == "start"
                        animations.push []
                        @mapWidth = turn.game.mapWidth
                        @mapHeight = turn.game.mapHeight

                        @worldMat = new Renderer.Matrix3x3()
                        @worldMat.scale(1/@mapWidth, 1/@mapHeight)

                        map = []
                        for i in [0..@mapWidth-1]
                            temp = []
                            for j in [0..@mapHeight-1]
                                temp.push null
                            map.push temp
                        for id, obj of turn.game.gameObjects
                            type = obj.gameObjectName

                            if type != "Warehouse" and type != "WeatherStation" and type != "PoliceDepartment" and type != "FireDepartment"
                                continue

                            console.log "found a building"
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
                            newBldg.setTransform(@worldMat)
                            newBldg.setx(obj.x)
                            newBldg.sety(obj.y)

                            #initialize start states
                            newBldg.fire.push obj.fire
                            newBldg.health.push obj.health
                            if obj.exposure?
                                newBldg.exposure = []
                                newBldg.exposure.push obj.exposure

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
                ###
                for i in [0..animations.length - 1]
                    for anim in animations[i]
                        if anim.data.run.functionName == "ignite"
                            burnie = anim.data.run.args.building.id
                            bribed = anim.data.run.caller.id

                            f = Building.setFire(@entities[burnie])
                            a = new BasePlugin.Animation(i, i+1, f)

                            console.log @entities
                            ent = @entities[burnie]
                            if ent?
                              ent.animations.push a
                ###


            getSexpScheme: () -> null

        return Anarchy

    # the dependencies are manually specified
    explicit.$inject = ['Options', 'Renderer']

    # the constructor function for the main checkers object is returned here
    return angular.module('webvisApp').injector.invoke(explicit)
