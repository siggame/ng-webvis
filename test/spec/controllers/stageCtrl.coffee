'use strict'

describe 'Controller: StagectrlCtrl', ->

  # load the controller's module
  beforeEach module 'webvisApp'

  StagectrlCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    StagectrlCtrl = $controller 'StagectrlCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
