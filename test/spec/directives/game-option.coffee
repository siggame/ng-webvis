'use strict'

describe 'Directive: gameOption', ->

  # load the directive's module
  beforeEach module 'webvisApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<game-option></game-option>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the gameOption directive'
