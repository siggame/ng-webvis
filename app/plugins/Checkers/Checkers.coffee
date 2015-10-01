`//# sourceURL=Checkers.js
`
'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.provide.factory 'Checkers', (PluginBase, Renderer, Options) ->
    class Checkers extends PluginBase.BasePlugin
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

    return new Checkers;
