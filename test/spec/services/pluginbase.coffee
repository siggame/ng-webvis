'use strict'

describe 'Service: PluginBase', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    PluginBase = {}
    beforeEach inject (_PluginBase_) ->
        PluginBase = _PluginBase_

    it 'should do something', ->
        expect(!!PluginBase).toBe true
