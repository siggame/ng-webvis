'use strict'

describe 'Directive: upload', ->

    # load the directive's module
    beforeEach module 'webvisApp'

    scope = {}

    beforeEach inject ($controller, $rootScope) ->
        scope = $rootScope.$new()

    it 'should not contain text', inject ($compile) ->
        element = angular.element '<upload></upload>'
        element = $compile(element) scope
        expect(element.text()).toBe ''
