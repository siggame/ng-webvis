'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:gameOption
 # @description
 # # gameOption
###

gameOption = ()->
    templateUrl: 'views/game-option.html'
    restrict: 'E'
    scope: {
        name: '='
        option: '='
        page: '='
    }

webvisApp = angular.module 'webvisApp'
webvisApp.directive 'gameOption', gameOption
