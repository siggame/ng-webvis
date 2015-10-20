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
        class DigDug extends BasePlugin.Entity
            constructor: () ->
                super()
                @animations = []
                @startTurn = 0
                @endTurn = 0
                @sprite = new Renderer.Sprite()
                @drawEnabled = false

            getAnimations: () -> @animations

            idle: (renderer, turnNum, turnProgress) ->
                console.log "calling digdug animation " + turnNum
                if @startTurn <= turnNum < @endTurn
                    renderer.drawSprite(@sprite)


        class Anarchy extends BasePlugin.Plugin
            constructor: () ->
                super()

            selectEntities: (renderer, turn, x, y) ->

            verifyEntities:(renderer, turn, selection) ->

            getName: () -> 'Anarchy'

            preDraw: (turn, dt, renderer) ->

            postDraw: (turn, dt, renderer) ->

            resize: (renderer) ->

            loadGame: (@gamedata, renderer) ->
                @mapWidth = 40
                @mapHeight = 20
                @maxTurn = 50

                @entities["blah1"] = new DigDug();
                blah1 = @entities["blah1"]
                blah1.startTurn = 10
                blah1.endTurn = 20

                blah1.sprite.texture = "myUnit"
                blah1.sprite.position.x = 20
                blah1.sprite.position.y = 20
                blah1.sprite.width = 20
                blah1.sprite.height = 20

            getSexpScheme: () -> null

        return Anarchy

    # the dependencies are manually specified
    explicit.$inject = ['Options', 'Renderer']

    # the constructor function for the main checkers object is returned here
    return angular.module('webvisApp').injector.invoke(explicit)