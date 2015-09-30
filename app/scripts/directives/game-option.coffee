'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:gameOption
 # @description
 # # gameOption
###

define ()->
    webvisApp = angular.module('webvisApp');
    webvisApp.directive('gameOption', ->
        templateUrl: 'views/game-option.html'
        restrict: 'E'
        scope: {
            name: '='
            option: '='
            page: '='
        }
      )
