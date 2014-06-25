'use strict'

describe 'Service: alert', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    alert = {}
    beforeEach inject (_alert_) ->
        alert = _alert_

    it 'should do something', ->
        expect(!!alert).toBe true
