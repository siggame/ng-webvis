'use strict'

describe 'Controller: PlaybackCtrl', ->

    # load the controller's module
    beforeEach module 'webvisApp'

    PlaybackCtrl = {}
    scope = {}

    # Initialize the controller and a mock scope
    beforeEach inject ($controller, $rootScope) ->
        scope = $rootScope.$new()
        PlaybackCtrl = $controller 'PlaybackCtrl', {
            $scope: scope
        }
