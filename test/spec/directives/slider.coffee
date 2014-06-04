'use strict'

describe 'Directive: slider', ->

    # load the directive's module
    beforeEach module 'webvisApp'

    scope = {}

    beforeEach inject ($controller, $rootScope) ->
        scope = $rootScope.$new()

    it 'should make a slider', inject ($compile) ->
        element = angular.element '<slider></slider>'
        element = $compile(element) scope
        slider_element = $(element).children('div').first()
        expect(slider_element.hasClass('ui-slider')).toBeTruthy
