'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.controller 'NavbarCtrl', ($scope, version) ->
    $scope.version = version
