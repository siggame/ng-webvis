'use strict'

###*
 # @ngdoc service
 # @name webvisApp.droids
 # @description
 # # droids
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')
webvisApp.service 'Plugin', (Parser, PluginBase)->

    class Bunny extends PluginBase.BaseEntity
        constructor: () ->
            @texture = PIXI.Texture.fromImage("images/bunny.png")
            @sprite = new PIXI.Sprite(@texture)
            @sprite.anchor.x = 0.5
            @sprite.anchor.y = 0.5
            @sprite.position.x = 20
            @sprite.position.y = 20
            @sprite.going_down = true
            @sprite.going_right = true

        getSprite: () -> @sprite

        getAnimations: () => [
            new PluginBase.Animation 0, 300, (turn, progress) =>
                @sprite.rotation += 0.1
        ]



    class Droids extends PluginBase.BasePlugin
        parse: (logfile) ->
            return Parser.SexpParser.parse logfile

        getName: () -> "Droids"

        getMaxTurn: () -> 300

        getEntities: (gameLog) -> [
            new Bunny()
        ]

    return new Droids
