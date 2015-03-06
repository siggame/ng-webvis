'use strict'

describe 'Service: PluginManager', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    PluginManager = {}
    beforeEach inject (_PluginManager_) ->
        PluginManager = _PluginManager_

    it 'should do something', ->
        expect(!!PluginManager).toBe true
