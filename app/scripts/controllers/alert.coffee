'use strict'

###*
 # @ngdoc function
 # @name webvisApp.controller:AlertCtrl
 # @description
 # # AlertCtrl
 # Controller of the webvisApp
###
app = angular.module('webvisApp')

app.controller 'AlertCtrl', (alert) ->
    @alert = alert
    
    @hasAlert = () ->
        console.log "checking alerts"
        alerts = alert.getAlerts()
        for a in alerts     
            if a.isVisible()
                return true
            else
                return false
    
    return this
