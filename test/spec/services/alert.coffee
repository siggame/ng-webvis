'use strict'

describe 'Service: alert', ->

    # load the service's module
    beforeEach module 'webvisApp'

    # instantiate service
    alert = {}
    beforeEach inject (_alert_) ->
        alert = _alert_

    it 'should not have any alerts yet', ->
        expect(alert.alerts.length).toBe 0
        expect(alert.getAlerts().length).toBe 0

    it 'can add new alerts', ->
        for i in [1..10]
            a = alert.alert "Hello, #{i}", "type"
            expect(alert.alerts.length).toBe i
            expect(a.message).toBe "Hello, #{i}"
            expect(a.type).toBe "type"

    it 'can add alerts of different types', ->
        methods =
            success: "success"
            info: "info",
            warning: "warning"
            error: "danger"

        for method, type in methods
            a = alert[method] "Hello"
            expect(a.message).toBe "Hello"
            expect(a.type).toBe type
