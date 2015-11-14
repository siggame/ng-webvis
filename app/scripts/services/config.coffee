'use strict'

###*
 # @ngdoc service
 # @name webvisApp.config
 # @description
 # # config
 # Factory in the webvisApp.
###


config = ()->
    version: "0.0.0"

    alert:
        timeoutAfter: 10000

webvisApp = angular.module 'webvisApp'
webvisApp.factory 'config', config