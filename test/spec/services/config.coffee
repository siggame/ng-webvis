'use strict'

describe 'Service: config', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    config = {}
    beforeEach inject (_config_) ->
        config = _config_

    it 'should have a version', ->
        expect(!!config.version).toBe true

    it 'should have an alert section', ->
        expect(!!config.alert).toBe true
        expect(!!config.alert.timeoutAfter).toBe true
