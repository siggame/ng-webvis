'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:fileDialog
 # @description
 # # fileDialog
###
webvisApp = angular.module('webvisApp')

webvisApp.directive 'fileDialog', ($log) ->
    restrict: 'A'

    template: "
        <a href>
            Open
        </a>
        <form ng-submit='submit()' onsubmit='return false'>
            <input style='display:none;' type='file' />
        </form>"

    link: (scope, element) ->
        anchorTag = $(element).find("a")
        formTag = $(element).find("form")
        inputTag = formTag.find("input[type='file']")
        anchorTag.bind 'click', (event) ->
            inputTag.click()

        inputTag.change (event) ->
            $log.debug "Input changed"
            formTag.submit()
            inputTag.val null

    controller: ($scope, $log) ->
        $scope.submit = () ->
            $log.debug "Submit!"
