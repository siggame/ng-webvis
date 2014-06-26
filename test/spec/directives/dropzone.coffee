'use strict'

describe 'Directive: dropzone', ->

    # load the directive's module
    beforeEach module 'webvisApp'

    scope = {}

    beforeEach inject ($controller, $rootScope) ->
        scope = $rootScope.$new()

    it 'should not contain any text', inject ($compile) ->
        element = angular.element '<div dropzone></div>'
        element = $compile(element) scope
        expect(element.text()).toBe ''
