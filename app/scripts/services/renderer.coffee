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
    @lastAnimateTime = null
    
    @getCurrentTurn = () -> Game.getCurrentTurn()

    @getPlaybackSpeed = () -> Game.getPlaybackSpeed()

    @getEntities = () -> Game.getEntities()

    @setRenderer = (element) ->
        @renderer = element

    @start = () ->
	lastAnimate = new Date()
	@lastAnimateTime = lastAnimate.getTime
        requestAnimationFrame @animate

    @updateTime = () ->
	currentDate = new Date()
	currentTime = currentDate.getTime
	curTurn = @getCurrentTurn + @turnProgress
	dtSeconds = (currentTime - @lastAnimateTime)/1000
	curTurn += @getPlaybackSpeed * dtSeconds  
	Game.setTurn(window.parseInt(curTurn))
	turnProgress = curTurn - window.parseInt(curTurn)

    @animate = () ->
	@updateTime
        entities = do @getEntities
        entities.each (entity) ->
            entity.draw @getCurrentTurn(), @turnProgress

        @turnProgress += @getPlaybackSpeed()
        requestAnimationFrame @animate

    return this
