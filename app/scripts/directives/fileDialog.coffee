'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:fileDialog
 # @description
 # # fileDialog
###
webvisApp = angular.module('webvisApp')

webvisApp.directive 'fileDialog', ($log, FileLoader) ->
    restrict: 'A'

    transclude: true

    template: "<div ng-transclude> </div>
        <form onsubmit='return false'>
            <input style='display:none;' type='file' />
        </form>"

    link: (scope, element) ->
        formTag = $(element).find("form")
        inputTag = formTag.find("input[type='file']")
        $(element).bind 'click', (event) ->
            inputTag.click()

        inputTag.click (event) ->
            event.stopPropagation()

        inputTag.change (event) ->
            $log.debug "File dialog input changed"
            FileLoader.loadFile event.target.files
            inputTag.val null
