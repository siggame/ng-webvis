'use strict'

describe 'Service: FileLoader', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    FileLoader = {}
    beforeEach inject (_FileLoader_) ->
        FileLoader = _FileLoader_

    it 'should do something', ->
        expect(!!FileLoader).toBe true
