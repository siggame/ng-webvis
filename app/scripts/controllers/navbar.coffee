'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.controller 'NavbarCtrl', ($scope, config) ->
    $scope.version = config.version
