'use strict'

###*
 # @ngdoc service
 # @name webvisApp.Renderer
 # @description
 # # Renderer
 # Service in the webvisApp.
###
webvisApp = angular.module('webvisApp')

webvisApp.service 'Renderer', (Game)->
    @entities = []
    @turnProgress = 0

    @setEntities = (entities) ->
        @entities = _(entities)
        Game.setTurn(0)
        do @start

    @getCurrentTurn = () -> Game.getCurrentTurn()

    @getPlaybackSpeed = () -> Game.getPlaybackSpeed()

    @start = () ->
        requestAnimationFrame @animate

    @animate = () ->
        @entities.each (entity) ->
            entity.draw @getCurrentTurn(), @turnProgress

        @turnProgress += @getPlaybackSpeed()
        requestAnimationFrame @animate

    return this
