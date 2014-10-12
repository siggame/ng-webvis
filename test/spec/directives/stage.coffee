'use strict'

describe 'Directive: Stage', ->

  # load the directive's module
  beforeEach module 'webvisApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<-stage></-stage>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the Stage directive'
