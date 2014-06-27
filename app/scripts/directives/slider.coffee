'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.directive 'slider', ($log, alert)->
    template: "
        <div class='slider-container'>
            <div class='slider'>
            </div>
            <div class='slider-value'>
                {{ liveValue || 0 }}
            </div>
        </div>"
    restrict: 'E'
    scope:
        value: '='
    link: (scope, element, attrs) ->
        inner_div = $(element).find(".slider")[0]
        $(inner_div).slider
            change: (event, ui) ->
                $log.debug "Changed to #{ui.value}"
                scope.$apply ->
                    scope.value = ui.value

            slide: (event, ui) ->
                $log.debug "Sliding!"
                scope.$apply ->
                    scope.liveValue = ui.value
