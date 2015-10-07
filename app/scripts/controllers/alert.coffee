'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:AlertCtrl
 # @description
 # # AlertCtrl
 # Controller of the webvisApp
###
define ()->
    AlertCtrl = (alert) ->
        @alert = alert

        @hasAlert = () ->
            alerts = alert.getAlerts()
            for a in alerts
                if a.isVisible()
                    return true

        return this
    AlertCtrl.$inject = ['alert'];
    return AlertCtrl
