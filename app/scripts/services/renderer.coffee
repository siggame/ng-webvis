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
    @turnProgress = 0
    @renderer = null

    @getCurrentTurn = () -> Game.getCurrentTurn()

    @getPlaybackSpeed = () -> Game.getPlaybackSpeed()

    @getEntities = () -> Game.getEntities()

    @setRenderer = (element) ->
        @renderer = element

    @start = () ->
        requestAnimationFrame @animate

    @animate = () ->
        entities = do @getEntities
        entities.each (entity) ->
            entity.draw @getCurrentTurn(), @turnProgress

        @turnProgress += @getPlaybackSpeed()
        requestAnimationFrame @animate

    return this
