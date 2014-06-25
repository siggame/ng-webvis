'use strict'

describe 'Controller: NavbarCtrl', ->

    # load the controller's module
    beforeEach module 'webvisApp'

    NavbarCtrl = {}

    # Initialize the controller and a mock scope
    beforeEach inject ($controller, config) ->
        NavbarCtrl = $controller 'NavbarCtrl', {
            config: config
        }

    it 'should attach "version" to the scope', ->
        expect(NavbarCtrl.version).toBe "0.0.0"
