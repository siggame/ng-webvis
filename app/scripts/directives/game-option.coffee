'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:gameOption
 # @description
 # # gameOption
###

define ()->
    gameOption = ()->
        templateUrl: 'views/game-option.html'
        restrict: 'E'
        scope: {
            name: '='
            option: '='
            page: '='
        }
    return gameOption