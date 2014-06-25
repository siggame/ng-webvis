'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:AlertCtrl
 # @description
 # # AlertCtrl
 # Controller of the webvisApp
###
app = angular.module('webvisApp')

app.controller 'AlertCtrl', ($scope, alert) ->
    console.log "Set up AlertCtrl"
    console.log alert.info
    $scope.getAlerts = alert.getAlerts
    $scope.info = alert.info
