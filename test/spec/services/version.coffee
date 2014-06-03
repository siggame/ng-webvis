'use strict'

describe 'Service: version', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    version = {}
    beforeEach inject (_version_) ->
        version = _version_

    it 'have a version set', ->
        expect(!!version).toBe true
