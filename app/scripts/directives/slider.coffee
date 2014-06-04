'use strict'

webvisApp = angular.module('webvisApp')

webvisApp.directive 'slider', ()->
    template: '<div></div>'
    restrict: 'E'
    link: (scope, element, attrs) ->
        inner_div = element.children()[0]
        $(inner_div).slider()
        $(inner_div).slider
            change: (event, ui) ->
                console.log "Changed to #{ui.value}"

            slide: (event, ui) ->
                console.log "Sliding!"
