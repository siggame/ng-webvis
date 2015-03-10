'use strict'

describe 'Controller: TabmenuCtrl', ->

  # load the controller's module
  beforeEach module 'webvisApp'

  TabmenuCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    TabmenuCtrl = $controller 'TabmenuCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
