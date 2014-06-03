'use strict'

angular.module('webvisApp')
  .directive('dropzone', ->
    template: '<div></div>'
    restrict: 'E'
    link: (scope, element, attrs) ->
      element.text 'this is the dropzone directive'
  )
