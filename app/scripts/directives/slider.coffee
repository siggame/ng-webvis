'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.directive 'slider', ($log, alert)->
    template: '<div></div>'
    restrict: 'E'
    link: (scope, element, attrs) ->
        inner_div = element.children()[0]
        $(inner_div).slider()
        $(inner_div).slider
            change: (event, ui) ->
                $log.debug "Changed to #{ui.value}"

            slide: (event, ui) ->
                $log.debug "Sliding!"
