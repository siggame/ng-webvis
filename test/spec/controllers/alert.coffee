'use strict'

describe 'Controller: AlertCtrl', ->

    # load the controller's module
    beforeEach module 'webvisApp'

    AlertCtrl = {}
    alertService = {}

    # Initialize the controller and a mock scope
    beforeEach inject ($controller, $rootScope, alert) ->
        alertService = alert
        AlertCtrl = $controller 'AlertCtrl', {
            $scope: $rootScope.$new()
        }

    it 'should attach the alert service to itself', ->
        expect(AlertCtrl.alert).toBe alertService
