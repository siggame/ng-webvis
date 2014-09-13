'use strict'

###*
 # @ngdoc directive
 # @name webvisApp.directive:fileDialog
 # @description
 # # fileDialog
###
webvisApp = angular.module('webvisApp')

webvisApp.directive 'fileDialog', ($log, GameLog) ->
    restrict: 'A'

    template: "
        <a href>
            Open
        </a>
        <form onsubmit='return false'>
            <input style='display:none;' type='file' />
        </form>"

    link: (scope, element) ->
        anchorTag = $(element).find("a")
        formTag = $(element).find("form")
        inputTag = formTag.find("input[type='file']")
        anchorTag.bind 'click', (event) ->
            inputTag.click()

        inputTag.change (event) ->
            $log.debug "File dialog input changed"
            GameLog.loadFile event.target.files
            inputTag.val null
