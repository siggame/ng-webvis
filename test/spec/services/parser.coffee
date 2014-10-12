'use strict'

describe 'Service: Parser', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    Parser = {}
    beforeEach inject (_Parser_) ->
        Parser = _Parser_

    it 'should do something', ->
        expect(!!Parser).toBe true
