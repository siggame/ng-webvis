'use strict'

define () ->
    slider = ($rootScope, $log, alert)->
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
                min: 0
                max: scope.maxValue
                animate: true

                change: (event, ui) ->
                    m = $(slider).slider "option", "max"
                    console.log "change " + m
                    if not $rootScope.$$phase
                        scope.$apply ->
                            scope.currentValue = ui.value

                slide: (event, ui) ->
                    console.log "slide"
                    if not $rootScope.$$phase
                        scope.$apply ->
                            scope.liveValue = ui.value

            scope.$watch ('currentValue'), (newValue, oldValue) =>
                slide = $(element).find("div")[0]
                if newValue != oldValue
                    $(slide).slider "value", newValue

            scope.$watch 'maxValue', (newValue, oldValue) =>
                slide = $(element).find("div")[0]
                if newValue != oldValue
                    $(slide).slider "option", {min:0, max: newValue}

    slider.$inject = ['$rootScope', '$log', 'alert']
    return slider
