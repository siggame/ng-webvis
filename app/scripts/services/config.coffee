'use strict'

###*
 # @ngdoc service
 # @name webvisApp.config
 # @description
 # # config
 # Factory in the webvisApp.
###


define () ->
    config = ()->
        version: "0.0.0"

        alert:
            timeoutAfter: 10000
    return config