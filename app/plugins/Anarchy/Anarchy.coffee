`//# sourceMappingURL=Anarchy.map.js
`
'use strict'

# define block lists out the modules you'll need
# in this case it is the basePlugin class to extend
define[
    'scripts/inherits/basePlugin'
], (BasePlugin) ->
    # The explicit block lists the angular services/factories you need
    # all game logic/entity classes go inside this block
    explicit = (Options, Renderer) ->
        class Anarchy extends BasePlugin.Plugin
            constructor: () ->
                super()

            selectEntities: (renderer, turn, x, y) ->

            verifyEntities:(renderer, turn, selection) ->

            getName: () -> 'Checkers'

            preDraw: (turn, dt, renderer) ->

            postDraw: (turn, dt, renderer) ->

            resize: (renderer) ->

            loadGame: (@gamedata, renderer) ->

            getSexpScheme: () -> null

        return Anarchy

    # the dependencies are manually specified
    explicit.$inject = ['Options', 'Renderer']

    # the constructor function for the main checkers object is returned here
    return angular.module('webvisApp').injector.invoke(explicit)