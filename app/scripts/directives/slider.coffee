'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.directive 'slider', ($rootScope, $log, alert)->
    template: '<div></div>'
    restrict: 'E'
    scope:
        maxValue: '='
        currentValue: '='
        liveValue: '='
    link: (scope, element, attrs) ->
        slider = $(element).find("div")[0]

        $(slider).slider
            value: scope.currentValue

            max: scope.maxValue

            change: (event, ui) ->
                if not $rootScope.$$phase
                    scope.$apply ->
                        scope.currentValue = ui.value

            slide: (event, ui) ->
                if not $rootScope.$$phase
                    scope.$apply ->
                        scope.liveValue = ui.value

        scope.$watch 'currentValue', (newValue, oldValue) ->
            if newValue != oldValue
                $(slider).slider "value", newValue

        scope.$watch 'maxValue', (newValue, oldValue) ->
            if newValue != oldValue
                $(slider).slider "option", "max", newValue
