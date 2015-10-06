`//# sourceMappingURL=Checkers.map.js
`
'use strict'

# The define block lists out the modules you'll need
# in this case it is the basePlugin class to extend
define [
    'scripts/inherits/basePlugin'
] , (BasePlugin) ->
    # The explicit block lists the angular services/factories you need
    # all game logic/entity classes go inside this block
    explicit = (Options, Renderer) ->
        class Checkers extends BasePlugin.Plugin
            constructor: () ->
                super()
                @checkersOptions = []
                Options.addPage "Checkers", @checkersOptions

            selectEntities: (renderer, turn, x, y) ->

            verifyEntities:(renderer, turn, selection) ->

            getName: () -> 'Checkers'

            predraw: (turn, dt, renderer) ->

            postdraw: (turn, dt, renderer) ->

            resize: (renderer) ->

            loadGame: (@gamedata, renderer) ->

            getSexpScheme: () -> null

        return Checkers

    # the dependencies are manually injected here
    explicit.$inject = ['Options', 'Renderer']
    $injector = angular.injector(['webvisApp'])

    # the constructor function for the main checkers object is returned here
    return $injector.invoke(explicit)
