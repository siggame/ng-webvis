'use strict'

describe 'Service: Renderer', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    Renderer = {}
    beforeEach inject (_Renderer_) ->
        Renderer = _Renderer_

    it 'should do something', ->
        expect(!!Renderer).toBe true
