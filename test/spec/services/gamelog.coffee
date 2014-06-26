'use strict'

describe 'Service: GameLog', ->

  # load the service's module
  beforeEach module 'webvisApp'

  # instantiate service
  GameLog = {}
  beforeEach inject (_GameLog_) ->
    GameLog = _GameLog_

  it 'should do something', ->
    expect(!!GameLog).toBe true
