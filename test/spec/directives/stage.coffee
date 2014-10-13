'use strict'

describe 'Directive: Stage', ->

    # load the directive's module
    beforeEach module 'webvisApp'

    scope = {}

    beforeEach inject ($controller, $rootScope) ->
        scope = $rootScope.$new()

    it 'should make hidden element visible', inject ($compile) ->
        element = '<div id="parent"><stage></stage></div>'
        element = $compile(element) scope
        expect(element.text()).toBe ''
