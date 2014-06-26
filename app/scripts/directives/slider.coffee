'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.directive 'slider', ($log, alert)->
    template: "
        <div>
            <div class='slider' style='width:90%'>
            </div>
            <p class='value pull-right' style='width:10%'>
                {{ liveValue }}
            </p>
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
