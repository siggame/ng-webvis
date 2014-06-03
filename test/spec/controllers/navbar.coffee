'use strict'

describe 'Controller: NavbarCtrl', ->

    # load the controller's module
    beforeEach module 'webvisApp'

    NavbarCtrl = {}
    scope = {}

    # Initialize the controller and a mock scope
    beforeEach inject ($controller, $rootScope) ->
        scope = $rootScope.$new()
        NavbarCtrl = $controller 'NavbarCtrl', {
            $scope: scope
        }

    it 'should attach "version" to the scope', ->
        expect(scope.versoin).toExist
