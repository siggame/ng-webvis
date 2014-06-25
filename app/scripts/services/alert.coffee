'use strict'

###*
 # @ngdoc service
 # @name webvisApp.alert
 # @description
 # # alert
 # Factory in the webvisApp.
###
app = angular.module('webvisApp')

app.factory 'alert', ->
    console.log "Created alert factory"

    alerts: [{message: 'hello', type: 'info'}]
    getAlerts: () ->
        console.log this
        @alerts
    info: (message) ->
        console.log "Logging " + message
        @alerts.push message: message, type: 'info'
