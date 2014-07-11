'use strict'

describe 'Service: Game', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    Game = {}
    beforeEach inject (_Game_) ->
        Game = _Game_

    it 'should have a minimum turn of zero turns', ->
        console.log Game
        expect(Game.minTurn).toBe 0
