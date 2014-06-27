'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.directive 'slider', ($rootScope, $log, alert)->
    template: '<div class="slider"></div>'
    restrict: 'E'
    scope:
        currentValue: '='
        liveValue: '='
    link: (scope, element, attrs) ->
        inner_div = $(element).find(".slider")[0]
        $(inner_div).slider
            change: (event, ui) ->
                $log.debug "Changed to #{ui.value}"
                if not $rootScope.$$phase
                    scope.$apply ->
                        scope.currentValue = ui.value

            slide: (event, ui) ->
                $log.debug "Sliding!"
                if not $rootScope.$$phase
                    scope.$apply ->
                        scope.liveValue = ui.value

        scope.$watch 'currentValue', (newValue, oldValue) ->
            $log.debug "currentValue changed to #{newValue}"
            if newValue != oldValue
                $(inner_div).slider "value", newValue
