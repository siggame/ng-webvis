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
                @type = "Building"
                @animations = []
                @startTurn = 0
                @endTurn = 0
                @sprite = new Renderer.Sprite()
                @fire = new Renderer.Sprite()
                #setup fire sprite
                @ignite = new Renderer.Sprite()

                #setup ignite sprite
                @id = -1


            getAnimations: () -> @animations

            idle: (renderer, turnNum, turnProgress) ->
                if @sprite.texture != null
                    renderer.drawSprite(@sprite)

            @setFire: (entity) =>
                (renderer, turnNum, turnProgress) =>
                    renderer.drawSprite(entity.sprite)
                    entity.ignite.frame = Math.floor(turnProgress * 8)
                    renderer.drawSprite(entity.ignite)

        class Road extends BasePlugin.Entity
            constructor: () ->
                super()
                @type = "Road"
                @animations = []
                @startTurn = 0
                @endTurn = 0
                @sprite = new Renderer.Sprite()
                @sideWalkSprite = new Renderer.Sprite()
                @id = -1
                @sideWalkN = false
                @sideWalkS = false
                @sideWalkE = false
                @sideWalkW = false

            getAnimations: () -> @animations

            idle: (renderer, turnNum, turnProgress) ->
                if @startTurn <= turnNum < @endTurn
                    console.log "drawing road sprite"
                    renderer.drawSprite(@sprite)
                    if @sprite.texture == "road"
                        #@TODO, change sprite or rotate based on which sidewalk needs to be drawn
                        if @sideWalkN == true
                            renderer.drawSprite(@sideWalkSprite)
                        if @sideWalkS == true
                            renderer.drawSprite(@sideWalkSprite)
                        if @sideWalkE == true
                            renderer.drawSprite(@sideWalkSprite)
                        if @sideWalkW == true
                            renderer.drawSprite(@sideWalkSprite)

        class Anarchy extends BasePlugin.Plugin
            constructor: () ->
                super()
                @gamestates = []

            selectEntities: (renderer, turn, x, y) ->

            verifyEntities:(renderer, turn, selection) ->

            getName: () -> 'Anarchy'

            preDraw: (turn, dt, renderer) ->

            postDraw: (turn, dt, renderer) ->

            resize: (renderer) ->

            loadGame: (@gamedata, renderer) ->
                animations = []
                j = 0

                console.log "starting the loadgame function"
                for turn in @gamedata.turns
                    if turn.type == "start"
                        animations.push []
                        @mapWidth = turn.game.mapWidth
                        @mapHeight = turn.game.mapHeight

                        @worldMat = new Renderer.Matrix3x3()
                        @worldMat.copy(renderer.getProjection())
                        @worldMat.scale(100/@mapWidth, 100/@mapHeight)

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
                            switch type
                                when "Warehouse"
                                    newBldg.type = "Warehouse"
                                    newBldg.sprite.texture = "building"
                                when "WeatherStation"
                                    newBldg.type = "WeatherStation"
                                    newBldg.sprite.texture = "building"
                                when "PoliceDepartment"
                                    newBldg.type = "PoliceDepartment"
                                    newBldg.sprite.texture = "policestation"
                                when "FireDepartment"
                                    newBldg.type = "FireDepartment"
                                    newBldg.sprite.texture = "firehouse"
                            newBldg.id = obj.id
                            newBldg.sprite.transform = @worldMat
                            newBldg.sprite.position.x = obj.x
                            newBldg.sprite.position.y = obj.y
                            newBldg.sprite.width = 1
                            newBldg.sprite.height = 1


                        ###
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
                                    newRoad.sprite.transform = @worldMat
                                    if i > 0
                                        #North
                                        if map[i-1][j] != null and map[i-1][j].type != "Road"
                                            newRoad.sideWalkN = true
                                            isRoad = true
                                        else
                                            north3 += 1
                                    #North West
                                    else if j > 0
                                        if map[i-1][j-1] != null and map[i-1][j].type != "Road"
                                            isRoad = true
                                        else
                                            north3 += 1
                                            west3 += 1
                                    #North East
                                    else if j < @mapWidth - 1
                                        if map[i-1][j+1] != null and map[i-1][j].type != "Road"
                                            isRoad = true
                                        else
                                            north3 += 1
                                            east3 += 1
                                    else
                                        newRoad.sideWalkN = true
                                        isRoad = true

                                    if i < @mapHeight-1
                                        #South
                                        if map[i+1][j] != null and map[i-1][j].type != "Road"
                                            newRoad.sideWalkS = true
                                            isRoad = true
                                        else
                                            south3 += 1
                                    #South West
                                    else if j > 0
                                        if map[i+1][j-1] != null and map[i-1][j].type != "Road"
                                            isRoad = true
                                        else
                                            south3 += 1
                                            west3 += 1
                                    #South East
                                    else if j < @mapWidth - 1
                                        if map[i+1][j+1] != null and map[i-1][j].type != "Road"
                                            isRoad = true
                                        else
                                            south3 += 1
                                            east3 += 1

                                    else
                                        newRoad.sideWalkS = true
                                        isRoad = true

                                    if j > 0
                                        #West
                                        if map[i][j-1] != null and map[i-1][j].type != "Road"
                                            newRoad.sideWalkW = true
                                        else
                                            west3 += 1
                                    else
                                        newRoad.sideWalkW = true
                                        isRoad = true

                                    if i < @mapWidth-1
                                        #East
                                        if map[i][j+1] != null and map[i-1][j].type != "Road"
                                            newRoad.sideWalkE = true
                                            isRoad = true
                                        else
                                            east3 += 1
                                    else
                                        newRoad.sideWalkE = true
                                        isRoad = true


                                    #replacing the road with building
                                    if isRoad == false
                                        newRoad.sprite.texture = "building"
                                    #if adjacent/diagonal building, keeping it road
                                    else
                                        newRoad.sprite.texture = "road"
                                        if north3 == 3
                                            map[i][j].sideWalkN = true
                                        if south3 == 3
                                            map[i][j].sideWalkS = true
                                        if east3 == 3
                                            map[i][j].sideWalkE = true
                                        if west3 == 3
                                            map[i][j].sideWalkW = true

                                isRoad = false
                                north3 = 0
                                south3 = 0
                                east3 = 0
                                west3 = 0

                        ###
                        console.log "start function blah"
                        console.log map
                        for row in map
                            for ent in row
                                if ent != null
                                    console.log ent.id
                                    @entities[ent.id] = ent

                    else if turn.type == "ran"
                        animations[animations.length - 1].push turn

                    else if turn.type == "finished"
                        console.log "current turn " + j
                        j++
                        @gamestates.push(turn.game)
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
